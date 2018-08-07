if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_version_by_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_version_by_format
GO
 
CREATE PROCEDURE qpl_calc_version_by_format (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_formatkey  INT,
  @i_placctgcategory      VARCHAR(50),
  @i_placctgsubcategory   VARCHAR(50),  
  @i_incomeind  TINYINT,
  @o_result     FLOAT OUTPUT)
AS

/**********************************************************************************************
**  Name: qpl_calc_version_by_format
**  Desc: Generic Version calculation which sums up costs or income records for all chargecodes
**        in the given P&L Accounting Category/Subcategory for the given Format.
**
**  Auth: Kate
**  Date: April 1 2010
***********************************************************************************************/

DECLARE
  @v_total  FLOAT

BEGIN

  SET @o_result = NULL

  IF @i_incomeind = 1
    IF @i_placctgsubcategory IS NULL
      SELECT @v_total = SUM(i.incomeamount)
      FROM taqversionincome i, taqversionformatyear y, cdlist cd
      WHERE i.acctgcode = cd.internalcode AND
          i.taqversionformatyearkey = y.taqversionformatyearkey AND 
          y.taqprojectkey = @i_projectkey AND 
          y.plstagecode = @i_plstage AND 
          y.taqversionkey = @i_plversion AND
          y.taqprojectformatkey = @i_formatkey AND 
          cd.placctgcategorycode IN 
            (SELECT datacode FROM gentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory)
    ELSE
      SELECT @v_total = SUM(i.incomeamount)
      FROM taqversionincome i, taqversionformatyear y, cdlist cd
      WHERE i.acctgcode = cd.internalcode AND
          i.taqversionformatyearkey = y.taqversionformatyearkey AND 
          y.taqprojectkey = @i_projectkey AND 
          y.plstagecode = @i_plstage AND 
          y.taqversionkey = @i_plversion AND 
          y.taqprojectformatkey = @i_formatkey AND 
          cd.placctgcategorycode IN 
            (SELECT datacode FROM gentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory) AND
          cd.placctgcategorysubcode IN
            (SELECT datasubcode FROM subgentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgsubcategory)
  ELSE  --Expenses
    IF @i_placctgsubcategory IS NULL
      SELECT @v_total = SUM(c.versioncostsamount)
      FROM taqversioncosts c, taqversionformatyear y, cdlist cd
      WHERE c.acctgcode = cd.internalcode AND 
	        c.taqversionformatyearkey = y.taqversionformatyearkey AND
          y.taqprojectkey = @i_projectkey AND 
          y.plstagecode = @i_plstage AND 
          y.taqversionkey = @i_plversion AND
          y.taqprojectformatkey = @i_formatkey AND 
          cd.placctgcategorycode IN 
            (SELECT datacode FROM gentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory)
    ELSE   
      SELECT @v_total = SUM(c.versioncostsamount)
      FROM taqversioncosts c, taqversionformatyear y, cdlist cd
      WHERE c.acctgcode = cd.internalcode AND 
	        c.taqversionformatyearkey = y.taqversionformatyearkey AND
          y.taqprojectkey = @i_projectkey AND 
          y.plstagecode = @i_plstage AND 
          y.taqversionkey = @i_plversion AND
          y.taqprojectformatkey = @i_formatkey AND 
          cd.placctgcategorycode IN 
            (SELECT datacode FROM gentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory) AND
          cd.placctgcategorysubcode IN
            (SELECT datasubcode FROM subgentables 
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgsubcategory)
       
  SET @o_result = @v_total
  
END
GO

GRANT EXEC ON qpl_calc_version_by_format TO PUBLIC
GO
