if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_related_projects_for_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_related_projects_for_format
GO

CREATE PROCEDURE qpl_get_related_projects_for_format
  (@i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************************
**  Name: qpl_get_related_projects_for_format
**  Desc: This stored procedure returns all related projects for the given format.
**
**  Auth: Kate
**  Date: Octover 31 2014
***********************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT r.taqversionformatkey formatkey, r.relatedprojectkey, p.taqprojecttitle
  FROM taqversionformatrelatedproject r, taqproject p
  WHERE r.relatedprojectkey = p.taqprojectkey 
    AND r.taqversionformatkey = @i_formatkey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatrelatedproject (taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

GO

GRANT EXEC ON qpl_get_related_projects_for_format TO PUBLIC
GO


