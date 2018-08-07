/****** Object:  UserDefinedFunction [dbo].[get_bookmisc_gent]    Script Date: 10/05/2008 15:42:40 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[get_bookmisc_gent]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[get_bookmisc_gent]


/****** Object:  UserDefinedFunction [dbo].[get_bookmisc_gent]    Script Date: 10/01/2008 11:28:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[get_bookmisc_gent]
		(@i_bookkey	INT,
		@i_misckey	int,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the get_bookmisc_gent function is to return a specific description column from subgentables for a BisacStatus

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
	DECLARE @v_desc			VARCHAR(255),
			@datacode		int,
			@datasubcode	int
	
	select @datacode = bmi.datacode, @datasubcode = bm.longvalue
	from bookmisc bm
	join bookmiscitems bmi
	on bm.misckey = bmi.misckey
	where bm.bookkey = @i_bookkey
	and bm.misckey = @i_misckey
	and bmi.misctype = 5

	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
		
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 525
					AND datacode = @datacode
					AND datasubcode = @datasubcode
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



