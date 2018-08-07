
/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_type]    Script Date: 03/24/2009 11:52:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_type') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_author_type
GO
CREATE FUNCTION [dbo].[rpt_get_author_type]
		(@i_bookkey		INT,
		@i_order		INT,
		@v_column		VARCHAR(1))

/*  	The rpt_get_author_type function returns a role description for a specfic author.  The parameters for the function 
	are the book key, author sort order, and gentable descriptive column


	@v_column OPTIONS
		D = Data Description
 		E = External code
  		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/

RETURNS	VARCHAR(255)

AS

BEGIN 
	DECLARE @i_type		INT
	DECLARE @RETURN		VARCHAR(255)
	DECLARE @v_desc		VARCHAR(255)

	SELECT @i_type = authortypecode
	FROM bookauthor
	WHERE bookkey = @i_bookkey
		AND sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc2))
			FROM	gentables  
			WHERE  tableid = 134
					AND datacode = @i_type
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
go
Grant All on dbo.rpt_get_author_type to Public
go
