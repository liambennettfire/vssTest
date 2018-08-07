IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_add_bookkeywords_to_titlelist]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_add_bookkeywords_to_titlelist]
GO

/******************************************************************************
**  Name: qtitle_add_bookkeywords_to_titlelist
**  Desc: 
**  Auth: Dustin Miller
**  Date: March 16, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_add_bookkeywords_to_titlelist] (
	@i_listkey INT,
	@i_keywords VARCHAR(MAX),
	@i_userid	VARCHAR(30),
	@o_error_code INTEGER OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT)
AS
BEGIN
	DECLARE @bookkey INT
	DECLARE @sortorder INT
	DECLARE @keywords VARCHAR(MAX)
	DECLARE @keyword VARCHAR(MAX)
	DECLARE @error_var INT
    SET @o_error_code = 0
	SET @o_error_desc = ''

	BEGIN TRANSACTION keywordTran

	BEGIN TRY
		DECLARE @bookTable TABLE
		(
			bookkey INT
		)
		
		INSERT INTO @bookTable
		SELECT bookkey
		FROM qcs_get_booklist(@i_listkey, null, null, 0)

		DECLARE keyword_cursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT bookkey
		FROM @bookTable

		OPEN keyword_cursor

		FETCH NEXT FROM keyword_cursor
		INTO @bookkey

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			SET @keywords = @i_keywords
			SET @keyword = null
			WHILE LEN(@keywords) > 0
			BEGIN
				IF PATINDEX('%;%',@keywords) > 0
				BEGIN
					SET @keyword = SUBSTRING(@keywords, 0, PATINDEX('%;%', @keywords))
					SET @keywords = SUBSTRING(@keywords, LEN(@keyword + ';') + 1, LEN(@keywords))
				END
				ELSE
				BEGIN
					SET @keyword = @keywords
					SET @keywords = NULL
				END
        SELECT @keyword = dbo.qutl_remove_special_characters(@keyword)
        
				IF NOT EXISTS (SELECT * FROM bookkeywords WHERE bookkey = @bookkey AND keyword = @keyword)
				BEGIN
					SET @sortorder = 0
					SELECT TOP 1 @sortorder = sortorder
					FROM bookkeywords
					WHERE bookkey = @bookkey
					ORDER BY sortorder DESC, keyword
					SET @sortorder = @sortorder + 1

					INSERT INTO bookkeywords
					(bookkey, keyword, sortorder, lastuserid, lastmaintdate)
					VALUES
					(@bookkey, @keyword, @sortorder, @i_userid, GETDATE())

					SELECT @error_var = @@ERROR
					IF @error_var <> 0
					BEGIN
						SET @o_error_code = 1
						SET @o_error_desc = 'error adding bookkeywords: bookkey = ' + cast(COALESCE(@bookkey, 0) AS VARCHAR)
						ROLLBACK TRANSACTION keywordTran
						RETURN
					END
				END
			END

			EXEC qtitle_update_Keywords_ONIX @bookkey, @i_userid, 0, @o_error_code, @o_error_desc
			SELECT @error_var = @@ERROR
			IF @error_var <> 0 OR @o_error_code <> 0
			BEGIN
				SET @o_error_code = 1
				SET @o_error_desc = 'error adding bookkeywords: bookkey = ' + cast(COALESCE(@bookkey, 0) AS VARCHAR)
				ROLLBACK TRANSACTION keywordTran
				RETURN
			END 

			FETCH NEXT FROM keyword_cursor
			INTO @bookkey
		END

		CLOSE keyword_cursor
		DEALLOCATE keyword_cursor

		COMMIT TRANSACTION keywordTran

	END TRY
	BEGIN CATCH
		SET @o_error_code = 1
		SET @o_error_desc = 'error adding bookkeywords: bookkey = ' + cast(COALESCE(@bookkey, 0) AS VARCHAR)
		ROLLBACK TRANSACTION keywordTran
	END CATCH

END
GO

GRANT EXEC ON [dbo].[qtitle_add_bookkeywords_to_titlelist] TO PUBLIC
GO