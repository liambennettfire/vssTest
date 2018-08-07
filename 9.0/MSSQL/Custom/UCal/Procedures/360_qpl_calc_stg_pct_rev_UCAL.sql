if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_pct_rev_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_pct_rev_UCAL
GO

CREATE PROCEDURE dbo.qpl_calc_stg_pct_rev_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_pct_rev_UCAL
**  Desc: UCAL Version/Operating Profit % of Revenue Calculation
**
**  Auth: slb	
**  Date: October 25, 2011
*******************************************************************************************/

DECLARE
  @v_net_sales_dollars FLOAT,  
  @v_bulk_sales_dollars FLOAT,
  @v_total_sales_dollars FLOAT,
  @v_op_profit FLOAT,
  @v_pct_rev FLOAT

BEGIN

  SET @o_result = NULL
  
   --Version - Net Sales Dollars
  EXEC qpl_calc_stg_net_sales @i_projectkey, @i_plstage,  @v_net_sales_dollars OUTPUT 

  IF @v_net_sales_dollars IS NULL
    SET @v_net_sales_dollars = 0
    
    -- Version - Bulk Sales Dollars
  EXEC qpl_calc_stg_bulk_sales @i_projectkey, @i_plstage,  @v_bulk_sales_dollars OUTPUT

  IF @v_bulk_sales_dollars IS NULL
    SET @v_bulk_sales_dollars = 0
    
  SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars

  -- Version - Total Operating Profit
  EXEC qpl_calc_stg_op_profit_UCAL @i_projectkey, @i_plstage,  @v_op_profit OUTPUT

  IF @v_op_profit IS NULL
    SET @v_op_profit = 0


   IF @v_total_sales_dollars= 0
    	SET @v_pct_rev= 0
  ELSE
    	SET @v_pct_rev = @v_op_profit / @v_total_sales_dollars
    
  SET @o_result = @v_pct_rev
  
END
GO
GRANT EXEC ON qpl_calc_stg_pct_rev_UCAL TO PUBLIC
GO