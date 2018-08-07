

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_Calc_ver_Inventory_Write_Off_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_Calc_ver_Inventory_Write_Off_IP]
GO




CREATE PROCEDURE [dbo].[qpl_Calc_ver_Inventory_Write_Off_IP] (  

  @i_projectkey INT,

  @i_plstage    INT,

  @i_plversion INT,

  @o_result     FLOAT OUTPUT)

AS



/******************************************************************************************

**  Name: qpl_Calc_ver_Inventory_Write_Off_IP

**  (Production Units - Net Units - comp units) * production unit cost



**

**  Auth: Jason

**  Date: August  2014

*******************************************************************************************/



DECLARE

  @v_Prepress_PPBF FLOAT,

  @v_total_Production_Units INT,

  @v_Total_net_Units	  FLOAT,

  @v_Total_Comp_Units	  FLOAT,

  @v_Production_unit_cost FLOAT,

  @v_Inventory_Write_OFF FLOAT



BEGIN



  SET @o_result = NULL



  --Version production Units

  EXEC qpl_calc_ver_tot_prod_unt @i_projectkey, @i_plstage,@i_plversion, @v_total_Production_Units OUTPUT

  

  If @v_total_Production_Units is null

  SET @v_total_Production_Units=0



    -- Version - TOTAL Net Units

  EXEC qpl_calc_ver_tot_net_unt @i_projectkey, @i_plstage, @i_plversion, @v_Total_net_Units OUTPUT



  IF @v_Total_net_Units is null

  SET @v_Total_net_Units=0

  

	-- Version - TOTAL Comp Units
	
  EXEC qpl_calc_ver_wo_edt_comps_units @i_projectkey, @i_plstage,@i_plversion, @v_Total_Comp_Units OUTPUT

   IF @v_Total_Comp_Units is null

   SET @v_Total_Comp_Units=0

  

  

  -- Version - Prepress & PPBF

  EXEC qpl_calc_version @i_projectkey, @i_plstage,@i_plversion, 'PRODEXP', NULL, 0, @v_Prepress_PPBF OUTPUT



  IF @v_Prepress_PPBF IS NULL

    SET @v_Prepress_PPBF = 0

  

  --Calculate production unit cost(Prepress&PPBF /Production Units

  IF @v_Prepress_PPBF <> 0 

  BEGIN

	SET @v_Production_unit_cost=@v_Prepress_PPBF/@v_total_Production_Units

  END    



  SET @v_Inventory_Write_OFF = (@v_total_Production_Units - @v_Total_net_Units - @v_Total_Comp_Units) *  @v_Production_unit_cost

  SET @o_result = @v_Inventory_Write_OFF

  

END


Go
Grant all on qpl_Calc_ver_Inventory_Write_Off_IP to Public