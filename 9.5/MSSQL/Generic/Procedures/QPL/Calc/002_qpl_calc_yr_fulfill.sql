if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc054') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc054
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_fulfill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_fulfill
GO

CREATE PROCEDURE qpl_calc_yr_fulfill (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_fulfill
**  Desc: P&L Item 54 - Year/Fulfillment Costs.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_bulk_sales FLOAT,
  @v_count INT,
  @v_net_sales FLOAT,
  @v_fulfillment_costs FLOAT,
  @v_fulfillment_percent FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Get Fulfillment Percent from client defaults
  SELECT @v_count = COUNT(*)
  FROM clientdefaults
  WHERE clientdefaultid = 39
  
  IF @v_count > 0
    SELECT @v_fulfillment_percent = clientdefaultvalue
    FROM clientdefaults
    WHERE clientdefaultid = 39
  
  IF @v_fulfillment_percent IS NULL
    SET @v_fulfillment_percent = 0  
     
  -- Year - Bulk Sales
  EXEC qpl_calc_yr_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_bulk_sales OUTPUT
  
  IF @v_bulk_sales IS NULL
    SET @v_bulk_sales = 0
    
  -- Year - Net Sales
  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_net_sales OUTPUT
  
  IF @v_net_sales IS NULL
    SET @v_net_sales = 0
  
  SET @v_fulfillment_costs = (@v_bulk_sales + @v_net_sales) * @v_fulfillment_percent
  SET @o_result = @v_fulfillment_costs
  
END
GO

GRANT EXEC ON qpl_calc_yr_fulfill TO PUBLIC
GO
