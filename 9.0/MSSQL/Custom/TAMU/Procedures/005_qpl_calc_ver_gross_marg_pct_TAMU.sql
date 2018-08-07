if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc030') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc030
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_gross_marg_pct_TAMU') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_gross_marg_pct_TAMU
GO

CREATE PROCEDURE qpl_calc_ver_gross_marg_pct_TAMU (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg_pct_TAMU
**  Desc: Island Press Item 30 - Version/Gross Margin %.
**
**  Auth: Kate
**  Date: February 4 2008
*******************************************************************************************/

DECLARE
  @v_gross_margin FLOAT,
  @v_gross_margin_percent FLOAT,
  @v_total_income FLOAT

BEGIN

  SET @o_result = NULL
 
  -- Version - TOTAL Income
  EXEC qpl_calc_ver_tot_inc @i_projectkey, @i_plstage, @i_plversion, @v_total_income OUTPUT

  IF @v_total_income IS NULL
    SET @v_total_income = 0
    
  -- Version - Gross Margin
  EXEC qpl_calc_ver_gross_marg_TAMU @i_projectkey, @i_plstage, @i_plversion, @v_gross_margin OUTPUT

  IF @v_gross_margin IS NULL
    SET @v_gross_margin = 0
  
  IF @v_total_income = 0
    SET @v_gross_margin_percent = 0
  ELSE
    SET @v_gross_margin_percent = @v_gross_margin / @v_total_income

  SET @o_result = @v_gross_margin_percent
  
END
GO

GRANT EXEC ON qpl_calc_ver_gross_marg_pct_TAMU TO PUBLIC
GO
