
GO
/****** Object:  UserDefinedFunction [dbo].[rpt_get_qpl_calc_year]    Script Date: 08/09/2011 11:03:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_qpl_calc_year]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_qpl_calc_year]

/****** Object:  UserDefinedFunction [dbo].[rpt_get_qpl_calc_year]    Script Date: 08/09/2011 11:02:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[rpt_get_qpl_calc_year] (    
  @i_projectkey INT,  
  @i_plstage    INT,  
  @i_plversion INT,  
  @i_yearcode   INT,    
  @i_placctgcategory      VARCHAR(50),  
  @i_placctgsubcategory   VARCHAR(50),    
  @i_incomeind  TINYINT)  

Returns Float
AS  
BEGIN
Declare @Return float
  
/**********************************************************************************************  
**  Name: qpl_calc_year  
**  Desc: Generic Year calculation which sums up costs or income records for all chargecodes  
**        in the given P&L Accounting Category/Subcategory.  
**  
**  Auth: Kate  
**  Date: January 11 2010  
***********************************************************************************************/  
  
DECLARE  
  @v_total  FLOAT  
Declare @o_result float
  
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
          y.yearcode = @i_yearcode AND  
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
          y.yearcode = @i_yearcode AND  
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
          y.yearcode = @i_yearcode AND  
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
          y.yearcode = @i_yearcode AND  
          cd.placctgcategorycode IN   
            (SELECT datacode FROM gentables   
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgcategory) AND  
          cd.placctgcategorysubcode IN  
            (SELECT datasubcode FROM subgentables   
             WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_placctgsubcategory)  
         
  SET @o_result = @v_total  


    
END  
Return @o_result
END


GO 
GRANT ALL ON rpt_get_qpl_calc_year TO PUBLIC