

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_RUP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_RUP
GO

CREATE PROCEDURE qpl_calc_ver_gross_marg_RUP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg_RUP
**  Desc: Version/Gross Margin for Rutgers.
**
**  Auth: slb
**  Date: April 7, 2011
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_total_expense FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Version - TOTAL Income
  EXEC qpl_calc_ver_tot_inc_RUP @i_projectkey, @i_plstage, @i_plversion, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Version - TOTAL Expenses
  EXEC qpl_calc_ver_tot_exp_RUP @i_projectkey, @i_plstage, @i_plversion, @v_total_expense OUTPUT

  IF @v_total_expense IS NULL
    SET @v_total_expense = 0
  
  SET @v_gross_margin = @v_total_income - @v_total_expense
  SET @o_result = @v_gross_margin
  
END
GO

GRANT EXEC ON qpl_calc_ver_gross_marg_RUP TO PUBLIC
GO
