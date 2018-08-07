IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_stg_gross_marg_pct_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_stg_gross_marg_pct_IP]
GO



CREATE PROCEDURE qpl_calc_stg_gross_marg_pct_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_stg_gross_marg_pct

**  Desc: Island Press Item 13 - Stage/Gross Margin %.

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

  

  -- Stage - TOTAL Income

  EXEC qpl_calc_stg_tot_inc @i_projectkey, @i_plstage, @v_total_income OUTPUT



  IF @v_total_income IS NULL

    SET @v_total_income = 0

    

  -- Stage - Gross Margin

  EXEC qpl_calc_stg_gross_marg_IP @i_projectkey, @i_plstage, @v_gross_margin OUTPUT



  IF @v_gross_margin IS NULL

    SET @v_gross_margin = 0

  

  IF @v_total_income = 0

    SET @v_gross_margin_percent = 0

  ELSE

    SET @v_gross_margin_percent = @v_gross_margin / @v_total_income

    

  SET @o_result = @v_gross_margin_percent

  

END

Go
Grant all on qpl_calc_stg_gross_marg_pct_IP to public

