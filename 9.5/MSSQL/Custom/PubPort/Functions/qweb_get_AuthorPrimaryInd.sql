SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorPrimaryInd]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AuthorPrimaryInd]
GO





CREATE FUNCTION dbo.qweb_get_AuthorPrimaryInd
		(@i_bookkey		INT,
		@i_order		INT)

/*  	The qweb_get_AuthorPrimaryInd function returns a Y/N (or yes/no) value depending upon whether or not a specfic author
	has the primary indicator set on the book author table.
	if the author doesn't exist, then set the primary indicator to null
	The parameters for the function are the book key and author sort order number
*/

RETURNS	VARCHAR(1)

AS

BEGIN 
	DECLARE @i_primaryind 	INT
	DECLARE @i_authorkey 	INT
	DECLARE @v_desc		VARCHAR(1)
	DECLARE @RETURN		VARCHAR(1)

	SELECT @i_primaryind = primaryind, @i_authorkey=authorkey
	FROM bookauthor
	WHERE bookkey = @i_bookkey
		AND sortorder = @i_order

	IF @i_primaryind = 1
		BEGIN
			SELECT @v_desc = 'Y'
		END

	ELSE
		BEGIN
			IF @i_authorkey > 0
				BEGIN
					SELECT @v_desc = 'N'
				END
			ELSE
				BEGIN
					SELECT @v_desc = ''
				END
		END


	SELECT @RETURN = @v_desc


RETURN @RETURN

END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

