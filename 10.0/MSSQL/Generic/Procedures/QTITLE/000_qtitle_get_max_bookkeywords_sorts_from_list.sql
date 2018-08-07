IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_max_bookkeywords_sorts_from_list]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_get_max_bookkeywords_sorts_from_list]
GO

/******************************************************************************
**  Name: qtitle_get_max_bookkeywords_sorts_from_list
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

CREATE PROCEDURE [dbo].[qtitle_get_max_bookkeywords_sorts_from_list] (
	@i_listkey INT,
	@o_error_code INTEGER OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT)
AS
BEGIN
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

	SELECT bk.bookkey, bk.sortorder
	FROM bookkeywords bk
    WHERE bk.bookkey IN (SELECT bookkey FROM @bookTable)
	  AND bk.sortorder = (SELECT MAX(sortorder) FROM bookkeywords bki WHERE bki.bookkey = bk.bookkey)

	SELECT @error_var = @@ERROR
	IF @error_var <> 0
	BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'error finding max sortorders from bookkeywords with listkey = ' + cast(COALESCE(@i_listkey, 0) AS VARCHAR)
		RETURN
	END

END
GO

GRANT EXEC ON [dbo].[qtitle_get_max_bookkeywords_sorts_from_list] TO PUBLIC
GO