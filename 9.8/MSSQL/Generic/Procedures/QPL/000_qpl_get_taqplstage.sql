if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqplstage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqplstage
GO

CREATE PROCEDURE qpl_get_taqplstage (  
  @i_projectkey integer,
  @i_plstage    integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_get_taqplstage
**  Desc: This stored procedure returns the given taqplstage record.
**
**  Auth: Kate
**  Date: November 12 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT * FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqplstage table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqplstage TO PUBLIC
GO
