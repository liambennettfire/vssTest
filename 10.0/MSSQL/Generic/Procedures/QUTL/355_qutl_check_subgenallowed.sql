PRINT 'STORED PROCEDURE : qutl_check_subgenallowed'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_subgenallowed')
  BEGIN
    DROP PROCEDURE  qutl_check_subgenallowed
  END
GO


CREATE PROCEDURE qutl_check_subgenallowed
(
  @i_tableid        INT,
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

BEGIN
  
  DECLARE 
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET NOCOUNT ON

  SELECT COUNT(*) numsubrows
  FROM subgentables
  WHERE tableid = @i_tableid
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'No data found - gentablesdesc tableid=' + cast(@i_tableid AS VARCHAR)
  END     

END
GO

GRANT EXEC ON qutl_check_subgenallowed TO PUBLIC
GO
