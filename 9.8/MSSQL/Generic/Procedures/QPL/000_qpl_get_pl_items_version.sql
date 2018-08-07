if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_items_version') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_items_version
GO

CREATE PROCEDURE qpl_get_pl_items_version (  
  @i_projectkey       integer,
  @i_plstage          integer,
  @i_versionkey       integer,
  @i_summarylevel     integer,
  @i_display_currency integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_get_pl_items_version
**  Desc: This stored procedure returns all active items under each heading
**        for given projectkey, P&L Stage and P&L summary level.
**
**  Auth: Kate
**  Date: August 31 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    -------- --------    -------------------------------------------
**    1/20/16  Colman      Added item type filtering: Case 35154
************************************************************************************/

BEGIN

  DECLARE
    @v_display_currency INT,
    @v_error  INT,
    @v_itemtypecode INT,
    @v_itemtypesubcode INT,
    @v_applyitemtypefilter INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  -- Assume Version-level by default (summarylevecode=2)
  IF @i_summarylevel IS NULL OR @i_summarylevel = 0
    SET @i_summarylevel = 2
    
  IF @i_display_currency > 0
    SET @v_display_currency = @i_display_currency
  ELSE
    SELECT @v_display_currency = COALESCE(plenteredcurrency,0)
    FROM taqproject
    WHERE taqprojectkey = @i_projectkey    

  SELECT @v_applyitemtypefilter = coalesce(gen1ind,0) FROM gentables WHERE tableid=561 AND datacode=@i_summarylevel
  
  -- Does this summary level require item type filtering?
  IF @v_applyitemtypefilter=1 BEGIN
    SELECT @v_itemtypecode = searchitemcode, @v_itemtypesubcode = usageclasscode 
    FROM taqproject 
    WHERE taqprojectkey = @i_projectkey
    
    IF @i_summarylevel = 3	--Year level
      SELECT DISTINCT @i_projectkey taqprojectkey, @i_plstage plstagecode, @i_versionkey versionkey, g.datacode, g.datadesc, g.sortorder, 
          i.plsummaryitemkey, i.itemlabel, i.itemtype, i.boldind, i.italicind, i.activeind, 
          CASE i.currencyind 
            WHEN 1 THEN 
              CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
              ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            END
            ELSE i.fieldformat
          END fieldformat,
          CASE WHEN COALESCE(t.summaryheadingcode,0) = 0 THEN
            i.summaryheadingcode
          ELSE
            t.summaryheadingcode
          END summaryheadingcode,
          CASE WHEN COALESCE(t.position,0) = 0 THEN
            i.position
          ELSE
            t.position
          END position,
          i.assocplsummaryitemkey versionitemkey, i.alwaysrecalcind, i.currencyind,
          CONVERT(INTEGER,NULL) long1, CONVERT(INTEGER,NULL) long2, CONVERT(INTEGER,NULL) long3, CONVERT(INTEGER,NULL) long4, CONVERT(INTEGER,NULL) long5, 
          CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(DECIMAL(18,4),NULL) dec4, CONVERT(DECIMAL(18,4),NULL) dec5,
          CONVERT(FLOAT,NULL) calc1, CONVERT(FLOAT,NULL) calc2, CONVERT(FLOAT,NULL) calc3, CONVERT(FLOAT,NULL) calc4, CONVERT(FLOAT,NULL) calc5,
          CONVERT(VARCHAR,NULL) text1, CONVERT(VARCHAR,NULL) text2, CONVERT(VARCHAR,NULL) text3, CONVERT(VARCHAR,NULL) text4, CONVERT(VARCHAR,NULL) text5, 
          CONVERT(INTEGER,NULL) yearcode1, CONVERT(INTEGER,NULL) yearcode2, CONVERT(INTEGER,NULL) yearcode3, CONVERT(INTEGER,NULL) yearcode4, CONVERT(INTEGER,NULL) yearcode5,
          CONVERT(DECIMAL(18,4),NULL) dectotal, CONVERT(FLOAT,NULL) calctotal
      FROM gentables g, 
           plsummaryitemtype t
      JOIN plsummaryitemdefinition i ON i.plsummaryitemkey=t.plsummaryitemkey
      WHERE g.datacode = CASE WHEN COALESCE(t.summaryheadingcode,0) = 0 THEN i.summaryheadingcode ELSE t.summaryheadingcode END AND
          g.tableid = 564 AND 
          g.deletestatus = 'N' AND
          i.summarylevelcode = 3 AND
          t.itemtypecode = @v_itemtypecode AND
          (t.itemtypesubcode = @v_itemtypesubcode OR coalesce(t.itemtypesubcode,0) = 0) AND
          i.activeind = 1 AND
          g.qsicode IS NULL
      ORDER BY g.sortorder, position
      
    ELSE	--Version level
      SELECT @i_projectkey taqprojectkey, @i_plstage plstagecode, g.datacode, g.datadesc, g.sortorder, 
          i.plsummaryitemkey, i.itemlabel, i.itemtype, 
          CASE i.currencyind 
            WHEN 1 THEN 
              CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
              ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            END
            ELSE i.fieldformat
          END fieldformat,
          CASE WHEN COALESCE(t.summaryheadingcode,0) = 0 THEN
            i.summaryheadingcode
          ELSE
            t.summaryheadingcode
          END summaryheadingcode,
          CASE WHEN COALESCE(t.position,0) = 0 THEN
            i.position
          ELSE
            t.position
          END position,
          i.boldind, i.italicind, i.activeind, i.alwaysrecalcind, i.currencyind,
          CONVERT(INTEGER,NULL) long1, CONVERT(INTEGER,NULL) long2, CONVERT(INTEGER,NULL) long3, CONVERT(INTEGER,NULL) long4, 
          CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(DECIMAL(18,4),NULL) dec4,
          CONVERT(FLOAT,NULL) calc1, CONVERT(FLOAT,NULL) calc2, CONVERT(FLOAT,NULL) calc3, CONVERT(FLOAT,NULL) calc4, 
          CONVERT(VARCHAR,NULL) text1, CONVERT(VARCHAR,NULL) text2, CONVERT(VARCHAR,NULL) text3, CONVERT(VARCHAR,NULL) text4, 
          CONVERT(INTEGER,NULL) versionkey1, CONVERT(INTEGER,NULL) versionkey2, CONVERT(INTEGER,NULL) versionkey3, CONVERT(INTEGER,NULL) versionkey4
      FROM gentables g, 
           plsummaryitemtype t
      JOIN plsummaryitemdefinition i ON i.plsummaryitemkey=t.plsummaryitemkey
      WHERE g.datacode = CASE WHEN COALESCE(t.summaryheadingcode,0) = 0 THEN i.summaryheadingcode ELSE t.summaryheadingcode END AND
          g.tableid = 564 AND 
          g.deletestatus = 'N' AND
          i.summarylevelcode = 2 AND
          t.itemtypecode = @v_itemtypecode AND
          (t.itemtypesubcode = @v_itemtypesubcode OR coalesce(t.itemtypesubcode,0) = 0) AND
          i.activeind = 1 AND
          g.qsicode IS NULL
      ORDER BY g.sortorder, position
      
  END ELSE BEGIN -- BEGIN no item type filtering
  
    IF @i_summarylevel = 3	--Year level
      SELECT DISTINCT @i_projectkey taqprojectkey, @i_plstage plstagecode, @i_versionkey versionkey, g.datacode, g.datadesc, g.sortorder, 
          i.plsummaryitemkey, i.itemlabel, i.itemtype, i.boldind, i.italicind, i.activeind, 
          CASE i.currencyind 
            WHEN 1 THEN 
              CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
              ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            END
            ELSE i.fieldformat
          END fieldformat,
          i.summaryheadingcode, i.position, i.assocplsummaryitemkey versionitemkey, i.alwaysrecalcind, i.currencyind,
          CONVERT(INTEGER,NULL) long1, CONVERT(INTEGER,NULL) long2, CONVERT(INTEGER,NULL) long3, CONVERT(INTEGER,NULL) long4, CONVERT(INTEGER,NULL) long5, 
          CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(DECIMAL(18,4),NULL) dec4, CONVERT(DECIMAL(18,4),NULL) dec5,
          CONVERT(FLOAT,NULL) calc1, CONVERT(FLOAT,NULL) calc2, CONVERT(FLOAT,NULL) calc3, CONVERT(FLOAT,NULL) calc4, CONVERT(FLOAT,NULL) calc5,
          CONVERT(VARCHAR,NULL) text1, CONVERT(VARCHAR,NULL) text2, CONVERT(VARCHAR,NULL) text3, CONVERT(VARCHAR,NULL) text4, CONVERT(VARCHAR,NULL) text5, 
          CONVERT(INTEGER,NULL) yearcode1, CONVERT(INTEGER,NULL) yearcode2, CONVERT(INTEGER,NULL) yearcode3, CONVERT(INTEGER,NULL) yearcode4, CONVERT(INTEGER,NULL) yearcode5,
          CONVERT(DECIMAL(18,4),NULL) dectotal, CONVERT(FLOAT,NULL) calctotal
      FROM gentables g, 
          plsummaryitemdefinition i
      WHERE g.datacode = i.summaryheadingcode AND
          g.tableid = 564 AND 
          g.deletestatus = 'N' AND
          i.summarylevelcode = 3 AND
          i.activeind = 1 AND
          g.qsicode IS NULL
      ORDER BY g.sortorder, i.position
      
    ELSE	--Version level
      SELECT @i_projectkey taqprojectkey, @i_plstage plstagecode, g.datacode, g.datadesc, g.sortorder, 
          i.plsummaryitemkey, i.itemlabel, i.itemtype, 
          CASE i.currencyind 
            WHEN 1 THEN 
              CASE WHEN CHARINDEX('.', i.fieldformat) > 0 THEN (SELECT COALESCE(g.gentext1, '$###,##0') + SUBSTRING(i.fieldformat, CHARINDEX('.', i.fieldformat), 10) FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
              ELSE (SELECT COALESCE(g.gentext1, '$###,##0') FROM gentables_ext g WHERE g.tableid = 122 AND datacode = @i_display_currency)
            END
            ELSE i.fieldformat
          END fieldformat,
          i.boldind, i.italicind, i.activeind, i.summaryheadingcode, i.position, i.alwaysrecalcind, i.currencyind,
          CONVERT(INTEGER,NULL) long1, CONVERT(INTEGER,NULL) long2, CONVERT(INTEGER,NULL) long3, CONVERT(INTEGER,NULL) long4, 
          CONVERT(DECIMAL(18,4),NULL) dec1, CONVERT(DECIMAL(18,4),NULL) dec2, CONVERT(DECIMAL(18,4),NULL) dec3, CONVERT(DECIMAL(18,4),NULL) dec4,
          CONVERT(FLOAT,NULL) calc1, CONVERT(FLOAT,NULL) calc2, CONVERT(FLOAT,NULL) calc3, CONVERT(FLOAT,NULL) calc4, 
          CONVERT(VARCHAR,NULL) text1, CONVERT(VARCHAR,NULL) text2, CONVERT(VARCHAR,NULL) text3, CONVERT(VARCHAR,NULL) text4, 
          CONVERT(INTEGER,NULL) versionkey1, CONVERT(INTEGER,NULL) versionkey2, CONVERT(INTEGER,NULL) versionkey3, CONVERT(INTEGER,NULL) versionkey4
      FROM gentables g, 
          plsummaryitemdefinition i 
      WHERE g.datacode = i.summaryheadingcode AND
          g.tableid = 564 AND 
          g.deletestatus = 'N' AND
          i.summarylevelcode = 2 AND
          i.activeind = 1 AND
          g.qsicode IS NULL
      ORDER BY g.sortorder, i.position
  END
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentables/plsummaryitemdefinition tables to get Version Summary Items (taqprojectkey=' + 
      CAST(@i_projectkey AS VARCHAR) + ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC ON qpl_get_pl_items_version TO PUBLIC
GO
