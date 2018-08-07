if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_exp_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_exp_RUP
GO

CREATE PROCEDURE qpl_calc_ver_tot_exp_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_exp_RUP
**  Desc: P&L Version/TOTAL Expenses for Rutgers. Removed Fulfillment and Other Expenses and
**        changed Roy Expenses to Royalty Earned
**
**  Auth: SLB
**  Date: February 23 2011
*******************************************************************************************/

DECLARE
  @v_marketing_cost  FLOAT,
  @v_production_cost  FLOAT,
  @v_royalty_cost FLOAT,
  @v_total_expenses FLOAT

BEGIN

  SET @v_total_expenses = 0
  SET @o_result = NULL
  
  -- Version - Prepress & PPBF
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'PRODEXP', NULL, 0, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0    
  
  -- Version - Marketing Expenses
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MKTGEXP', NULL, 0, @v_marketing_cost OUTPUT

  IF @v_marketing_cost IS NULL
    SET @v_marketing_cost = 0    
  
  -- Version - Royalties Earnings
  EXEC qpl_calc_ver_roy_ern @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0

 
  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_royalty_cost 
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_exp_RUP TO PUBLIC
GO
