		IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = Object_id('dbo.html_to_text_from_row_new')
			AND (
				type = 'P'
				OR type = 'TR'
				)
		)
BEGIN
	DROP PROCEDURE dbo.html_to_text_from_row_new
END

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Desc: This stored procedure will pupulate commenttext column
**        replacing, html tags specified in htmltexttags table
**    Auth: Anes Hrenovica
**    Date: 10/6/2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
CREATE PROCEDURE [dbo].[html_to_text_from_row_new] @i_key INT
	,@i_print_key INT
	,@i_commenttypecode INT
	,@i_commenttypesubcode INT
	,@i_update_table_name VARCHAR(100)
	,@o_error_code INT OUTPUT
	,@o_error_desc VARCHAR(2000) OUTPUT 

AS

BEGIN
	DECLARE @DEBUG INT;

	SET @DEBUG = 0

	IF @DEBUG <> 0
		INSERT INTO DEBUG
		SELECT 'html_to_text_from_row_new'

	IF upper(@i_update_table_name) = 'BOOKCOMMENTS'
	BEGIN
		UPDATE bookcomments
		SET commenttext = dbo.udf_StripSelectedHTMLTags(commenthtml, 0)
		WHERE bookkey = @i_key
			AND printingkey = @i_print_key
			AND commenttypecode = @i_commenttypecode
			AND commenttypesubcode = @i_commenttypesubcode
	END

	IF upper(@i_update_table_name) = 'QSICOMMENTS'
	BEGIN
		UPDATE qsicomments
		SET commenttext = dbo.udf_StripSelectedHTMLTags(commenthtml, 0)
		WHERE commentkey = @i_key
			AND commenttypecode = @i_commenttypecode
			AND commenttypesubcode = @i_commenttypesubcode
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXEC
	ON dbo.html_to_text_from_row_new
	TO PUBLIC
GO

