IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_stg_Unsold_Inventory_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_stg_Unsold_Inventory_IP]
GO



Create PROCEDURE qpl_calc_stg_Unsold_Inventory_IP (  

  @i_projectkey INT,

  @i_plstage    INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_calc_stg_Unsold_Inventory_IP

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

  

  -- Stage - Production Expense
  
  EXEC qpl_calc_stg_Profit_Loss_IP  @i_projectkey, @i_plstage, @v_Production_Expense OUTPUT
  



  IF @v_Production_Expense IS NULL

    SET @v_Production_Expense = 0

    

  -- Stage - COGS

  EXEC qpl_calc_stg_tot_inc  @i_projectkey, @i_plstage, @v_COGS OUTPUT
  



  IF @v_COGS IS NULL

    SET @v_COGS = 0

 

  SET @v_Insold_Inventory = @v_Production_Expense  - @v_COGS

  SET @o_result = @v_Insold_Inventory

  

END

Go
Grant all on qpl_calc_stg_Unsold_Inventory_IP to public