if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_stg_cv_pctof_netsales') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_stg_cv_pctof_netsales
GO

CREATE PROCEDURE qpl_calc_stg_cv_pctof_netsales (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_clientvalue VARCHAR(50),
  @i_placctgcategory VARCHAR(50),
  @i_placctgsubcategory VARCHAR(50),	
  @i_incomeind  TINYINT,
  @o_result     FLOAT OUTPUT)
AS

/**********************************************************************************************
**  Name: qpl_calc_stg_cv_pctof_netsales
**  Desc: Generic Stage calculation which which multiples a client value * net sales if not in
**        actual stage or if actual sums up costs or income records for all chargecodes
**        in the given P&L Accounting Category/Subcategory.
**
**  Auth: SLB
**  Date: February 23 2011
***********************************************************************************************/

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
      IF @i_incomeind = 1
        IF @i_placctgsubcategory IS NULL
          SELECT @o_result = SUM(i.amount)
          FROM taqplincome_actual i, cdlist cd
          WHERE i.acctgcode = cd.internalcode AND
                i.taqprojectkey = @i_projectkey AND
                cd.placctgcategorycode IN 
                  (SELECT datacode FROM gentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory)
        ELSE
          SELECT @o_result = SUM(i.amount)
          FROM taqplincome_actual i, cdlist cd
          WHERE i.acctgcode = cd.internalcode AND
                i.taqprojectkey = @i_projectkey AND
                cd.placctgcategorycode IN
                  (SELECT datacode FROM gentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory) AND
                cd.placctgcategorysubcode IN
                  (SELECT datasubcode FROM subgentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgsubcategory)        
      ELSE  --Expenses
        IF @i_placctgsubcategory IS NULL
          SELECT @o_result = SUM(c.amount)
          FROM taqplcosts_actual c, cdlist cd
          WHERE c.acctgcode = cd.internalcode AND
                c.taqprojectkey = @i_projectkey AND
                cd.placctgcategorycode IN 
                  (SELECT datacode FROM gentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory)
        ELSE        
          SELECT @o_result = SUM(c.amount)
          FROM taqplcosts_actual c, cdlist cd
          WHERE c.acctgcode = cd.internalcode AND
                c.taqprojectkey = @i_projectkey AND
                cd.placctgcategorycode IN 
                  (SELECT datacode FROM gentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory) AND
                cd.placctgcategorysubcode IN
                  (SELECT datasubcode FROM subgentables 
                   WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgsubcategory)
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

      -- Version Calc by Summary Item Code
      EXEC qpl_calc_ver_cv_pctof_netsales @i_projectkey, @i_plstage, @v_selected_versionkey, 
        @i_clientvalue, @o_result OUTPUT
    END
  
END
GO
GO

GRANT EXEC ON qpl_calc_stg_cv_pctof_netsales TO PUBLIC
GO
