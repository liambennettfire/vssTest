IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_Calc_stg_Total_Cost_Of_Sales_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_Calc_stg_Total_Cost_Of_Sales_IP]
GO



  


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[qpl_Calc_stg_Total_Cost_Of_Sales_IP] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_Calc_stg_Total_Cost_Of_Sales_IP
**  COGS + Inventory Write Offs + Royalty Earnings + Royalty Write-Off

**
**  Auth: Jason
**  Date: August  2014
*******************************************************************************************/

DECLARE
 @v_COGS FLOAT,
 @v_Inventory_Write_OFFS FLOAT,
 @v_Royalty_Earned FLOAT,
 @v_Royalty_Write_OFF FLOAT,
 @v_Total_Cost_Of_Sales FLOAT

BEGIN

  SET @o_result = NULL

  --Stage COGS
  EXEC qpl_Calc_stg_COGS_IP @i_projectkey, @i_plstage, @v_COGS OUTPUT
  
  If @v_COGS is null
  SET @v_COGS=0

    -- Stage - Inventory Write Offs
  EXEC qpl_Calc_stg_Inventory_Write_Off_IP @i_projectkey, @i_plstage, @v_Inventory_Write_OFFS OUTPUT

  IF @v_Inventory_Write_OFFS is null
  SET @v_Inventory_Write_OFFS=0
  
	-- Stage Royalties Earned
  EXEC qpl_calc_stg_roy_ern @i_projectkey, @i_plstage, @v_Royalty_Earned OUTPUT
   
   IF @v_Royalty_Earned is null
   SET @v_Royalty_Earned=0
  
  
  -- Stage Royalty Write OFF
  EXEC qpl_Calc_stg_Royalty_Write_Off_IP @i_projectkey, @i_plstage, @v_Royalty_Write_OFF OUTPUT

  IF @v_Royalty_Write_OFF IS NULL
    SET @v_Royalty_Write_OFF = 0


  SET @v_Total_Cost_Of_Sales=@v_COGS + @v_Inventory_Write_OFFS + @v_Royalty_Earned + @v_Royalty_Write_OFF
  SET @o_result = @v_Total_Cost_Of_Sales
  
END

GO

GRANT ALL ON qpl_Calc_stg_Total_Cost_Of_Sales_IP TO PUBLIC
