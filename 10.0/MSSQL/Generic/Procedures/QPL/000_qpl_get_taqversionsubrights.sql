if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsubrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsubrights
GO

CREATE PROCEDURE qpl_get_taqversionsubrights (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_get_taqversionsubrights
**  Desc: This stored procedure returns all Subrights records for given P&L Version.
**
**  Auth: Kate
**  Date: October 31 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_decpos INT,
    @v_decprecision_mask VARCHAR(40),  
    @v_error  INT,
    @v_plcurrency_format VARCHAR(40)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Get the P&L Currency Format mask based on project's P&L entry currency (default to US currency mask)
  SELECT @v_plcurrency_format = COALESCE(g.gentext1, '$###,##0') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables_ext g ON p.plenteredcurrency = g.datacode AND g.tableid = 122 
  WHERE p.taqprojectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject/gentables_ext tables to get P&L Currency info (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END
  
  -- Ignore the decimal portion of currency format from above (in case entered)
  SET @v_decpos = CHARINDEX('.', @v_plcurrency_format)
  IF @v_decpos > 0
    SET @v_plcurrency_format = LEFT(@v_plcurrency_format, @v_decpos -1)
    
  -- Get the decimal precision mask for currency format as set for the project's item type (default to none)
  SELECT @v_decprecision_mask = COALESCE(g.gentext1, '') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables_ext g ON p.searchitemcode = g.datacode AND g.tableid = 550 
  WHERE p.taqprojectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject/gentables_ext tables to get P&L Currency Decimal Precision mask (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END  
  
  -- If decimal precision mask exists for the project's item type, include it in the P&L Currency Format mask
  IF @v_decprecision_mask <> ''
    SET @v_plcurrency_format = @v_plcurrency_format + @v_decprecision_mask
        
  SELECT v.maxyearcode, r.rightscode origrightscode, (100 - r.authorpercent) pubpercent, 0.00 total, 
    @v_plcurrency_format currencyformat, @v_decprecision_mask decprecision, r.*
  FROM taqversionsubrights r, taqversion v
  WHERE r.taqprojectkey = v.taqprojectkey AND
      r.plstagecode = v.plstagecode AND
      r.taqversionkey = v.taqversionkey AND
      r.taqprojectkey = @i_projectkey AND
      r.plstagecode = @i_plstage AND
      r.taqversionkey = @i_versionkey
     

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversion/taqversionsubrights tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionsubrights TO PUBLIC
GO
