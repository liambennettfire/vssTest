if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getID') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.WK_getID
GO

CREATE FUNCTION dbo.WK_getID(@bookkey int, @IdType varchar(100), @sortorder int, @filelocationgeneratedkey int) 
RETURNS int
AS
/*
This function takes @bookkey and the type of ID we are after as a parameter
Type should be the name of PACE table we want to go after
Each table should be imported into WK db from WK_ORA because we don't want to maintain two dbs after go-live

Select TOP 100 bookkey, dbo.WK_getID(bookkey, 'PHYSICAL_SPECIFICATIONS', 0, 0) from book
ORDER BY bookkey

where bookkey = 566164

Select TOP 100 bookkey, dbo.WK_getID(bookkey, 'PRODUCT_LINK', sortorder, filelocationgeneratedkey) from filelocation
where filetypecode = 3


Select * FROM book


*/
BEGIN
DECLARE @RETURN int
DECLARE @ProductId int
SET @ProductId = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long')

DECLARE @CommonProductId int
SET @CommonProductId = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long')




IF @IdType = 'PHYSICAL_SPECIFICATIONS'
	BEGIN

		Select @Return = (CASE WHEN @ProductId IS NULL OR @ProductId = '' THEN @bookkey
		ELSE (
		CASE WHEN EXISTS (Select * FROM dbo.WK_PHYSICAL_SPECIFICATIONS ps WHERE ps.PRODUCT_ID = @ProductId)
			 THEN (Select TOP 1 PHYSICAL_SPECIFICATIONS_ID FROM dbo.WK_PHYSICAL_SPECIFICATIONS ps WHERE ps.PRODUCT_ID = @ProductId ORDER BY PHYSICAL_SPECIFICATIONS_ID DESC)
			ELSE @bookkey END)
		END)
	END

IF @IdType = 'PRODUCT_LINK'
	BEGIN

		Select @Return = (CASE WHEN @ProductId IS NULL OR @ProductId = '' THEN @filelocationgeneratedkey
			ELSE (
			CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_LINK pl WHERE pl.PRODUCT_ID = @ProductId AND pl.DISPLAY_SEQUENCE = @sortorder)
				 THEN (Select TOP 1 PRODUCT_LINK_ID FROM dbo.WK_PRODUCT_LINK pl WHERE pl.PRODUCT_ID = @ProductId AND pl.DISPLAY_SEQUENCE = @sortorder)
				ELSE @filelocationgeneratedkey END)
			END)

	END

IF @IdType = 'PRODUCT_PRICE'
	BEGIN

		Select @Return = (CASE WHEN @ProductId IS NULL OR @ProductId = '' THEN @bookkey
		ELSE (
		CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_PRICES WHERE PRODUCT_ID = @ProductId)
			 THEN (Select TOP 1 PRODUCT_PRICES_ID FROM dbo.WK_PRODUCT_PRICES WHERE PRODUCT_ID = @ProductId ORDER BY PRODUCT_PRICES_ID DESC)
			ELSE @bookkey END)
		END) 

	END

IF @IdType = 'MARKETING_INFO'
	BEGIN
/*
Select * FROM WK_ORA.WKDBA.MARKETING_INFO
ORDER BY MARKETING_INFO_ID

Select MAX(MARKETING_INFO_ID) FROM WK_ORA.WKDBA.MARKETING_INFO


*/

		Select @Return = (CASE WHEN @ProductId IS NULL OR @ProductId = '' THEN @bookkey
		ELSE (
		CASE WHEN EXISTS (Select * FROM dbo.WK_MARKETING_INFO WHERE PRODUCT_ID = @ProductId)
			 THEN (Select TOP 1 MARKETING_INFO_ID FROM dbo.WK_MARKETING_INFO WHERE PRODUCT_ID = @ProductId ORDER BY PRODUCT_ID DESC)
			ELSE @bookkey END)
		END) 

	END

--IF @IdType = 'ALTERNATE_PRICE'
--	BEGIN
--
--		Select @Return = (CASE WHEN @ProductId IS NULL OR @ProductId = '' THEN @bookkey
--		ELSE (
--		CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_PRICES pp JOIN dbo.WK_ALTERNATE_PRICE ap ON pp.PRODUCT_PRICES_ID = ap.PRODUCT_PRICES_ID WHERE pp.PRODUCT_ID = @ProductId)
--			 THEN (Select TOP 1 ALTERNATE_PRICE_ID FROM dbo.WK_PRODUCT_PRICES pp JOIN dbo.WK_ALTERNATE_PRICE ap ON pp.PRODUCT_PRICES_ID = ap.PRODUCT_PRICES_ID WHERE pp.PRODUCT_ID = @ProductId)
--			ELSE @bookkey END)
--		END) 
--
--	END


RETURN @RETURN

END