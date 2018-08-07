IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_Calc_yr_COGS_IP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_Calc_yr_COGS_IP]
GO






/****** Object:  StoredProcedure [dbo].[qpl_Calc_yr_COGS_IP]    Script Date: 7/31/2014 2:51:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[qpl_Calc_yr_COGS_IP] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @i_yearcode INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_gross_marg
**  Desc: Island Press Item 29 - Version/Gross Margin.
**
**  Auth: Kate
**  Date: February 4 2008
*******************************************************************************************/

DECLARE
  @v_Prepress_PPBF FLOAT,
  @v_total_Production_Units INT,
  @v_Production_unit_cost FLOAT,
  @v_Total_net_Units	  FLOAT,
  @v_COGS FLOAT

BEGIN

  SET @o_result = NULL
  
  --Version production Units
  EXEC qpl_calc_yr_tot_prod_unt @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @v_total_Production_Units OUTPUT
  
  If @v_total_Production_Units is null
  SET @v_total_Production_Units=0
  
  
  -- Version - Prepress & PPBF
  EXEC qpl_calc_year @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, 'PRODEXP', NULL, 0, @v_Prepress_PPBF OUTPUT

  IF @v_Prepress_PPBF IS NULL
    SET @v_Prepress_PPBF = 0
  
  --Calculate production unit cost(Prepress&PPBF /Production Units
  IF @v_total_Production_Units <> 0 
  BEGIN
	SET @v_Production_unit_cost=@v_Prepress_PPBF/@v_total_Production_Units
  END    
  
  -- Version - TOTAL Net Units
  EXEC qpl_calc_yr_tot_net_unt @i_projectkey, @i_plstage, @i_plversion,@i_yearcode, @v_Total_net_Units OUTPUT

  IF @v_Total_net_Units is null
  SET @v_Total_net_Units=0

  
  
  SET @v_COGS = @v_Total_net_Units - @v_Production_unit_cost
  SET @o_result = @v_COGS
  
END

GO

GRANT ALL ON qpl_Calc_yr_COGS_IP TO PUBLIC
