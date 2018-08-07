if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_prtgproj_from_prtgtbl') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qprinting_prtgproj_from_prtgtbl
GO

CREATE PROCEDURE qprinting_prtgproj_from_prtgtbl (  
  @i_bookkey      integer,
  @i_printingkey  integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qprinting_prtgproj_from_prtgtbl
**  Desc: This stored procedure creates a Printing project from printing table
**        if one doesn't exist yet.
**
**  Auth: Kate
**  Date: November 14 2014
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
*   03/20/2016   Kate        Case 37102 - Fixed the bug with datagroup string for qproject_copy_project.
*******************************************************************************************************/
DECLARE
  @v_book_title VARCHAR(255),
  @v_copy_projectkey INT,
  @v_count  INT,
  @v_count_prtgproj	INT,
  @v_datacode INT,
  @v_datagroup_string VARCHAR(2000),
  @v_def_projstatus INT,
  @v_def_projtype INT,
  @v_error	INT,
  @v_error_desc VARCHAR(2000),
  @v_rowcount	INT, 
  @v_max_prtg INT,
  @v_name_gen_sql  VARCHAR(255),
  @v_newkey INT,
  @v_new_projectkey INT,
  @v_printingnum  INT,
  @v_projectrole  INT,  
  @v_prtg_itemtype  INT,
  @v_prtg_title  VARCHAR(255),
  @v_prtg_usageclass  INT,
  @v_quote  CHAR(1),
  @v_result_value1  VARCHAR(255),
  @v_result_value2  VARCHAR(255),
  @v_result_value3  VARCHAR(255),
  @v_titlerole  INT,
  @i_mediatypecode INT,
  @i_mediatypesubcode INT,
  @v_userkey INT	,
  @v_jobnumberalpha CHAR(7) ,
  @v_productidcode INT,
  @v_count2 INT ,
  @v_new_productnumberkey INT      
  
BEGIN
   
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_datagroup_string = ''
  SET @v_quote = CHAR(39)

  SET @v_userkey = null
  SELECT @v_userkey = userkey
    FROM qsiusers
   WHERE userid = @i_userid

  IF @v_userkey IS NULL BEGIN
	  SELECT @v_userkey = clientdefaultvalue
	  FROM clientdefaults
	  WHERE clientdefaultid = 48
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_userkey is null BEGIN
		SET @v_userkey = -1
  END  
  
  select @i_mediatypecode = mediatypecode, @i_mediatypesubcode = mediatypesubcode  from bookdetail where bookkey=@i_bookkey
  
  SELECT @v_prtg_itemtype = datacode, @v_prtg_usageclass = datasubcode, @v_name_gen_sql = alternatedesc1
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 40  --Printing/Printing

  -- Get the default Project Type and Status for Printings
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype 
  WHERE tableid = 521 AND itemtypecode = @v_prtg_itemtype AND itemtypesubcode = @v_prtg_usageclass

  IF @v_count > 0
    SELECT TOP 1 @v_def_projtype = i.datacode
    FROM gentablesitemtype i, gentables g 
    WHERE i.tableid = g.tableid AND i.datacode = g.datacode 
      AND i.tableid = 521 AND i.itemtypecode = @v_prtg_itemtype AND i.itemtypesubcode = @v_prtg_usageclass
    ORDER BY g.deletestatus, COALESCE(i.sortorder, g.sortorder)    
  ELSE
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype 
    WHERE tableid = 521 AND itemtypecode = @v_prtg_itemtype

    IF @v_count > 0
      SELECT TOP 1 @v_def_projtype = i.datacode
      FROM gentablesitemtype i, gentables g 
      WHERE i.tableid = g.tableid AND i.datacode = g.datacode 
        AND i.tableid = 521 AND i.itemtypecode = @v_prtg_itemtype
      ORDER BY g.deletestatus, COALESCE(i.sortorder, g.sortorder)      
  END

  SELECT @v_count = COUNT(*)
  FROM gentables 
  WHERE tableid = 522 AND qsicode = 3 -- Active

  IF @v_count > 0 BEGIN
    SELECT @v_def_projstatus = datacode
    FROM gentables 
    WHERE tableid = 522 AND qsicode = 3 -- Active
  END
  ELSE BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype 
    WHERE tableid = 522 AND itemtypecode = @v_prtg_itemtype AND itemtypesubcode = @v_prtg_usageclass

    IF @v_count > 0
      SELECT TOP 1 @v_def_projstatus = i.datacode
      FROM gentablesitemtype i, gentables g 
      WHERE i.tableid = g.tableid AND i.datacode = g.datacode 
        AND i.tableid = 522 AND i.itemtypecode = @v_prtg_itemtype AND i.itemtypesubcode = @v_prtg_usageclass
      ORDER BY g.deletestatus, COALESCE(i.sortorder, g.sortorder)    
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype 
      WHERE tableid = 522 AND itemtypecode = @v_prtg_itemtype

      IF @v_count > 0
        SELECT TOP 1 @v_def_projstatus = i.datacode
        FROM gentablesitemtype i, gentables g 
        WHERE i.tableid = g.tableid AND i.datacode = g.datacode 
          AND i.tableid = 522 AND i.itemtypecode = @v_prtg_itemtype
        ORDER BY g.deletestatus, COALESCE(i.sortorder, g.sortorder) 
    END
  END
  
  -- Get the printing number associated with this printing
  SELECT @v_printingnum = printingnum
  FROM printing
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- If name generation stored procedure exists for Printings, execute it.
  -- Otherwise, use book.title and printing.printingnum as the Printing project name.
  IF @v_name_gen_sql IS NOT NULL
  BEGIN
    -- Replace each parameter placeholder with corresponding value
    SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@userid', @v_quote + @i_userid + @v_quote)
    SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@bookkey', CONVERT(VARCHAR, @i_bookkey))
    SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@printingkey', CONVERT(VARCHAR, @i_printingkey))
    SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@printingnum', CONVERT(VARCHAR, COALESCE(@v_printingnum,0)))
   
    -- Execute the stored name auto-generation stored procedure for Printings
    EXEC qutl_execute_prodidsql2 @v_name_gen_sql, @v_result_value1 OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT,
      @v_error OUTPUT, @v_error_desc OUTPUT

    IF @v_error <> 0 BEGIN
      SET @o_error_code = @v_error
      SET @o_error_desc = 'Failed to execute name auto generation stored procedure: ' + @v_error_desc
      RETURN
    END

    SET @v_prtg_title = @v_result_value1
  END
  ELSE
  BEGIN
    SELECT @v_book_title = title
    FROM book
    WHERE bookkey = @i_bookkey

    SET @v_prtg_title = @v_book_title + ' ' + CONVERT(VARCHAR, @v_printingnum)
  END

  -- Add the Printing project
  EXEC dbo.get_next_key 'QSIDBA', @v_new_projectkey OUT

  INSERT INTO taqproject
    (taqprojectkey, taqprojectownerkey, taqprojecttitle, taqprojecttype, taqprojectstatuscode, lastuserid, lastmaintdate,
    searchitemcode, usageclasscode, autogeneratenameind)
  VALUES
    (@v_new_projectkey, -1, @v_prtg_title, @v_def_projtype, @v_def_projstatus, @i_userid, getdate(), @v_prtg_itemtype, @v_prtg_usageclass, 1)
  
 SELECT @v_jobnumberalpha = jobnumberalpha
  FROM printing
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey


  IF @v_jobnumberalpha IS NOT NULL AND LEN(@v_jobnumberalpha) > 0 BEGIN
		SELECT @v_productidcode = datacode FROM gentables WHERE tableid = 594 and qsicode = 14
		
		IF @v_productidcode > 0 BEGIN
		    SET @v_count2 = 0
		    
			SELECT @v_count2 = COUNT(*) FROM taqproductnumbers WHERE taqprojectkey = @v_new_projectkey AND productidcode = @v_productidcode
				 AND ltrim(rtrim(productnumber)) = @v_jobnumberalpha
				
			IF @v_count2 = 0 BEGIN 
				EXEC dbo.get_next_key 'QSIDBA', @v_new_productnumberkey OUT
				
				INSERT INTO taqproductnumbers (productnumberkey,taqprojectkey,productidcode,productnumber,sortorder,lastuserid, lastmaintdate)
				    VALUES (@v_new_productnumberkey,@v_new_projectkey,@v_productidcode,@v_jobnumberalpha,1,@i_userid, getdate())
            END
       END --@v_productidcode > 0
  END    --IF @v_jobnumberalpha IS NOT NULL AND LEN(@v_jobnumberalpha) > 0       

  -- Add the orgentries
  INSERT INTO taqprojectorgentry
    (taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
  SELECT
    @v_new_projectkey, orgentrykey, orglevelkey, @i_userid, GETDATE()
  FROM bookorgentry
  WHERE bookkey = @i_bookkey
 
 -- Get the project role of "Printing" and title role of "Printing Title
  SELECT @v_projectrole = datacode FROM gentables WHERE tableid = 604 AND qsicode = 3
  SELECT @v_titlerole = datacode FROM gentables WHERE tableid = 605 AND qsicode = 7
  
  -- Check if at least one printing project already exists for this title - prior to inserting taqprojecttitle record
  SELECT @v_count_prtgproj = COUNT(*)
  FROM taqprojecttitle 
  WHERE bookkey = @i_bookkey AND projectrolecode = @v_projectrole  

   -- Add the relationship between the title printing and the newly added Printing project 
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  INSERT INTO taqprojecttitle
    (taqprojectformatkey, taqprojectkey,mediatypecode,mediatypesubcode, primaryformatind, bookkey, printingkey, projectrolecode, titlerolecode, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, @v_new_projectkey,@i_mediatypecode,@i_mediatypesubcode, 0, @i_bookkey, @i_printingkey, @v_projectrole, @v_titlerole, @i_userid, getdate())
 
  --DECLARE @v_test1 INT, @v_test2 INT, @v_test3 INT
     
  --SELECT @v_test1 = mediatypecode, @v_test2 = mediatypesubcode, @v_test3 = bookkey
  --FROM taqprojectprinting_view
  --WHERE taqprojectkey = @v_new_projectkey
    
  --PRINT 'media/format/bookkey from taqprojectprinting_view'
  --PRINT 'Media: ' + convert(varchar,  @v_test1)
  --PRINT 'Format: ' + convert(varchar,  @v_test2) 
  --PRINT 'Bookkey: ' + convert(varchar, @v_test3)

  --SELECT @v_test1 = mediatypecode, @v_test2 = mediatypesubcode
  --FROM bookdetail
  --WHERE bookkey = @v_test3

  --PRINT 'from bookdetail:'
  --PRINT '@v_media: ' + convert(varchar, @v_test1)
  --PRINT '@v_format: ' + convert(varchar, @v_test2)

  --SELECT @v_test1 = mediatypecode, @v_test2 = mediatypesubcode
  --FROM coretitleinfo
  --WHERE bookkey = @v_test3 And printingkey=1

  --PRINT 'from coretitleinfo'
  --PRINT '@v_media: ' + convert(varchar, @v_test1)
  --PRINT '@v_format: ' + convert(varchar, @v_test2)

  --Add default project tasks
  EXEC dbo.qproject_new_project_setup @v_new_projectkey, @v_def_projtype, @i_userid, @v_error OUTPUT, @v_error_desc OUTPUT
 
  IF @v_error <> 0 BEGIN
      SET @o_error_code = @v_error
      SET @o_error_desc = 'Failed to execute name new project setup stored procedure: ' + @v_error_desc
      RETURN
  END  

  --PRINT '@v_count_prtgproj: ' + convert(varchar, @v_count_prtgproj)
  
  IF @v_count_prtgproj = 0	--there were no printing projects prior to this one created above
  BEGIN
    -- Check if Acquisitions project exists for this title
    SELECT @v_count = COUNT(*)
    FROM taqprojecttitle 
    WHERE bookkey = @i_bookkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2)

    --PRINT '@v_count (acq proj): ' + convert(varchar, @v_count)

    IF @v_count > 0
    BEGIN
      SELECT @v_copy_projectkey = taqprojectkey
      FROM taqprojecttitle 
      WHERE bookkey = @i_bookkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2)
    END
    ELSE
    BEGIN
      -- Get the max printingkey for this title
      SELECT @v_max_prtg = COALESCE(MAX(printingkey),0) 
      FROM taqprojecttitle 
      WHERE bookkey = @i_bookkey AND projectrolecode = @v_projectrole

      --PRINT '@v_max_prtg: ' + convert(varchar, @v_max_prtg)

      IF @v_max_prtg > 0
      BEGIN
        -- If Printing projects already exist for this title, get the taqprojectkey for the latest printing
        SELECT @v_copy_projectkey = taqprojectkey 
        FROM taqprojecttitle 
        WHERE bookkey = @i_bookkey AND printingkey = @v_max_prtg AND projectrolecode = @v_projectrole
      END
      ELSE    
        --No Printing or Acquisition projects exist for this title - use default template to copy
        SELECT @v_count = COUNT(*)
        FROM coreprojectinfo
        WHERE searchitemcode = @v_prtg_itemtype
          AND usageclasscode = @v_prtg_usageclass
          AND defaulttemplateind = 1
          AND templateind = 1

        IF @v_count > 0
          SELECT TOP (1) @v_copy_projectkey = projectkey
          FROM coreprojectinfo
          WHERE searchitemcode = @v_prtg_itemtype
            AND usageclasscode = @v_prtg_usageclass
            AND defaulttemplateind = 1
            AND templateind = 1
        ELSE
          SET @v_copy_projectkey = 0
      END
    END

  --PRINT '@v_copy_projectkey: ' + convert(varchar, @v_copy_projectkey)
  --PRINT '@v_new_projectkey: ' + convert(varchar, @v_new_projectkey)

  IF @v_copy_projectkey > 0
  BEGIN
    -- Form the datagroup string - list of all Project data Group datacodes (gentable 598) valid for Printing projects -
    -- sort on gentablesitemtype.sortorder first, then gentables.sortorder and datadesc
    DECLARE datagroup_cur CURSOR FOR
      SELECT i.datacode
      FROM gentablesitemtype i, gentables g 
      WHERE i.tableid = g.tableid AND i.datacode = g.datacode AND g.tableid = 598 
        AND itemtypecode = @v_prtg_itemtype AND COALESCE(itemtypesubcode,0) IN (0,@v_prtg_usageclass)
      ORDER BY i.sortorder, g.sortorder, g.datadesc

    OPEN datagroup_cur 

    FETCH datagroup_cur INTO @v_datacode

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      IF COALESCE(@v_datagroup_string,'') = ''
        SET @v_datagroup_string = CONVERT(VARCHAR, @v_datacode)
      ELSE
        SET @v_datagroup_string = @v_datagroup_string + ',' + CONVERT(VARCHAR, @v_datacode)
    
      FETCH datagroup_cur INTO @v_datacode
    END

    CLOSE datagroup_cur
    DEALLOCATE datagroup_cur

    EXEC qproject_copy_project @v_copy_projectkey, 0, @v_new_projectkey, @v_datagroup_string, '', 0, 0, 0, @i_userid, @v_prtg_title, 
      @v_new_projectkey OUTPUT, @v_error OUTPUT, @v_error_desc OUTPUT

    IF @v_error <> 0 BEGIN
      SET @o_error_code = @v_error
      SET @o_error_desc = 'Failed to copy from project ' + CONVERT(VARCHAR, @v_copy_projectkey) + ': ' + @v_error_desc
      RETURN
    END
  END

END
GO

GRANT EXEC ON qprinting_prtgproj_from_prtgtbl TO PUBLIC
GO
