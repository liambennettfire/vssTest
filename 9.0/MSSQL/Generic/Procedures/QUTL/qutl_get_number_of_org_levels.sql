IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_number_of_org_levels')
BEGIN
  PRINT 'Dropping Procedure qutl_get_number_of_org_levels'
  DROP  Procedure  dbo.qutl_get_number_of_org_levels
END
GO

PRINT 'Creating Procedure qutl_get_number_of_org_levels'
GO

CREATE PROCEDURE dbo.qutl_get_number_of_org_levels
 (@o_max_org_level_key integer output,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_number_of_org_levels
**  Desc: This stored procedure returns the number of org levels that
**        have been set up for this installation of the software.
**
**    Auth: James P. Weber
**    Date: 18 Oct 2004
*******************************************************************************/
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_max_org_level_key = 0
  SET @o_error_desc = ''

  SELECT @o_max_org_level_key = MAX(orglevelkey)
  FROM orglevel

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: Nor orgs set up.' 
  END 
GO

GRANT EXEC ON dbo.qutl_get_number_of_org_levels TO PUBLIC
GO
