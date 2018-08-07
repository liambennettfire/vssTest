if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionincome_by_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionincome_by_format
GO

CREATE PROCEDURE qpl_get_taqversionincome_by_format (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @i_category_qsicode integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionincome_by_format
**  Desc: This stored procedure returns taqversionincome by format for a 
**  given projectkey, stage, version, and format.
**
**  Pass in a qsicode for a specific type of income (0 returns ALL).
**
**  Auth: Alan Katzen
**  Date: November 12, 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
       
  IF @i_category_qsicode > 0 BEGIN
    -- return costs for given category
    SELECT f.yearcode, i.acctgcode origacctgcode, i.acctgcode, i.incomenote, i.incomeamount, i.templatechangedind, 0.00 total, 
           cd.externaldesc externalcostdesc, cd.externalcode externalcostcode
      FROM taqversionformatyear f, taqversionincome i, cdlist cd
     WHERE f.taqversionformatyearkey = i.taqversionformatyearkey AND
           i.acctgcode = cd.internalcode AND
           f.taqprojectkey = @i_projectkey AND
           f.plstagecode = @i_plstage AND 
           f.taqversionkey = @i_versionkey AND
           f.taqprojectformatkey = @i_formatkey AND
           cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = @i_category_qsicode)
  ORDER BY f.taqprojectformatkey, i.acctgcode, f.yearcode
  END 
  ELSE BEGIN
    -- return all costs
    SELECT f.yearcode, i.acctgcode origacctgcode, i.acctgcode, i.incomenote, i.incomeamount, i.templatechangedind, 0.00 total, 
           dbo.qutl_get_cdlist_desc(acctgcode,'externaldesc') externalcostdesc,
           dbo.qutl_get_cdlist_desc(acctgcode,'externalcost') externalcostcode
      FROM taqversionformatyear f, taqversionincome i  
     WHERE f.taqversionformatyearkey = i.taqversionformatyearkey AND
           f.taqprojectkey = @i_projectkey AND
           f.plstagecode = @i_plstage AND 
           f.taqversionkey = @i_versionkey AND
           f.taqprojectformatkey = @i_formatkey 
  ORDER BY f.taqprojectformatkey, i.acctgcode, f.yearcode
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear/taqversionincome tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionincome_by_format TO PUBLIC
GO
