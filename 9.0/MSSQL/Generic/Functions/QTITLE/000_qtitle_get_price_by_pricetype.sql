if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_price_by_pricetype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_price_by_pricetype
GO

CREATE FUNCTION dbo.qtitle_get_price_by_pricetype
(
  @i_bookkey as integer,
  @i_pricetype as integer
) 
RETURNS FLOAT

/*******************************************************************************************************
**  Name: qtitle_get_price_by_pricetype
**  Desc: This function returns the best US Price for the given PriceTypeCode.
**
**  Auth: Alan Katzen
**  Date: September 11 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_price  FLOAT
    
  /* First check if Price of the given type exists */
  SELECT @v_count = COUNT(*)
  FROM bookprice
  WHERE bookkey = @i_bookkey AND
      currencytypecode = 6 AND
      pricetypecode = @i_pricetype
  
  IF @v_count = 0
    RETURN NULL   /* this Price doesn't exist - return NULL */
  
  SELECT @v_price = COALESCE(finalprice, budgetprice)
  FROM bookprice
  WHERE bookkey = @i_bookkey AND
      currencytypecode = 6 AND
      pricetypecode = @i_pricetype
    
  RETURN @v_price

END
GO

GRANT EXEC ON dbo.qtitle_get_price_by_pricetype TO public
GO
