if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Update_LastBookkey_Processed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Update_LastBookkey_Processed
GO
CREATE PROCEDURE dbo.WK_Update_LastBookkey_Processed
@Last_Bookkey_Processed int
AS
BEGIN
UPDATE [dbo].[WK_lastTitle_processed]
SET [Last_Bookkey_Processed] = @Last_Bookkey_Processed,
changeddate = getdate()
END
