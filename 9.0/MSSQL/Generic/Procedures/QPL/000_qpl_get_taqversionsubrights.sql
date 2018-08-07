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
    @v_error  INT,
    @v_plcurrency_format VARCHAR(40)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_plcurrency_format = COALESCE(g.alternatedesc1, '$###,##0') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables g ON p.plenteredcurrency = g.datacode AND g.tableid = 122 
  WHERE p.taqprojectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject table to get P&L currency info (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END
        
  SELECT v.maxyearcode, r.rightscode origrightscode, (100 - r.authorpercent) pubpercent, 0.00 total, @v_plcurrency_format currencyformat, r.*
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
