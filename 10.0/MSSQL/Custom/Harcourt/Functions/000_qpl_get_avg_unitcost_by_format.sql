if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_avg_unitcost_by_format') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_avg_unitcost_by_format
GO

CREATE FUNCTION dbo.qpl_get_avg_unitcost_by_format
(
  @i_projectkey as integer,
  @i_plstagecode as integer,
  @i_versionkey as integer,
  @i_formatkey as integer
) 
RETURNS FLOAT

/*******************************************************************************************************
**  Name: qpl_get_avg_unitcost_by_format
**  Desc: This function returns the Average Unit Cost for given Format (from all years).
**
**  Auth: Kate Wiewiora
**  Date: March 30 2010
*******************************************************************************************************/

BEGIN 
  DECLARE
  @v_avg_unitcost FLOAT,
  @v_count  INT,
  @v_sum_amt  FLOAT,
  @v_sum_qty  INT
  
  -- First check if costs exist for this Format
  SELECT @v_count = COUNT(*)
  FROM taqversionformatyear y, taqversioncosts c
  WHERE y.taqversionformatyearkey = c.taqversionformatyearkey AND
      y.taqprojectformatkey = @i_formatkey AND 
      c.printingnumber > 0
  
  IF @v_count = 0
    RETURN 0   -- no costs for this Format - return 0 unit cost 
  
  -- Get the sum of production quantities for this Format
  SELECT @v_sum_qty = SUM(y.quantity)
  FROM taqversionformatyear y
  WHERE y.taqprojectkey = @i_projectkey AND
    y.plstagecode = @i_plstagecode AND 
    y.taqversionkey = @i_versionkey AND
    y.taqprojectformatkey = @i_formatkey AND
    y.printingnumber > 0
        
  -- Get the sum of Total costs for chargecodes in the Production Unit Cost cagetory
  SELECT @v_sum_amt = SUM(c.versioncostsamount)
  FROM taqversioncosts c, taqversionformatyear y, cdlist cd
  WHERE c.acctgcode = cd.internalcode AND 
    c.taqversionformatyearkey = y.taqversionformatyearkey AND
    y.taqprojectkey = @i_projectkey AND 
    y.plstagecode = @i_plstagecode AND 
    y.taqversionkey = @i_versionkey AND 
    y.taqprojectformatkey = @i_formatkey AND
    cd.placctgcategorycode IN 
      (SELECT datacode FROM gentables 
      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = 'PRODEXP') AND
    cd.placctgcategorysubcode IN
      (SELECT datasubcode FROM subgentables 
      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = 'UNITCOST')   

  SET @v_avg_unitcost = @v_sum_amt / @v_sum_qty
  RETURN @v_avg_unitcost

END
GO

GRANT EXEC ON dbo.qpl_get_avg_unitcost_by_format TO public
GO
