IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'next_generic_key')
  BEGIN
    PRINT 'Dropping Procedure next_generic_key'
    DROP  Procedure  next_generic_key
  END

GO

PRINT 'Creating Procedure next_generic_key'
GO
CREATE Procedure next_generic_key
    @i_lastuser           varchar(30),
    @o_key                int         output,
    @o_error_code         int         output,
    @o_error_desc         char(200)   output 
AS

/******************************************************************************
**  File: next_generic_key.sql
**  Name: next_generic_key
**  Desc: This stored procedure is designed to get the next
**        key that is to be used in the system.  It is transactional
**        and should work correctly in all cases unless there
**        is some type of locking error. 
**
**    Return values:
** 
**    Called by:   
**              
**    Parameters:
**    Input                                      Output
**    ----------                                 -----------
**
**    Auth: James P. Weber
**    Date: 02 Jul 2003
**    
*******************************************************************************/

DECLARE @nextkey int

BEGIN TRANSACTION

if (@i_lastuser is null or @i_lastuser = '') BEGIN
  UPDATE keys SET generickey = generickey+1, 
     lastuserid = 'sp_next_generic_key', lastmaintdate = getdate()
END
ELSE BEGIN
    if ltrim(rtrim(lower(@i_lastuser))) = 'taqprojecttask' begin 
      SELECT TOP 1 @nextkey=taqtaskkey+1 FROM keys

      if @nextkey > 428683000 begin
        SET @i_lastuser = 'sp_next_generic_key'

        UPDATE keys SET generickey = generickey+1, 
           lastuserid = @i_lastuser, lastmaintdate = getdate()
      end
      else begin
        UPDATE keys SET taqtaskkey = taqtaskkey+1, 
           lastuserid = @i_lastuser, lastmaintdate = getdate()
      end
    end
    else begin
      UPDATE keys SET generickey = generickey+1, 
         lastuserid = @i_lastuser, lastmaintdate = getdate()
    end
END

if @@Error <> 0
BEGIN
  ROLLBACK TRANSACTION;
  print 'Error creating the next key.  Rollback';
  SET @o_error_code = 1;
  SET @o_error_desc = 'Error updating the generic key';
  SET @o_key = 0;
  return;
END

if ltrim(rtrim(lower(@i_lastuser))) = 'taqprojecttask' begin 
   SELECT @o_key = taqtaskkey FROM keys
end
else begin
   SELECT @o_key = generickey FROM keys
end

COMMIT TRANSACTION

GO

GRANT EXEC ON next_generic_key TO PUBLIC

GO
