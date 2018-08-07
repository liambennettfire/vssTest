if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversion
GO

CREATE PROCEDURE qpl_get_taqversion (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversion
**  Desc: This stored procedure returns all items for given projectkey and P&L Level.
**
**  Auth: Kate
**  Date: September 4 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_max_versionkey INT,
    @v_new_versionkey INT,
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  IF @i_plstage > 0 AND @i_versionkey > 0
    SET @v_new_versionkey = @i_versionkey
  ELSE IF @i_plstage > 0
    BEGIN
      SELECT @v_max_versionkey = MAX(taqversionkey)
      FROM taqversion
      WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage
          
      IF @v_max_versionkey IS NULL
        SET @v_max_versionkey = 0

      SET @v_new_versionkey = @v_max_versionkey + 1
    END
  ELSE
    SET @v_new_versionkey = NULL
        
  SELECT p.taqprojecttitle, p.plenteredcurrency, p.plapprovalcurrency, @v_new_versionkey newversionkey, 1 taqversiontype, v.*
  FROM taqproject p 
    LEFT OUTER JOIN taqversion v ON p.taqprojectkey = v.taqprojectkey AND 
      v.plstagecode = @i_plstage AND 
      v.taqversionkey = @i_versionkey
  WHERE p.taqprojectkey = @i_projectkey      

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject/taqversion tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversion TO PUBLIC
GO
