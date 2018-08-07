IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontact_update_author')
  BEGIN
    PRINT 'Dropping Procedure qcontact_update_author'
    DROP  Procedure  qcontact_update_author
  END

GO

PRINT 'Creating Procedure qcontact_update_author'
GO

CREATE PROCEDURE qcontact_update_author
 (@i_masterkey    integer,
  @i_detailkey    integer,
  @i_owneruserid  varchar(30),
  @i_tablename    varchar(100),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_update_author
**  Desc: Update author table with modified values from globalcontact tables.
**
**              
**    Return values: 
**
**    Called by:   
**              
**    Parameters:
**    Input              
**    ----------         
**    masterkey - globalcontactkey on globalcontact tables/authorkey on author table
**    detailkey - Other key on globalcontact table, if there is one 
                  (will be globalcontactkey if no second key)
**    tablename - name of globalcontact table that has changes to be updated on author table
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 7/29/04
*******************************************************************************
**    Change History
*******************************************************************************
**  9/1/04 - KW - Added OwnerUserID parameter since we need the lastuserid
**  of the person who made a contact private - a trigger will then update
**  privateind and owneruserid columns on corecontactinfo table so that
**  no other user can access that contact but the person who owns it.
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @userid_var VARCHAR(30),
          @scopetag_var VARCHAR(20),
          @individualind_var INT,
          @corporatecontributorind_var INT,
          @groupname_var VARCHAR(255),
          @lastname_var VARCHAR(75),
          @firstname_var VARCHAR(75),
          @middlename_var VARCHAR(75),
          @accreditationcode_var INT,
          @suffix_var VARCHAR(75),
          @degree_var VARCHAR(25),
          @ssn_var VARCHAR(25),
          @displayname_var VARCHAR(255),
          @uscitizenind_var INT,
          @globalcontactnotes_var VARCHAR(4000),
          @addresstypecode_var INT,
          @address1_var VARCHAR(255),
          @address2_var VARCHAR(255),
          @address3_var VARCHAR(255),
          @city_var VARCHAR(25),
          @statecode_var INT,
          @zipcode_var VARCHAR(50),
          @countrycode_var INT,
          @primaryind_var INT,
          @defaultaddressnumber_var INT,
          @contactmethodvalue_var VARCHAR(100),
          @need_to_insert_var TINYINT,
          @no_row_on_author_var TINYINT,
          @contactmethodcode_var INT,
          @methodsearchtype_var VARCHAR(25),
          @author_rowcount_var INT,
          @activeind_var TINYINT,
          @count_var INT,
          @empty_slot TINYINT,
          @empty_slot_search VARCHAR(10),
          @commenttypecode INT,
          @commenttypesubcode INT,
          @title_var 	VARCHAR(80)

  -- Verify Data
  IF @i_masterkey IS NULL OR @i_masterkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: masterkey is empty.'
    RETURN
  END 

  IF @i_detailkey IS NULL OR @i_detailkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: detailkey is empty.'
    RETURN
  END 

  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: tablename is empty.'
    RETURN
  END 

  -- check if we need to insert to author table 
  SELECT @rowcount_var=count(*)
    FROM globalcontactauthor a
   WHERE a.masterkey = @i_masterkey 
 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (0).'
    RETURN
  END 

  IF @rowcount_var <= 0 BEGIN
    -- check if we need to insert to author table - does new contact have author roles
    SELECT @count_var=count(*)
      FROM globalcontactrole r
     WHERE r.globalcontactkey = @i_masterkey and
           r.rolecode in (SELECT code2 FROM gentablesrelationshipdetail 
                           WHERE gentablesrelationshipkey = 1) 
 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (0).'
      RETURN
    END 

    IF @count_var <= 0 BEGIN
      -- not an author, just return
      SET @o_error_code = 0
      SET @o_error_desc = ''
      RETURN 
    END
  END

--print'@i_masterkey: ' + cast(@i_masterkey as varchar)
--print'@i_detailkey: ' + cast(@i_detailkey as varchar)

  -- check if we need to update author table
  SELECT @rowcount_var=count(*)
    FROM globalcontactauthor
   WHERE masterkey = @i_masterkey and
         detailkey = @i_detailkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table.'
    RETURN
  END 

--print'@rowcount_var: ' + cast(@rowcount_var as varchar)

  IF @rowcount_var = 0 BEGIN
    SET @need_to_insert_var = 1
  END
  ELSE BEGIN
    SET @need_to_insert_var = 0

    SELECT @scopetag_var=scopetag
      FROM globalcontactauthor
     WHERE masterkey = @i_masterkey and
           detailkey = @i_detailkey

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table.'
      RETURN
    END 

    IF @scopetag_var IS NULL OR ltrim(rtrim(@scopetag_var)) = '' BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: scopetag is empty on globalcontactauthor table.'
      RETURN
    END 
  END

--print'@need_to_insert_var: ' + cast(@need_to_insert_var as varchar)

  SET @no_row_on_author_var = 0
  IF @need_to_insert_var = 1 BEGIN
    -- make sure author row exists so updates can be performed later
    SELECT @author_rowcount_var=count(*)
      FROM author a
     WHERE a.authorkey = @i_masterkey 
 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access author table (count).'
      RETURN
    END 

    IF @author_rowcount_var <= 0 BEGIN
      -- no row on author
      SET @no_row_on_author_var = 1
    END
  END

--print'@no_row_on_author_var: ' + cast(@no_row_on_author_var as varchar)

  IF lower(@i_tablename) = 'globalcontact' OR @no_row_on_author_var = 1 BEGIN
    -- update author table with info from globalcontact
    SELECT @lastname_var=lastname,@firstname_var=firstname,@middlename_var=middlename,
           @accreditationcode_var=accreditationcode,@suffix_var=suffix,@degree_var=degree,
           @ssn_var=ssn,@displayname_var=displayname,@uscitizenind_var=uscitizenind,
           @globalcontactnotes_var=globalcontactnotes,@individualind_var=individualind,
           @groupname_var=groupname,@activeind_var=activeind
      FROM globalcontact
     WHERE globalcontactkey = @i_masterkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access globalcontact table.'
      RETURN
    END 

    IF @need_to_insert_var = 1 BEGIN
      SET @scopetag_var = 'contact'
--print'1 contact'
--print@scopetag_var  
      --Insert into globalcontactauthor for globalcontact
      INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
      VALUES (@i_masterkey, @i_masterkey, @scopetag_var)
    END

    IF @individualind_var = 1 BEGIN
      -- individual
      SET @corporatecontributorind_var = 0
    END
    ELSE BEGIN
      -- group
      SET @corporatecontributorind_var = 1
      SET @lastname_var = left(@groupname_var,75)
    END

	
	 IF @accreditationcode_var IS NULL AND @accreditationcode_var > 0
    BEGIN
		SELECT @accreditationcode_var = 0
    END

	 IF @accreditationcode_var > 0 
	 BEGIN
		exec  gentables_longdesc 210,@accreditationcode_var, @title_var OUTPUT
	 END
	 ELSE
	 BEGIN
		SELECT @title_var = ''
	 END

    IF @no_row_on_author_var = 1 BEGIN
      -- insert
      IF @activeind_var IS NULL BEGIN
        -- default to active
        SET @activeind_var = 1
      END
 
      INSERT INTO author (authorkey,lastname,firstname,middlename,nameabbrcode,title,authorsuffix,
              authordegree,ssn,displayname,uscitizenind,notes,lastuserid,
              lastmaintdate,corporatecontributorind,activeind)
       VALUES (@i_masterkey,@lastname_var,@firstname_var,@middlename_var,@accreditationcode_var,@title_var,
              @suffix_var,@degree_var,left(replace(@ssn_var,'-',''),9),left(@displayname_var,80),
              @uscitizenind_var,left(@globalcontactnotes_var,255),
              @i_owneruserid,getdate(),@corporatecontributorind_var,@activeind_var)
 
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to insert into author table.'
        RETURN
      END 
      SET @no_row_on_author_var = 0
    END
    ELSE BEGIN
      -- update author table
      UPDATE author
          SET lastname=@lastname_var,firstname=@firstname_var,middlename=@middlename_var,title=@title_var,
             nameabbrcode=@accreditationcode_var,authorsuffix=@suffix_var,authordegree=@degree_var,
             ssn=left(replace(@ssn_var,'-',''),9),displayname=left(@displayname_var,80),
             uscitizenind=@uscitizenind_var,notes=left(@globalcontactnotes_var,255),
             lastuserid=@i_owneruserid,lastmaintdate=getdate(),
             corporatecontributorind=@corporatecontributorind_var,activeind=@activeind_var
       WHERE authorkey = @i_masterkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Update failed (globalcontact).'
        RETURN
      END            
    END
  END

  IF lower(@i_tablename) = 'globalcontactaddress' BEGIN
    -- check to see if data still exists on globalcontactaddress
    SELECT @rowcount_var=count(*)
      FROM globalcontactaddress
     WHERE globalcontactaddresskey = @i_detailkey and
           globalcontactkey = @i_masterkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access globalcontactaddress table.'
      RETURN
    END 

    IF @rowcount_var > 0 BEGIN
      -- update author table with info from globalcontactaddress
      SELECT @addresstypecode_var=addresstypecode,@address1_var=address1,@address2_var=address2,
             @address3_var=address3,@city_var=city,@statecode_var=statecode,
             @zipcode_var=zipcode,@countrycode_var=countrycode,@primaryind_var=primaryind
        FROM globalcontactaddress
       WHERE globalcontactaddresskey = @i_detailkey and
             globalcontactkey = @i_masterkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not access globalcontactaddress table.'
        RETURN
      END 

      SET @defaultaddressnumber_var = null

      IF @need_to_insert_var = 1 BEGIN
        -- no globalcontactauthor row exists for this data, so add one unless there is already 3 on the database
        SELECT @rowcount_var=count(*)
          FROM globalcontactauthor a
         WHERE a.masterkey = @i_masterkey and
               lower(a.scopetag) like 'addr%'

        SELECT @error_var = @@ERROR
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table.'
          RETURN
        END 
      
        IF @rowcount_var + 1 >= 3 BEGIN
          -- can't have more than 3
          RETURN
        END

        -- find first empty "slot" for address
        SET @empty_slot = 0
        IF @rowcount_var = 0 BEGIN
          SET @empty_slot = 1   
        END

        -- addr1
        IF @empty_slot = 0 BEGIN 
          SELECT @rowcount_var=count(*)
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like 'addr1%'

          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (1).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 1   
          END
        END

        IF @empty_slot = 0 BEGIN 
          -- addr2
          SELECT @rowcount_var=count(*)
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like 'addr2%'
 
          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (2).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 2  
          END
        END

        IF @empty_slot = 0 BEGIN 
          -- addr3
          SELECT @rowcount_var=count(*)
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like 'addr3%'
 
          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (3).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 3   
          END
        END

        IF @empty_slot > 0 BEGIN 
          SET @scopetag_var = 'addr' + CONVERT(VARCHAR, @empty_slot)
        END
        ELSE BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update author table: Could not find empty slot for globalcontactauthor table.'
          RETURN
        END
--print'2 contact'
--print@scopetag_var  
        --Insert into globalcontactauthor for each address occurance
        INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
        VALUES (@i_masterkey, @i_detailkey, @scopetag_var)
      END

      IF @no_row_on_author_var = 1 BEGIN
        -- no row on author yet - add one
        INSERT INTO author (authorkey, lastuserid, lastmaintdate)
        VALUES (@i_masterkey, @i_owneruserid, getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update to insert into author table (globalcontactaddress - ' + ltrim(rtrim(@scopetag_var)) + ').'
          RETURN
        END 
      END
    END
    ELSE BEGIN
      -- no globalcontactaddress row - delete the globalcontactauthor row
      DELETE FROM globalcontactauthor
      WHERE masterkey = @i_masterkey AND detailkey = @i_detailkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not remove row from globalcontactauthor table.'
        RETURN
      END 
    END

    -- update author table
    IF lower(@scopetag_var) = 'addr1' BEGIN
      -- address1
      IF @primaryind_var = 1 BEGIN
        SET @defaultaddressnumber_var = 1
      END

      UPDATE author
         SET addresstypecode1=@addresstypecode_var,address1=left(@address1_var,80),
             address1line2=left(@address2_var,80),address1line3=left(@address3_var,80),
             city=@city_var,statecode=@statecode_var,zip=@zipcode_var,countrycode=@countrycode_var,
             defaultaddressnumber=@defaultaddressnumber_var,lastuserid=@i_owneruserid,
             lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'addr2' BEGIN
      -- address2
      IF @primaryind_var = 1 BEGIN
        SET @defaultaddressnumber_var = 2
      END

      UPDATE author
         SET addresstypecode2=@addresstypecode_var,address2line1=left(@address1_var,80),
             address2line2=left(@address2_var,80),address2line3=left(@address3_var,80),
             city2=@city_var,statecode2=@statecode_var,zip2=@zipcode_var,countrycode2=@countrycode_var,
             defaultaddressnumber=@defaultaddressnumber_var,lastuserid=@i_owneruserid,
             lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'addr3' BEGIN
      -- address3
      IF @primaryind_var = 1 BEGIN
        SET @defaultaddressnumber_var = 3
      END

      UPDATE author
         SET addresstypecode3=@addresstypecode_var,address3line1=left(@address1_var,80),
             address3line2=left(@address2_var,80),address3line3=left(@address3_var,80),
             city3=@city_var,statecode3=@statecode_var,zip3=@zipcode_var,countrycode3=@countrycode_var,
             defaultaddressnumber=@defaultaddressnumber_var,lastuserid=@i_owneruserid,
             lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Update failed (globalcontactaddress - ' + ltrim(rtrim(@scopetag_var)) + ').'
      RETURN
    END 
  END

  IF lower(@i_tablename) = 'globalcontactmethod' BEGIN
    -- check to see if data still exists on globalcontactmethod
    SELECT @rowcount_var=count(*)
      FROM globalcontactmethod
     WHERE globalcontactmethodkey = @i_detailkey and
           globalcontactkey = @i_masterkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access globalcontactmethod table.'
      RETURN
    END 

    IF @rowcount_var > 0 BEGIN
      -- update author table with info from globalcontactmethod
      SELECT @contactmethodvalue_var=contactmethodvalue, @contactmethodcode_var=contactmethodcode
        FROM globalcontactmethod
       WHERE globalcontactmethodkey = @i_detailkey and
             globalcontactkey = @i_masterkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not access globalcontactmethod table.'
        RETURN
      END 
--print'@contactmethodcode_var: ' + cast(@contactmethodcode_var as varchar)

      IF @need_to_insert_var = 1 BEGIN
        -- no globalcontactmethod row exists for this data, so add one unless there is already 3 (for this type) on the database
        IF @contactmethodcode_var = 1 BEGIN
          SET @methodsearchtype_var = 'phone%'
          SET @scopetag_var = 'phone'
        END
        IF @contactmethodcode_var = 2 BEGIN
          SET @methodsearchtype_var = 'fax%'
          SET @scopetag_var = 'fax'
        END
        IF @contactmethodcode_var = 3 BEGIN
          SET @methodsearchtype_var = 'email%'
          SET @scopetag_var = 'email'
        END
        IF @contactmethodcode_var = 4 BEGIN
          SET @methodsearchtype_var = 'url%'
          SET @scopetag_var = 'url'
        END
		
		IF @scopetag_var IS NULL BEGIN
			RETURN
		END

        SELECT @rowcount_var=count(*)
          FROM globalcontactauthor a
         WHERE a.masterkey = @i_masterkey and
               lower(a.scopetag) like @methodsearchtype_var

        SELECT @error_var = @@ERROR
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update author table: Could not access globalcontactmethod table.'
          RETURN
        END 
      
        IF @rowcount_var + 1 >= 3 BEGIN
          -- can't have more than 3
          RETURN
        END

        IF @contactmethodcode_var <> 4 BEGIN
          SET @empty_slot = 1   
        END

        -- find first empty "slot"
        SET @empty_slot = 0
        IF @rowcount_var = 0 BEGIN
          SET @empty_slot = 1   
        END

        IF @empty_slot = 0 BEGIN 
          SET @empty_slot_search = @scopetag_var + '1%'

          SELECT @rowcount_var=count(*) 
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like @empty_slot_search

          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactmethod table (1).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 1   
          END
        END

        IF @empty_slot = 0 BEGIN 
          SET @empty_slot_search = @scopetag_var + '2%'

          SELECT @rowcount_var=count(*)
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like @empty_slot_search
 
          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (2).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 2  
          END
        END

        IF @empty_slot = 0 BEGIN 
          SET @empty_slot_search = @scopetag_var + '3%'

          SELECT @rowcount_var=count(*)
            FROM globalcontactauthor a
           WHERE a.masterkey = @i_masterkey and
                 lower(a.scopetag) like @empty_slot_search
 
          SELECT @error_var = @@ERROR
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table (3).'
            RETURN
          END 

          IF @rowcount_var = 0 BEGIN
            SET @empty_slot = 3   
          END
        END

        --IF @contactmethodcode_var <> 4 BEGIN
          IF @empty_slot > 0 BEGIN 
            SET @scopetag_var = @scopetag_var + CONVERT(VARCHAR, @empty_slot)
          END
          ELSE BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update author table: Could not find empty slot for globalcontactauthor table.'
            RETURN
          END
        --END
--print'3 contact'
--print@scopetag_var  
        --Insert into globalcontactauthor for each address occurance
        INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
        VALUES (@i_masterkey, @i_detailkey, @scopetag_var)
      END

      IF @no_row_on_author_var = 1 BEGIN
        -- no row on author yet - add one
        INSERT INTO author (authorkey, lastuserid, lastmaintdate)
        VALUES (@i_masterkey, @i_owneruserid, getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update author table: Update failed (globalcontactmethod - ' + ltrim(rtrim(@scopetag_var)) + ').'
          RETURN
        END 
      END
    END
    ELSE BEGIN
      -- no globalcontactmethod row - delete the globalcontactauthor row
      DELETE FROM globalcontactauthor
      WHERE masterkey = @i_masterkey AND detailkey = @i_detailkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not remove row from globalcontactmethod table.'
        RETURN
      END 
    END

    IF lower(@scopetag_var) = 'phone1' BEGIN
      -- phone1
      UPDATE author
         SET phone1=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'phone2' BEGIN
      -- phone2
      UPDATE author
         SET phone2=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'phone3' BEGIN
      -- phone3
      UPDATE author
         SET phone3=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'fax1' BEGIN
      -- fax1
      UPDATE author
         SET fax1=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'fax2' BEGIN
      -- fax2
      UPDATE author
         SET fax2=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'fax3' BEGIN
      -- fax3
      UPDATE author
         SET fax3=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'email1' BEGIN
      -- email1
      UPDATE author
         SET emailaddress1=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'email2' BEGIN
      -- email2
      UPDATE author
         SET emailaddress2=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'email3' BEGIN
      -- email3
      UPDATE author
         SET emailaddress3=left(@contactmethodvalue_var,50),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    IF lower(@scopetag_var) = 'url' BEGIN
      -- url
      UPDATE author
         SET authorurl=left(@contactmethodvalue_var,80),lastuserid=@i_owneruserid,lastmaintdate=getdate()
       WHERE authorkey = @i_masterkey
    END

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Update failed (globalcontactmethod - ' + ltrim(rtrim(@scopetag_var)) + ').'
      RETURN
    END 
  END
  
  IF lower(@i_tablename) = 'qsicomments' BEGIN
    -- for now this is assumed to be author bio - check to see if data still exists on qsicomments
    SELECT @rowcount_var=count(*)
      FROM gentables
     WHERE tableid = 528 and
           qsicode = 2

    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access gentables table.'
      RETURN
    END 

    IF @rowcount_var > 0 BEGIN
      SELECT @commenttypecode=datacode, @commenttypesubcode=0
        FROM gentables
       WHERE tableid = 528 and
             qsicode = 2

      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not access gentables table.'
        RETURN
      END      
    END

    SELECT @rowcount_var=count(*)
      FROM qsicomments
     WHERE commentkey = @i_masterkey and
           commenttypecode = @commenttypecode and
           commenttypesubcode = @commenttypesubcode

    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access qsicomments table.'
      RETURN
    END 

    IF @rowcount_var > 0 BEGIN
      IF @need_to_insert_var = 1 BEGIN
        -- no globalcontactauthor row exists for this data, so add one 
        SELECT @rowcount_var=count(*)
          FROM globalcontactauthor a
         WHERE a.masterkey = @i_masterkey and
               lower(a.scopetag) = 'biogr'

        SELECT @error_var = @@ERROR
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update author table: Could not access globalcontactauthor table.'
          RETURN
        END 
 --print'4 contact'
--print@scopetag_var       
        IF @rowcount_var <= 0 BEGIN
          --Insert into globalcontactauthor
          INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
          VALUES (@i_masterkey, @i_detailkey, 'biogr')
        END
      END

      IF @no_row_on_author_var = 1 BEGIN
        -- no row on author yet - add one
        INSERT INTO author (authorkey, lastuserid, lastmaintdate)
        VALUES (@i_masterkey, @i_owneruserid, getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update to insert into author table (author bio).'
          RETURN
        END 
      END
      
      -- update author table
      UPDATE author
         SET lastuserid=@i_owneruserid,lastmaintdate=getdate(),biography=c.commenttext
        FROM author a, globalcontactauthor g, qsicomments c
       WHERE a.authorkey = g.masterkey and
             g.detailkey = c.commentkey and
             a.authorkey = @i_masterkey and
             c.commentkey = @i_masterkey and
             c.commenttypecode = @commenttypecode and
             COALESCE(c.commenttypesubcode,0) = @commenttypesubcode

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Update failed (author bio).'
        RETURN
      END       
    END
    ELSE BEGIN
      -- no qsicomments row - delete the globalcontactauthor row
      DELETE FROM globalcontactauthor
      WHERE masterkey = @i_masterkey AND detailkey = @i_detailkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Could not remove row from globalcontactauthor table.'
        RETURN
      END 
      
      -- update author table
      UPDATE author
         SET lastuserid=@i_owneruserid,lastmaintdate=getdate(),biography=null
        FROM author 
       WHERE authorkey = @i_masterkey 

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update author table: Update failed (author bio).'
        RETURN
      END       
    END


  END

  SET @o_error_code = 0
  SET @o_error_desc = ''
  RETURN 
GO

GRANT EXEC ON qcontact_update_author TO PUBLIC
GO

