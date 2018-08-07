IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_ver_Net_Profit_Percent_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_ver_Net_Profit_Percent_IP]
GO



Create PROCEDURE qpl_calc_ver_Net_Profit_Percent_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion	INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_ver_Net_Profit_Percent_IP

**  Desc: Net Profit/Total Income

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  
  @v_Net_Profit FLOAT,
  @v_Total_Income FLOAT,
  @v_Net_Profit_Percent FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Stage - Net Profit
  
  EXEC qpl_calc_ver_Net_Profit_IP   @i_projectkey, @i_plstage,@i_plversion, @v_Net_Profit OUTPUT
  

  IF @v_Net_Profit IS NULL

    SET @v_Net_Profit = 0

    

  -- Stage - TOTAL Income

  EXEC qpl_calc_ver_tot_inc  @i_projectkey, @i_plstage,@i_plversion, @v_Total_income OUTPUT
  



  IF @v_Total_income IS NULL

    SET @v_Total_income = 0

  

  If @v_Total_income=0
  Return 0

  SET @v_Net_Profit_Percent = @v_Net_Profit / @v_Total_income

  SET @o_result = @v_Net_Profit_Percent

  

END

Go
Grant all on qpl_calc_ver_Net_Profit_Percent_IP to public