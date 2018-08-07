IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qutl_get_all_admin_spec_items')
               AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qutl_get_all_admin_spec_items
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_all_admin_spec_items
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_all_admin_spec_items
**  Desc: 
**
**    Auth: Dustin Miller
**    Date: March 16, 2012
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE	@error_var    INT,
          @rowcount_var INT

	SELECT *
	FROM taqspecadmin
	ORDER BY itemcategorycode, itemcode
	
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqspecadmin'
    RETURN 
  END

GO
GRANT EXEC ON qutl_get_all_admin_spec_items TO PUBLIC
GO


