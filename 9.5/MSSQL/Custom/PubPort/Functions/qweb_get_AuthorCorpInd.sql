SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorCorpInd]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AuthorCorpInd]
GO





--drop FUNCTION dbo.qweb_get_AuthorCorpInd
--go

CREATE FUNCTION dbo.qweb_get_AuthorCorpInd 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (1)

/*  The purpose of the qweb_get_AuthorCorpInd function is to return a specific author name 
    formatted correctly for the Borders e-cat spreadsheet.  Borders likes their authors formatted as lastname-space-firstname
    with no punctuation of any kind and in an all uppercase form.

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(1)
	DECLARE @v_desc			VARCHAR(1)
	DECLARE @i_authorkey		INT
	DECLARE @i_corporatename	INT



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.qweb_get_AuthorKey(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR NAME		*/

			SELECT @i_corporatename = corporatecontributorind
			FROM author
			WHERE authorkey = @i_authorkey


			IF @i_corporatename = 1	
				BEGIN
					SELECT @v_desc = 'Y'
				END

			ELSE
				BEGIN

					SELECT @v_desc = 'N'

				END
		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
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

