if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_cons_stg_gross_marg_pct') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_cons_stg_gross_marg_pct
GO

CREATE PROCEDURE qpl_calc_cons_stg_gross_marg_pct (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_display_currency INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_cons_stg_gross_marg_pct
**  Desc: Consolidated Stage/Gross Margin %.
**
**  Auth: Kate
**  Date: February 26 2014
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_gross_margin_percent FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Cons Stage - TOTAL Income
  EXEC qpl_calc_consolidated_stage @i_projectkey, @i_plstage, 7, @i_display_currency, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Cons Stage - Gross Margin
  EXEC qpl_calc_consolidated_stage @i_projectkey, @i_plstage, 13, @i_display_currency, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
  
  IF @v_total_income = 0
    SET @v_gross_margin_percent = 0
  ELSE
    SET @v_gross_margin_percent = @v_gross_margin / @v_total_income
    
  SET @o_result = @v_gross_margin_percent
  
END
GO

GRANT EXEC ON qpl_calc_cons_stg_gross_marg_pct TO PUBLIC
GO