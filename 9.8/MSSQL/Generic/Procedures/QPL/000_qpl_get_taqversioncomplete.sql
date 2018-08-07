if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversioncomplete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncomplete
GO

CREATE PROCEDURE qpl_get_taqversioncomplete
  (@i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qpl_get_taqversioncomplete
**  Desc: This stored procedure returns version complete information from taqversioncomplete table.
**
**  Auth: Kate
**  Date: 5 January 2011
************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT * FROM taqversioncomplete
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_versionkey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversioncomplete table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

GO

GRANT EXEC ON qpl_get_taqversioncomplete TO PUBLIC
GO


