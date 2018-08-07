IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_ver_Net_Cash_Flow_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_ver_Net_Cash_Flow_IP]
GO





CREATE PROCEDURE qpl_calc_ver_Net_Cash_Flow_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion	INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_ver_Net_Cash_Flow_IP

**  Desc: Net Profit - Unsold Inventory - Unearned Advance

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  @v_Net_profit FLOAT,
  @v_Unsold_Inventory FLOAT,
  @v_Unearned_Advance FLOAT,
  @v_Net_Cash_Flow	  FLOAT


BEGIN



  SET @o_result = NULL

  

  -- Version - Net Profit
  
  EXEC qpl_calc_ver_Net_Profit_IP   @i_projectkey, @i_plstage,@i_plversion, @v_Net_profit OUTPUT
  

  IF @v_Net_profit IS NULL

    SET @v_Net_profit = 0

    
  -- Version - Unsold Inventory
  
  EXEC qpl_calc_ver_Unsold_Inventory_IP   @i_projectkey, @i_plstage,@i_plversion, @v_Unsold_Inventory OUTPUT
  

  IF @v_Unsold_Inventory IS NULL

    SET @v_Unsold_Inventory = 0


  -- Version - Unearned Advance
  
  EXEC qpl_calc_ver_Unearned_Advance_IP   @i_projectkey, @i_plstage,@i_plversion, @v_Unearned_Advance OUTPUT
  



  IF @v_Unearned_Advance IS NULL

    SET @v_Unearned_Advance = 0
  

  SET @v_Net_Cash_Flow = @v_Net_profit - @v_Unsold_Inventory - @v_Unearned_Advance

  SET @o_result = @v_Net_Cash_Flow

  

END

Go
Grant all on qpl_calc_ver_Net_Cash_Flow_IP to public