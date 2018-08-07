if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_UpdateImageData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_UpdateImageData]
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

Create PROC [dbo].[qweb_ecf_UpdateImageData]
@metakey int,
@FileName varchar(255)
AS

DECLARE @SqlStatement nvarchar(MAX),
		@i_fileexists_flag int

CREATE TABLE #BlobData(BlobData varbinary(max))

--insert blob into temp table
SET @SqlStatement =
N'
INSERT INTO #BlobData
SELECT BlobData.*
FROM OPENROWSET
(BULK ''' + @FileName + ''',
SINGLE_BLOB) BlobData'

exec xp_fileexist @FileName, @i_fileexists_flag output

If @i_fileexists_flag = 1

begin

	EXEC sp_executesql @SqlStatement

	--update main table with blob data
	UPDATE dbo.MetaFileValue
	SET data = (SELECT BlobData FROM #BlobData),
	size = (SELECT datalength(BlobData) FROM #BlobData)
	WHERE MetaFileValue.Metakey = @metakey

	DROP TABLE #BlobData

end

else

begin
	print 'Warning: ' + @FileName + ' does not exist and will not be inserted.'
end