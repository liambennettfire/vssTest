/******************************************************************************
**  Name: imp_300014160001
**  Desc: IKE KeyWords Ingestion
**  Auth: Chris Adler     
**  Date: 6/7/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
** 6/7/2016		 Cadler      original
*******************************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[imp_300014160001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[imp_300014160001]
GO

CREATE PROCEDURE [dbo].[imp_300014160001] 
	@i_batch int, 
	@i_row int , 
	@i_dmlkey bigint, 
	@i_titlekeyset varchar(500),
	@i_contactkeyset varchar(500),
	@i_templatekey int,
	@i_elementseq int,
	@i_level int,
	@i_userid varchar(50),
	@i_newtitleind int,
	@i_newcontactind int,
	@o_writehistoryind int output
AS
DECLARE
	@v_bookkey INT,
	@v_KeyWords VARCHAR(max),
	@v_keyword VARCHAR(500),
	@v_diffCount INT,
	@v_errcode INT,
	@v_errmsg VARCHAR(4000),
	@v_elementdesc VARCHAR(4000),
	@v_elementkey BIGINT
	
DECLARE @Keywords TABLE (
	Keyword VARCHAR(500),
	SortOrder INT IDENTITY(1,1) PRIMARY KEY)

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'KeyWords updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
    
	-- Get Keywords
	SELECT
		@v_KeyWords = LTRIM(RTRIM(originalvalue)),
		@v_elementkey = elementkey
	FROM imp_batch_detail
	WHERE batchkey = @i_batch
	AND row_id = @i_row
	AND elementseq = @i_elementseq
	AND elementkey = 100014160

	-- Standardize regular delimiters
	SET @v_KeyWords=REPLACE(REPLACE(@v_KeyWords,';','|'),',','|')

	-- Parse individual keywords out of a potential list
	WHILE LEN(@v_KeyWords) > 0
	BEGIN
		IF PATINDEX('%|%',@v_KeyWords) > 0
		BEGIN
			SET @v_keyword = SUBSTRING(@v_KeyWords, 0, PATINDEX('%|%', @v_KeyWords))
			SET @v_KeyWords = SUBSTRING(@v_KeyWords, LEN(@v_keyword + '|') + 1, LEN(@v_KeyWords))
			
			SELECT @v_diffCount = COUNT(*) FROM @Keywords WHERE keyword=@v_keyword
			IF @v_diffCount=0 AND @v_keyword!=''
			BEGIN
				INSERT INTO @Keywords SELECT @v_keyword
			END
		END
		ELSE
		BEGIN
			SET @v_keyword = @v_KeyWords
			SET @v_KeyWords = NULL

			SELECT @v_diffCount = COUNT(*) FROM @Keywords WHERE keyword=@v_keyword
			IF @v_diffCount=0 AND @v_keyword!=''
			BEGIN
				INSERT INTO @Keywords SELECT @v_keyword
			END
		END
	END
	
	-- Count up the diffrences in Keywords we currently have and Keywords we do not
	SELECT @v_diffCount=COUNT(*)
	FROM @Keywords kw
	FULL OUTER JOIN (
		SELECT keyword
		FROM bookkeywords
		WHERE bookkey=@v_bookkey
	) bkw
	ON bkw.keyword=kw.Keyword
	WHERE kw.Keyword IS NULL 
	OR bkw.keyword IS NULL

	-- Update if there are differences
	IF @v_diffCount!=0
	BEGIN
		-- Update they Keywords
		DELETE FROM bookkeywords WHERE bookkey=@v_bookkey
		INSERT INTO bookkeywords 
		SELECT @v_bookkey, keyword, SortOrder, 'QSIDBA', GETDATE()
		FROM @Keywords

		EXEC qtitle_update_Keywords_ONIX @v_bookkey, 'QSIDBA', @o_writehistoryind, @v_errcode, @v_errmsg
	END

	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3
END
