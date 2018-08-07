if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc143') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc143
GO
 
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_fgt_dlvry_KAP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_fgt_dlvry_KAP
GO

CREATE PROCEDURE qpl_calc_stg_fgt_dlvry_KAP (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_fgt_dlvry_KAP
**  Desc: Kaplan Item 143 - Stage/Freight & Delivery.
**
**  Auth: Kate
**  Date: November 8 2010
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
  @v_freightdeliv_amount  FLOAT,
  @v_freightdeliv_percent FLOAT,
  @v_gross_sales FLOAT,
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
      -- Stage - Gross Sales
      EXEC qpl_calc_stg_gross_sales @i_projectkey, @i_plstage, @v_gross_sales OUTPUT
      
      IF @v_gross_sales IS NULL
        SET @v_gross_sales = 0  
          
      SELECT @v_freightdeliv_percent = v.clientvalue
      FROM gentables g 
        LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
          v.taqprojectkey = @i_projectkey AND
          v.plstagecode = @i_plstage AND
          v.taqversionkey = @v_selected_versionkey
      WHERE g.tableid = 614 AND g.datacode = 4

      IF @v_freightdeliv_percent IS NULL
        SET @v_freightdeliv_percent = 0
        
      SET @v_freightdeliv_amount = (@v_freightdeliv_percent / 100) * @v_gross_sales      
      SET @o_result = @v_freightdeliv_amount     
    END
  ELSE
    BEGIN       
      -- Version/Freight & Delivery
      EXEC qpl_calc_ver_fgt_dlvry_KAP @i_projectkey, @i_plstage, @v_selected_versionkey, @o_result OUTPUT
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_fgt_dlvry_KAP TO PUBLIC
GO
