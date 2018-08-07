IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_Profit_Loss_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_Profit_Loss_IP]
GO



CREATE PROCEDURE qpl_calc_yr_Profit_Loss_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT, 

  @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_Profit_Loss_IP

**  Desc: Gross Margin - Total Operating Expenses


**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  @v_gross_margin FLOAT,
  @v_Total_operating_Expenses FLOAT,
  @v_Total_Profit_Lost FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Year - Gross margin

  EXEC qpl_calc_yr_gross_marg_IP @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_gross_margin OUTPUT
  



  IF @v_gross_margin IS NULL

    SET @v_gross_margin = 0

    

  -- Year - TOTAL Operating Expenses
  
  EXEC qpl_calc_yr_tot_exp_IP @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_Total_operating_Expenses OUTPUT
  



  IF @v_Total_operating_Expenses IS NULL

    SET @v_Total_operating_Expenses = 0

  

  SET @v_Total_Profit_Lost = @v_gross_margin - @v_Total_operating_Expenses

  SET @o_result = @v_Total_Profit_Lost

  

END

Go
Grant all on qpl_calc_yr_Profit_Loss_IP to public