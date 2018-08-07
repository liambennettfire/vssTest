IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_Profit_Loss_Percent_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_Profit_Loss_Percent_IP]
GO




Create PROCEDURE qpl_calc_yr_Profit_Loss_Percent_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion  INT, 

   @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_Profit_Loss_Percent_IP

**  Desc: Profit (Loss)/Total Income


**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  
  @v_Total_Profit_Lost FLOAT,
  @v_Total_income FLOAT,
  @v_Profit_loss_Percent FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Year - Profit Loss
  
  EXEC qpl_calc_yr_Profit_Loss_IP  @i_projectkey, @i_plstage,@i_plversion, @i_yearcode, @v_Total_Profit_Lost OUTPUT
  



  IF @v_Total_Profit_Lost IS NULL

    SET @v_Total_Profit_Lost = 0

    

  -- Year - TOTAL Income

  EXEC qpl_calc_yr_tot_inc  @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_Total_income OUTPUT
  



  IF @v_Total_income IS NULL

    SET @v_Total_income = 0

  

  If @v_Total_income=0
  Return 0

  SET @v_Profit_loss_Percent = @v_Total_Profit_Lost / @v_Total_income

  SET @o_result = @v_Profit_loss_Percent

  

END

Go
Grant all on qpl_calc_yr_Profit_Loss_Percent_IP to public