
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_BisacSubject') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.get_BisacSubject
GO

CREATE FUNCTION dbo.get_BisacSubject
		(@i_bookkey	INT,
		@i_order	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(510)

/*	The purpose of the get_BisacSubject function is to return a specific descriptive column from gentables/subgentables for a BISAC Subject.  
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

	SELECT @i_bisaccode = bisaccategorycode,
		@i_bisacsubcode = bisaccategorysubcode
	FROM	bookbisaccategory
	WHERE	bookkey = @i_bookkey and sortorder = @i_order


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(dbo.proper_case(g.datadesc)))+'/'+LTRIM(RTRIM(s.datadesc))
			FROM bookbisaccategory b,gentables g, subgentables s
			WHERE g.tableid = 339 
					AND s.tableid = 339 
					AND g.datacode = @i_bisaccode
					AND s.datacode = @i_bisaccode
					AND s.datasubcode = @i_bisacsubcode
					AND b.bookkey=@i_bookkey
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	subgentables  
			WHERE  tableid = 339
					AND datacode = @i_bisaccode
					AND datasubcode = @i_bisacsubcode
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



Go
 grant all on get_BisacSubject to public