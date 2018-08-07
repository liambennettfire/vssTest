if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_tot_op_exp_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_tot_op_exp_RUP
GO

CREATE PROCEDURE qpl_calc_ver_tot_op_exp_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_tot_op_exp_RUP
**  Desc: P&L - version/TOTAL Operating Expenses for Rutgers.  
**
**  Auth: SLB	
**  Date: February 23 2011
*******************************************************************************************/

DECLARE
  @v_fulfillment  FLOAT,
  @v_commission FLOAT,
  @v_honoraria  FLOAT,
  @v_copyed FLOAT,
  @v_design FLOAT,
  @v_other FLOAT,
  @v_overhead FLOAT,
  @v_total_op_expenses FLOAT

BEGIN

  SET @v_total_op_expenses = 0
  SET @o_result = NULL
  
  -- version - Fulfillment Costs
  EXEC qpl_calc_ver_fulfill @i_projectkey, @i_plstage, @i_plversion, @v_fulfillment OUTPUT

  IF @v_fulfillment IS NULL
    SET @v_fulfillment = 0    
  
  -- version - Commission
  EXEC qpl_calc_ver_cv_pctof_netsales @i_projectkey, @i_plstage, @i_plversion, 'COMM', @v_commission OUTPUT
 
  IF @v_commission IS NULL
    SET @v_commission = 0    
  
  -- version - Honoraria
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion,  'MISCEXP', 'HONOR', 0, @v_honoraria OUTPUT
  
  IF @v_honoraria IS NULL
    SET @v_honoraria = 0
      
  -- version - Copy Edit/Proof
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion,  'MISCEXP', 'PROOF', 0, @v_copyed OUTPUT
  
  IF @v_copyed  IS NULL
    SET @v_copyed  = 0  

  -- version - Design 
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion,  'MISCEXP', 'DESIGN', 0, @v_design OUTPUT
  
  IF @v_design  IS NULL
    SET @v_design  = 0
 
 -- version - Other Costs
  EXEC qpl_calc_version @i_projectkey, @i_plstage, @i_plversion, 'MISCEXP', 'OTHEXP', 0, @v_other OUTPUT
  
  IF @v_other IS NULL
    SET @v_other = 0

 -- version - Overhead
  EXEC qpl_calc_ver_cv_pctof_netsales @i_projectkey, @i_plstage, @i_plversion,  'OVERHEAD', @v_overhead OUTPUT  
  
  IF @v_overhead  IS NULL
    SET @v_overhead = 0

  SET @v_total_op_expenses = @v_fulfillment + @v_commission + @v_honoraria + @v_copyed + @v_design + @v_other + @v_overhead
    
  SET @o_result = @v_total_op_expenses
  
END
GO

GRANT EXEC ON qpl_calc_ver_tot_op_exp_RUP TO PUBLIC
GO
