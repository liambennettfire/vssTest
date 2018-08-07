if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_op_exp_wo_ga_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_op_exp_wo_ga_UCAL
GO


CREATE PROCEDURE dbo.qpl_calc_stg_op_exp_wo_ga_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_op_exp_UCAL
**  Desc: UCAL Version/Operating Expenses
**
**  Auth: tt
**  Date: March 8th, 2011
*******************************************************************************************/

DECLARE
  @v_mktdirect_cost  FLOAT,
  @v_mktoverhead_cost  FLOAT,
  @v_mktaddtl_cost  FLOAT,
  @v_edpdirect_cost  FLOAT,
  @v_edpoverhead_cost  FLOAT,
  --@v_ancillaries_cost  FLOAT,
  --@v_preprod_cost  FLOAT,
  @v_comp_cost FLOAT,
  @v_fulfillment_cost FLOAT,
  --@v_ga_cost  FLOAT,
  @v_total_expenses FLOAT,
  @v_acquisition_overhead FLOAT,
  @v_other_adjustments FLOAT

BEGIN

  SET @v_total_expenses = 0
  SET @o_result = NULL
  
  
  --Acquisitions - Overhead
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCEXP', 'ACQOH', 0, @v_acquisition_overhead OUTPUT
  IF @v_acquisition_overhead IS NULL
    SET @v_acquisition_overhead = 0
  
  -- Version - Marketing Direct
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MKTGEXP', 'MKTDIR', 0, @v_mktdirect_cost OUTPUT

  IF @v_mktdirect_cost IS NULL
    SET @v_mktdirect_cost = 0    
  
  -- Version - Marketing Overhead
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MKTGEXP', 'MKTOVR', 0, @v_mktoverhead_cost OUTPUT

  IF @v_mktoverhead_cost IS NULL
    SET @v_mktoverhead_cost = 0    

    -- Version - Marketing Additonal
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MKTGEXP', 'MKTADDT', 0, @v_mktaddtl_cost  OUTPUT

  IF @v_mktaddtl_cost  IS NULL
    SET @v_mktaddtl_cost  = 0    

    -- Version - EDP Direct
  EXEC qpl_calc_stage @i_projectkey, @i_plstage,  'MISCEXP', 'EDPDIR', 0, @v_edpdirect_cost OUTPUT
  
  IF @v_edpdirect_cost IS NULL
    SET @v_edpdirect_cost = 0
  
  -- Version - EDP Overhead
  EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'MISCEXP', 'EDPOVR', 0, @v_edpoverhead_cost OUTPUT
  
  IF @v_edpoverhead_cost IS NULL
    SET @v_edpoverhead_cost = 0

  -- Version - Ancillaries
  --EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'ANCL', 0, @v_ancillaries_cost OUTPUT
  
  --IF @v_ancillaries_cost IS NULL
  --  SET @v_ancillaries_cost = 0

  -- Version - Pre Production Costs
  --EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'PREPROD', 0, @v_preprod_cost OUTPUT
  
  --IF @v_preprod_cost IS NULL
  --  SET @v_preprod_cost = 0

  -- Version - Comp Costs
  EXEC qpl_calc_stg_wo_edt_comps_UCAL @i_projectkey, @i_plstage,3.5, @v_comp_cost OUTPUT

  IF @v_comp_cost IS NULL
    SET @v_comp_cost = 0    

  -- Version - Fulfillment Costs
  EXEC qpl_calc_stg_fulfill @i_projectkey, @i_plstage,  @v_fulfillment_cost OUTPUT

  IF @v_fulfillment_cost IS NULL
    SET @v_fulfillment_cost = 0    
    
   -- Version - G&A Costs
  --EXEC qpl_calc_stage @i_projectkey, @i_plstage,  'MISCEXP', 'GA', 0, @v_ga_cost OUTPUT
  
  --IF @v_ga_cost IS NULL
  --  SET @v_ga_cost = 0
   
  -- Version - Other Adjustments
  EXEC qpl_calc_stage @i_projectkey, @i_plstage,'MISCEXP', 'OTHEXP', 0, @v_other_adjustments OUTPUT
  
   IF @v_other_adjustments IS NULL
     SET @v_other_adjustments = 0 
  

  --SET @v_total_expenses =  @v_mktdirect_cost + @v_mktoverhead_cost + @v_mktaddtl_cost + @v_edpdirect_cost + @v_edpoverhead_cost + @v_ancillaries_cost + @v_preprod_cost + @v_comp_cost + @v_fulfillment_cost + @v_ga_cost
 
  SET @v_total_expenses =   @v_acquisition_overhead + @v_mktdirect_cost + @v_mktoverhead_cost + @v_mktaddtl_cost + @v_edpdirect_cost + @v_edpoverhead_cost +  @v_comp_cost + @v_fulfillment_cost +  @v_other_adjustments
    
  SET @o_result = @v_total_expenses
  
END
GO

GRANT EXEC ON qpl_calc_stg_op_exp_wo_ga_UCAL TO PUBLIC
GO
