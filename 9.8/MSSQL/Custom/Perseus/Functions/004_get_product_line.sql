/****** Object:  UserDefinedFunction [dbo].[get_Product_line]    Script Date: 03/20/2009 14:31:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_Product_line]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[get_Product_line]


/****** Object:  UserDefinedFunction [dbo].[get_Product_line]    Script Date: 03/20/2009 14:29:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_Product_line]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the get_answer_codes function is to return a specific description column from 
gentables for misc field Product Line

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_longvalue	INT
	DECLARE	@i_misckey		int
	DECLARE	@i_datacode		int

	set @i_misckey = 2
	
	SELECT @i_longvalue = longvalue
	FROM	bookmisc
	WHERE	bookkey = @i_bookkey
	and misckey = @i_misckey

	select @i_datacode = datacode
	from bookmiscitems
	where misckey = @i_misckey

	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc2))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @i_datacode
					and datasubcode = @i_longvalue
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



