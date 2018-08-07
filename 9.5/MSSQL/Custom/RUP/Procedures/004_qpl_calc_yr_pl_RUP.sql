if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_pl_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_pl_RUP
GO

CREATE PROCEDURE qpl_calc_yr_pl_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_pl_RUP
**  Desc: P&L - Year/Profit-Loss for Rutgers.
**        Profit/Loss = Total Income + Subsidy - Total Expense - Total Operating Expense   
**
**  Auth: SLB
**  Date: February 24 2011
*******************************************************************************************/

DECLARE
  @v_total_income FLOAT,
  @v_subsidy FLOAT,

  @v_total_expense FLOAT,
  @v_total_op_expense FLOAT,

  @v_pl FLOAT

BEGIN

  SET @o_result = NULL

  -- Year - Total Income
  EXEC qpl_calc_yr_tot_inc_RUP @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
  
  -- Year - Subsidy
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 'MISCINC', 'PRODSUB', 1, @v_subsidy OUTPUT

  IF @v_subsidy IS NULL
    SET @v_subsidy = 0

  -- Year - Total Expense
  EXEC qpl_calc_yr_tot_exp_RUP @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_expense OUTPUT

  IF @v_total_expense IS NULL
    SET @v_total_expense = 0

  -- Year - Total Operating Expense
  EXEC qpl_calc_yr_tot_op_exp_RUP @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_op_expense OUTPUT

  IF @v_total_op_expense IS NULL
    SET @v_total_op_expense = 0

  SET @v_pl = @v_total_income + @v_subsidy - @v_total_expense - @v_total_op_expense

  SET @o_result = @v_pl
  
END
GO

GRANT EXEC ON qpl_calc_yr_pl_RUP TO PUBLIC
GO
