IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID(N'dbo.[TMDEMO_keywords_web_process_procedure]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.[TMDEMO_keywords_web_process_procedure]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************************************
**  Name: [TMDEMO_keywords_web_process_procedure]
**  Desc: 
** 
**  Auth: UNKNOWN
**  Date: September 12, 2016
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:       Author:     Description:
**  ----------  ------      ---------------------------------------------------------------------------------
**  09/12/2017	JHess		Found that when 979 EAN values are allowed, isbn aren't. This was causing issues. 
**							Altered to pull from ean instead. Everything seems to have been fixed in the 
**							consuming TMWebProcess now. - 47242
*************************************************************************************************************/

CREATE PROCEDURE [dbo].[TMDEMO_keywords_web_process_procedure] (@i_instancekey INT,
@i_jobkey INT,
@o_error_code INTEGER OUTPUT,
@o_error_desc VARCHAR(2000) OUTPUT)

AS
	DECLARE	@sql VARCHAR(MAX),
			@tableName VARCHAR(255),
			@dateRun VARCHAR(50),
			@dataCode INT,
			@dataSubCode INT,
			@bookKey INT,
			@separator VARCHAR(1),
			@jobdesc VARCHAR(2000),
			@jobdescshort VARCHAR(255),
			@qsibatchkey INT,
			@i_JobTypeCode INT,
			@lastUserID VARCHAR(255),
			@v_error INT,
			@v_error_desc VARCHAR(2000),
			@miscKey INT,
			@qsijobkey INT,
			@started_job INT,
			@backupData CHAR(1)

	BEGIN
		---------------------------------------------------------
		--	Variable setting section
		---------------------------------------------------------
		SET @o_error_code = 1
		SET @backupData = 'N'
		SET @lastUserID = (SELECT TOP 1
			lastuserid
		FROM dbo.tmdemo_keywords_web_process)
		SET @jobdesc = 'Web Keywords Load'
		SET @jobdescshort = 'Web Keywords Load'
		SET @qsijobkey = @i_jobkey
		SET @separator = ';'
		SET @tableName = 'bookKeywords_'
		SET @dateRun = (REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), GETDATE(), 120) + CONVERT(NVARCHAR(MAX), GETDATE(), 8), '-', ''), ' ', '_'), ':', ''))

		SELECT
		TOP 1
			@i_JobTypeCode = datacode
		FROM gentables
		WHERE tableid = 543
		AND datadesc = @jobdesc


		SELECT
			@miscKey = misckey
		FROM bookmiscitems
		WHERE miscName = 'Keywords ONIX Statement'

		---------------------------------------------------------
		--	Write out start message
		---------------------------------------------------------	
		IF COALESCE(@qsijobkey, 0) = 0
		BEGIN
			EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT,
												@qsijobkey OUTPUT,
												@i_JobTypeCode,
												0,
												@jobdesc,
												@jobdescshort,
												@lastUserID,
												0,
												0,
												0,
												1,
												'Web Keywords Load Job Started',
												'Job Started',
												@v_error OUTPUT,
												@v_error_desc OUTPUT
			SET @started_job = 1
		END
		ELSE
		BEGIN
			SELECT
			TOP 1
				@qsibatchkey = qsibatchkey
			FROM qsijob
			WHERE qsijobkey = @i_jobkey
		END

		---------------------------------------------------------
		--	See if we have data
		---------------------------------------------------------	
		IF NOT EXISTS (SELECT
				1
			FROM dbo.tmdemo_keywords_web_process
			WHERE processinstancekey = @i_instancekey)
		BEGIN
			EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT,
												@qsijobkey,
												@i_JobTypeCode,
												0,
												@jobdesc,
												@jobdescshort,
												@lastUserID,
												0,
												0,
												0,
												2,
												'No records have been uploaded to the TMDEMO_keywords_web_process table',
												'No Rows Exist',
												@v_error OUTPUT,
												@v_error_desc OUTPUT
			SET @o_error_code = 1
			SET @o_error_desc = 'Errors exist, no records were in table'
			RETURN

		END

		---------------------------------------------------------
		--	See if we have dupes
		---------------------------------------------------------	
		IF EXISTS (SELECT
				isbn,
				COUNT(1)
			FROM dbo.tmdemo_keywords_web_process
			GROUP BY isbn
			HAVING COUNT(1) > 1)
		BEGIN
			EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT,
												@qsijobkey,
												@i_JobTypeCode,
												0,
												@jobdesc,
												@jobdescshort,
												@lastUserID,
												0,
												0,
												0,
												2,
												'Duplicate records have been uploaded to the TMDEMO_keywords_web_process table',
												'Duplicate Rows Exist',
												@v_error OUTPUT,
												@v_error_desc OUTPUT
			SET @o_error_code = 1
			SET @o_error_desc = 'Errors exist, deuplicate records in table'

			--Truncate this because they won't be able to run this again until we truncate
			--Otherwise they'll need to get someone with database access to clear it out
			DELETE dbo.tmdemo_keywords_web_process
			RETURN

		END


		---------------------------------------------------------
		--	Get the book key
		---------------------------------------------------------	
		UPDATE tmp
		SET tmp.bookkey = bk.bookkey
		FROM dbo.tmdemo_keywords_web_process tmp
		INNER JOIN isbn bk
			ON REPLACE(tmp.isbn, '-', '') = bk.ean13


		---------------------------------------------------------
		--	Get related titles
		---------------------------------------------------------	
		INSERT INTO dbo.tmdemo_keywords_web_process (bookkey,
		isbn,
		title,
		keywords,
		lastuserid,
		lastmaintdate,
		processinstancekey)
			SELECT
				bookkey,
				ean,
				title,
				keywords,
				lastuserid,
				lastmaintdate,
				processinstancekey
			FROM (SELECT
				ad.bookkey,
				i.ean,
				ad.title,
				kw.keywords,
				kw.lastuserid,
				kw.lastmaintdate,
				kw.processinstancekey,
				ROW_NUMBER() OVER (PARTITION BY ad.bookkey ORDER BY kw.lastmaintdate) rnk
			FROM dbo.tmdemo_keywords_web_process kw
			INNER JOIN book b
				ON kw.bookkey = b.bookkey
			INNER JOIN book ad
				ON b.workkey = ad.workkey
				AND ad.bookkey != b.bookkey
			INNER JOIN isbn i
				ON ad.bookkey = i.bookkey
			WHERE NOT EXISTS (SELECT
				1
			FROM dbo.tmdemo_keywords_web_process chk
			WHERE chk.bookkey = ad.bookkey)) dd
			WHERE rnk = 1


		---------------------------------------------------------
		--	Undelimit the data
		---------------------------------------------------------	
		DECLARE @undelimitedData TABLE (
			bookkey INT,
			value VARCHAR(500),
			sortOrder INT,
			lastuserid VARCHAR(30),
			dup INT
		)

		;
		WITH CreateTableFromList
		AS (SELECT
			1 AS n,
			bookkey,
			lastuserid,
			CAST(LEFT(CAST(keywords AS NVARCHAR(MAX)), ISNULL(NULLIF(CHARINDEX(@separator, CAST(keywords AS NVARCHAR(MAX))), 0), 1001) - 1) AS NVARCHAR(1000)) AS value,
			CAST(LTRIM(SUBSTRING(CAST(keywords AS NVARCHAR(MAX)), NULLIF(CHARINDEX(@separator, CAST(keywords AS NVARCHAR(MAX))), 0) + 1, 100000)) AS NVARCHAR(MAX)) AS RemainingValues
		FROM tmdemo_keywords_web_process x
		UNION ALL
		SELECT
			n + 1,
			bookkey,
			lastuserid,
			CAST(LEFT(RemainingValues, ISNULL(NULLIF(CHARINDEX(@separator, RemainingValues), 0), 1001) - 1) AS NVARCHAR(1000)),
			CAST(LTRIM(SUBSTRING(RemainingValues, NULLIF(CHARINDEX(@separator, RemainingValues), 0) + LEN(@separator), 100000)) AS NVARCHAR(MAX))
		FROM CreateTableFromList
		WHERE LEN(RemainingValues) > 0)
		INSERT INTO @undelimitedData (bookkey, value, sortOrder, lastuserid, dup)
			SELECT
				bookkey,
				value,
				n AS sortOrder,
				lastuserid,
				ROW_NUMBER() OVER (PARTITION BY bookkey, value ORDER BY n) dup --find dupes
			FROM CreateTableFromList
			WHERE NULLIF(value, '') IS NOT NULL
			OPTION (MAXRECURSION 0)


		---------------------------------------------------------
		--	Back up keywords that we're going to delete
		--	Format is bookKeywords_YYYYMMDD_hhmmssms
		---------------------------------------------------------	
		IF @backupData = 'Y'
		BEGIN
			SET @sql = '
		SELECT 
			bk.*
		INTO 
			' + @tableName + @dateRun + '
		FROM
			bookKeywords bk
		INNER JOIN TMDEMO_keywords_web_process tmp
			ON bk.bookKey = tmp.bookkey '

			EXEC (@sql)
		END



		---------------------------------------------------------
		--	Delete old keywords
		---------------------------------------------------------	
		DELETE bc
			FROM bookkeywords bc
			INNER JOIN dbo.tmdemo_keywords_web_process tmp
				ON bc.bookkey = tmp.bookkey


		---------------------------------------------------------
		--	Insert new keywords
		---------------------------------------------------------	
		INSERT INTO bookkeywords (bookkey,
		keyword,
		sortOrder,
		lastuserid,
		lastmaintdate)
			SELECT
				bookkey,
				value,
				sortOrder,
				lastuserid,
				GETDATE() AS lastmaintdate
			FROM @undelimitedData
			WHERE dup = 1


		---------------------------------------------------------
		--	Update the onix string
		---------------------------------------------------------
		--Compatibility mode on this db is too low for a merge
		--MERGE INTO bookmisc bm
		--USING TMDEMO_keywords_web_process kw 
		--ON bm.bookkey = kw.bookkey
		--	AND bm.misckey = @miscKey
		--WHEN MATCHED THEN 
		--UPDATE 
		--	SET
		--		bm.textvalue = kw.keywords,
		--		bm.lastuserid = @lastUserID,
		--		bm.lastmaintdate = GETDATE(),
		--		bm.sendtoeloquenceind = 1
		--WHEN NOT MATCHED THEN 
		--INSERT
		--	(bookkey,misckey,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
		--VALUES
		--	(kw.bookkey,@miscKey,kw.keywords,@lastUserID,GETDATE(),1);

		UPDATE bm
		SET	bm.textvalue = kw.keywords,
			bm.lastuserid = @lastUserID,
			bm.lastmaintdate = GETDATE(),
			bm.sendtoeloquenceind = 1
		FROM bookmisc bm
		INNER JOIN dbo.tmdemo_keywords_web_process kw
			ON bm.bookkey = kw.bookkey
		WHERE bm.misckey = @miscKey

		INSERT INTO bookmisc (bookkey,
		misckey,
		textvalue,
		lastuserid,
		lastmaintdate,
		sendtoeloquenceind)
			SELECT
				kw.bookkey,
				@miscKey,
				kw.keywords,
				@lastUserID,
				GETDATE(),
				1 AS sendToEloquence
			FROM dbo.tmdemo_keywords_web_process kw
			WHERE NOT EXISTS (SELECT
				1
			FROM bookmisc bm
			WHERE kw.bookkey = bm.bookkey
			AND bm.misckey = @miscKey)
		---------------------------------------------------------
		--	Update title history so this gets sent
		---------------------------------------------------------	
		DECLARE @bookComment NVARCHAR(MAX)
		DECLARE csr_ediUpdate CURSOR FOR
		SELECT
			bookkey,
			CAST(Keywords AS NVARCHAR(MAX)) commentString
		FROM tmdemo_keywords_web_process


		OPEN csr_ediUpdate
		FETCH NEXT FROM csr_ediUpdate INTO @bookKey, @bookComment
		WHILE @@fetch_status = 0
		BEGIN
			EXEC [dbo].[qtitle_update_titlehistory]	@i_tablename = 'bookKeywords', -- varchar(100)
													@i_columnname = 'keyword', -- varchar(100)
													@i_bookkey = @bookKey, -- int
													@i_printingkey = 1, -- int
													@i_datetypecode = 0, -- int
													@i_currentstringvalue = @bookComment, -- varchar(255)
													@i_transtype = 'INSERT', -- varchar(25)
													@i_userid = 'QSIADMIN', -- varchar(30)
													@i_historyorder = 1, -- int
													@i_fielddescdetail = 'KeyWord', -- varchar(120)
													@o_error_code = 0, -- int
													@o_error_desc = '' -- varchar(2000)
			FETCH NEXT FROM csr_ediUpdate INTO @bookKey, @bookComment
		END
		CLOSE csr_ediUpdate
		DEALLOCATE csr_ediUpdate

		--DELETE dbo.TMDEMO_keywords_web_process

		IF @started_job = 1
		BEGIN
			EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
												@qsijobkey,
												@i_JobTypeCode,
												0,
												@jobdesc,
												@jobdescshort,
												@lastuserid,
												0,
												0,
												0,
												6,
												'Completed Successfully',
												'Success',
												@v_error OUTPUT,
												@v_error_desc OUTPUT
		END

	END

--GRANT ALL ON dbo.TMDEMO_keywords_web_process_procedure TO PUBLIC
--GRANT ALL ON dbo.TMDEMO_keywords_web_process TO PUBLIC


--SELECT * FROM TMDEMO_keywords_web_process