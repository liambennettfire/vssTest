IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_existing_bookkeywords_in_list]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_get_existing_bookkeywords_in_list]
GO

/******************************************************************************
**  Name: qtitle_get_existing_bookkeywords_in_list
**  Desc: 
**  Auth: Dustin Miller
**  Date: May 11, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_get_existing_bookkeywords_in_list] (
	@i_listkey INT,
	@i_keywords VARCHAR(MAX),
	@o_error_code INTEGER OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT)
AS
BEGIN
	DECLARE @keywords VARCHAR(MAX)
	DECLARE @keyword VARCHAR(MAX)
	DECLARE @error_var INT
    SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @bookTable TABLE
	(
		bookkey INT
	)
		
	INSERT INTO @bookTable
	SELECT bookkey
	FROM qcs_get_booklist(@i_listkey, null, null, 0)

	DECLARE @keywordTable TABLE
	(
		keyword VARCHAR(500)
	)

	SET @keywords = @i_keywords
	SET @keyword = null
	WHILE LEN(@keywords) > 0
	BEGIN
		IF PATINDEX('%,%',@keywords) > 0
		BEGIN
			SET @keyword = SUBSTRING(@keywords, 0, PATINDEX('%,%', @keywords))
			SET @keywords = SUBSTRING(@keywords, LEN(@keyword + ',') + 1, LEN(@keywords))
		END
		ELSE
		BEGIN
			SET @keyword = @keywords
			SET @keywords = NULL
		END

		INSERT INTO @keywordTable
		(keyword)
		VALUES
		(@keyword)
	END

	SELECT bookkey, keyword
	FROM bookkeywords
	WHERE bookkey IN (SELECT bookkey FROM @bookTable)
	  AND keyword IN (SELECT keyword FROM @keywordTable)

	SELECT @error_var = @@ERROR
	IF @error_var <> 0
	BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'error finding existing bookkeywords within list: listkey = ' + cast(COALESCE(@i_listkey, 0) AS VARCHAR)
		RETURN
	END

END
GO

GRANT EXEC ON [dbo].[qtitle_get_existing_bookkeywords_in_list] TO PUBLIC
GO