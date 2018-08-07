IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_Net_Profit_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_Net_Profit_IP]
GO




CREATE PROCEDURE qpl_calc_yr_Net_Profit_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion	INT,

  @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_Net_Profit_IP

**  Desc: Profit (Loss) - Corporate Overhead

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  @v_Profit_loss FLOAT,
  @v_Corporate_Overhead FLOAT,
  @v_Net_Profit FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Stage - Profit Loss
  
  EXEC qpl_calc_yr_Profit_Loss_IP  @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_Profit_loss OUTPUT
  

  IF @v_Profit_loss IS NULL

    SET @v_Profit_loss = 0

    
  -- Stage - Corporate Overhead
  
  EXEC qpl_calc_yr_Corporate_Overhead_IP  @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_Corporate_Overhead OUTPUT
  



  IF @v_Corporate_Overhead IS NULL

    SET @v_Corporate_Overhead = 0

  

  SET @v_Net_Profit = @v_Profit_loss - @v_Corporate_Overhead

  SET @o_result = @v_Net_Profit

  

END

Go
Grant all on qpl_calc_yr_Net_Profit_IP to public