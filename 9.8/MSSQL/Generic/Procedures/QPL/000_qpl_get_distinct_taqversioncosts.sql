if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_distinct_taqversioncosts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_distinct_taqversioncosts
GO

CREATE PROCEDURE qpl_get_distinct_taqversioncosts (  
  @i_projectkey integer,  
  @i_plstage    integer,  
  @i_versionkey integer,  
  @i_formatkey integer,  
  @i_category_qsicode integer,  
  @o_error_code integer output,  
  @o_error_desc varchar(2000) output)  
AS  
  
/*************************************************************************************  
**  Name: qpl_get_distinct_taqversioncosts  
**  Desc: This stored procedure returns distinct taqversioncosts by format for a   
**  given projectkey, stage, version, and format.  
**  
**  Pass in a qsicode for a specific type of costs (0 returns ALL).  
**  
**  Auth: Alan Katzen  
**  Date: November 6, 2007  
**************************************************************************************  
** Change History  
**************************************************************************************  
**  Date     Author  Description  
** -------- ------ -----------  
** 01/20/16 Kate    Took out the restriction for NOT NULL amounts (see case 35860)  
**  04/05/17  Colman  44238 - Protect against non-unique sub select  
**  05/02/17  Colman  44464 - ** Changes removed **  
**  03/20/18  Case# 50398 Bad join on line 86, needed to add an additional join on c2.plcalccostcode=c.plcalccostcode, to prevent multiple values returning(Error:Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.)
**************************************************************************************/  
  
