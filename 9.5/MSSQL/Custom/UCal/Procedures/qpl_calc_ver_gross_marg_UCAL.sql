if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_UCAL
GO

CREATE PROCEDURE qpl_calc_ver_gross_marg_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg_UCAL
**  Desc: UCAL - Version/Gross Margin.
**
**  Auth: slb
**  Date: Oct 25, 2011
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
  --,@v_subsidiary_rights_income FLOAT,
  --@v_other_income FLOAT
  @v_ancillaries FLOAT,
  @v_fees FLOAT 


BEGIN

  SET @o_result = NULL 
    
  --Version - Net Sales Dollars
  EXEC qpl_calc_ver_net_sales @i_projectkey, @i_plstage, @i_plversion,  @v_net_sales_dollars OUTPUT 

  IF @v_net_sales_dollars IS NULL
    SET @v_net_sales_dollars = 0
  
  -- Version - Bulk Sales Dollars
  EXEC qpl_calc_ver_bulk_sales @i_projectkey, @i_plstage, @i_plversion, @v_bulk_sales_dollars OUTPUT

  IF @v_bulk_sales_dollars IS NULL
    SET @v_bulk_sales_dollars = 0
    
/*
Added by Tolga on 3/08/12
*/

--Subsidiary Rights Income

--EXEC qpl_calc_ver_sub_rights_inc @i_projectkey, @i_plstage, @i_plversion, @v_subsidiary_rights_income OUTPUT
--  IF @v_subsidiary_rights_income IS NULL
--    SET @v_subsidiary_rights_income = 0
 
---- Other Income 
-- EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCINC', 'OTHINC', 1, @v_other_income OUTPUT
--  IF @v_other_income IS NULL
--    SET @v_other_income = 0 
 
/*
END OF NEW INCOME ITEMS ADDED BY TOLGA 
*/

    
  -- Version - Plant
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'PRODEXP', 'PLANT', 0, @v_plant_costs OUTPUT
  IF @v_plant_costs IS NULL
    SET @v_plant_costs = 0

  -- Version - PPB_CL
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'PRODEXP', 'PPBCL', 0, @v_ppbcl_costs OUTPUT
  IF @v_ppbcl_costs IS NULL
    SET @v_ppbcl_costs = 0

  -- Version - PPB_PA
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'PRODEXP', 'PPBPA', 0, @v_ppbpa_costs OUTPUT
  IF @v_ppbpa_costs IS NULL
    SET @v_ppbpa_costs = 0


  -- Version - Royalty
  EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @i_plversion, 0, @v_royalty OUTPUT

  IF @v_royalty IS NULL
    SET @v_royalty = 0
 
 
 EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'ANCL', 0, @v_ancillaries OUTPUT
   IF @v_ancillaries IS NULL
    SET @v_ancillaries = 0 
  
  
 EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'FEES', 0, @v_fees OUTPUT
 
    IF @v_fees IS NULL
    SET @v_fees = 0 

   SET @v_total_sales_dollars = @v_net_sales_dollars + @v_bulk_sales_dollars  

   SET @v_gross_margin = @v_total_sales_dollars - (@v_plant_costs + @v_ppbcl_costs + @v_ppbpa_costs + @v_royalty + @v_ancillaries + @v_fees)
   SET @o_result = @v_gross_margin

END
GO

GRANT EXEC ON qpl_calc_ver_gross_marg_UCAL TO PUBLIC
GO