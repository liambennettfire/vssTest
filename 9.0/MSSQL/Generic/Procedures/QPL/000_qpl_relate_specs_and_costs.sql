if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_relate_specs_and_costs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_relate_specs_and_costs
GO

CREATE PROCEDURE qpl_relate_specs_and_costs (  
  @i_current_projkey integer,
  @i_related_projkey integer,
  @i_vendorkey	integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/********************************************************************************************
**  Name: qpl_relate_specs_and_costs
**  Desc: This stored procedure will relate the specs and costs from one project to another.
**
**  Auth: Kate
**  Date: September 6 2014
*********************************************************************************************/

DECLARE
  @v_allow_relation_of_components INT,
  @v_count  INT,
  @v_cur_versionformatkey	INT,
  @v_cur_stage	INT,
  @v_cur_version	INT,
  @v_current_projecttype INT,
  @v_error  INT,
  @v_errordesc	VARCHAR(2000),  
  @v_itemtype	INT,
  @v_itemtype_current_project INT,
  @v_itemtype_purchase_order INT,
  @v_mediatype	INT,
  @v_mediasubtype	INT,  
  @v_newkey	INT,
  @v_num_formats  INT,
  @v_projecttype_miscellaneous INT,
  @v_rel_formatdesc	VARCHAR(MAX),
  @v_rel_projdesc VARCHAR(255),
  @v_rel_stage  INT,
  @v_rel_version  INT,
  @v_rel_versionformatkey	INT,
  @v_sortorder  INT,
  @v_speccategorycode INT,
  @v_speccategorykey  INT,
  @v_usageclass	INT,
  @v_usageclass_current_project INT

BEGIN
  
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_current_projkey IS NULL OR @i_current_projkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  IF @i_related_projkey IS NULL OR @i_related_projkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid related projectkey.'
    GOTO RETURN_ERROR
  END
    
  -- Get the most recent active stage on this project that has a selected version
  SELECT @v_cur_stage = dbo.qpl_get_most_recent_stage(@i_current_projkey)
  
  -- Get the Item Type and Usage Class for the current project - need for figuring out the order of P&L Stages based on itemtype filter
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM taqproject 
  WHERE taqprojectkey = @i_current_projkey  
  
  SET @v_itemtype_current_project = @v_itemtype
  
  SELECT @v_itemtype_purchase_order = datacode
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 15
  
  SELECT @v_projecttype_miscellaneous = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 10  
  
  SELECT @v_current_projecttype = taqprojecttype 
  FROM taqproject 
  WHERE taqprojectkey = @i_current_projkey
  
  SET @v_allow_relation_of_components = 1
  
  IF (@v_itemtype_purchase_order = @v_itemtype_current_project) AND (@v_current_projecttype = @v_projecttype_miscellaneous) BEGIN
	  SET @v_allow_relation_of_components = 0
  END  
  
  IF @v_cur_stage <= 0	--error occurred or no selected version exists for any active stage on this project
  BEGIN	
    IF @v_itemtype IS NULL
      SET @v_itemtype = 0
    IF @v_usageclass IS NULL
      SET @v_usageclass = 0
	
    -- Get the most recent stage existing on this project (regardless of whether it has a selected version)
    SELECT TOP(1) @v_cur_stage = g.datacode 
    FROM gentablesitemtype gi, gentables g, taqplstage p
    WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
      AND p.plstagecode = g.datacode AND p.taqprojectkey = @i_current_projkey
      AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtype 
      AND (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0)
    ORDER BY gi.sortorder DESC, g.sortorder DESC
    
    IF @v_cur_stage <= 0	--no stages exist on this project
    BEGIN
      -- Get the first active stage for this project's Item Type and Usage Class
      SELECT TOP(1) @v_cur_stage = g.datacode FROM gentablesitemtype gi, gentables g
      WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
        AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtype
        AND (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0)
      ORDER BY gi.sortorder ASC, g.sortorder ASC
      
      IF @v_cur_stage IS NULL
        SET @v_cur_stage = 0
    END
  END
  
  -- Get the selected version for the most recent active stage on the project
  SELECT @v_cur_version = selectedversionkey 
  FROM taqplstage 
  WHERE taqprojectkey = @i_current_projkey AND plstagecode = @v_cur_stage
  
  IF @v_cur_version IS NULL OR @v_cur_version = 0	--no selected version exist for any active stage on this project
  BEGIN
    -- Get the next versionkey to use for this stage
    SELECT @v_cur_version = COALESCE(MAX(taqversionkey),0) + 1 
    FROM taqversion 
    WHERE taqprojectkey = @i_current_projkey
  END
  
  -- Call the stored procedure that will check if this version exists, and if not, it will add it.
  -- It will also add taqversionformat row if none exist for the version (in which case the generated taqversionformatkey will be passed out).
  EXEC qpl_check_taqversion @i_current_projkey, @v_cur_stage, @v_cur_version, 
    @v_cur_versionformatkey OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT
  
  IF @v_error < 0
    GOTO return_error

  IF @v_cur_versionformatkey IS NULL
    SET @v_cur_versionformatkey = 0

  -- Check if taqversionformatrelatedproject record exists for current and related project
  SELECT @v_count = COUNT(*)
  FROM taqversionformatrelatedproject
  WHERE taqprojectkey = @i_current_projkey AND relatedprojectkey = @i_related_projkey

  IF @v_count = 0 -- taqversionformatrelatedproject row doesn't exist, so must be added
  BEGIN
    -- For the current project's taqversionformatkey, use the taqversionformatkey created above in the qpl_check_taqversion stored procedure.
    -- If taqversionformatkey = 0, it was not created there so we must get it. 
    IF @v_cur_versionformatkey = 0
      SELECT TOP(1) @v_cur_versionformatkey = f.taqprojectformatkey
      FROM taqversionformat f
        LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
        LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode
      WHERE f.taqprojectkey = @i_current_projkey AND f.plstagecode = @v_cur_stage AND f.taqversionkey = @v_cur_version
      ORDER BY f.sortorder, g.sortorder, s.sortorder

    -- Get the description of the related project
    SELECT @v_rel_projdesc = taqprojecttitle
    FROM taqproject
    WHERE taqprojectkey = @i_related_projkey
    
    -- Get the most recent active stage on the related project that has a selected version
    SELECT @v_rel_stage = dbo.qpl_get_most_recent_stage(@i_related_projkey)
  
    IF @v_rel_stage <= 0	--error occurred or no selected version exists for any active stage on the related project
    BEGIN
	    SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
	    FROM taqproject 
	    WHERE taqprojectkey = @i_related_projkey
	
	    IF @v_itemtype IS NULL
	      SET @v_itemtype = 0
	    IF @v_usageclass IS NULL
	      SET @v_usageclass = 0
	
      -- Get the most recent stage existing on the related project (regardless of whether it has a selected version)
      SELECT TOP(1) @v_rel_stage = g.datacode 
      FROM gentablesitemtype gi, gentables g, taqplstage p
      WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
        AND p.plstagecode = g.datacode AND p.taqprojectkey = @i_related_projkey
        AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtype 
        AND (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0)
      ORDER BY gi.sortorder DESC, g.sortorder DESC
    
      IF @v_rel_stage IS NULL	--no stages exist on the related project
      BEGIN
        -- Get the first active stage for the related project's Item Type and Usage Class
        SELECT TOP(1) @v_rel_stage = g.datacode FROM gentablesitemtype gi, gentables g
        WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
          AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtype
          AND (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0)
        ORDER BY gi.sortorder ASC, g.sortorder ASC
      
        IF @v_rel_stage IS NULL
          SET @v_rel_stage = 0
      END
    END
  
    -- Get the selected version for the most recent active stage on the related project
    SELECT @v_rel_version = selectedversionkey 
    FROM taqplstage 
    WHERE taqprojectkey = @i_related_projkey AND plstagecode = @v_rel_stage
  
    IF @v_rel_version IS NULL	--no selected version exist for any active stage on the related project
    BEGIN
	    -- Get the next versionkey for this stage
	    SELECT @v_rel_version = COALESCE(MAX(taqversionkey),0) + 1 
	    FROM taqversion 
	    WHERE taqprojectkey = @i_related_projkey
    END    
	
    -- Get the first taqversionformatkey for the related project's selected version
    SELECT TOP(1) @v_rel_versionformatkey = f.taqprojectformatkey,
      @v_rel_formatdesc = CASE f.mediatypesubcode
        WHEN 0 THEN g.datadesc
        ELSE g.datadesc + '/' + s.datadesc
      END
    FROM taqversionformat f
      LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
      LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode
    WHERE f.taqprojectkey = @i_related_projkey AND f.plstagecode = @v_rel_stage AND f.taqversionkey = @v_rel_version
    ORDER BY f.sortorder, g.sortorder, s.sortorder

    IF @v_rel_versionformatkey IS NULL OR @v_rel_versionformatkey = 0 --taqversionformat record doesn't yet exist for the selected version - add it
    BEGIN
      SELECT @v_mediatype = c.mediatypecode, @v_mediasubtype = c.mediatypesubcode, 
        @v_rel_formatdesc = 
        CASE 
          WHEN c.formatname IS NULL OR c.formatname = '' THEN g.datadesc
          ELSE g.datadesc + '/' + c.formatname
        END
      FROM coretitleinfo c
        LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = c.mediatypecode, 
        taqprojectprinting_view v
      WHERE c.bookkey = v.bookkey AND c.printingkey = v.printingkey AND v.taqprojectkey = @i_related_projkey
    
      IF @v_mediatype IS NULL
        SET @v_mediatype = 0
      IF @v_mediasubtype IS NULL
        SET @v_mediasubtype = 0

      SELECT @v_sortorder = COALESCE(MAX(sortorder),0) + 1
      FROM taqversionformat
      WHERE taqprojectkey = @i_related_projkey AND plstagecode = @v_rel_stage AND taqversionkey = @v_rel_version

      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionformat
        (taqprojectformatkey, taqprojectkey, plstagecode, taqversionkey, mediatypecode, mediatypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, @i_related_projkey, @v_rel_stage, @v_rel_version, @v_mediatype, @v_mediasubtype, 'FIREBRAND', getdate(), @v_sortorder)

      SET @v_rel_versionformatkey = @v_newkey
    END
    
    -- Check to see if we need to add taqversionformat row as well
    SELECT @v_num_formats = count(*)
      FROM taqversionformatrelatedproject
     WHERE taqversionformatkey = @v_cur_versionformatkey

    IF @v_num_formats = 0 BEGIN
      -- Update the description on taqversionformat table for the current project's taqversionformatkey
      UPDATE taqversionformat
      SET description = @v_rel_projdesc + ', ' + @v_rel_formatdesc
      WHERE taqprojectformatkey = @v_cur_versionformatkey
    END
    ELSE BEGIN   
      -- Create new format for current project
      SELECT @v_mediatype = mediatypecode, @v_mediasubtype = mediatypesubcode
      FROM taqprojectprinting_view
      WHERE taqprojectkey = @i_related_projkey

      --PRINT 'Media/Format from taqprojectprinting_view (@i_related_projkey=' + convert(varchar, @i_related_projkey) + ')'
      --PRINT '@v_mediatype: ' + convert(varchar, @v_mediatype)
      --PRINT '@v_mediasubtype: ' + convert(varchar, @v_mediasubtype)      

      IF @v_mediatype IS NULL
        SET @v_mediatype = 0
      IF @v_mediasubtype IS NULL
        SET @v_mediasubtype = 0

      SELECT @v_sortorder = COALESCE(MAX(sortorder),0) + 1
      FROM taqversionformat
      WHERE taqprojectkey = @i_current_projkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionformat
        (taqprojectformatkey, taqprojectkey, plstagecode, taqversionkey, mediatypecode, mediatypesubcode, lastuserid, lastmaintdate, sortorder, [description])
      VALUES
        (@v_newkey, @i_current_projkey, @v_cur_stage, @v_cur_version, @v_mediatype, @v_mediasubtype, 'FIREBRAND', getdate(), @v_sortorder, @v_rel_projdesc + ', ' + @v_rel_formatdesc)

      SET @v_cur_versionformatkey = @v_newkey
      
      -- Create taqversionformatyear rows - Year 1 and Pre-Pub
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionformatyear
        (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode, printingnumber,
        quantity, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, @i_current_projkey, @v_cur_stage, @v_cur_version, @v_cur_versionformatkey, 1, 1, 1, 'FIREBRAND', getdate())

      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionformatyear
        (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, @i_current_projkey, @v_cur_stage, @v_cur_version, @v_cur_versionformatkey, 5, 'FIREBRAND', getdate())
    END
    
    -- Add the relationship between current and related projects taqversionformatkeys
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO taqversionformatrelatedproject
      (taqversionformatrelatedkey, taqversionformatkey, taqprojectkey, relatedprojectkey, relatedversionformatkey,
      plantcostpercent, editioncostpercent, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, @v_cur_versionformatkey, @i_current_projkey, @i_related_projkey, @v_rel_versionformatkey, 100, 100, 'FIREBRAND', getdate())
  END
  ELSE IF @v_count = 1 -- a single taqversionformatrelatedproject row exists for this current and related project
  BEGIN
    SELECT @v_cur_versionformatkey = taqversionformatkey
    FROM taqversionformatrelatedproject
    WHERE taqprojectkey = @i_current_projkey AND relatedprojectkey = @i_related_projkey
  END
  ELSE  --multiple taqversionformatrealtedproject rows exist for this current and related project
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM taqversionformatrelatedproject
    WHERE taqprojectkey = @i_current_projkey AND relatedprojectkey = @i_related_projkey
      AND plantcostpercent = 100 AND editioncostpercent = 100

    IF @v_count > 0
      SELECT TOP(1) @v_cur_versionformatkey = taqversionformatkey
      FROM taqversionformatrelatedproject
      WHERE taqprojectkey = @i_current_projkey AND relatedprojectkey = @i_related_projkey
        AND plantcostpercent = 100 AND editioncostpercent = 100
    ELSE
      SELECT TOP(1) @v_cur_versionformatkey = taqversionformatkey
      FROM taqversionformatrelatedproject
      WHERE taqprojectkey = @i_current_projkey AND relatedprojectkey = @i_related_projkey
  END

  IF COALESCE(@i_vendorkey, 0) > 0 AND @v_allow_relation_of_components = 1 BEGIN
    DECLARE @avail_components_list TABLE
      (speccategorykey integer, 
      speccategorycode integer, 
      speccategorydescription varchar(255))

    INSERT INTO @avail_components_list
    SELECT speccategorykey, speccategorycode, speccategorydescription
    FROM dbo.qspec_get_avail_components(@i_related_projkey, @i_vendorkey)

    DECLARE avail_components_cur CURSOR FOR 
      SELECT speccategorykey, speccategorycode
      FROM @avail_components_list
           
    OPEN avail_components_cur
      
    FETCH avail_components_cur INTO @v_speccategorykey, @v_speccategorycode

    SET @v_sortorder = 1

    WHILE @@fetch_status = 0
    BEGIN

      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionspeccategory
        (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
        lastuserid, lastmaintdate, relatedspeccategorykey, sortorder)
      VALUES
        (@v_newkey, @i_current_projkey, @v_cur_stage, @v_cur_version, @v_cur_versionformatkey, @v_speccategorycode,
        'FIREBRAND', getdate(), @v_speccategorykey, @v_sortorder)

      SET @v_sortorder = @v_sortorder + 1
      
      FETCH avail_components_cur INTO @v_speccategorykey, @v_speccategorycode
    END

    CLOSE avail_components_cur 
    DEALLOCATE avail_components_cur
  END  

  RETURN

RETURN_ERROR:   
  SET @o_error_code = -1
  SET @o_error_desc = 'Error occurred inside qpl_relate_specs_and_costs stored procedure (@i_current_projkey=' + CONVERT(VARCHAR, @i_current_projkey) +
    ', @i_related_projkey=' + CONVERT(VARCHAR, @i_related_projkey) + ')'
  RETURN

END
GO

GRANT EXEC ON qpl_relate_specs_and_costs TO PUBLIC
GO
