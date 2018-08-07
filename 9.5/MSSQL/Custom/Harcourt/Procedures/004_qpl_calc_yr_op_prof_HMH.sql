if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc086') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc086
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_op_prof_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_op_prof_HMH
GO

CREATE PROCEDURE qpl_calc_yr_op_prof_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_op_prof_HMH
**  Desc: Houghton Mifflin Item 86 - Year/Operating Profit.
**
**  Auth: Kate
**  Date: February 25 2010
*******************************************************************************************/

DECLARE
  @v_operating_profit FLOAT,
  @v_total_expense FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Year - TOTAL Income
  EXEC qpl_calc_yr_tot_inc_HMH @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Year - TOTAL Expenses
  EXEC qpl_calc_yr_tot_exp_HMH @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_expense OUTPUT

  IF @v_total_expense IS NULL
    SET @v_total_expense = 0
  
  SET @v_operating_profit = @v_total_income - @v_total_expense
  SET @o_result = @v_operating_profit
  
END
GO

GRANT EXEC ON qpl_calc_yr_op_prof_HMH TO PUBLIC
GO
