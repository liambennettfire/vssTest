IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qpl_get_taqversioncosts_by_format') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncosts_by_format
GO

CREATE PROCEDURE qpl_get_taqversioncosts_by_format (
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @i_category_qsicode integer,
  @o_error_code integer output,
  @o_error_desc VARCHAR(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversioncosts_by_format
**  Desc: This stored procedure returns taqversioncosts by format FOR a 
**  given projectkey, stage, version, AND format.
**
**  Pass IN a qsicode FOR a specific type of costs (0 returns ALL).
**
**  Auth: Alan Katzen
**  Date: November 6, 2007
**************************************************************************************
**	Change History
**************************************************************************************
**  Date	    Author  Description
**	--------	------	-----------
**  05/02/17  Colman  44464 - ** Changes removed **
**  08/12/17  Colman  46785 - Return all cost columns
**  05/08/18  Colman  51229 - Costs display -1 instead of no row for 0 costs 
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  IF @i_category_qsicode > 0 BEGIN  -- return costs FOR given category
    SELECT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey, f.taqversionformatyearkey, f.yearcode, g.sortorder, 
        c.acctgcode, c.versioncostsnote, ISNULL(c.versioncostsamount,0) versioncostsamount, ISNULL(c.unitcost,0) unitcost, ISNULL(c.compunitcost,0) compunitcost,
        c.acceptgenerationind, c.templatechangedind, c.printingnumber, c.taqversionspeccategorykey, c.plcalccostcode, c.plcalccostsubcode, c.pocostind
    FROM taqversionformatyear f, taqversioncosts c, cdlist cd, gentables g
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
        c.acctgcode = cd.internalcode AND
        f.yearcode = g.datacode AND
        g.tableid = 563 AND
        f.taqprojectkey = @i_projectkey AND
        f.plstagecode = @i_plstage AND 
        f.taqversionkey = @i_versionkey AND
        f.taqprojectformatkey = @i_formatkey AND
        cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = @i_category_qsicode)
  END 
  ELSE BEGIN  -- return all costs
    SELECT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey, f.taqversionformatyearkey, f.yearcode, g.sortorder, 
        c.acctgcode, c.versioncostsnote, ISNULL(c.versioncostsamount,0) versioncostsamount, ISNULL(c.unitcost,0) unitcost, ISNULL(c.compunitcost,0) compunitcost,
        c.acceptgenerationind, c.templatechangedind, c.printingnumber, c.taqversionspeccategorykey, c.plcalccostcode, c.plcalccostsubcode, c.pocostind
    FROM taqversionformatyear f, taqversioncosts c, gentables g
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
        f.yearcode = g.datacode AND
        g.tableid = 563 AND
        f.taqprojectkey = @i_projectkey AND
        f.plstagecode = @i_plstage AND 
        f.taqversionkey = @i_versionkey AND
        f.taqprojectformatkey = @i_formatkey 
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could NOT access taqversionformatyear/taqversioncosts tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC ON qpl_get_taqversioncosts_by_format TO PUBLIC
GO
