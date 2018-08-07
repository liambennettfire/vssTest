if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_exp_WK') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_exp_WK
GO

CREATE PROCEDURE qpl_calc_stg_tot_exp_WK (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_tot_exp_WK
**  Desc: Stage/TOTAL Expenses.
**
**  Auth: Kate
**  Date: October 18 2013
*******************************************************************************************/

DECLARE
  @v_other_cost FLOAT,
  @v_postage_cost FLOAT,
  @v_production_cost  FLOAT,
  @v_royalty_cost FLOAT,
  @v_total_expenses FLOAT

BEGIN

  SET @v_total_expenses = 0
  SET @o_result = NULL
  
  -- Production Expenses (Prepress & PPBF)
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'PRODEXP', NULL, 0, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0
  
  -- Royalties Expenses
  EXEC qpl_calc_stg_roy_exp @i_projectkey, @i_plstage, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0  
    
  -- Other Costs
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCEXP', NULL, 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0
 
  -- Postage Costs
  EXEC qpl_calc_stg_postage @i_projectkey, @i_plstage, 1, @v_postage_cost OUTPUT
  
  IF @v_postage_cost IS NULL
    SET @v_postage_cost = 0
    
  SET @v_total_expenses = @v_production_cost + @v_royalty_cost +  @v_other_cost + @v_postage_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_stg_tot_exp_WK TO PUBLIC
GO
