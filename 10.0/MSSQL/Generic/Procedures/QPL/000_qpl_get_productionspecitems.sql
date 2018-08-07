IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qpl_get_productionspecitems')
      AND OBJECTPROPERTY(id, N'IsProcedure') = 1
    )
  DROP PROCEDURE dbo.qpl_get_productionspecitems
GO

CREATE PROCEDURE qpl_get_productionspecitems (
  @i_categorykey INT,
  @i_showinsummaryind INT,
  @i_itemtype INT,
  @i_usageclass INT,
  @i_culturecode INT,
  @i_userkey INT,
  @i_windowname VARCHAR(100),
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*********************************************************************************
**  Name: qpl_get_productionspecitems
**  Desc: This stored procedure gets the P&L spec items for taqversionspeccategorykey
**        as well as all associated taqspecadmin data.
**
**  Auth: Dustin
**  Date: March 5, 2012
************************************************************************************************************************
**  Change History
************************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  06/21/16  Kate      Fixes for related specs - see case 29764.
**  11/14/16  Colman    Case 40992: Add hyper link to related purchase order in specification section
**  01/03/17  Colman    Case 40615: Spec Items get duplicated when added if item filtered for class and all classes
**  11/20/17  Colman    Case 48469: No spec items appear when qsiadmin userkey != 0
**  12/19/17  Colman    Case 48909: 'Show in summary' spec items are not appearing
**  06/07/18  Colman    Case 50971: security for 'first printing only' was never implemented
**********************************************************************************/
DECLARE @v_categorycode INT,
  @v_error INT,
  @v_formatkey INT,
  @v_plstagecode INT,
  @v_projectkey INT,
  @v_proj_itemtype INT,
  @v_proj_usageclass INT,
  @v_filter_usageclass INT,
  @v_rowcount INT,
  @v_taqversionkey INT,
  @v_spectemplate_itemtype INT,
  @v_spectemplate_usageclass INT,
  @v_categorykey INT,
  @v_showinsummaryind INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_culturecode INT,
  @v_userkey INT,
  @v_windowname VARCHAR(100),
  @v_printing_rolecode INT,
  @v_printingkey INT

BEGIN
  --I know this looks weird but it will prevent parameter sniffing which has been slowing down the proc
  SET @v_categorykey = @i_categorykey
  SET @v_showinsummaryind = @i_showinsummaryind
  SET @v_itemtype = @i_itemtype
  SET @v_usageclass = @i_usageclass
  SET @v_culturecode = @i_culturecode
  SET @v_userkey = @i_userkey
  SET @v_windowname = @i_windowname
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_printing_rolecode = datacode FROM gentables WHERE tableid = 604 AND qsicode = 3

  SELECT @v_spectemplate_itemtype = datacode,
    @v_spectemplate_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND qsicode = 44 --Specification Template

  -- Get the details associated with the passed taqversionspecategorykey (@i_categorykey)
  SELECT @v_projectkey = c.taqprojectkey,
    @v_plstagecode = c.plstagecode,
    @v_taqversionkey = c.taqversionkey,
    @v_formatkey = c.taqversionformatkey,
    @v_categorycode = c.itemcategorycode,
    @v_itemtype = p.searchitemcode
  FROM taqversionspeccategory c
    JOIN taqproject p ON p.taqprojectkey = c.taqprojectkey
  WHERE c.taqversionspecategorykey = @v_categorykey

  IF @v_itemtype = 14
  BEGIN
    SELECT @v_printing_rolecode = datacode FROM gentables WHERE tableid = 604 AND qsicode = 3
      
    SELECT @v_printingkey = printingkey 
    FROM taqprojecttitle
        WHERE taqprojectkey = @v_projectkey
          AND projectrolecode = @v_printing_rolecode
  END

  IF ISNULL(@v_culturecode, 0) = 0
    SELECT @v_culturecode = COALESCE(qsiusersculturecode, projectculturecode)
    FROM dbo.get_culture(@v_userkey, @v_projectkey, 0)

  -- Check if the passed Item Type/Usage Class matches this project's item type/class
  -- NOTE: The taqversionspeccategorykey passed in (@v_categorykey) may be the relatedspeccategorykey - ex. on Purchase Order summary,
  -- specs may really be coming from the Printing project, but we still need to filter the specs based on Purchase Order item type
  SELECT @v_proj_itemtype = searchitemcode,
    @v_proj_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @v_projectkey

  SET @v_filter_usageclass = @v_usageclass

  -- exec qutl_trace 'qpl_get_productionspecitems',
  -- '@v_categorykey', @v_categorykey, NULL,
  -- '@v_showinsummaryind', @v_showinsummaryind, NULL,
  -- '@v_itemtype', @v_itemtype, NULL,
  -- '@v_usageclass', @v_usageclass, NULL,
  -- '@v_culturecode', @v_culturecode, NULL,
  -- '@v_userkey', @v_userkey, NULL,
  -- '@v_windowname', NULL, @v_windowname,
  -- '@v_filter_usageclass', @v_filter_usageclass
  -- For Specification Templates, show items regardless of item type filter.
  -- In all other cases, show the items based on item type filter regardless if value is filled in (first part of union)
  -- and, if passed item type matches the project's item type, any existing items that have a value filled 
  -- even though item type filter would normally not show that item (second part of union)
  -- NOTE: We need to keep any specs with values in case that spec item was valid at some point but is not valid now - users should be able to view these
  IF @v_showinsummaryind = 1
  BEGIN
    --Break this out a bit and hopefully gain some speed 
    SELECT v.*
    INTO #temp_taqversionspecitem_summary
    FROM taqversionspecitems_view v
    WHERE v.taqprojectkey = @v_projectkey
      AND v.plstagecode = @v_plstagecode
      AND v.taqversionkey = @v_taqversionkey
      AND v.taqversionformatkey = @v_formatkey

    IF @v_itemtype = @v_spectemplate_itemtype
    BEGIN
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem_summary v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE (
          v.taqversionspecategorykey = @v_categorykey
          OR a.showinsummaryind = 1
          )
      ORDER BY Sort_Summary ASC
    END
    ELSE IF @v_itemtype = @v_proj_itemtype
    BEGIN
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary,
        COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem_summary v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      INNER JOIN gentablesitemtype gi
        ON gi.tableid = s.tableid
          AND gi.datacode = s.datacode
          AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND (
            (gi.itemtypesubcode = @v_filter_usageclass)
            OR (
              gi.itemtypesubcode = 0
              AND NOT EXISTS (
                SELECT *
                FROM gentablesitemtype gi2
                WHERE gi2.tableid = s.tableid
                  AND gi2.datacode = s.datacode
                  AND gi2.datasubcode = s.datasubcode
                  AND gi2.itemtypecode = @v_itemtype
                  AND gi2.itemtypesubcode = @v_filter_usageclass
                )
              )
            )
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE (
          v.taqversionspecategorykey = @v_categorykey
          OR a.showinsummaryind = 1
          )
      
      UNION
      
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary,
        s.sortorder item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem_summary v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE (
          v.taqversionspecategorykey = @v_categorykey
          OR a.showinsummaryind = 1
          )
        AND NOT EXISTS (
          SELECT *
          FROM gentablesitemtype gi
          WHERE gi.tableid = s.tableid
            AND gi.datacode = s.datacode
            AND gi.datasubcode = s.datasubcode
            AND gi.itemtypecode = @v_itemtype
            AND gi.itemtypesubcode IN (@v_filter_usageclass, 0)
          )
        AND (
          v.itemdetailcode IS NOT NULL
          OR v.decimalvalue IS NOT NULL
          OR v.quantity IS NOT NULL
          OR v.description IS NOT NULL
          OR v.description2 IS NOT NULL
          )
      ORDER BY Sort_Summary ASC,
        item_sort ASC
    END
    ELSE
    BEGIN
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary,
        COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem_summary v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      INNER JOIN gentablesitemtype gi
        ON gi.tableid = s.tableid
          AND gi.datacode = s.datacode
          AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND (
            (gi.itemtypesubcode = @v_filter_usageclass)
            OR (
              gi.itemtypesubcode = 0
              AND NOT EXISTS (
                SELECT *
                FROM gentablesitemtype gi2
                WHERE gi2.tableid = s.tableid
                  AND gi2.datacode = s.datacode
                  AND gi2.datasubcode = s.datasubcode
                  AND gi2.itemtypecode = @v_itemtype
                  AND gi2.itemtypesubcode = @v_filter_usageclass
                )
              )
            )
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE (
          v.taqversionspecategorykey = @v_categorykey
          OR a.showinsummaryind = 1
          )
      ORDER BY Sort_Summary ASC,
        item_sort ASC
    END
  END
  ELSE
  BEGIN -- @v_showinsummaryind <> 1
    SELECT v.*
    INTO #temp_taqversionspecitem
    FROM dbo.qpl_get_taqversion_specitems(@v_categorykey) v

    IF @v_itemtype = @v_spectemplate_itemtype
    BEGIN
      SELECT s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE v.taqversionspecategorykey = @v_categorykey
      ORDER BY s.sortorder ASC
    END
    ELSE IF @v_itemtype = @v_proj_itemtype
    BEGIN
      SELECT COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      INNER JOIN gentablesitemtype gi
        ON gi.tableid = s.tableid
          AND gi.datacode = s.datacode
          AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND (
            (gi.itemtypesubcode = @v_filter_usageclass)
            OR (
              gi.itemtypesubcode = 0
              AND NOT EXISTS (
                SELECT *
                FROM gentablesitemtype gi2
                WHERE gi2.tableid = s.tableid
                  AND gi2.datacode = s.datacode
                  AND gi2.datasubcode = s.datasubcode
                  AND gi2.itemtypecode = @v_itemtype
                  AND gi2.itemtypesubcode = @v_filter_usageclass
                )
              )
            )
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE v.taqversionspecategorykey = @v_categorykey
      
      UNION
      
      SELECT s.sortorder item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE v.taqversionspecategorykey = @v_categorykey
        AND NOT EXISTS (
          SELECT *
          FROM gentablesitemtype gi
          WHERE gi.tableid = s.tableid
            AND gi.datacode = s.datacode
            AND gi.datasubcode = s.datasubcode
            AND gi.itemtypecode = @v_itemtype
            AND gi.itemtypesubcode IN (@v_filter_usageclass, 0)
          )
        AND (
          v.itemdetailcode IS NOT NULL
          OR v.decimalvalue IS NOT NULL
          OR v.quantity IS NOT NULL
          OR v.description IS NOT NULL
          OR v.description2 IS NOT NULL
          )
      ORDER BY item_sort ASC
    END
    ELSE -- @v_itemtype != @v_proj_itemtype
    BEGIN
      SELECT COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1,
        COALESCE(a.itemlabel, s.datadesc) itemlabel,
        (
          SELECT COUNT(*)
          FROM sub2gentables
          WHERE tableid = 616
            AND datacode = s.datacode
            AND datasubcode = s.datasubcode
          ) num_sub2rows,
        a.itemcategorycode AS admincategorycode,
        a.itemcode AS adminitemcode,
        a.showqtyind,
        a.showqtylabel,
        a.showdecimalind,
        a.showdecimallabel,
        a.showdescind,
        a.showdesclabel,
        a.showvalidprtgsind,
        a.defaultvalidforprtgscode,
        a.showunitofmeasureind,
        a.defaultunitofmeasurecode,
        a.showdesc2ind,
        a.showdesc2label,
        v.*,
        CASE 
          WHEN v.itemdetailcode > 0
            AND v.itemdetailsubcode > 0
            AND s.numericdesc1 > 0
            THEN subs.datadesc
          ELSE ''
          END itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey, @v_windowname,  616, s.datacode, s.datasubcode, @v_printingkey) accesscode,
        rp.taqprojecttitle AS relatedprojectname
      FROM #temp_taqversionspecitem v
      INNER JOIN subgentables s
        ON s.tableid = 616
          AND s.datacode = v.itemcategorycode
          AND s.datasubcode = v.itemcode
      INNER JOIN gentablesitemtype gi
        ON gi.tableid = s.tableid
          AND gi.datacode = s.datacode
          AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND (
            (gi.itemtypesubcode = @v_filter_usageclass)
            OR (
              gi.itemtypesubcode = 0
              AND NOT EXISTS (
                SELECT *
                FROM gentablesitemtype gi2
                WHERE gi2.tableid = s.tableid
                  AND gi2.datacode = s.datacode
                  AND gi2.datasubcode = s.datasubcode
                  AND gi2.itemtypecode = @v_itemtype
                  AND gi2.itemtypesubcode = @v_filter_usageclass
                )
              )
            )
      LEFT JOIN taqspecadmin a
        ON a.itemcategorycode = v.itemcategorycode
          AND a.itemcode = v.itemcode
          AND ISNULL(a.prodspecsaccessind, 1) <> 0
          AND a.culturecode = @v_culturecode
      LEFT JOIN subgentables subs
        ON subs.tableid = s.numericdesc1
          AND subs.datacode = v.itemdetailcode
          AND subs.datasubcode = v.itemdetailsubcode
      LEFT JOIN taqproject rp
        ON rp.taqprojectkey = v.relatedprojectkey
          AND v.taqprojectkey = v.relatedprojectkey
      WHERE v.taqversionspecategorykey = @v_categorykey
      ORDER BY item_sort ASC
    END
  END

  SELECT @v_error = @@ERROR

  IF @v_error <> 0
  BEGIN
    SET @o_error_code = - 1
    SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@v_projectkey AS VARCHAR) + ', plstagecode=' + CAST(@v_plstagecode AS VARCHAR) + ', taqversionkey=' + CAST(@v_taqversionkey AS VARCHAR) + ', taqprojectformatkey=' + CAST(@v_formatkey AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC
  ON qpl_get_productionspecitems
  TO PUBLIC
GO


