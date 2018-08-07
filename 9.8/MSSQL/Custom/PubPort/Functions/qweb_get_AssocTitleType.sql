SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AssocTitleType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AssocTitleType]
GO




CREATE FUNCTION dbo.qweb_get_AssocTitleType
		(@i_bookkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_AssocTitleType function is to return a specific descriptive column from gentables for the associated
	title type.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n			

		Column
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
	DECLARE @i_associationtypecode	INT


	SELECT @i_associationtypecode = associationtypecode
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey and sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(g.datadesc))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM gentables g
			WHERE g.tableid = 440
					AND g.datacode = @i_associationtypecode
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