BEGIN  
  
  DECLARE  
    @v_decpos INT,  
    @v_decprecision_mask VARCHAR(40),  
    @v_error  INT,  
    @v_plcurrency_format VARCHAR(40)  
      
  SET @o_error_code = 0  
  SET @o_error_desc = ''  
    
  -- Get the P&L Currency Format mask based on project's P&L entry currency (default to US currency mask)  
  SELECT @v_plcurrency_format = COALESCE(g.gentext1, '$###,##0')   
  FROM taqproject p   
    LEFT OUTER JOIN gentables_ext g ON p.plenteredcurrency = g.datacode AND g.tableid = 122   
  WHERE p.taqprojectkey = @i_projectkey  
    
  SELECT @v_error = @@ERROR  
  IF @v_error <> 0 BEGIN  
    SET @o_error_code = -1  
    SET @o_error_desc = 'Could not access taqproject/gentables_ext tables to get P&L Currency info (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'  
  END  
    
  -- Ignore the decimal portion of currency format from above (in case entered)  
  SET @v_decpos = CHARINDEX('.', @v_plcurrency_format)  
  IF @v_decpos > 0  
    SET @v_plcurrency_format = LEFT(@v_plcurrency_format, @v_decpos -1)  
      
  -- Get the decimal precision mask for currency format as set for the project's item type (default to none)  
  SELECT @v_decprecision_mask = COALESCE(g.gentext1, '')   
  FROM taqproject p   
    LEFT OUTER JOIN gentables_ext g ON p.searchitemcode = g.datacode AND g.tableid = 550   
  WHERE p.taqprojectkey = @i_projectkey  
    
  SELECT @v_error = @@ERROR  
  IF @v_error <> 0 BEGIN  
    SET @o_error_code = -1  
    SET @o_error_desc = 'Could not access taqproject/gentables_ext tables to get P&L Currency Decimal Precision mask (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'  
  END    
    
  -- If decimal precision mask exists for the project's item type, include it in the P&L Currency Format mask  
  IF @v_decprecision_mask <> ''  
    SET @v_plcurrency_format = @v_plcurrency_format + @v_decprecision_mask  
    
  -- NOTE: For Production costs, duplicate chargecode costs may exist   
  -- (for different years in the same printing - ex.Pre-Pub and Year 1 in printing 1)  
  -- so the procedure must return these rows  
  IF @i_category_qsicode = 2  --distinct Production costs  
    SELECT DISTINCT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey,   
                    c.acctgcode, c.acctgcode origacctgcode, c.plcalccostcode, c.plcalccostsubcode,   
      -- if the note for the current printing is null, get the corresponding note for this chargecode existing on another printing  
      COALESCE(c.versioncostsnote, (SELECT DISTINCT c2.versioncostsnote FROM taqversioncosts c2, taqversionformatyear y2   
                                    WHERE y2.taqversionformatyearkey = c2.taqversionformatyearkey AND y2.taqprojectkey = @i_projectkey   
                                    AND y2.plstagecode = @i_plstage AND y2.taqversionkey = @i_versionkey  
                                    AND y2.taqprojectformatkey = @i_formatkey AND c2.acctgcode = c.acctgcode    and c2.plcalccostcode=c.plcalccostcode
                                    AND c2.versioncostsnote IS NOT NULL)) versioncostsnote,  
      CASE COALESCE(c.taqversionspeccategorykey,0)  
        WHEN 0 THEN NULL  
        ELSE   
          CASE(SELECT COALESCE(c2.relatedspeccategorykey,0) FROM taqversionspeccategory c2 WHERE c2.taqversionspecategorykey = c.taqversionspeccategorykey)  
            WHEN 0 THEN (SELECT ct.itemcategorycode FROM taqversionspeccategory ct WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey)  
            ELSE (SELECT c2.itemcategorycode FROM taqversionspeccategory ct, taqversionspeccategory c2 WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey AND c2.taqversionspecategorykey = ct.relatedspeccategorykey)  
          END  
      END itemcategorycode,  
      CASE COALESCE(c.taqversionspeccategorykey,0)  
        WHEN 0 THEN NULL  
        ELSE   
          CASE(SELECT COALESCE(c2.relatedspeccategorykey,0) FROM taqversionspeccategory c2 WHERE c2.taqversionspecategorykey = c.taqversionspeccategorykey)  
            WHEN 0 THEN (SELECT ct.quantity FROM taqversionspeccategory ct WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey)  
            ELSE (SELECT c2.quantity FROM taqversionspeccategory ct, taqversionspeccategory c2 WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey AND c2.taqversionspecategorykey = ct.relatedspeccategorykey)  
          END  
      END compquantity,  
      0.00 total, c.pocostind, COALESCE(c.taqversionspeccategorykey,0) taqversionspeccategorykey,  
      cd.externaldesc externalcostdesc, cd.externalcode externalcostcode,   
      g.sortorder, @v_plcurrency_format currencyformat, @v_decprecision_mask decprecision  
    FROM taqversionformatyear f, taqversioncosts c, cdlist cd, gentables g  
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND   
      f.yearcode = g.datacode AND  
      g.tableid = 563 AND  
      c.acctgcode = cd.internalcode AND  
      f.taqprojectkey = @i_projectkey AND  
      f.plstagecode = @i_plstage AND   
      f.taqversionkey = @i_versionkey AND  
      f.taqprojectformatkey = @i_formatkey AND   
      c.printingnumber = 1 AND  
      cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = 2)  
    UNION  
    SELECT DISTINCT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey,   
                    c.acctgcode, c.acctgcode origacctgcode, c.plcalccostcode, c.plcalccostsubcode,   
      -- if the note for the current printing is null, get the corresponding note for this chargecode existing on another printing  
      COALESCE(c.versioncostsnote, (SELECT TOP(1) c2.versioncostsnote FROM taqversioncosts c2, taqversionformatyear y2   
                                    WHERE y2.taqversionformatyearkey = c2.taqversionformatyearkey AND y2.taqprojectkey = @i_projectkey   
                                    AND y2.plstagecode = @i_plstage AND y2.taqversionkey = @i_versionkey  
                                    AND y2.taqprojectformatkey = @i_formatkey AND c2.acctgcode = c.acctgcode   
                                    AND c2.versioncostsnote IS NOT NULL)) versioncostsnote,  
      CASE COALESCE(c.taqversionspeccategorykey,0)  
        WHEN 0 THEN NULL  
        ELSE   
          CASE(SELECT COALESCE(c2.relatedspeccategorykey,0) FROM taqversionspeccategory c2 WHERE c2.taqversionspecategorykey = c.taqversionspeccategorykey)  
            WHEN 0 THEN (SELECT ct.itemcategorycode FROM taqversionspeccategory ct WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey)  
            ELSE (SELECT c2.itemcategorycode FROM taqversionspeccategory ct, taqversionspeccategory c2 WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey AND c2.taqversionspecategorykey = ct.relatedspeccategorykey)  
  END  
      END itemcategorycode,  
      CASE COALESCE(c.taqversionspeccategorykey,0)  
        WHEN 0 THEN NULL  
        ELSE   
          CASE(SELECT COALESCE(c2.relatedspeccategorykey,0) FROM taqversionspeccategory c2 WHERE c2.taqversionspecategorykey = c.taqversionspeccategorykey)  
            WHEN 0 THEN (SELECT ct.quantity FROM taqversionspeccategory ct WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey)  
            ELSE (SELECT c2.quantity FROM taqversionspeccategory ct, taqversionspeccategory c2 WHERE ct.taqversionspecategorykey = c.taqversionspeccategorykey AND c2.taqversionspecategorykey = ct.relatedspeccategorykey)  
          END  
      END compquantity,  
      0.00 total, c.pocostind, COALESCE(c.taqversionspeccategorykey,0) taqversionspeccategorykey,  
      cd.externaldesc externalcostdesc, cd.externalcode externalcostcode,   
      COALESCE((SELECT sortorder FROM gentables   
      WHERE tableid = 563 AND qsicode IS NULL AND datacode IN  
        (SELECT y2.yearcode FROM taqversionformatyear y2, taqversioncosts c2  
         WHERE y2.taqversionformatyearkey = c2.taqversionformatyearkey AND   
          y2.taqprojectkey = @i_projectkey AND  
          y2.plstagecode = @i_plstage AND   
          y2.taqversionkey = @i_versionkey AND  
          y2.taqprojectformatkey = @i_formatkey AND   
          c2.acctgcode = c.acctgcode AND  
          c2.printingnumber = 1)),0) sortorder,   
      @v_plcurrency_format currencyformat, @v_decprecision_mask decprecision  
    FROM taqversionformatyear f, taqversioncosts c, cdlist cd  
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND   
      c.acctgcode = cd.internalcode AND  
      f.taqprojectkey = @i_projectkey AND  
      f.plstagecode = @i_plstage AND   
      f.taqversionkey = @i_versionkey AND  
      f.taqprojectformatkey = @i_formatkey AND   
      c.printingnumber > 1 AND  
      cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = 2)  
    ORDER BY c.acctgcode, g.sortorder  
  
  ELSE IF @i_category_qsicode > 0 -- distinct costs for given category  
    SELECT DISTINCT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey,   
        c.acctgcode, c.acctgcode origacctgcode, c.plcalccostcode, c.versioncostsnote, 0.00 total,  
        cd.externaldesc externalcostdesc, cd.externalcode externalcostcode,   
        @v_plcurrency_format currencyformat, @v_decprecision_mask decprecision  
    FROM taqversionformatyear f, taqversioncosts c, cdlist cd  
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND   
        c.acctgcode = cd.internalcode AND  
        f.taqprojectkey = @i_projectkey AND  
        f.plstagecode = @i_plstage AND   
        f.taqversionkey = @i_versionkey AND  
        f.taqprojectformatkey = @i_formatkey AND  
        cd.placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = @i_category_qsicode)  
    ORDER BY c.acctgcode  
  
  ELSE -- all distinct costs  
    SELECT DISTINCT @i_projectkey taqprojectkey, @i_formatkey taqversionformatkey, @i_plstage plstagecode, @i_versionkey taqversionkey,   
        c.acctgcode, c.acctgcode origacctgcode, c.plcalccostcode, c.versioncostsnote, 0.00 total,  
        dbo.qutl_get_cdlist_desc(c.acctgcode,'externaldesc') externalcostdesc,  
        dbo.qutl_get_cdlist_desc(c.acctgcode,'externalcode') externalcostcode,   
        @v_plcurrency_format currencyformat, @v_decprecision_mask decprecision  
    FROM taqversionformatyear f, taqversioncosts c  
    WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND   
        f.taqprojectkey = @i_projectkey AND  
        f.plstagecode = @i_plstage AND   
        f.taqversionkey = @i_versionkey AND  
        f.taqprojectformatkey = @i_formatkey   
    ORDER BY c.acctgcode  
  
  SELECT @v_error = @@ERROR  
  IF @v_error <> 0 BEGIN  
    SET @o_error_code = -1  
    SET @o_error_desc = 'Could not access taqversionformatyear/taqversioncosts tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +   
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) +   
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'  
  END   
  
END 