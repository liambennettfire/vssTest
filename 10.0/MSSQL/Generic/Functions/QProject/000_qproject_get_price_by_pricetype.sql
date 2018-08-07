if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_price_by_pricetype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_price_by_pricetype
GO

CREATE FUNCTION dbo.qproject_get_price_by_pricetype
(
  @i_projectkey as integer,
  @i_pricetype as integer
) 
RETURNS FLOAT

/*******************************************************************************************************
**  Name: qproject_get_price_by_pricetype
**  Desc: This function returns the best US Price for the given PriceTypeCode.
**
**  Auth: Kate Wiewiora
**  Date: April 2 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  11/14/17  Colman    Performance
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_price  FLOAT

    SET @v_price = NULL
  /* First check if Price of the given type exists */
  -- SELECT @v_count = COUNT(*)
  -- FROM taqprojectprice
  -- WHERE taqprojectkey = @i_projectkey AND
      -- currencytypecode = 6 AND
      -- pricetypecode = @i_pricetype
  
  -- IF @v_count = 0
    -- RETURN NULL   /* this Price doesn't exist - return NULL */
  
  SELECT @v_price = COALESCE(finalprice, budgetprice)
  FROM taqprojectprice
  WHERE taqprojectkey = @i_projectkey AND
      currencytypecode = 6 AND
      pricetypecode = @i_pricetype
  
  RETURN @v_price

END
GO

GRANT EXEC ON dbo.qproject_get_price_by_pricetype TO public
GO
