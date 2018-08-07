if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc002') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc002
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_net_sales_unt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_net_sales_unt
GO

CREATE PROCEDURE qpl_calc_stg_net_sales_unt (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_net_sales_unt
**  Desc: Island Press Item 2 - Stage/Net Sales Units.
**
**  Auth: Kate
**  Date: January 29 2008
*******************************************************************************************/

DECLARE
  @v_actuals_stage  INT,
  @v_count  INT,
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
  
  IF @i_plstage = @v_actuals_stage
    BEGIN
      SELECT @o_result = SUM(grosssalesunits) - SUM(returnsalesunits)
      FROM taqplsales_actual
      WHERE taqprojectkey = @i_projectkey
    END
  ELSE
    BEGIN
      -- Get the selected versionkey for this stage
      SELECT @v_selected_versionkey = selectedversionkey
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

      -- If there is no selected version for this stage, return NULL
      IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL
        RETURN

      -- Version/Net Sales Units
      EXEC qpl_calc_ver_tot_net_unt @i_projectkey, @i_plstage, @v_selected_versionkey, @o_result OUTPUT
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_net_sales_unt TO PUBLIC
GO
