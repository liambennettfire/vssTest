if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc012') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc012
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_exp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_exp
GO

CREATE PROCEDURE qpl_calc_stg_tot_exp (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_tot_exp
**  Desc: P&L Item 12 - Stage/TOTAL Expenses.
**
**  Auth: Kate
**  Date: November 15 2007
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
  
  -- Production Expenses (Prepress & PPBF)
  EXEC qpl_calc_stg_pre_PPBF @i_projectkey, @i_plstage, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0

  -- Marketing Expenses
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MKTGEXP', NULL, 0, @v_marketing_cost OUTPUT

  IF @v_marketing_cost IS NULL
    SET @v_marketing_cost = 0
  
  -- Royalties Expenses
  EXEC qpl_calc_stg_roy_exp @i_projectkey, @i_plstage, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
  
  -- Fulfillment Costs
  EXEC qpl_calc_stg_fulfill @i_projectkey, @i_plstage, @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
    
  -- Other Costs
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCEXP', 'OTHEXP', 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0
  
  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_royalty_cost + @v_fulfillment_cost + @v_other_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_stg_tot_exp TO PUBLIC
GO
