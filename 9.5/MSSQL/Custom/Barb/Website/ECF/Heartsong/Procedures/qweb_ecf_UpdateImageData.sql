IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_UpdateImageData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_UpdateImageData]
go

Create PROC [dbo].[qweb_ecf_UpdateImageData]
@metakey int,
@FileName varchar(255)
AS

DECLARE @SqlStatement nvarchar(MAX),
		@i_fileexists_flag int,
    @v_blobsize int
    
CREATE TABLE #BlobData(BlobData varbinary(max))

--insert blob into temp table
SET @SqlStatement =
N'
INSERT INTO #BlobData
SELECT BlobData.*
FROM OPENROWSET
(BULK ''' + replace(@FileName,'''','''''') + ''',
SINGLE_BLOB) BlobData'

exec xp_fileexist @FileName, @i_fileexists_flag output

If @i_fileexists_flag = 1

begin

	EXEC sp_executesql @SqlStatement

  SELECT @v_blobsize = datalength(BlobData) FROM #BlobData
  
  if @v_blobsize > 0 begin
	  --update main table with blob data
	  UPDATE dbo.MetaFileValue
	  SET data = (SELECT BlobData FROM #BlobData),
	  size = (SELECT datalength(BlobData) FROM #BlobData)
	  WHERE MetaFileValue.Metakey = @metakey
  end
  
	DROP TABLE #BlobData

end

else

begin
	print 'Warning: ' + @FileName + ' does not exist and will not be inserted.'
end