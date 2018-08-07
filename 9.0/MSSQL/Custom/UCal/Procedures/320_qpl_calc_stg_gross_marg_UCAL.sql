if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_gross_marg_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_gross_marg_UCAL
GO

CREATE PROCEDURE dbo.qpl_calc_stg_gross_marg_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_gross_marg
**  Desc: Island Press Item 13 - Stage/Gross Margin.
**
**  Auth: Tolga
**  Date: Janurary 30 2012
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
  
 
    --STAGE - Net Sales Dollars
  EXEC qpl_calc_stg_net_sales @i_projectkey, @i_plstage, @v_net_sales_dollars OUTPUT 


  IF @v_net_sales_dollars IS NULL
    SET @v_net_sales_dollars = 0
   
 -- STAGE, Bulk Sales 
 EXEC qpl_calc_stg_bulk_sales @i_projectkey, @i_plstage, @v_bulk_sales_dollars OUTPUT
 
  IF @v_bulk_sales_dollars IS NULL
    SET @v_bulk_sales_dollars = 0

    
  -- STAGE - Plant
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'PRODEXP', 'PLANT', 0, @v_plant_costs OUTPUT
  IF @v_plant_costs IS NULL
    SET @v_plant_costs = 0

  -- STAGE - PPB_CL
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'PRODEXP', 'PPBCL', 0, @v_ppbcl_costs OUTPUT
  IF @v_ppbcl_costs IS NULL
    SET @v_ppbcl_costs = 0

  -- STAGE - PPB_PA
  EXEC qpl_calc_stage @i_projectkey, @i_plstage,  'PRODEXP', 'PPBPA', 0, @v_ppbpa_costs OUTPUT
  IF @v_ppbpa_costs IS NULL
    SET @v_ppbpa_costs = 0


  -- STAGE - Royalty
  EXEC qpl_calc_stg_roy_exp @i_projectkey, @i_plstage, @v_royalty OUTPUT

  IF @v_royalty IS NULL
    SET @v_royalty = 0
    
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'PRODEXP', 'ANCIL', 0, @v_ancillaries OUTPUT
  
  IF @v_ancillaries IS NULL
    SET @v_ancillaries = 0
    
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'PRODEXP', 'FEES', 0, @v_fees OUTPUT
  
  IF @v_fees IS NULL
    SET @v_fees = 0
  

   SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars

   SET @v_gross_margin = @v_total_sales_dollars - (@v_plant_costs + @v_ppbcl_costs + @v_ppbpa_costs + @v_royalty + @v_ancillaries + @v_fees)
   SET @o_result = @v_gross_margin
  
END

GO

GRANT EXEC ON qpl_calc_stg_gross_marg_UCAL TO PUBLIC
GO

