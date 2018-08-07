SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorBioUnique]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AuthorBioUnique]
GO





CREATE FUNCTION [dbo].[qweb_get_AuthorBioUnique] 
            	(@i_bookkey 	INT,
		@i_order	INT)

		

 
/*      The qweb_get_AuthorBioUnique function is used to retrieve the best Author Bio Available.  If the Author Bio is present on the Author record,
	it pulls that one.  If not, it looks on the book record, if not, it returns nothing.
	This procedure can only return plain text.
        The parameters are for the book key and author order.  


*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

	DECLARE @i_authorkey		INT
	DECLARE @v_text			VARCHAR(8000)
	DECLARE @RETURN       		VARCHAR(8000)

/*  Get the Author key		*/
	SELECT @i_authorkey = dbo.qweb_get_AuthorKey(@i_bookkey, @i_order)
	SELECT @v_text = ''

	IF @i_authorkey > 0
		BEGIN
			SELECT @v_text = CAST(biography AS VARCHAR(8000))
			FROM author
			WHERE authorkey = @i_authorkey 
 		END

/*  If it doesn't exist, get the author bio for the title	*/
	IF LEN(@v_text) > 0
		BEGIN
			SELECT @RETURN = ltrim(rtrim(@v_text)) 
		END
	ELSE IF @i_authorkey > 0
		BEGIN
			SELECT @RETURN = dbo.qweb_get_AuthorBio(@i_bookkey,1)
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN

END










GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

