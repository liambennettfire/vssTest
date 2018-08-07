SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_product_availability') )
	DROP FUNCTION rpt_get_product_availability
GO


CREATE FUNCTION rpt_get_product_availability (@i_bookkey	INT,@v_column	VARCHAR(1)) RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_product_availability function is to return a specific description column 
     from gentables for a Product Availability

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
	DECLARE @i_prodavailability	INT
	DECLARE @i_BisacStatusCode	INT
	
	SELECT @i_BisacStatusCode = bisacstatuscode,
			 @i_prodavailability = prodavailability
	  FROM bookdetail
	 WHERE bookkey = @i_bookkey

	if @i_prodavailability is null or @i_prodavailability = 0
	BEGIN
		SELECT @v_desc = ''
	END
	ELSE
	BEGIN
		IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			  FROM subgentables  
			 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
		ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
		  	  FROM subgentables  
		 	 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
		ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			  FROM subgentables  
			 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
		ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			  FROM subgentables  
			 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
		ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			  FROM subgentables  
			 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
		ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			  FROM subgentables  
			 WHERE tableid = 314
				AND datacode = @i_BisacStatusCode
				AND datasubcode = @i_prodavailability
		END
	END /*End ELSE*/

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

grant execute on rpt_get_product_availability to public
go