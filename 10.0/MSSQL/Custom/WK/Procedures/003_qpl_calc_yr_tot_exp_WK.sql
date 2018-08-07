if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_tot_exp_WK') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_tot_exp_WK
GO

CREATE PROCEDURE qpl_calc_yr_tot_exp_WK (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_tot_exp_WK
**  Desc: Year/TOTAL Expenses.
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
  
  -- Year - Prepress & PPBF
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'PRODEXP', NULL, 0, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0    
   
  -- Year - Royalties Expenses
  SET @v_royalty_cost = -1
  EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 0, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
     
  -- Year - Other Costs
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCEXP', NULL, 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0
    
  -- Year - Postage Costs
  EXEC qpl_calc_yr_postage @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 1, @v_postage_cost OUTPUT
  
  IF @v_postage_cost IS NULL
    SET @v_postage_cost = 0    

  SET @v_total_expenses = @v_production_cost + @v_royalty_cost + @v_other_cost + @v_postage_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_yr_tot_exp_WK TO PUBLIC
GO
