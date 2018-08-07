if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc012') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc012
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_exp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_exp
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_exp_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_exp_HMH
GO

CREATE PROCEDURE qpl_calc_stg_tot_exp_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_tot_exp_HMH
**  Desc: HMH Item 12 - Stage/TOTAL Expenses.
**
**  Auth: Kate
**  Date: November 10 2009
*******************************************************************************************/

DECLARE
  @v_coop_cost  FLOAT,
  @v_fulfillment_cost FLOAT,
  @v_marketing_cost  FLOAT,
  @v_other_cost FLOAT,
  @v_production_cost  FLOAT,
  @v_royalty_cost FLOAT,
  @v_subrights_cost FLOAT,
  @v_total_expenses FLOAT,
  @v_writeoffs_editcomps  FLOAT

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
  
  -- HMH only: Coop Expense
  EXEC qpl_calc_stg_coop_HMH @i_projectkey, @i_plstage, @v_coop_cost OUTPUT

  IF @v_coop_cost IS NULL
    SET @v_coop_cost = 0
  
  -- Royalties Expenses
  EXEC qpl_calc_stg_roy_exp @i_projectkey, @i_plstage, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
  
  -- Fulfillment Costs
  EXEC qpl_calc_stg_fulfill_HMH @i_projectkey, @i_plstage, @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
  
  -- Write-offs & Edit Comps
  EXEC qpl_calc_stg_wo_edt_comps @i_projectkey, @i_plstage, @v_writeoffs_editcomps OUTPUT
  
  IF @v_writeoffs_editcomps IS NULL
    SET @v_writeoffs_editcomps = 0
  
  -- HMH only: Subrights Expense
  EXEC qpl_calc_stg_sub_rights_exp_HMH @i_projectkey, @i_plstage, @v_subrights_cost OUTPUT

  IF @v_subrights_cost IS NULL
    SET @v_subrights_cost = 0

  -- Other Costs
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCEXP', 'OTHEXP', 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0
  
  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_coop_cost + @v_royalty_cost + 
    @v_fulfillment_cost + @v_writeoffs_editcomps + @v_subrights_cost + @v_other_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_stg_tot_exp_HMH TO PUBLIC
GO
