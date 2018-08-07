if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_distinct_taqversionincome') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_distinct_taqversionincome
GO

CREATE PROCEDURE qpl_get_distinct_taqversionincome (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @i_category_qsicode integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_distinct_taqversionincome
**  Desc: This stored procedure returns distinct taqversionincome by format for a 
**  given projectkey, stage, version, and format.
**
**  Pass in a qsicode for a specific type of costs (0 returns ALL).
**
**  Auth: Alan Katzen
**  Date: November 12, 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_plcurrency_format VARCHAR(40)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_plcurrency_format = COALESCE(g.alternatedesc1, '$###,##0') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables g ON p.plenteredcurrency = g.datacode AND g.tableid = 122 
  WHERE p.taqprojectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject table to get P&L currency info (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END  
       
  IF @i_category_qsicode > 0 BEGIN
    -- return costs for given category
    SELECT DISTINCT cd.placctgcategorycode, i.acctgcode, i.acctgcode origacctgcode, i.incomenote, 0.00 total,
           cd.externaldesc externalcostdesc, cd.externalcode externalcostcode, @v_plcurrency_format currencyformat
      FROM taqversionformatyear f, taqversionincome i, cdlist cd
     WHERE f.taqversionformatyearkey = i.taqversionformatyearkey AND 
           i.acctgcode = cd.internalcode AND
           f.taqprojectkey = @i_projectkey AND
           f.plstagecode = @i_plstage AND 
           f.taqversionkey = @i_versionkey AND
           f.taqprojectformatkey = @i_formatkey AND
           cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = @i_category_qsicode)
    ORDER BY i.acctgcode
  END 
  ELSE BEGIN
    -- return all costs
    SELECT DISTINCT cd.placctgcategorycode, i.acctgcode, i.acctgcode origacctgcode, i.incomenote, 0.00 total,
           cd.externaldesc externalcostdesc, cd.externalcode externalcostcode, @v_plcurrency_format currencyformat
      FROM taqversionformatyear f, taqversionincome i, cdlist cd
     WHERE f.taqversionformatyearkey = i.taqversionformatyearkey AND 
           i.acctgcode = cd.internalcode AND
           f.taqprojectkey = @i_projectkey AND
           f.plstagecode = @i_plstage AND 
           f.taqversionkey = @i_versionkey AND
           f.taqprojectformatkey = @i_formatkey 
    ORDER BY i.acctgcode
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear/taqversionincome  tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_distinct_taqversionincome TO PUBLIC
GO
