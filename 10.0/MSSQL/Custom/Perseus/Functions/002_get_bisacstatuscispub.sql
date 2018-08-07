/****** Object:  UserDefinedFunction [dbo].[get_BisacStatus]    Script Date: 04/22/2009 11:38:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_BisacStatusCispub]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[get_BisacStatusCispub]

/****** Object:  UserDefinedFunction [dbo].[get_BisacStatusCispub]    Script Date: 04/22/2009 11:09:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[get_BisacStatusCispub]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the get_BisacStatusCispub function is to return a specific description column from gentables 
	for a BisacSubStatus if it exists, or the BisacStatus if the substatus or its specific gentable field is not populated

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
	DECLARE @i_BisacStatusCode	INT
	declare @i_bisacsubstatuscode	int
	
	SELECT @i_BisacStatusCode = bisacstatuscode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey

	SELECT @i_BisacsubStatusCode = isnull(prodavailability,0)
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey

	if @i_bisacsubstatuscode = 0 
	begin
		SELECT @v_desc = LTRIM(RTRIM(externalcode))
		FROM	gentables  
		WHERE  tableid = 314
				AND datacode = @i_BisacStatusCode

	end
	else --use substatuscode
	begin
		IF @v_column = '1'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
				FROM	subgentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
						and datasubcode = @i_bisacsubstatuscode
			END

		ELSE IF @v_column = '2'
			BEGIN
				SELECT @v_desc = LTRIM(RTRIM(alternatedesc2))
				FROM	subgentables  
				WHERE  tableid = 314
						AND datacode = @i_BisacStatusCode
						and datasubcode = @i_bisacsubstatuscode
			END


	end

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




