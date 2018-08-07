IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_calc_stg_roy_ern')
  DROP PROCEDURE qpl_calc_stg_roy_ern
GO

CREATE PROCEDURE [dbo].[qpl_calc_stg_roy_ern] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT,
  @i_roleSumItemCode VARCHAR(255) = NULL,
  @i_allIncludedInd INT = NULL)
AS

/**************************************************************************************************************************
**  Name: qpl_calc_stg_roy_ern
**  Desc: Island Press Item 10 - Stage/Royalty Earned.
**
**  Auth: Kate
**  Date: February 26 2008
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  01/09/2017  Josh G    Case 42565 Royalty Advances and Rates by contributor P&L Procedure changes 
**************************************************************************************************************************/

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
      SELECT @o_result = SUM(c.amount)
      FROM taqplcosts_actual c, cdlist cd
      WHERE c.acctgcode = cd.internalcode AND
            c.taqprojectkey = @i_projectkey AND
            cd.placctgcategorycode IN 
              (SELECT datacode FROM gentables 
               WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = 'ROYEARN')    
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

      -- Version/Royalties Earned
      EXEC qpl_calc_ver_roy_ern @i_projectkey, @i_plstage, @v_selected_versionkey, 0, @o_result OUTPUT, @i_roleSumItemCode, @i_allIncludedInd
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_roy_ern TO PUBLIC
GO