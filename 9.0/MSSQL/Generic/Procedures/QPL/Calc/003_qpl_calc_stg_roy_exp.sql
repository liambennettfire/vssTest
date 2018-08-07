if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc067') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc067
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_roy_exp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_roy_exp
GO

CREATE PROCEDURE qpl_calc_stg_roy_exp (  
  @i_projectkey INT,
  @i_plstage    INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_stg_roy_exp
**  Desc: P&L Item 67 - Stage/Royalty Expense
**
**  Auth: Kate
**  Date: February 9 2010
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
      SELECT @o_result = SUM(c.amount)
      FROM taqplcosts_actual c, cdlist cd
      WHERE c.acctgcode = cd.internalcode AND
            c.taqprojectkey = @i_projectkey AND
            cd.placctgcategorycode IN 
              (SELECT datacode FROM gentables 
               WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = 'ROYEXP')    
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

      -- Version/Royalty Expense
      EXEC qpl_calc_ver_roy_exp @i_projectkey, @i_plstage, @v_selected_versionkey, 0, @o_result OUTPUT
    END
  
END
GO

GRANT EXEC ON qpl_calc_stg_roy_exp TO PUBLIC
GO
