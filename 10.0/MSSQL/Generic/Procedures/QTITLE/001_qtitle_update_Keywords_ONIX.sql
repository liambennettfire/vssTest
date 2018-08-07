IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_update_Keywords_ONIX]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_update_Keywords_ONIX]
GO

/******************************************************************************
**  Name: qtitle_update_Keywords_ONIX
**  Desc: 
**  Auth: Dustin Miller
**  Date: March 7, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  08/09/2016   UK		     Case 39731
**	12/12/2016	 DM			 Case 42175
**  04/18/2018   JH			 TM-125, TM-401
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_update_Keywords_ONIX] (
	@i_bookkey INT,
	@i_userid  VARCHAR(30),
	@o_updateind tinyint output,
	@o_error_code integer output,
	@o_error_desc varchar(2000) output)
AS
BEGIN
	DECLARE @id INT,
			@maxkeywordlen INT,
			@keyword VARCHAR(MAX),
			@sortorder INT,
			@keywordconcat VARCHAR(MAX),
			@misckey INT,
			@misctext VARCHAR(4000),
			@elofieldid INT,
			@error_var INT,
		    @v_searchfield VARCHAR(MAX)
    SET @o_error_code = 0
	SET @o_error_desc = ''

	SET @o_updateind = 0
	SET @keywordconcat = ''

	SET @maxkeywordlen = 500
	SELECT @maxkeywordlen = CAST(numericdesc1 AS INT)
	FROM gentables
	WHERE tableid = 684
	  AND qsicode = 1

	DECLARE keyword_cursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT id, keyword, sortorder
	FROM bookkeywords
	WHERE bookkey = @i_bookkey
	ORDER BY sortorder asc, keyword

	OPEN keyword_cursor

	FETCH NEXT FROM keyword_cursor
	INTO @id, @keyword, @sortorder

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		SELECT @keyword = [dbo].qutl_remove_special_characters(@keyword)
		IF LEN(@keywordconcat) > 0
		BEGIN
			SET @keywordconcat = @keywordconcat + ';'
		END
		SET @keywordconcat = @keywordconcat + LTRIM(RTRIM(@keyword))

		FETCH NEXT FROM keyword_cursor
		INTO @id, @keyword, @sortorder
	END

	CLOSE keyword_cursor
	DEALLOCATE keyword_cursor

	IF LEN(@keywordconcat) > @maxkeywordlen
	BEGIN
		SET @keywordconcat = SUBSTRING(@keywordconcat, 0, @maxkeywordlen)

		UPDATE bookdetail
		SET keywordstruncatedind = 1
		WHERE bookkey = @i_bookkey
	END
	ELSE BEGIN
		UPDATE bookdetail
		SET keywordstruncatedind = 0
		WHERE bookkey = @i_bookkey
	END

	SELECT @elofieldid = datacode
	FROM gentables
	WHERE tableid = 560
	  AND eloquencefieldtag = 'DPIDXBIZKEYWORDS'
    
	SELECT @misckey = misckey
	FROM bookmiscitems
	WHERE eloquencefieldidcode = @elofieldid
  
  IF @@ROWCOUNT = 0
    RETURN

	IF EXISTS(SELECT * FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @misckey)
	BEGIN
		SELECT @misctext = textvalue
		FROM bookmisc
		WHERE bookkey = @i_bookkey
		  AND misckey = @misckey

		IF @misctext = @keywordconcat
		BEGIN
			SET @o_updateind = 0
		END
		ELSE BEGIN
			SET @o_updateind = 1

			DELETE FROM bookmisc
			WHERE bookkey = @i_bookkey AND misckey = @misckey

			SELECT @error_var = @@ERROR
			IF @error_var <> 0
			BEGIN
				SET @o_error_code = 1
				SET @o_error_desc = 'error updating keywords onix: bookkey = ' + cast(COALESCE(@i_bookkey, 0) AS VARCHAR)
				RETURN
			END 
		END
	END
	ELSE BEGIN
		SET @o_updateind = 1
	END

	IF @o_updateind = 1
	BEGIN
		INSERT INTO bookmisc
		(bookkey, misckey, textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
		VALUES
		(@i_bookkey, @misckey, @keywordconcat, @i_userid, GETDATE(), 1)

		SELECT @error_var = @@ERROR
		IF @error_var <> 0
		BEGIN
			SET @o_error_code = 1
			SET @o_error_desc = 'error updating keywords onix: bookkey = ' + cast(COALESCE(@i_bookkey, 0) AS VARCHAR)
			RETURN
		END
	END
END
GO

GRANT EXEC ON [dbo].[qtitle_update_Keywords_ONIX] TO PUBLIC
GO