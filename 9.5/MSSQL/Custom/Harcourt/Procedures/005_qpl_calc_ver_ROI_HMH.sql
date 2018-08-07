if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc070') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc070
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_ROI_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_ROI_HMH
GO

CREATE PROCEDURE qpl_calc_ver_ROI_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_ROI_HMH
**  Desc: Houghton Mifflin Item 70 - Version/ROI.
**
**  Auth: Kate
**  Date: February 25 2010
*******************************************************************************************/

DECLARE
  @v_operating_profit FLOAT,
  @v_roi  FLOAT,
  @v_total_costs  FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Version - Operating Profit  
  EXEC qpl_calc_ver_op_prof_HMH @i_projectkey, @i_plstage, @i_plversion, @v_operating_profit OUTPUT

  IF @v_operating_profit IS NULL
    SET @v_operating_profit = 0
    
  -- Version - Total Costs 
  EXEC qpl_calc_ver_tot_exp_HMH @i_projectkey, @i_plstage, @i_plversion, @v_total_costs OUTPUT

  IF @v_total_costs IS NULL
    SET @v_total_costs = 0    
 
  IF @v_total_costs = 0
    SET @v_roi = 0
  ELSE
    SET @v_roi = @v_operating_profit / @v_total_costs
    
  SET @o_result = @v_roi
  
END
GO

GRANT EXEC ON qpl_calc_ver_ROI_HMH TO PUBLIC
GO
