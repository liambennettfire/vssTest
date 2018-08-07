if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc039') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc039
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_sub_rights_exp_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_sub_rights_exp_HMH
GO


CREATE PROCEDURE qpl_calc_stg_sub_rights_exp_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_sub_rights_exp_HMH
**  Desc: Houghton Mifflin Item 39 - Stage/Subsidiary Rights Expenses.
**
**  Auth: Kate
**  Date: November 10 2009
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
    EXEC qpl_calc_stage @i_projectkey, @i_plstage, 'SUBEXP', NULL, 0, @o_result OUTPUT
  ELSE
    BEGIN
      -- Get the selected versionkey for this stage
      SELECT @v_selected_versionkey = selectedversionkey
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

      -- If there is no selected version for this stage, return NULL
      IF @v_selected_versionkey = 0 OR @v_selected_versionkey IS NULL
        RETURN
        
      -- Version/Subsidiary Rights Expense
      EXEC qpl_calc_ver_sub_rights_exp_HMH @i_projectkey, @i_plstage, @v_selected_versionkey, @o_result OUTPUT
    END
  
END
GO
GO

GRANT EXEC ON qpl_calc_stg_sub_rights_exp_HMH TO PUBLIC
GO
