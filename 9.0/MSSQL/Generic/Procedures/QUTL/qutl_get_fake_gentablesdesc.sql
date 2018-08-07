PRINT 'STORED PROCEDURE : qutl_get_fake_gentablesdesc'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_fake_gentablesdesc')
	BEGIN
		PRINT 'Dropping Procedure qutl_get_fake_gentablesdesc'
		DROP PROCEDURE  qutl_get_fake_gentablesdesc
	END

GO


PRINT 'Creating Procedure qutl_get_fake_gentablesdesc'
GO

CREATE PROCEDURE qutl_get_fake_gentablesdesc
(
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

BEGIN

  SET NOCOUNT ON
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT tableid, tabledesc, tabledesclong, location, filterorglevelkey 
  FROM gentablesdesc
  WHERE location <> 'gentables' AND activeind = 1 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'No data found - active fake gentablesdesc'
  END 
  
END
GO

GRANT EXEC ON qutl_get_fake_gentablesdesc TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qutl_get_fake_gentablesdesc'
GO
