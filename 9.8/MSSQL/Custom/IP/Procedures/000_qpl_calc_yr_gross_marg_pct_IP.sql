IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_gross_marg_pct_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_gross_marg_pct_IP]
GO




CREATE PROCEDURE qpl_calc_yr_gross_marg_pct_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT,

  @i_yearcode   INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_gross_marg_pct_IP

**  Desc: P&L Item 60 - Year/Gross Margin %.

**

**  Auth: Kate

**  Date: November 20 2009

*******************************************************************************************/



DECLARE

  @v_gross_margin FLOAT,

  @v_gross_margin_percent FLOAT,

  @v_total_income FLOAT



BEGIN



  SET @o_result = NULL

 

  -- Year - TOTAL Income

  EXEC qpl_calc_yr_tot_inc @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_total_income OUTPUT



  IF @v_total_income IS NULL

    SET @v_total_income = 0

    

  -- Year - Gross Margin

  EXEC qpl_calc_yr_gross_marg_IP @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_gross_margin OUTPUT



  IF @v_gross_margin IS NULL

    SET @v_gross_margin = 0

  

  IF @v_total_income = 0

    SET @v_gross_margin_percent = 0

  ELSE

    SET @v_gross_margin_percent = @v_gross_margin / @v_total_income



  SET @o_result = @v_gross_margin_percent

  

END
Go
Grant all on qpl_calc_yr_gross_marg_pct_IP to public