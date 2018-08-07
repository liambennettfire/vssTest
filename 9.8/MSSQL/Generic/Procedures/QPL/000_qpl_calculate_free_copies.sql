if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calculate_free_copies') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calculate_free_copies
GO

CREATE PROCEDURE qpl_calculate_free_copies (
  @i_projectkey   INT,
  @i_plstagecode  INT,
  @i_versionkey   INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/*************************************************************************************
**  Name: qpl_calculate_free_copies
**  Desc: This stored procedure calculates comp copies based on total sales units
**        and percentage from freecopiesscale, if the client option is turned on.
**
**  Auth: Kate
**  Date: June 26 2014
**************************************************************************************/

DECLARE
  @v_addtlunitskey  INT,
  @v_calc_option  TINYINT,
  @v_calculated_units INT,
  @v_count	INT,
  @v_error  INT,
  @v_format INT,
  @v_formatkey  INT,
  @v_formattype VARCHAR(50),
  @v_media  INT,
  @v_overrideind  TINYINT,
  @v_percentage DECIMAL(10,2),
  @v_plsubtype  INT,
  @v_pltype INT,
  @v_plunitsubtype  INT,
  @v_plunittype INT,
  @v_rowcount	INT,
  @v_total_format_units INT
    
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_calc_option = optionvalue
  FROM clientoptions
  WHERE optionid = 118  --Calculate # of Comp Copies
  
  IF @v_calc_option IS NULL OR @v_calc_option = 0
    RETURN
    
  SELECT @v_pltype = pltypecode, @v_plsubtype = pltypesubcode
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_versionkey
  
  SELECT TOP 1 @v_plunittype = datacode, @v_plunitsubtype = datasubcode
  FROM subgentables
  WHERE tableid = 570 AND subgen1ind = 1
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Could not calculate Comp Copies - missing calculated P&L Unit Type (subgentables 570).'
    GOTO RETURN_ERROR
  END
    
  DECLARE cur_ver_formats CURSOR FOR
    SELECT f.taqprojectformatkey, f.mediatypecode, f.mediatypesubcode, COALESCE(s.gentext1, '')
    FROM taqversionformat f, subgentables_ext s 
    WHERE f.mediatypecode = s.datacode
      AND f.mediatypesubcode = s.datasubcode
      AND s.tableid = 312
      AND f.taqprojectkey = @i_projectkey 
      AND f.plstagecode = @i_plstagecode
      AND f.taqversionkey = @i_versionkey
    
  OPEN cur_ver_formats
  
  FETCH NEXT FROM cur_ver_formats INTO @v_formatkey, @v_media, @v_format, @v_formattype

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN  

    SELECT @v_total_format_units = SUM(u.grosssalesunits)
    FROM taqversionsalesunit u, taqversionsaleschannel c
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstagecode AND
        c.taqversionkey = @i_versionkey AND
        c.taqprojectformatkey = @v_formatkey
    
    IF @v_total_format_units IS NULL
      SET @v_total_format_units = 0
      
    SELECT @v_count = COUNT(*)
    FROM freecopiesscale
    WHERE pltypecode = @v_pltype AND pltypesubcode = @v_plsubtype
      AND mediatypecode = @v_media AND mediatypesubcode = @v_format
      AND @v_total_format_units > salesqtylow
      AND @v_total_format_units <= salesqtyhigh
      
    IF @v_count > 0
      SELECT @v_percentage = percentage
      FROM freecopiesscale
      WHERE pltypecode = @v_pltype AND pltypesubcode = @v_plsubtype
        AND mediatypecode = @v_media AND mediatypesubcode = @v_format
        AND @v_total_format_units > salesqtylow
        AND @v_total_format_units <= salesqtyhigh
    ELSE
      SET @v_percentage = 0
      
    SET @v_calculated_units = ROUND((@v_total_format_units * @v_percentage / 100), 0)
    
    SELECT @v_count = COUNT(*)
    FROM taqversionaddtlunits
    WHERE taqprojectkey = @i_projectkey 
      AND plstagecode = @i_plstagecode
      AND taqversionkey = @i_versionkey
      AND taqprojectformatkey = @v_formatkey
      AND plunittypecode = @v_plunittype
      AND plunittypesubcode = @v_plunitsubtype
      
    IF @v_count > 0
      SELECT @v_addtlunitskey = addtlunitskey
      FROM taqversionaddtlunits
      WHERE taqprojectkey = @i_projectkey 
        AND plstagecode = @i_plstagecode
        AND taqversionkey = @i_versionkey
        AND taqprojectformatkey = @v_formatkey
        AND plunittypecode = @v_plunittype
        AND plunittypesubcode = @v_plunitsubtype
    ELSE
    BEGIN
      EXEC get_next_key @i_userid, @v_addtlunitskey OUTPUT

      INSERT INTO taqversionaddtlunits
        (addtlunitskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, plunittypecode, plunittypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_addtlunitskey, @i_projectkey, @i_plstagecode, @i_versionkey, @v_formatkey, @v_plunittype, @v_plunitsubtype, @i_userid, getdate())
    END
    
    SELECT @v_count = COUNT(*)
    FROM taqversionaddtlunitsyear
    WHERE addtlunitskey = @v_addtlunitskey
    
    IF @v_count > 0
    BEGIN
      -- Check override indicator - only update if not set
      SELECT @v_overrideind = overrideind
      FROM taqversionaddtlunitsyear
      WHERE addtlunitskey = @v_addtlunitskey
      
      IF @v_overrideind = 0
        UPDATE taqversionaddtlunitsyear
        SET quantity = @v_calculated_units, lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE addtlunitskey = @v_addtlunitskey AND yearcode = 1
    END
    ELSE
      INSERT INTO taqversionaddtlunitsyear
        (addtlunitskey, yearcode, quantity, lastuserid, lastmaintdate)
      VALUES
        (@v_addtlunitskey, 1, @v_calculated_units, @i_userid, getdate())      
          
    FETCH NEXT FROM cur_ver_formats INTO @v_formatkey, @v_media, @v_format, @v_formattype
  END
  
  CLOSE cur_ver_formats
  DEALLOCATE cur_ver_formats
  
  RETURN
  
  return_error:
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qpl_calculate_free_copies TO PUBLIC
GO


