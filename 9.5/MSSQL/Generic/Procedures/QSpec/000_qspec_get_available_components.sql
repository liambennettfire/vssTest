if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_get_available_components') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_get_available_components
GO

CREATE PROCEDURE qspec_get_available_components (  
  @i_projectkey   integer,
  @i_vendorkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qspec_get_available_components
**  Desc: This stored procedure returns available components for the given project and vendor.
**
**  Auth: Uday A. Khisty
**  Date: September 9 2014
***********************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT

  SELECT * FROM dbo.qspec_get_avail_components(@i_projectkey, @i_vendorkey)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspeccategory/taqversionrelatedcomponents_view tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qspec_get_available_components TO PUBLIC
GO
