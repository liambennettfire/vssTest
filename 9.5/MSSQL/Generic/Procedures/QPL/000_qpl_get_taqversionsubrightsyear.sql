if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsubrightsyear') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsubrightsyear
GO

CREATE PROCEDURE qpl_get_taqversionsubrightsyear (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_get_taqversionsubrightsyear
**  Desc: This stored procedure returns all Subrights Year records for given P&L Version.
**
**  Auth: Kate
**  Date: October 31 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
        
  SELECT y.* 
  FROM taqversionsubrightsyear y, taqversionsubrights r
  WHERE y.subrightskey = r.subrightskey AND
      r.taqprojectkey = @i_projectkey AND
      r.plstagecode = @i_plstage AND
      r.taqversionkey = @i_versionkey     

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionsubrights/taqversionsubrightsyear tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsubrightsyear TO PUBLIC
GO
