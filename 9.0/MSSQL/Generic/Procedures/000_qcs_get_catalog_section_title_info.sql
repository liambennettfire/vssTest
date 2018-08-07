IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_catalog_section_title_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_catalog_section_title_info]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_section_title_info]
 (@i_projectkey               integer,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

DECLARE
  @error_var    INT,
  @rowcount_var INT
          
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
   
  SELECT i.cloudproductid, COALESCE(tpt.quantity1,99999) as "order", i.bookkey AS "bookkey"
    FROM taqprojecttitle tpt, isbn i
   WHERE tpt.bookkey = i.bookkey
     AND tpt.taqprojectkey = @i_projectkey
    
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error retrieving catalog section title info (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    return   
  END 
END
GO

GRANT EXEC ON qcs_get_catalog_section_title_info TO PUBLIC
GO
