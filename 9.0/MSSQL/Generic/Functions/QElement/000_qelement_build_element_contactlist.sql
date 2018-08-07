if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qelement_build_element_contactlist') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qelement_build_element_contactlist
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qelement_build_element_contactlist(
  @i_elementkey     integer,
  @i_bookkey        integer,
  @i_projectkey     integer,
  @i_rolecode       integer)
RETURNS @contactlist TABLE(
	contactkey INT,
	displayname VARCHAR(255),
	itemtypecode INT,
	usageclasscode INT
)
AS
/******************************************************************************
**  File: qelement_build_element_contactlist
**  Name: qelement_build_element_contactlist
**  Desc: This function gets contacts associated with an element.
**
**    Auth: Alan Katzen
**    Date: 15 May 2008
*******************************************************************************/
BEGIN
  DECLARE @v_bookkey INT,
          @v_projectkey INT,
          @v_count INT,
          @error_var  INT,
          @rowcount_var INT
      
  -- return contacts associated with the title and contact info
  -- for participants on the project/journal associated with the element      
  SELECT @v_bookkey = COALESCE(bookkey,0),
         @v_projectkey = COALESCE(taqprojectkey,0)
    FROM taqprojectelement
   WHERE taqelementkey = @i_elementkey
   
  SET @v_bookkey = COALESCE(@v_bookkey,@i_bookkey,0)
  SET @v_projectkey = COALESCE(@v_projectkey,@i_projectkey,0)
  
  IF (@v_bookkey <= 0 AND @v_projectkey <= 0) BEGIN
    -- this element is not associated with a title or a project/journal
    return
  END
   
  -- get contact info for participants on project/journal
  IF (@v_projectkey > 0) BEGIN
    IF @i_rolecode > 0 BEGIN
      INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
      SELECT c.contactkey, c.displayname, 2, 0
        FROM corecontactinfo c, taqprojectcontact pc, taqprojectcontactrole pcr
       WHERE pc.taqprojectkey = @v_projectkey
         AND pc.taqprojectcontactkey = pcr.taqprojectcontactkey
         AND pcr.rolecode = @i_rolecode
         AND pc.globalcontactkey = c.contactkey
         AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)           
    END
    ELSE BEGIN
      INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
      SELECT c.contactkey, c.displayname, 2, 0
        FROM corecontactinfo c, taqprojectcontact pc
       WHERE pc.taqprojectkey = @v_projectkey
         AND pc.globalcontactkey = c.contactkey   
         AND pc.globalcontactkey not in (SELECT contactkey FROM @contactlist)  
    END         
  END
  
  -- get contact info for contacts associated with the title 
  -- need to look at bookauthor and bookcontact
  IF (@v_bookkey > 0) BEGIN
    -- bookauthor
    IF @i_rolecode > 0 BEGIN
      INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
      SELECT c.contactkey, c.displayname, 2, 0
        FROM corecontactinfo c, bookauthor ba
       WHERE ba.bookkey = @v_bookkey
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
       WHERE ba.bookkey = @v_bookkey
         AND ba.authorkey = c.contactkey   
         AND ba.authorkey not in (SELECT contactkey FROM @contactlist)           
    END
        
    -- bookcontact
    IF @i_rolecode > 0 BEGIN
      INSERT INTO @contactlist (contactkey,displayname,itemtypecode,usageclasscode)
      SELECT c.contactkey, c.displayname, 2, 0
        FROM corecontactinfo c, bookcontact bc, bookcontactrole bcr
       WHERE bc.bookkey = @v_bookkey
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
       WHERE bc.bookkey = @v_bookkey
         AND bc.printingkey = 1
         AND bc.globalcontactkey = c.contactkey
         AND bc.globalcontactkey not in (SELECT contactkey FROM @contactlist)  
    END         
  END
            
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

