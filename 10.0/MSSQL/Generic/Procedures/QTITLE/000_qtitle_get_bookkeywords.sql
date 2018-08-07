IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_bookkeywords]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_get_bookkeywords]
GO

/******************************************************************************
**  Name: qtitle_get_bookkeywords
**  Desc: 
**  Auth: Dustin Miller
**  Date: March 7, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_get_bookkeywords] (
	@i_bookkey INT,
	@o_error_code integer output,
	@o_error_desc varchar(2000) output)
AS
BEGIN
	DECLARE @error_var    INT
    SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT id, keyword, sortorder
	FROM bookkeywords
	WHERE bookkey = @i_bookkey
	ORDER BY sortorder asc, keyword

	SELECT @error_var = @@ERROR
	IF @error_var <> 0
	BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'error getting bookkeywords: bookkey = ' + cast(COALESCE(@i_bookkey, 0) AS VARCHAR)
	END 

END
GO

GRANT EXEC ON [dbo].[qtitle_get_bookkeywords] TO PUBLIC
GO