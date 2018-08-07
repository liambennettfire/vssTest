IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_calc_yr_tot_exp')
  DROP PROCEDURE qpl_calc_yr_tot_exp
GO

CREATE PROCEDURE [dbo].[qpl_calc_yr_tot_exp] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_tot_exp
**  Desc: P&L Item 58 - Year/TOTAL Expenses.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_fulfillment_cost FLOAT,
  @v_marketing_cost  FLOAT,
  @v_other_cost FLOAT,
  @v_production_cost  FLOAT,
  @v_royalty_cost FLOAT,
  @v_total_expenses FLOAT

BEGIN

  SET @v_total_expenses = 0
  SET @o_result = NULL
  
  -- Year - Prepress & PPBF
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'PRODEXP', NULL, 0, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0    
  
  -- Year - Marketing Expenses
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MKTGEXP', NULL, 0, @v_marketing_cost OUTPUT

  IF @v_marketing_cost IS NULL
    SET @v_marketing_cost = 0    
  
  -- Year - Royalties Expenses
  EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 0, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
  
  -- Year - Fulfillment Costs
  EXEC qpl_calc_yr_fulfill @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
    
  -- Year - Other Costs
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCEXP', 'OTHEXP', 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0

  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_royalty_cost + @v_fulfillment_cost + @v_other_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_yr_tot_exp TO PUBLIC
GO
