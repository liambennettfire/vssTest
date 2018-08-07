if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_plstage_version_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_plstage_version_info
GO

CREATE PROCEDURE qpl_get_plstage_version_info (  
  @i_projectkey integer,
  @i_plstage    integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_plstage_version_info
**  Desc: This stored procedure returns all versions for given projectkey and P&L Stage.
**
**  Auth: Kate
**  Date: September 10 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  SELECT 
    CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
    END isselected, v.*
  FROM taqversion v
  WHERE v.taqprojectkey = @i_projectkey AND v.plstagecode = @i_plstage
  ORDER BY v.taqversionkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversion table to get all Versions for Stage (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_plstage_version_info TO PUBLIC
GO
