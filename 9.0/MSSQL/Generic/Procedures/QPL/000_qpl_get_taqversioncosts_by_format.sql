if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversioncosts_by_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncosts_by_format
GO

CREATE PROCEDURE qpl_get_taqversioncosts_by_format (
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @i_category_qsicode integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversioncosts_by_format
**  Desc: This stored procedure returns taqversioncosts by format for a 
**  given projectkey, stage, version, and format.
**
**  Pass in a qsicode for a specific type of costs (0 returns ALL).
**
**  Auth: Alan Katzen
**  Date: November 6, 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
       
  IF @i_category_qsicode > 0 BEGIN  -- return costs for given category
    SELECT f.taqversionformatyearkey, f.yearcode, g.sortorder, 
        c.acctgcode, c.versioncostsnote, c.versioncostsamount, c.unitcost, c.compunitcost,
        c.acceptgenerationind, c.templatechangedind, c.printingnumber, c.taqversionspeccategorykey
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
    SELECT f.taqversionformatyearkey, f.yearcode, g.sortorder, 
        c.acctgcode, c.versioncostsnote, c.versioncostsamount, c.unitcost, c.compunitcost,
        c.acceptgenerationind, c.templatechangedind, c.printingnumber, c.taqversionspeccategorykey
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
    SET @o_error_desc = 'Could not access taqversionformatyear/taqversioncosts tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC ON qpl_get_taqversioncosts_by_format TO PUBLIC
GO
