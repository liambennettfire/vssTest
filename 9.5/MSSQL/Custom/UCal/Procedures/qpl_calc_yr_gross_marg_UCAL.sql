if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_gross_marg_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_gross_marg_UCAL
GO

CREATE PROCEDURE qpl_calc_yr_gross_marg_UCAL(  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_gross_marg
**  Desc: P&L Item 59 - Year/Gross Margin.
**
**  Auth: Kate
**  Date: November 20 2009
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_net_sales_dollars FLOAT,
  @v_bulk_sales_dollars FLOAT,
  @v_plant_costs FLOAT,
  @v_ppbcl_costs FLOAT,
  @v_ppbpa_costs FLOAT,
  @v_royalty FLOAT,
  @v_total_sales_dollars FLOAT,
  @v_ancillaries FLOAT,
  @v_fees FLOAT 

BEGIN

  SET @o_result = NULL
  
 
    --Year - Net Sales Dollars
  EXEC qpl_calc_yr_net_sales @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @v_net_sales_dollars OUTPUT 


  IF @v_net_sales_dollars IS NULL
    SET @v_net_sales_dollars = 0
   
 -- Year, Bulk Sales 
 EXEC qpl_calc_yr_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_bulk_sales_dollars OUTPUT
 
  IF @v_bulk_sales_dollars IS NULL
    SET @v_bulk_sales_dollars = 0

    
  -- YEAR - Plant
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion,  @i_yearcode, 'PRODEXP', 'PLANT', 0, @v_plant_costs OUTPUT
  IF @v_plant_costs IS NULL
    SET @v_plant_costs = 0

  -- YEAR - PPB_CL
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, 'PRODEXP', 'PPBCL', 0, @v_ppbcl_costs OUTPUT
  IF @v_ppbcl_costs IS NULL
    SET @v_ppbcl_costs = 0

  -- YEAR - PPB_PA
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'PRODEXP', 'PPBPA', 0, @v_ppbpa_costs OUTPUT
  IF @v_ppbpa_costs IS NULL
    SET @v_ppbpa_costs = 0


  -- YEAR - Royalty
  EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 0, @v_royalty OUTPUT
  
  
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion,@i_yearcode,'MISCEXP','ANCL', 0, @v_ancillaries OUTPUT
  IF @v_ancillaries IS NULL
    SET @v_ancillaries = 0
    
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion,@i_yearcode,'MISCEXP','FEES', 0, @v_fees OUTPUT
  IF @v_fees IS NULL
    SET @v_fees = 0
  

  IF @v_royalty IS NULL
    SET @v_royalty = 0

   SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars

   SET @v_gross_margin = @v_total_sales_dollars - (@v_plant_costs + @v_ppbcl_costs + @v_ppbpa_costs + @v_royalty + @v_ancillaries + @v_fees)
   SET @o_result = @v_gross_margin

END
GO

GRANT EXEC ON qpl_calc_yr_gross_marg_UCAL TO PUBLIC
GO