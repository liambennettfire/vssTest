/****** Object:  UserDefinedFunction [dbo].[rpt_qpl_calc_version_by_format]    Script Date: 04/13/2010 10:06:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_qpl_calc_version_by_format]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_qpl_calc_version_by_format]
GO
CREATE FUNCTION [dbo].[rpt_qpl_calc_version_by_format] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_formatkey  INT,
  @i_placctgcategory      VARCHAR(50),
  @i_placctgsubcategory   VARCHAR(50),  
  @i_incomeind  TINYINT)

RETURNS FLOAT 
AS

/**********************************************************************************************
**  Name: [rpt_qpl_calc_version_by_format]
**  Desc: Generic Version calculation which sums up costs or income records for all chargecodes
**        in the given P&L Accounting Category/Subcategory for the given Format.
**
**  Auth: Paul
**  Date: April 1 2010
***********************************************************************************************/
BEGIN

DECLARE @v_total FLOAT
DECLARE @RETURN FLOAT

  
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
       
  SET @RETURN = @v_total

  RETURN @RETURN
  
END
