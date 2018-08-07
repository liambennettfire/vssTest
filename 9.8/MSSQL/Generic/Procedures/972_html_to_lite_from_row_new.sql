	IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = Object_id('dbo.html_to_lite_from_row_new')
			AND (
				type = 'P'
				OR type = 'TR'
				)
		)
BEGIN
	DROP PROCEDURE dbo.html_to_lite_from_row_new
END

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Desc: This stored procedure will pupulate htmllite column
**        replacing, remaining or removing html tags specified in htmllitetags table
**    Auth: Anes Hrenovica
**    Date: 10/6/2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
CREATE PROCEDURE [dbo].[html_to_lite_from_row_new] @i_key INT
	,@i_print_key INT
	,@i_commenttypecode INT
	,@i_commenttypesubcode INT
	,@i_update_table_name VARCHAR(100)
	,@i_commentstyle INT
	,@o_error_code INT OUTPUT
	,@o_error_desc VARCHAR(2000) OUTPUT 

AS

BEGIN
	DECLARE @DEBUG INT,
			@v_clientOption_41 INT,
			@v_test NVARCHAR(MAX)

	SET @DEBUG = 0

	SELECT @v_clientOption_41 = optionvalue
	FROM clientoptions
	WHERE optionid = 41

	IF @DEBUG <> 0
		INSERT INTO DEBUG
		SELECT 'html_to_lite_from_row_new'

	IF upper(@i_update_table_name) = 'BOOKCOMMENTS'
	BEGIN
		UPDATE bookcomments
		SET commenthtmllite = dbo.udf_StripSelectedHTMLTags(commenthtml, 1)
		WHERE bookkey = @i_key
			AND printingkey = @i_print_key
			AND commenttypecode = @i_commenttypecode
			AND commenttypesubcode = @i_commenttypesubcode
	END

	IF upper(@i_update_table_name) = 'QSICOMMENTS'
	BEGIN
		UPDATE qsicomments
		SET commenthtmllite = dbo.udf_StripSelectedHTMLTags(commenthtml, 1)
		WHERE commentkey = @i_key
			AND commenttypecode = @i_commenttypecode
			AND commenttypesubcode = @i_commenttypesubcode
	END

	IF upper(@i_update_table_name) = 'TEMP_BLOB'
	BEGIN
		UPDATE temp_blob
		SET htmldata = dbo.udf_StripSelectedHTMLTags(htmldata, 1)
		FROM temp_blob
		WHERE keyid = @i_key
	END

	-- UK - 23063 - If ClientOptions(41)/AllowFullHTMLPaste = 0 then copy htmllite to htmlcomments otherwise do nothing.
	IF @v_clientOption_41 = 0
	BEGIN
		IF upper(@i_update_table_name) = 'BOOKCOMMENTS'
		BEGIN
			SELECT @v_test = commenthtmllite
			FROM bookcomments
			WHERE bookkey = @i_key
				AND printingkey = @i_print_key
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode

			UPDATE bookcomments
			SET commenthtml = @v_test
			WHERE bookkey = @i_key
				AND printingkey = @i_print_key
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END

		IF upper(@i_update_table_name) = 'QSICOMMENTS'
		BEGIN
			SELECT @v_test = commenthtmllite
			FROM qsicomments
			WHERE commentkey = @i_key
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode

			UPDATE qsicomments
			SET commenthtml = @v_test
			WHERE commentkey = @i_key
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXEC
	ON dbo.html_to_lite_from_row_new
	TO PUBLIC
GO

