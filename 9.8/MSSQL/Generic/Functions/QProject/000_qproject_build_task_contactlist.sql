if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_build_task_contactlist') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_build_task_contactlist
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_build_task_contactlist(
  @i_projectkeylist varchar(max),
  @i_contactkeylist varchar(max),
  @i_bookkeylist    varchar(max),
  @i_rolecode       integer)
RETURNS @contactlist TABLE(
	contactkey INT,
	displayname VARCHAR(255),
	itemtypecode INT,
	usageclasscode INT
)
AS
/******************************************************************************
**  File: qproject_build_task_contactlist
**  Name: qproject_build_task_contactlist
**  Desc: This function gets contacts associated with a list of projects/journals
**        and titles.  A list of contacts may be passed in to append to the list.
**        Also, a role may be passed in to filter the contacts.
**
**    Auth: Alan Katzen
**    Date: 21 April 2008
*******************************************************************************/
BEGIN
  DECLARE @v_key INT,
          @v_key_string varchar(20),
          @v_startpos INT,
          @v_endpos INT,
          @v_count INT,
          @error_var  INT,
          @rowcount_var INT
       
  -- get contact info for contacts in passed in contact list
  SET @v_startpos = 1     
  SET @v_endpos = 0  
  SET @v_key_string = ''   
  IF datalength(@i_contactkeylist) > 0 BEGIN
    -- parse key list
    SET @v_endpos = charindex(',',@i_contactkeylist)
    WHILE @v_endpos > 0 BEGIN
      SET @v_key_string = substring(@i_contactkeylist, @v_startpos, @v_endpos - @v_startpos)
      
      IF isnumeric(@v_key_string)=1 BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey,c.displayname,2,0
          FROM corecontactinfo c
         WHERE c.contactkey = cast(@v_key_string as int)
      END 
      
      SET @v_startpos = @v_endpos + 1
      SET @v_endpos = charindex(',',@i_contactkeylist, @v_startpos)    
    END
    
    -- there is one more key at end with no comma
    SET @v_key_string = substring(@i_contactkeylist, @v_startpos, datalength(@i_contactkeylist))
    
    IF isnumeric(@v_key_string)=1 BEGIN
      INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
      SELECT c.contactkey,c.displayname,2,0
        FROM corecontactinfo c
       WHERE c.contactkey = cast(@v_key_string as int)
    END   
  END

  -- get contact info for participants in project/journal list
  SET @v_startpos = 1     
  SET @v_endpos = 0  
  SET @v_key_string = ''   
  IF datalength(@i_projectkeylist) > 0 BEGIN
    -- parse key list
    SET @v_endpos = charindex(',',@i_projectkeylist)
    WHILE @v_endpos > 0 BEGIN
      SET @v_key_string = substring(@i_projectkeylist, @v_startpos, @v_endpos - @v_startpos)
      
      IF isnumeric(@v_key_string)=1 BEGIN
        IF @i_rolecode > 0 BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, taqprojectcontact pc, taqprojectcontactrole pcr
           WHERE pc.taqprojectkey = cast(@v_key_string as int)
             AND pc.taqprojectcontactkey = pcr.taqprojectcontactkey
             AND pcr.rolecode = @i_rolecode
             AND pc.globalcontactkey = c.contactkey
             AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
        END
        ELSE BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, taqprojectcontact pc
           WHERE pc.taqprojectkey = cast(@v_key_string as int)
             AND pc.globalcontactkey = c.contactkey   
             AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
        END
      END 
      
      SET @v_startpos = @v_endpos + 1
      SET @v_endpos = charindex(',',@i_projectkeylist, @v_startpos)    
    END
    
    -- there is one more key at end with no comma
    SET @v_key_string = substring(@i_projectkeylist, @v_startpos, datalength(@i_projectkeylist))
    
    IF isnumeric(@v_key_string)=1 BEGIN
      IF @i_rolecode > 0 BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, taqprojectcontact pc, taqprojectcontactrole pcr
         WHERE pc.taqprojectkey = cast(@v_key_string as int)
           AND pc.taqprojectcontactkey = pcr.taqprojectcontactkey
           AND pcr.rolecode = @i_rolecode
           AND pc.globalcontactkey = c.contactkey             
           AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
      END
      ELSE BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, taqprojectcontact pc
         WHERE pc.taqprojectkey = cast(@v_key_string as int)
           AND pc.globalcontactkey = c.contactkey   
           AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
      END
    END   
  END

  -- get contact info for contacts in title list - need to look at bookauthor and bookcontact
  -- bookauthor
  SET @v_startpos = 1     
  SET @v_endpos = 0  
  SET @v_key_string = ''   
  IF datalength(@i_bookkeylist) > 0 BEGIN
    -- parse key list
    SET @v_endpos = charindex(',',@i_bookkeylist)
    WHILE @v_endpos > 0 BEGIN
      SET @v_key_string = substring(@i_bookkeylist, @v_startpos, @v_endpos - @v_startpos)
      
      IF isnumeric(@v_key_string)=1 BEGIN
        IF @i_rolecode > 0 BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, bookauthor ba
           WHERE ba.bookkey = cast(@v_key_string as int)
             AND ba.authorkey = c.contactkey
             AND ba.authorkey not in (SELECT contactkey FROM @contactlist)           
             AND ba.authortypecode in (SELECT code2 FROM gentablesrelationshipdetail 
                                        WHERE gentablesrelationshipkey = 2
                                          AND code1 = @i_rolecode)  
        END
        ELSE BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, bookauthor ba
           WHERE ba.bookkey = cast(@v_key_string as int)
             AND ba.authorkey = c.contactkey   
             AND ba.authorkey not in (SELECT contactkey FROM @contactlist)           
        END
      END 
      
      SET @v_startpos = @v_endpos + 1
      SET @v_endpos = charindex(',',@i_bookkeylist, @v_startpos)    
    END
    
    -- there is one more key at end with no comma
    SET @v_key_string = substring(@i_bookkeylist, @v_startpos, datalength(@i_bookkeylist))
    
    IF isnumeric(@v_key_string)=1 BEGIN
      IF @i_rolecode > 0 BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, bookauthor ba
         WHERE ba.bookkey = cast(@v_key_string as int)
           AND ba.authorkey = c.contactkey
           AND ba.authorkey not in (SELECT contactkey FROM @contactlist)           
           AND ba.authortypecode in (SELECT code2 FROM gentablesrelationshipdetail 
                                      WHERE gentablesrelationshipkey = 2
                                        AND code1 = @i_rolecode)  
      END
      ELSE BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, bookauthor ba
         WHERE ba.bookkey = cast(@v_key_string as int)
           AND ba.authorkey = c.contactkey   
           AND ba.authorkey not in (SELECT contactkey FROM @contactlist)           
      END
    END   
  END
     
  -- bookcontact
  SET @v_startpos = 1     
  SET @v_endpos = 0  
  SET @v_key_string = ''   
  IF datalength(@i_bookkeylist) > 0 BEGIN
    -- parse key list
    SET @v_endpos = charindex(',',@i_bookkeylist)
    WHILE @v_endpos > 0 BEGIN
      SET @v_key_string = substring(@i_bookkeylist, @v_startpos, @v_endpos - @v_startpos)
      
      IF isnumeric(@v_key_string)=1 BEGIN
        IF @i_rolecode > 0 BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, bookcontact bc, bookcontactrole bcr
           WHERE bc.bookkey = cast(@v_key_string as int)
             AND bc.printingkey = 1
             AND bc.globalcontactkey = c.contactkey
             AND bc.bookcontactkey = bcr.bookcontactkey
             AND bc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
             AND bcr.rolecode = @i_rolecode  
        END
        ELSE BEGIN
          INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
          SELECT c.contactkey, c.displayname, 2, 0
            FROM corecontactinfo c, bookcontact bc
           WHERE bc.bookkey = cast(@v_key_string as int)
             AND bc.printingkey = 1
             AND bc.globalcontactkey = c.contactkey
             AND bc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
        END
      END 
      
      SET @v_startpos = @v_endpos + 1
      SET @v_endpos = charindex(',',@i_bookkeylist, @v_startpos)    
    END
    
    -- there is one more key at end with no comma
    SET @v_key_string = substring(@i_bookkeylist, @v_startpos, datalength(@i_bookkeylist))
    
    IF isnumeric(@v_key_string)=1 BEGIN
      IF @i_rolecode > 0 BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, bookcontact bc, bookcontactrole bcr
         WHERE bc.bookkey = cast(@v_key_string as int)
           AND bc.printingkey = 1
           AND bc.globalcontactkey = c.contactkey
           AND bc.bookcontactkey = bcr.bookcontactkey
           AND bc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
           AND bcr.rolecode = @i_rolecode  
      END
      ELSE BEGIN
        INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
        SELECT c.contactkey, c.displayname, 2, 0
          FROM corecontactinfo c, bookcontact bc
         WHERE bc.bookkey = cast(@v_key_string as int)
           AND bc.printingkey = 1
           AND bc.globalcontactkey = c.contactkey
           AND bc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
      END
    END   
  END
            
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

