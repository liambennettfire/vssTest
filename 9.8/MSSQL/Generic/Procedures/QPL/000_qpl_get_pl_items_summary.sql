if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_items_summary') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_items_summary
GO

CREATE PROCEDURE qpl_get_pl_items_summary (  
  @i_projectkey       integer,
  @i_plsummarylevel   integer,
  @i_display_currency integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************
**  Name: qpl_get_pl_items_summary
**  Desc: This stored procedure returns all active items under each heading for the
**        given projectkey and P&L Summary Level - either Stage or Consolidated Stage.
**
**  Auth: Kate
**  Date: August 31 2007
**
**  Modified: Colman 
**  Date: December 17, 2015
**  Desc: Added support for item type filtering of P&L summary items 
**  Case: 35196
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    -------- --------    -------------------------------------------
**    1/27/16  Colman      Fixed summary level filtering: Case 35154 task 002
****************************************************************************************/

DECLARE
  @v_actuals_plstagecode  INT,
  @v_display_currency INT,
  @v_error  INT,
  @v_plstagecode1 INT,
  @v_plstagecode2 INT,
  @v_plstagecode3 INT,
  @v_plstagecode4 INT,
  @v_itemtypecode INT,
  @v_itemtypesubcode INT,
  @v_applyitemtypefilter INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_actuals_plstagecode = datacode
  FROM gentables
  WHERE tableid = 562 AND qsicode = 1  

  SET @v_plstagecode1 =   
  CASE (SELECT g.qsicode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 1)
    WHEN 1 THEN (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 1 AND
      (EXISTS (SELECT * FROM taqplcosts_actual ca WHERE ca.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplincome_actual ia WHERE ia.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplproduction_actual pa WHERE pa.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplsales_actual sa WHERE sa.taqprojectkey = @i_projectkey)))
    ELSE (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 1 AND 
      EXISTS (SELECT * FROM taqversion v WHERE g.datacode = v.plstagecode AND v.taqprojectkey = @i_projectkey))
  END
  
  SET @v_plstagecode2 = 
  CASE (SELECT g.qsicode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 2)
    WHEN 1 THEN (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 2 AND
      (EXISTS (SELECT * FROM taqplcosts_actual ca WHERE ca.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplincome_actual ia WHERE ia.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplproduction_actual pa WHERE pa.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplsales_actual sa WHERE sa.taqprojectkey = @i_projectkey)))
    ELSE (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 2 AND 
      EXISTS (SELECT * FROM taqversion v WHERE g.datacode = v.plstagecode AND v.taqprojectkey = @i_projectkey))
  END
  
  SET @v_plstagecode3 = 
  CASE (SELECT g.qsicode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 3)
    WHEN 1 THEN (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 3 AND
      (EXISTS (SELECT * FROM taqplcosts_actual ca WHERE ca.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplincome_actual ia WHERE ia.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplproduction_actual pa WHERE pa.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplsales_actual sa WHERE sa.taqprojectkey = @i_projectkey)))
    ELSE (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 3 AND 
      EXISTS (SELECT * FROM taqversion v WHERE g.datacode = v.plstagecode AND v.taqprojectkey = @i_projectkey))
  END
  
  SET @v_plstagecode4 =
  CASE (SELECT g.qsicode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 4)
    WHEN 1 THEN (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 4 AND
      (EXISTS (SELECT * FROM taqplcosts_actual ca WHERE ca.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplincome_actual ia WHERE ia.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplproduction_actual pa WHERE pa.taqprojectkey = @i_projectkey) OR
       EXISTS (SELECT * FROM taqplsales_actual sa WHERE sa.taqprojectkey = @i_projectkey)))
    ELSE (SELECT g.datacode FROM gentables g WHERE g.tableid = 562 AND g.sortorder = 4 AND 
      EXISTS (SELECT * FROM taqversion v WHERE g.datacode = v.plstagecode AND v.taqprojectkey = @i_projectkey))
  END  
  
  
  IF @i_display_currency > 0
    SET @v_display_currency = @i_display_currency
  ELSE
    SELECT @v_display_currency = COALESCE(plenteredcurrency,0)
    FROM taqproject
    WHERE taqprojectkey = @i_projectkey
         
  SELECT @v_actuals_plstagecode = datacode
  FROM gentables
  WHERE tableid = 562 AND qsicode = 1  

  SELECT @v_applyitemtypefilter = coalesce(gen1ind,0) FROM gentables WHERE tableid=561 AND datacode=@i_plsummarylevel
  
  -- Does this summary level require item type filtering?
  IF @v_applyitemtypefilter=1 BEGIN
    SELECT @v_itemtypecode = searchitemcode, @v_itemtypesubcode = usageclasscode FROM taqproject WHERE taqprojectkey = @i_projectkey

    SELECT @i_projectkey taqprojectkey, g.datacode, g.datadesc, g.sortorder, 
        i.plsummaryitemkey, i.itemlabel, i.itemtype, 
        CASE i.currencyind 
          WHEN 1 THEN 
            CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
          END
          ELSE i.fieldformat
        END fieldformat,
        CASE coalesce(t.summaryheadingcode,0)
          WHEN 0 THEN
            i.summaryheadingcode
          ELSE
            t.summaryheadingcode
          END summaryheadingcode,
        CASE coalesce(t.position,0)
          WHEN 0 THEN
            i.position
          ELSE
            t.position
          END position,
        i.boldind, i.italicind, i.activeind, i.alwaysrecalcind, i.currencyind,
        CONVERT(INTEGER,NULL) long1, CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(FLOAT,NULL) calc1, CONVERT(VARCHAR,NULL) text1,
        CONVERT(INTEGER,NULL) long2, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(FLOAT,NULL) calc2, CONVERT(VARCHAR,NULL) text2,
        CONVERT(INTEGER,NULL) long3, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(FLOAT,NULL) calc3, CONVERT(VARCHAR,NULL) text3,
        CONVERT(INTEGER,NULL) long4, CONVERT(DECIMAL(18,4),NULL) dec4, CONVERT(FLOAT,NULL) calc4, CONVERT(VARCHAR,NULL) text4,
        @v_actuals_plstagecode actuals_code,
        @v_plstagecode1 plstagecode1, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode1) plstage1desc,
        @v_plstagecode2 plstagecode2, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode2) plstage2desc,
        @v_plstagecode3 plstagecode3, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode3) plstage3desc,
        @v_plstagecode4 plstagecode4, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode4) plstage4desc,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode1) plstage1selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode2) plstage2selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode3) plstage3selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode4) plstage4selverkey
    FROM gentables g, 
        plsummaryitemtype t
    JOIN plsummaryitemdefinition i ON i.plsummaryitemkey=t.plsummaryitemkey
    WHERE 
        g.datacode = (CASE coalesce(t.summaryheadingcode,0)
          WHEN 0 THEN
            i.summaryheadingcode
          ELSE
            t.summaryheadingcode
          END) AND
        g.tableid = 564 AND 
        g.deletestatus = 'N' AND
        t.itemtypecode = @v_itemtypecode AND
        (t.itemtypesubcode = @v_itemtypesubcode OR coalesce(t.itemtypesubcode,0) = 0) AND
        i.summarylevelcode = @i_plsummarylevel AND
        i.activeind = 1 AND
        g.qsicode IS NULL
    ORDER BY g.sortorder, i.position
  END
  ELSE BEGIN
    SELECT @i_projectkey taqprojectkey, g.datacode, g.datadesc, g.sortorder, 
        i.plsummaryitemkey, i.itemlabel, i.itemtype, 
        CASE i.currencyind 
          WHEN 1 THEN 
            CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
          END
          ELSE i.fieldformat
        END fieldformat,
        i.boldind, i.italicind, i.activeind, i.summaryheadingcode, i.position, i.alwaysrecalcind, i.currencyind,
        CONVERT(INTEGER,NULL) long1, CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(FLOAT,NULL) calc1, CONVERT(VARCHAR,NULL) text1,
        CONVERT(INTEGER,NULL) long2, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(FLOAT,NULL) calc2, CONVERT(VARCHAR,NULL) text2,
        CONVERT(INTEGER,NULL) long3, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(FLOAT,NULL) calc3, CONVERT(VARCHAR,NULL) text3,
        CONVERT(INTEGER,NULL) long4, CONVERT(DECIMAL(18,4),NULL) dec4, CONVERT(FLOAT,NULL) calc4, CONVERT(VARCHAR,NULL) text4,
        @v_actuals_plstagecode actuals_code,
        @v_plstagecode1 plstagecode1, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode1) plstage1desc,
        @v_plstagecode2 plstagecode2, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode2) plstage2desc,
        @v_plstagecode3 plstagecode3, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode3) plstage3desc,
        @v_plstagecode4 plstagecode4, (SELECT datadesc FROM gentables WHERE tableid = 562 AND datacode = @v_plstagecode4) plstage4desc,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode1) plstage1selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode2) plstage2selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode3) plstage3selverkey,
        (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode4) plstage4selverkey
    FROM gentables g, 
        plsummaryitemdefinition i 
    WHERE g.datacode = i.summaryheadingcode AND
        g.tableid = 564 AND 
        g.deletestatus = 'N' AND
        i.summarylevelcode = @i_plsummarylevel AND
        i.activeind = 1 AND
        g.qsicode IS NULL
    ORDER BY g.sortorder, i.position
  END
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentables/plsummaryitemdefinition tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_pl_items_summary TO PUBLIC
GO
