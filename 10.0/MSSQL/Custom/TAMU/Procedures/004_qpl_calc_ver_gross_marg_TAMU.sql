if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc029') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc029
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_TAMU') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_TAMU
GO

CREATE PROCEDURE qpl_calc_ver_gross_marg_TAMU (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg_TAMU
**  Desc: Texas A&M Item 29 - Version/Gross Margin.
**
**  Auth: Kate
**  Date: January 20 2011
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_total_expense FLOAT,
  @v_total_income FLOAT,
  @v_writeoffs FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Version - TOTAL Income
  EXEC qpl_calc_ver_tot_inc @i_projectkey, @i_plstage, @i_plversion, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Version - TOTAL Expenses
  EXEC qpl_calc_ver_tot_exp @i_projectkey, @i_plstage, @i_plversion, @v_total_expense OUTPUT

  IF @v_total_expense IS NULL
    SET @v_total_expense = 0
  
  -- Version - Write-offs & Edit Comps
  EXEC qpl_calc_ver_wo_edt_comps @i_projectkey, @i_plstage, @i_plversion, @v_writeoffs OUTPUT
  
  IF @v_writeoffs IS NULL
    SET @v_writeoffs = 0
  
  SET @v_gross_margin = @v_total_income - (@v_total_expense - @v_writeoffs)
  SET @o_result = @v_gross_margin
  
END
GO

GRANT EXEC ON qpl_calc_ver_gross_marg_TAMU TO PUBLIC
GO
