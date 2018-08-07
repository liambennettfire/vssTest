if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_inc_profit_pct_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_inc_profit_pct_UCAL
GO

CREATE PROCEDURE dbo.qpl_calc_yr_inc_profit_pct_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,    
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_inc_profit_UCAL
**  Desc: UCAL Version/Operating Profit Calculation
**
**  Auth: tt	
**  Date: March 8, 2011
*******************************************************************************************/

DECLARE
  @v_incremental_profit FLOAT,  
  @v_total_op_exp FLOAT,
  @v_incremental_profit_percent FLOAT,
  @v_net_sales_dollars FLOAT,
  @v_bulk_sales_dollars FLOAT,
  @v_total_sales_dollars FLOAT

BEGIN

  SET @o_result = NULL
  
 
  -- Version - Incremental Profit 
  EXEC qpl_calc_yr_inc_profit_UCAL @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_incremental_profit OUTPUT


  --Version - Net Sales Dollars
  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode,  @v_net_sales_dollars OUTPUT 

  IF @v_net_sales_dollars IS NULL
    SET @v_net_sales_dollars = 0
    
    -- Version - Bulk Sales Dollars
  EXEC qpl_calc_yr_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode,  @v_bulk_sales_dollars OUTPUT

  IF @v_bulk_sales_dollars IS NULL
    SET @v_bulk_sales_dollars = 0
    
  SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars

  IF @v_total_sales_dollars = 0
    SET @v_incremental_profit_percent = 0
  ELSE
    SET @v_incremental_profit_percent = @v_incremental_profit / @v_total_sales_dollars  

  SET @o_result = @v_incremental_profit_percent 
  
END
GO
GRANT EXEC ON qpl_calc_yr_inc_profit_pct_UCAL TO PUBLIC
GO