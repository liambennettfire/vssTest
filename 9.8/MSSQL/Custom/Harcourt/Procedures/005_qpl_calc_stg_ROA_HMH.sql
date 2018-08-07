if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc082') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc082
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_ROA_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_ROA_HMH
GO

CREATE PROCEDURE qpl_calc_stg_ROA_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_ROA_HMH
**  Desc: Houghton Mifflin Item 82 - Stage/ROA.
**
**  Auth: Kate
**  Date: February 25 2010
*******************************************************************************************/

DECLARE
  @v_operating_profit FLOAT,
  @v_production_cost  FLOAT,
  @v_roa  FLOAT,
  @v_total_advance  FLOAT
  
BEGIN

  SET @o_result = NULL
  
  -- Stage - Operating Profit  
  EXEC qpl_calc_stg_op_prof_HMH @i_projectkey, @i_plstage, @v_operating_profit OUTPUT

  IF @v_operating_profit IS NULL
    SET @v_operating_profit = 0
    
  -- Stage - Prepress & PPBF (production costs)
  EXEC qpl_calc_stg_pre_PPBF @i_projectkey, @i_plstage, @v_production_cost OUTPUT

  IF @v_production_cost IS NULL
    SET @v_production_cost = 0
    
  -- Stage - Total Advance
  EXEC qpl_calc_stg_roy_adv @i_projectkey, @i_plstage, @v_total_advance OUTPUT

  IF @v_total_advance IS NULL
    SET @v_total_advance = 0    
 
  IF @v_total_advance + @v_production_cost = 0
    SET @v_roa = 0
  ELSE
    SET @v_roa = @v_operating_profit / (@v_total_advance + @v_production_cost)
    
  SET @o_result = @v_roa
  
END
GO

GRANT EXEC ON qpl_calc_stg_ROA_HMH TO PUBLIC
GO
