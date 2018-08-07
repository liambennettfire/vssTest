if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc028') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc028
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_exp_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_exp_KAP
GO

CREATE PROCEDURE qpl_calc_ver_tot_exp_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_exp_KAP
**  Desc: Kaplan Item 28 - Version/TOTAL Expenses.
**
**  Auth: Kate
**  Date: November 8 2010
*******************************************************************************************/

DECLARE
  @v_distr_cost  FLOAT,
  @v_freightdeliv_cost  FLOAT,
  @v_fulfillment_cost FLOAT,
  @v_maned_cost  FLOAT,
  @v_marketing_cost  FLOAT,
  @v_other_cost FLOAT,
  @v_production_cost  FLOAT,
  @v_royalty_cost FLOAT,
  @v_salescoms_cost  FLOAT,
  @v_total_expenses FLOAT,
  @v_writeoffs_editcomps  FLOAT

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
    
  -- Version - Royalty Expenses
  EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty_cost OUTPUT

  IF @v_royalty_cost IS NULL
    SET @v_royalty_cost = 0
  
  -- Version - Fulfillment Costs
  EXEC qpl_calc_ver_fulfill @i_projectkey, @i_plstage, @i_plversion, @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
  
  -- Version - Write-offs & Edit Comps
  EXEC qpl_calc_ver_wo_edt_comps @i_projectkey, @i_plstage, @i_plversion, @v_writeoffs_editcomps OUTPUT
  
  IF @v_writeoffs_editcomps IS NULL
    SET @v_writeoffs_editcomps = 0
  
  -- Kaplan only: Management/Editorial Expense
  EXEC qpl_calc_ver_mgt_edt_KAP @i_projectkey, @i_plstage, @i_plversion, @v_maned_cost OUTPUT

  IF @v_maned_cost IS NULL
    SET @v_maned_cost = 0
  
  -- Kaplan only: Distribution Expenses
  EXEC qpl_calc_ver_dist_KAP @i_projectkey, @i_plstage, @i_plversion, @v_distr_cost OUTPUT
  
  IF @v_distr_cost IS NULL
    SET @v_distr_cost = 0

  -- Kaplan only: Sales Commission Expense
  EXEC qpl_calc_ver_sales_comm_KAP @i_projectkey, @i_plstage, @i_plversion, @v_salescoms_cost OUTPUT

  IF @v_salescoms_cost IS NULL
    SET @v_salescoms_cost = 0
  
  -- Kaplan only: Freight & Delivery Expenses
  EXEC qpl_calc_ver_fgt_dlvry_KAP @i_projectkey, @i_plstage, @i_plversion, @v_freightdeliv_cost OUTPUT
  
  IF @v_freightdeliv_cost IS NULL
    SET @v_freightdeliv_cost = 0

  -- Version - Other Costs
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'OTHEXP', 0, @v_other_cost OUTPUT
  
  IF @v_other_cost IS NULL
    SET @v_other_cost = 0

  PRINT 'Prod: ' + CONVERT(VARCHAR, @v_production_cost)
  PRINT 'Marketing: ' + CONVERT(VARCHAR, @v_marketing_cost)
  PRINT 'Royalty: ' + CONVERT(VARCHAR, @v_royalty_cost)
  PRINT 'Fulfillment: ' + CONVERT(VARCHAR, @v_fulfillment_cost)
  PRINT 'Write-Offs: ' + CONVERT(VARCHAR, @v_writeoffs_editcomps)
  PRINT 'Man/Ed: ' + CONVERT(VARCHAR, @v_maned_cost)
  PRINT 'Distr: ' + CONVERT(VARCHAR, @v_distr_cost)
  PRINT 'Sales Coms: ' + CONVERT(VARCHAR, @v_salescoms_cost)
  PRINT 'Freight&Deliv: ' + CONVERT(VARCHAR, @v_freightdeliv_cost)
  PRINT 'Other: ' + CONVERT(VARCHAR, @v_other_cost)

  SET @v_total_expenses = @v_production_cost + @v_marketing_cost + @v_royalty_cost + @v_fulfillment_cost + @v_writeoffs_editcomps + 
    @v_maned_cost + @v_distr_cost + @v_salescoms_cost + @v_freightdeliv_cost + @v_other_cost
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_exp_KAP TO PUBLIC
GO
