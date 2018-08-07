
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'sp_AppendToFile')
BEGIN
 DROP  Procedure  sp_AppendToFile
END

GO


create PROCEDURE sp_AppendToFile(@FileName varchar(255), @Text1 varchar(8000)) AS
DECLARE @FS int, @OLEResult int, @FileID int


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT

IF @OLEResult <> 0 PRINT 'Error: Scripting.FileSystemObject Failed.'
--Open a file
execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1

IF @OLEResult <> 0 PRINT 'Error: OpenTextFile Failed'

--Write Text1
execute @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @Text1

IF @OLEResult <> 0 PRINT 'Error: WriteLine Failed.'
EXECUTE @OLEResult = sp_OADestroy @FileID

EXECUTE @OLEResult = sp_OADestroy @FS

go

grant execute on sp_AppendToFile  to public

go