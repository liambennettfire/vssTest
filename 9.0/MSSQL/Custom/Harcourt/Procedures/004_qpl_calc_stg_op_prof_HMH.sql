if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc084') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc084
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_op_prof_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_op_prof_HMH
GO

CREATE PROCEDURE qpl_calc_stg_op_prof_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_op_prof_HMH
**  Desc: Houghton Mifflin Item 84 - Stage/Operating Profit
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
  
  -- Stage - TOTAL Income
  EXEC qpl_calc_stg_tot_inc_HMH @i_projectkey, @i_plstage, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Stage - TOTAL Expenses
  EXEC qpl_calc_stg_tot_exp_HMH @i_projectkey, @i_plstage, @v_total_expense OUTPUT

  IF @v_total_expense IS NULL
    SET @v_total_expense = 0
  
  SET @v_operating_profit = @v_total_income - @v_total_expense
  SET @o_result = @v_operating_profit
  
END
GO

GRANT EXEC ON qpl_calc_stg_op_prof_HMH TO PUBLIC
GO
