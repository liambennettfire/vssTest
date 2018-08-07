if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_inc_profit_UCAL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_inc_profit_UCAL
GO

CREATE PROCEDURE dbo.qpl_calc_yr_inc_profit_UCAL (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,    
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_op_profit_UCAL
**  Desc: UCAL Version/Operating Profit Calculation
**
**  Auth: tt	
**  Date: March 8, 2011
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,  
  @v_total_op_exp FLOAT,
  @v_total_op_profit FLOAT

BEGIN

  SET @v_total_op_profit = 0
  SET @o_result = NULL
  
 
  -- Version - Gross Margin 
  EXEC qpl_calc_yr_gross_marg_UCAL @i_projectkey, @i_plstage, @i_plversion, @i_yearcode,  @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
   
  -- Version - Total Operating Expenses 
  EXEC qpl_calc_yr_op_exp_wo_ga_UCAL @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_op_exp OUTPUT

  IF @v_total_op_exp IS NULL
    SET @v_total_op_exp = 0


  SET @v_total_op_profit = @v_gross_margin - @v_total_op_exp     
  SET @o_result = @v_total_op_profit 
  
END
GO
GRANT EXEC ON qpl_calc_yr_inc_profit_UCAL TO PUBLIC
GO