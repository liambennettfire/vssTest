IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_gross_marg_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_gross_marg_IP]
GO


CREATE PROCEDURE qpl_calc_yr_gross_marg_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT,  

  @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_gross_marg_IP

**  Desc: Total Income - Total Cost of Sales

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  @v_gross_margin FLOAT,
  @v_total_income FLOAT,
  @v_total_Cost_of_Sales FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Year - TOTAL Income

  EXEC qpl_calc_yr_tot_inc @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_total_income OUTPUT



  IF @v_total_income IS NULL

    SET @v_total_income = 0

    

  -- Year - TOTAL Cost of Sales

  EXEC qpl_Calc_yr_Total_Cost_Of_Sales_IP @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_total_Cost_of_Sales OUTPUT



  IF @v_total_Cost_of_Sales IS NULL

    SET @v_total_Cost_of_Sales = 0

  

  SET @v_gross_margin = @v_total_income - @v_total_Cost_of_Sales

  SET @o_result = @v_gross_margin

  

END

Go
Grant all on qpl_calc_yr_gross_marg_IP to public