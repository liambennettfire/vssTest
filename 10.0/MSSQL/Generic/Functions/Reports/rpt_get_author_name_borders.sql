
/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_name_borders]    Script Date: 03/24/2009 11:52:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_name_borders') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_author_name_borders
GO
CREATE FUNCTION [dbo].[rpt_get_author_name_borders] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (120)

/*  The purpose of the rpt_get_author_name_borders function is to return a specific author name 
    formatted correctly for the Borders e-cat spreadsheet.  Borders likes their authors formatted as lastname-space-firstname
    with no punctuation of any kind and in an all uppercase form.

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @i_authorkey		INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @i_corporatename	INT



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.rpt_get_author_primary_key(@i_bookkey, @i_order)

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
					SELECT @v_desc = lastname
					FROM	author
					WHERE authorkey = @i_authorkey
				END

			ELSE
				BEGIN

					SELECT @v_firstname = firstname,
						@v_desc = lastname
					FROM author
					WHERE authorkey = @i_authorkey
		 
					IF @v_firstname IS  NOT NULL 
						BEGIN
							SELECT @v_desc = @v_desc + ' ' + @v_firstname
							SELECT @v_desc = REPLACE(@v_desc,'.','')
							SELECT @v_desc = REPLACE(@v_desc,',','')
							SELECT @v_desc = REPLACE(@v_desc,'-','')
				            	END

				END
		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END
go
Grant All on dbo.rpt_get_author_name_borders to Public
go