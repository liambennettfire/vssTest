IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_yr_Unsold_Inventory_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_yr_Unsold_Inventory_IP]
GO


Create PROCEDURE qpl_calc_yr_Unsold_Inventory_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion	INT,

  @i_yearcode INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_yr_Unsold_Inventory_IP

**  Desc: Production Expense - COGS

**

**  Auth: Jason

**  Date: August 2014

*******************************************************************************************/



DECLARE

  
 @v_Production_Expense FLOAT,
 @v_COGS FLOAT,
 @v_Insold_Inventory FLOAT





BEGIN



  SET @o_result = NULL

  

  -- Year - Production Expense
  
  EXEC qpl_calc_yr_Profit_Loss_IP  @i_projectkey, @i_plstage,@i_plversion,@i_yearcode, @v_Production_Expense OUTPUT
  



  IF @v_Production_Expense IS NULL

    SET @v_Production_Expense = 0

    

  -- Year - COGS

  EXEC qpl_calc_yr_tot_inc  @i_projectkey,@i_plversion, @i_plstage,@i_yearcode, @v_COGS OUTPUT
  



  IF @v_COGS IS NULL

    SET @v_COGS = 0

 

  SET @v_Insold_Inventory = @v_Production_Expense  - @v_COGS

  SET @o_result = @v_Insold_Inventory

  

END

Go
Grant all on qpl_calc_yr_Unsold_Inventory_IP to public