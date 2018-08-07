if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_exp_AMP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_exp_AMP
GO

CREATE PROCEDURE qpl_calc_ver_tot_exp_AMP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_exp
**  Desc: P&L Item 28 - Version/TOTAL Expenses.
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
  @v_commission FLOAT,
  @v_distribution FLOAT,
  @v_marketing_coop FLOAT,
  @v_writeoff_edcomps FLOAT, 
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
  
  -- Version - Royalties Expenses
  EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
  
  -- Version - Fulfillment Costs
  EXEC qpl_calc_ver_fulfill @i_projectkey, @i_plstage, @i_plversion, @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
    
  -- Version - Other Costs
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'OTHEXP', 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0
    
    
   -- Version - Write off and Editorial Comps
   EXEC dbo.qpl_calc_ver_wo_edt_comps @i_projectkey, @i_plstage, @i_plversion, @v_writeoff_edcomps OUTPUT
    
   IF @v_writeoff_edcomps IS NULL
		SET @v_writeoff_edcomps = 0

    
   EXEC dbo.qpl_calc_ver_client_value_AMP @i_projectkey, @i_plstage, @i_plversion, 'Commission', 'N', @v_commission OUTPUT
	
   IF @v_commission IS NULL
	 SET @v_commission = 0

   EXEC dbo.qpl_calc_ver_client_value_AMP @i_projectkey, @i_plstage, @i_plversion, 'Distribution', 'N', @v_distribution OUTPUT
	
   IF @v_distribution IS NULL
	 SET @v_distribution = 0

   EXEC dbo.qpl_calc_ver_client_value_AMP @i_projectkey, @i_plstage, @i_plversion, 'MarketingCoop', 'G', @v_marketing_coop OUTPUT
	
   IF @v_marketing_coop IS NULL
	 SET @v_marketing_coop = 0		
	

  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_royalty_cost + @v_fulfillment_cost + @v_other_cost + @v_writeoff_edcomps + @v_commission + @v_distribution + @v_marketing_coop
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_exp_AMP TO PUBLIC
GO
