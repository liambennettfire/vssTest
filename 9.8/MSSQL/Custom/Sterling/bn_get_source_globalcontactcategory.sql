/****** Object:  UserDefinedFunction [dbo].[bn_get_source_globalcontactcategory]    Script Date: 04/20/2010 17:40:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[bn_get_source_globalcontactcategory]
		(@i_globalcontactkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(510)

/*	The purpose of the qweb_get_BisacSubject function is to return a specific descriptive column from gentables/subgentables for a BISAC Subject.  
	When the @v_column = 'D', then the function will build the description from the gentable/subgentable combination.  All other options will 
	only return the subgentables values.

	Parameter Options

		Order
			1 = Returns first BISAC Subject
			2 = Returns second BISAC Subject
			3 = Returns third BISAC Subject
			4
			5
			.
			.
			.
			n			

		Column
			D = Data Description
			U = subgentablesdesc
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(500)
	DECLARE @v_desc			VARCHAR(500)
	DECLARE @i_bisaccode		INT
	DECLARE @i_bisacsubcode		INT

	SELECT @i_bisaccode = contactcategorycode,
		@i_bisacsubcode = contactcategorysubcode
	FROM	globalcontactcategory
	WHERE	globalcontactkey = @i_globalcontactkey and sortorder = @i_order
			and contactcategorycode = 5


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM((g.datadesc)))+'/'+LTRIM(RTRIM(s.datadesc))
			FROM gentables g, subgentables s
			WHERE g.tableid = 518 
					AND s.tableid = 518 
					AND g.datacode = @i_bisaccode
					AND s.datacode = @i_bisaccode
					AND s.datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'U'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 518
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '3'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(s.datadesc))
			FROM gentables g, subgentables s
			WHERE g.tableid = 518 
					AND s.tableid = 518 
					AND g.datacode = @i_bisaccode
					AND s.datacode = @i_bisaccode
					AND s.datasubcode = @i_bisacsubcode
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
grant all on dbo.bn_get_source_globalcontactcategory to public
go
