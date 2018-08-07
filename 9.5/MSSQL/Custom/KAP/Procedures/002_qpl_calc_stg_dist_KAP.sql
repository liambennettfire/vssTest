if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc141') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc141
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_dist_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_dist_KAP
GO

CREATE PROCEDURE qpl_calc_stg_dist_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_dist_KAP
**  Desc: Kaplan Item 141 - Stage/Distribution.
**
**  Auth: Kate
**  Date: November 8 2010
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
  @v_distr_amount  FLOAT,
  @v_distr_percent FLOAT,
  @v_net_sales FLOAT,
  @v_selected_versionkey  INT

BEGIN

  SET @o_result = NULL
  
  -- Get the Actuals stage code
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 562 AND qsicode = 1
  
  IF @v_count > 0       
    SELECT @v_actuals_stage = datacode
    FROM gentables
    WHERE tableid = 562 AND qsicode = 1
  ELSE
    SET @v_actuals_stage = 0
    
  -- Get the selected versionkey for this stage
  SELECT @v_selected_versionkey = selectedversionkey
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

  -- If there is no selected version for this stage, return NULL
  IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL
    RETURN

  IF @i_plstage = @v_actuals_stage
    BEGIN
      -- Stage - Net Sales
      EXEC qpl_calc_stg_net_sales @i_projectkey, @i_plstage, @v_net_sales OUTPUT
      
      IF @v_net_sales IS NULL
        SET @v_net_sales = 0  
          
      SELECT @v_distr_percent = v.clientvalue
      FROM gentables g 
        LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
          v.taqprojectkey = @i_projectkey AND
          v.plstagecode = @i_plstage AND
          v.taqversionkey = @v_selected_versionkey
      WHERE g.tableid = 614 AND g.datacode = 2

      IF @v_distr_percent IS NULL
        SET @v_distr_percent = 0
        
      SET @v_distr_amount = (@v_distr_percent / 100) * @v_net_sales      
      SET @o_result = @v_distr_amount     
    END
  ELSE
    BEGIN       
      -- Version/Distribution
      EXEC qpl_calc_ver_dist_KAP @i_projectkey, @i_plstage, @v_selected_versionkey, @o_result OUTPUT
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_dist_KAP TO PUBLIC
GO
