SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[export_MBI]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[export_MBI]
GO


CREATE PROCEDURE export_MBI(@userid	VARCHAR(30))
AS

DECLARE @bookkey		INT
DECLARE @cstatus		INT
DECLARE @running_title_count	INT
DECLARE @total_title_count	INT
DECLARE @o_errorcode		INT
DECLARE @o_errormsg		VARCHAR(1000)

BEGIN
	TRUNCATE TABLE export_title
	TRUNCATE TABLE export_author
	TRUNCATE TABLE export_subject
	TRUNCATE TABLE export_comment
	TRUNCATE TABLE export_assoctitle


	SET @running_title_count = 0
	SET @total_title_count = 0
	SET @o_errorcode = 0
	SET @o_errormsg = ''

	SELECT @total_title_count = COUNT(*)
	FROM mbi_orgentry1_view

	DECLARE c_export INSENSITIVE CURSOR FOR
		SELECT bookkey
		FROM mbi_orgentry1_view
	FOR READ ONLY

	OPEN c_export

	FETCH NEXT FROM c_export
	INTO @bookkey

	SELECT @cstatus = @@FETCH_STATUS

	WHILE @cstatus <>-1
		BEGIN
			IF @cstatus <>-2
				BEGIN
					SET @running_title_count = @running_title_count+1

					EXECUTE get_title_export @bookkey, @o_errorcode OUT, @o_errormsg OUT			


					EXECUTE get_author_export @bookkey, @o_errorcode OUT, @o_errormsg OUT			

	
					EXECUTE get_subject_export @bookkey, @o_errorcode OUT, @o_errormsg OUT

					EXECUTE get_comment_export @bookkey, @o_errorcode OUT, @o_errormsg OUT

					EXECUTE get_assoctitle_export @bookkey,@o_errorcode OUT,@o_errormsg	OUT
					
					PRINT 'Row processed	:'+ CONVERT(CHAR(10),@running_title_count)
				END

			

			FETCH NEXT FROM c_export
			INTO @bookkey

			SELECT @cstatus = @@FETCH_STATUS
		
			

		END

CLOSE c_export
DEALLOCATE c_export

END


GRANT ALL ON export_MBI TO PUBLIC
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

