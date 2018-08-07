if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc001') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc001
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_tot_prod_unt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_tot_prod_unt
GO

CREATE PROCEDURE qpl_calc_stg_tot_prod_unt (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_tot_prod_unt
**  Desc: Island Press Item 1 - Stage/Total Production Units.
**
**  Auth: Kate
**  Date: March 24 2008
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
      SELECT @o_result = SUM(productionqty)
      FROM taqplproduction_actual
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

      SELECT @o_result = SUM(quantity)
      FROM taqversionformatyear
      WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @v_selected_versionkey
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_tot_prod_unt TO PUBLIC
GO
