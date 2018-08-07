IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_update_addtlprocessing')
BEGIN
  PRINT 'Dropping Procedure qse_get_update_addtlprocessing'
  DROP PROCEDURE  qse_get_update_addtlprocessing
END
GO

PRINT 'Creating Procedure qse_get_update_addtlprocessing'
GO

CREATE PROCEDURE qse_get_update_addtlprocessing
(
  @i_userkey		INT,
  @i_itemtype		INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @Item   VARCHAR(255),
    @Message  VARCHAR(2000),
    @ErrorValue			INT,
    @RowcountValue		INT

  SET NOCOUNT ON

  -- Get rows for this user and itemtype
  SELECT *
  FROM qse_update_addtlprocessing
  WHERE userkey = @i_userkey AND searchitemcode = @i_itemtype 
  ORDER BY searchcriteriakey,key1,key2

  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
  IF @ErrorValue <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access qse_update_addtlprocessing table'
    RETURN
  END

  IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    PRINT 'ERROR: ' + @o_error_desc

END
GO

GRANT EXEC ON qse_get_update_addtlprocessing TO PUBLIC
GO
