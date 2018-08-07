if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_acq_version') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_acq_version
GO

CREATE PROCEDURE qpl_create_acq_version (  
  @i_projectkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_create_acq_version
**  Desc: This stored procedure will make sure that a system-generated version/format exists
**        and is kept in sync with an acquisition project's formats whenever format is added/deleted.
**
**  Auth: Kate
**  Date: December 4 2014
***********************************************************************************************************
**  Change History
***********************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------------
**  05/18/2016   UK          Case 38174 Unable to Change Price in Formats Tab
***********************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_cur_stage	INT,
  @v_cur_version  INT,
  @v_def_plstatus INT,
  @v_def_pltype INT,
  @v_def_relstrategy  INT,
  @v_error  INT,
  @v_errordesc  VARCHAR(2000),
  @v_format INT,
  @v_itemtype	INT,
  @v_media  INT,
  @v_newformatkey INT,
  @v_newkey INT,
  @v_price  FLOAT,
  @v_quantity INT,
  @v_sel_versionkey	INT,
  @v_usageclass	INT,
  @v_versionformats VARCHAR(120),
  @v_versionformatsstring VARCHAR(255)  

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_versionformatsstring = NULL 
  SET @v_versionformats = NULL   

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  -- Get the item type and usage class for this project
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM coreprojectinfo
  WHERE projectkey = @i_projectkey 

  -- Get the most recent active stage on this project that has a selected version
  SELECT @v_cur_stage = dbo.qpl_get_most_recent_stage(@i_projectkey)
  
  IF @v_cur_stage <= 0	--error occurred or no selected version exists for any active stage on this project
  BEGIN	
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

  -- Add taqversion record if it doesn't exist.
  SELECT @v_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

  IF @v_count = 0
  BEGIN
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
          
    INSERT INTO taqversion
      (taqprojectkey, plstagecode, taqversionkey, taqversiondesc, plstatuscode, pltypecode, pltypesubcode, 
      releasestrategycode, maxyearcode, lastuserid, lastmaintdate, prodqtyentrytypecode)
    VALUES
      (@i_projectkey, @v_cur_stage, @v_cur_version, 'System Generated', @v_def_plstatus, @v_def_pltype, 0,
      @v_def_relstrategy, 1, 'FIREBRAND', getdate(), 4)
  END

  -- Make sure that taqversionformat records for the selected version are in sync with acquisition project's formats:
  -- Loop through all acquisition formats and make sure that version has the corresponding format
  DECLARE acq_formats_cur CURSOR FOR
    SELECT mediatypecode, mediatypesubcode, price, initialrun
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_projectkey AND 
		  projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2) AND
		  titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)    
    ORDER BY primaryformatind DESC

	OPEN acq_formats_cur

	FETCH acq_formats_cur INTO @v_media, @v_format, @v_price, @v_quantity

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

    SELECT @v_count = COUNT(*)
    FROM taqversionformat
    WHERE taqprojectkey = @i_projectkey 
      AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version
      AND mediatypecode = @v_media AND mediatypesubcode = @v_format

    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newformatkey OUT

      INSERT INTO taqversionformat
        (taqprojectformatkey, taqprojectkey, plstagecode, taqversionkey, mediatypecode, mediatypesubcode, activeprice, lastuserid, lastmaintdate)
      VALUES
        (@v_newformatkey, @i_projectkey, @v_cur_stage, @v_cur_version, @v_media, @v_format, @v_price, 'FIREBRAND', getdate())
 
      -- Make sure that at least one taqversionformatyear record exists for this format
      SELECT @v_count = COUNT(*)
      FROM taqversionformatyear
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version AND taqprojectformatkey = @v_newformatkey

      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

        INSERT INTO taqversionformatyear
          (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode, printingnumber,
          quantity, lastuserid, lastmaintdate)
        VALUES
          (@v_newkey, @i_projectkey, @v_cur_stage, @v_cur_version, @v_newformatkey, 1, 1, @v_quantity, 'FIREBRAND', getdate())
      END
    END
	ELSE BEGIN
	  -- Case 33435: price was being overwritten by qpl_sync_version_to_acq_project when saving updated project format info
      UPDATE taqversionformat SET
        activeprice = @v_price, lastuserid='FIREBRAND', lastmaintdate=getdate()
      WHERE taqprojectkey = @i_projectkey 
        AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version
        AND mediatypecode = @v_media AND mediatypesubcode = @v_format
	END

    FETCH acq_formats_cur INTO @v_media, @v_format, @v_price, @v_quantity
  END

  CLOSE acq_formats_cur
  DEALLOCATE acq_formats_cur
  
  -- Delete formats that exist only on the version
  DELETE FROM taqversionformat
  WHERE taqprojectkey = @i_projectkey
    AND plstagecode = @v_cur_stage
    AND taqversionkey = @v_cur_version
    AND NOT EXISTS 
      (SELECT * FROM taqprojecttitle t 
       WHERE t.taqprojectkey = taqversionformat.taqprojectkey AND 
        t.mediatypecode = taqversionformat.mediatypecode AND 
        t.mediatypesubcode = taqversionformat.mediatypesubcode)
        
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
        

  -- Delete any records associated with the deleted formats above
  EXEC qpl_maintain_format_year @i_projectkey, @v_cur_stage, @v_cur_version, 'FIREBRAND', @v_error OUT, @v_errordesc OUT

  IF @v_error = -1 BEGIN
    SET @o_error_desc = 'Error returned from qpl_maintain_format_year: ' + @v_errordesc
    GOTO RETURN_ERROR
  END  
  
  RETURN

RETURN_ERROR:   
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qpl_create_acq_version TO PUBLIC
GO
  