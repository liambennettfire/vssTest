if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_check_taqversion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_check_taqversion
GO

CREATE PROCEDURE qpl_check_taqversion (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_versionformatkey	integer output,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_check_taqversion
**  Desc: This stored procedure will make sure that version exists for the passed values.
**        If it doesn't exist, it will to be added here - it is needed for saving production specs.
**        If taqversionformat record was created here (if would be created if none existed for the version),
**        the taqversionformatkey will be passed to the calling place as an output parameter.
**
**  Auth: Kate
**  Date: May 15 2014
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**	12/05/16    Dustin    Case 41185
****************************************************************************************************************************/

DECLARE
  @v_bookkey INT,
  @v_count  INT,
  @v_version_count INT,
  @v_cur_stage  INT,
  @v_cur_version  INT,
  @v_def_plstatus INT,
  @v_def_pltype INT,
  @v_def_relstrategy  INT,
  @v_error  INT,
  @v_itemtype INT,
  @v_mediatype  INT,
  @v_mediasubtype INT,
  @v_newkey INT,
  @v_sel_versionkey INT,
  @v_usageclass INT,
  @i_printingprojectkey int,
  @v_versionformats VARCHAR(120),
  @v_versionformatsstring VARCHAR(255),
  @v_taqversiontype int,
  @v_sortorder int

BEGIN
    
  SET @v_def_pltype = 0
  SET @v_def_plstatus = 0
  SET @v_def_relstrategy = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_version_count = 0  
  SET @v_versionformatsstring = NULL 
  SET @v_versionformats = NULL

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  -- Get the Item Type and Usage Class for the current project
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM taqproject 
  WHERE taqprojectkey = @i_projectkey 

  -- If no stage and versionkey was passed, determine the plstagecode and taqversionkey to use
  IF @i_plstage = 0 AND @i_versionkey = 0
  BEGIN
    -- Get the most recent active stage on this project that has a selected version
    SELECT @v_cur_stage = dbo.qpl_get_most_recent_stage(@i_projectkey)
  
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
        AND p.plstagecode = g.datacode AND p.taqprojectkey = @i_projectkey
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
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage
  
    IF @v_cur_version IS NULL OR @v_cur_version = 0	--no selected version exist for any active stage on this project
    BEGIN
      -- Get the next versionkey to use for this stage
      SELECT @v_cur_version = COALESCE(MAX(taqversionkey),0) + 1 
      FROM taqversion 
      WHERE taqprojectkey = @i_projectkey
    END
  END
  ELSE
  BEGIN
    SET @v_cur_stage = @i_plstage
    SET @v_cur_version = @i_versionkey
  END
    
  -- Make sure taqplstage record exists for the passed plstagecode, with selectedversionkey = passed versionkey.
  -- Add taqplstage record if it doesn't exist.
  SELECT @v_count = COUNT(*)
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage

  IF @v_count > 0
  BEGIN
    SELECT @v_sel_versionkey = selectedversionkey
    FROM taqplstage
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage

    IF @v_sel_versionkey <> @v_cur_version
      UPDATE taqplstage
      SET selectedversionkey = @v_cur_version
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage
  END
  ELSE
    INSERT INTO taqplstage
      (taqprojectkey, plstagecode, selectedversionkey, lastuserid, lastmaintdate)
    VALUES
      (@i_projectkey, @v_cur_stage, @v_cur_version, 'FIREBRAND', getdate())

  -- Check if taqversion record already exists - create it if it doesn't exist.
  SELECT @v_version_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

  IF @v_version_count = 0
  BEGIN
    -- When creating a behind-the-scenes version for Titles, we are really saving for associated Printing project
    IF @v_itemtype = 1  --Titles
    BEGIN
      SET @v_itemtype = 14
      SET @v_usageclass = 1
    END

    -- Get the default values for the itemtype/usageclass to be used for the taqversion row insert
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype 
    WHERE tableid = 566 
      AND itemtypecode = @v_itemtype
      AND itemtypesubcode = @v_usageclass

    IF @v_count > 0
      SELECT TOP 1 @v_def_pltype = datacode
      FROM gentablesitemtype 
      WHERE tableid = 566 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      ORDER BY sortorder, datacode
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype 
      WHERE tableid = 566 
        AND itemtypecode = @v_itemtype

      IF @v_count > 0
        SELECT TOP 1 @v_def_pltype = datacode
        FROM gentablesitemtype 
        WHERE tableid = 566 AND itemtypecode = @v_itemtype
        ORDER BY sortorder, datacode     
    END

    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype 
    WHERE tableid = 565
      AND itemtypecode = @v_itemtype
      AND itemtypesubcode = @v_usageclass

    IF @v_count > 0
      SELECT TOP 1 @v_def_plstatus = datacode
      FROM gentablesitemtype 
      WHERE tableid = 565 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      ORDER BY sortorder, datacode
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype 
      WHERE tableid = 565
        AND itemtypecode = @v_itemtype

      IF @v_count > 0
        SELECT TOP 1 @v_def_plstatus = datacode
        FROM gentablesitemtype 
        WHERE tableid = 565 AND itemtypecode = @v_itemtype
        ORDER BY sortorder, datacode     
    END

    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype 
    WHERE tableid = 567
      AND itemtypecode = @v_itemtype
      AND itemtypesubcode = @v_usageclass

    IF @v_count > 0
      SELECT TOP 1 @v_def_relstrategy = datacode
      FROM gentablesitemtype 
      WHERE tableid = 567 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      ORDER BY sortorder, datacode
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype 
      WHERE tableid = 567
        AND itemtypecode = @v_itemtype

      IF @v_count > 0
        SELECT TOP 1 @v_def_relstrategy = datacode
        FROM gentablesitemtype 
        WHERE tableid = 567 AND itemtypecode = @v_itemtype
        ORDER BY sortorder, datacode     
    END

    -- Get taqversiontype for P&L
    SELECT @v_taqversiontype=datacode
    FROM gentables
    WHERE tableid=629 AND lower(datadesc) like 'p&l'
          
    INSERT INTO taqversion
      (taqprojectkey, plstagecode, taqversionkey, taqversiondesc, plstatuscode, pltypecode, pltypesubcode, 
      releasestrategycode, maxyearcode, lastuserid, lastmaintdate, prodqtyentrytypecode, taqversiontype)
    VALUES
      (@i_projectkey, @v_cur_stage, @v_cur_version, 'System Generated', @v_def_plstatus, @v_def_pltype, 0,
      @v_def_relstrategy, 1, 'FIREBRAND', getdate(), 4, @v_taqversiontype)
  END

  -- Make sure that at least one taqversionformat record exists
  SELECT @v_count = COUNT(*)
  FROM taqversionformat
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

--PRINT 'INSIDE qpl_check_taqversion'
--PRINT 'number of formats: ' + convert(varchar, @v_count)

  IF @v_count = 0
  BEGIN
	--maybe we are creating a po and should copy the media\format from the printing and not try to get it with the new key eh?
	IF @v_itemtype =15  
	BEGIN
	--get the printingprojectkey instead 
	select @i_printingprojectkey = taqprojectkey2 from taqprojectrelationship where taqprojectkey1=@i_projectkey
	and relationshipcode1=13 and relationshipcode2=12
	
	IF coalesce(@i_printingprojectkey,0)<>0
		begin
		SELECT @v_mediatype = c.mediatypecode, @v_mediasubtype = c.mediatypesubcode
		FROM coretitleinfo c, taqprojectprinting_view v
		WHERE c.bookkey = v.bookkey AND c.printingkey = v.printingkey AND v.taqprojectkey = @i_printingprojectkey
		end
	END
	
	IF @v_itemtype <> 15  
	BEGIN
    -- For some reason, Media/Format are NULL at this point on coretitleinfo (against MontyQC.DEMO_QC), so getting these from bookdetail instead
    SELECT @v_mediatype = mediatypecode, @v_mediasubtype = mediatypesubcode, @v_bookkey = bookkey
    FROM taqprojectprinting_view v
    WHERE taqprojectkey = @i_projectkey

    --PRINT 'Media/Format from taqprojectprinting_view (@i_projectkey=' + convert(varchar, @i_projectkey) + ')'
    --PRINT '@v_mediatype: ' + convert(varchar, @v_mediatype)
    --PRINT '@v_mediasubtype: ' + convert(varchar, @v_mediasubtype)
    --PRINT '@v_bookkey: ' + convert(varchar, @v_bookkey)

    SELECT @v_mediatype = mediatypecode, @v_mediasubtype = mediatypesubcode
    FROM bookdetail
    WHERE bookkey = @v_bookkey

    --PRINT 'Media/Format from bookdetail'
    --PRINT '@v_mediatype: ' + convert(varchar, @v_mediatype)
    --PRINT '@v_mediasubtype: ' + convert(varchar, @v_mediasubtype)
  END
      
    IF @v_mediatype IS NULL
      SET @v_mediatype = 0
    IF @v_mediasubtype IS NULL
      SET @v_mediasubtype = 0

	SELECT @v_sortorder = COALESCE(MAX(sortorder),0) + 1
    FROM taqversionformat
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    INSERT INTO taqversionformat
      (taqprojectformatkey, taqprojectkey, plstagecode, taqversionkey, mediatypecode, mediatypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, @i_projectkey, @v_cur_stage, @v_cur_version, @v_mediatype, @v_mediasubtype, @v_sortorder, 'FIREBRAND', getdate())

    SET @o_versionformatkey = @v_newkey
  END
  
  IF @v_version_count = 0 BEGIN
	  DECLARE versionformats_cur CURSOR FOR
	  SELECT s.datadesc
	  FROM taqversionformat f
		LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
		LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode
	  WHERE f.taqprojectkey = @i_projectkey AND f.plstagecode = @v_cur_stage AND f.taqversionkey = @v_cur_version
	  ORDER BY f.sortorder, g.sortorder, s.sortorder 

	  OPEN versionformats_cur 
	    
	  FETCH versionformats_cur INTO @v_versionformats
	    
	  SET @v_versionformatsstring = ' '
	  WHILE (@@FETCH_STATUS=0)
	  BEGIN  
		IF @v_versionformatsstring <> ' '
	     SET @v_versionformatsstring = @v_versionformatsstring + ','
	        
		SET @v_versionformatsstring = @v_versionformatsstring + @v_versionformats

		FETCH versionformats_cur INTO @v_versionformats
	  END

	  CLOSE versionformats_cur 
	  DEALLOCATE versionformats_cur
	  
	  UPDATE taqversion SET versionformats = @v_versionformatsstring WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version  
  END
  
  -- Make sure that at least one taqversionformatyear record exists  
  SELECT @v_count = COUNT(*)
  FROM taqversionformatyear
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    IF @o_versionformatkey IS NULL
      SELECT @o_versionformatkey = taqprojectformatkey
      FROM taqversionformat
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

    INSERT INTO taqversionformatyear
      (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode, printingnumber,
      quantity, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, @i_projectkey, @v_cur_stage, @v_cur_version, @o_versionformatkey, 1, 1, 1, 'FIREBRAND', getdate())
  END
  
  RETURN

RETURN_ERROR:   
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qpl_check_taqversion TO PUBLIC
GO