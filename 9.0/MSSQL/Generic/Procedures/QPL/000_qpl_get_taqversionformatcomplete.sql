if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionformatcomplete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionformatcomplete
GO

CREATE PROCEDURE qpl_get_taqversionformatcomplete
  (@i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************************
**  Name: qpl_get_taqversionformatcomplete
**  Desc: This stored procedure returns format complete information from taqversionformatcomplete table.
**
**  Auth: Kate
**  Date: 5 January 2011
***********************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT * FROM taqversionformatcomplete
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_versionkey AND
      taqprojectformatkey = @i_formatkey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatcomplete table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

GO

GRANT EXEC ON qpl_get_taqversionformatcomplete TO PUBLIC
GO


