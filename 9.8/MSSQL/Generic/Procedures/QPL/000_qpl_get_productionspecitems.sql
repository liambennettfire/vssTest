if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_productionspecitems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_productionspecitems
GO

CREATE PROCEDURE qpl_get_productionspecitems
 (@i_categorykey      integer,
  @i_showinsummaryind	integer,
  @i_itemtype         integer,
  @i_usageclass       integer,
  @i_culturecode      integer,
  @i_userkey          integer,
  @i_windowname       varchar(100),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
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
**********************************************************************************/
  
DECLARE
  @v_categorycode INT,
  @v_error    INT,
  @v_formatkey  INT,
  @v_plstagecode  INT,
  @v_projectkey INT,
  @v_proj_itemtype  INT,
  @v_proj_usageclass  INT,
  @v_filter_usageclass INT,
  @v_rowcount INT,
  @v_taqversionkey  INT,
  @v_spectemplate_itemtype INT,
  @v_spectemplate_usageclass INT  

 --I know this looks weird but it will prevent parameter sniffing which has been slowing down the proc
DECLARE
	@v_categorykey      integer,
	@v_showinsummaryind	integer,
	@v_itemtype         integer,
	@v_usageclass       integer,
	@v_culturecode      integer,
	@v_userkey          integer,
	@v_windowname       varchar(100)
 
SET @v_categorykey = @i_categorykey
SET @v_showinsummaryind	= @i_showinsummaryind 
SET @v_itemtype = @i_itemtype
SET @v_usageclass = @i_usageclass    
SET @v_culturecode = @i_culturecode  
SET @v_userkey = @i_userkey       
SET @v_windowname = @i_windowname






BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_spectemplate_itemtype = datacode, @v_spectemplate_usageclass = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 44    --Specification Template

  -- Get the details associated with the passed taqversionspecategorykey (@i_categorykey)
  SELECT @v_projectkey = taqprojectkey, @v_plstagecode = plstagecode, @v_taqversionkey = taqversionkey,
    @v_formatkey = taqversionformatkey, @v_categorycode = itemcategorycode
  FROM taqversionspeccategory
  WHERE taqversionspecategorykey = @v_categorykey

  -- Check if the passed Item Type/Usage Class matches this project's item type/class
  -- NOTE: The taqversionspeccategorykey passed in (@v_categorykey) may be the relatedspeccategorykey - ex. on Purchase Order summary,
  -- specs may really be coming from the Printing project, but we still need to filter the specs based on Purchase Order item type
  SELECT @v_proj_itemtype = searchitemcode, @v_proj_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @v_projectkey

  SET @v_filter_usageclass = @v_usageclass
  
  --exec qutl_trace 'qpl_get_productionspecitems',
  --  '@v_categorykey', @v_categorykey, NULL,
  --  '@v_showinsummaryind', @v_showinsummaryind, NULL,
  --  '@v_itemtype', @v_itemtype, NULL,
  --  '@v_usageclass', @v_usageclass, NULL,
  --  '@v_culturecode', @v_culturecode, NULL,
  --  '@v_userkey', @v_userkey, NULL,
  --  '@v_windowname', NULL, @v_windowname,
  --  '@v_filter_usageclass', @v_filter_usageclass
  
  -- For Specification Templates, show items regardless of item type filter.
  -- In all other cases, show the items based on item type filter regardless if value is filled in (first part of union)
  -- and, if passed item type matches the project's item type, any existing items that have a value filled 
  -- even though item type filter would normally not show that item (second part of union)
  -- NOTE: We need to keep any specs with values in case that spec item was valid at some point but is not valid now - users should be able to view these
   
  
  IF @v_showinsummaryind = 1 BEGIN
  
  --Break this out a bit and hopefully gain some speed
  SELECT v.*
  INTO #temp_taqversionspecitem
  FROM taqversionspecitems_view v
  WHERE v.taqprojectkey = @v_projectkey AND
        v.plstagecode = @v_plstagecode AND
        v.taqversionkey = @v_taqversionkey AND
        v.taqversionformatkey = @v_formatkey
	
	--related project 
	;WITH CTE_relatedCategory
	AS
	(
		SELECT 
			c.taqprojectkey,
			sc.relatedspeccategorykey AS relatedcategorykey,
			c.taqversionspecategorykey,
			CASE WHEN gen.datacode IS NOT NULL THEN 0 ELSE 1 END activeind,
			tp.taqprojecttitle
		FROM 
			taqversionspeccategory c
		INNER JOIN taqversionspeccategory sc
			ON c.relatedspeccategorykey = sc.taqversionspecategorykey
		INNER JOIN taqproject tp
			ON c.taqprojectkey = tp.taqprojectkey		
		LEFT JOIN gentables gen 
			ON tp.taqprojectstatuscode = gen.datacode
			AND gen.tableid = 522 
			AND gen.qsicode = 10
		WHERE c.relatedspeccategorykey IS NOT NULL 
		AND c.relatedspeccategorykey != 0
	)
	SELECT TOP 1 r.taqprojecttitle,v.taqversionspecategorykey
	INTO #temp_taqversionspecitemRel
	FROM #temp_taqversionspecitem v
	INNER JOIN CTE_relatedCategory r
		ON r.relatedcategorykey = v.taqversionspecategorykey
		AND r.relatedcategorykey <> r.taqversionspecategorykey 
	ORDER BY r.activeind DESC 
				
    IF @v_itemtype = @v_spectemplate_itemtype
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, 
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
	   --(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitem v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode 
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE 
        (v.taqversionspecategorykey = @v_categorykey OR a.showinsummaryind = 1)         
      ORDER BY Sort_Summary ASC
    ELSE IF @v_itemtype = @v_proj_itemtype
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitem v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode  
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid 
          AND gi.datacode = s.datacode 
          AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype 
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND ((gi.itemtypesubcode = @v_filter_usageclass)
                OR 
                (gi.itemtypesubcode = 0 
                AND NOT EXISTS (SELECT * FROM gentablesitemtype gi2 WHERE gi2.tableid = s.tableid 
                                AND gi2.datacode = s.datacode 
                                AND gi2.datasubcode = s.datasubcode
                                AND gi2.itemtypecode = @v_itemtype
                                AND gi2.itemtypesubcode = @v_filter_usageclass)))
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE 
        (v.taqversionspecategorykey = @v_categorykey OR a.showinsummaryind = 1) 
      UNION
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, s.sortorder item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitem v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode 
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE 
        (v.taqversionspecategorykey = @v_categorykey OR a.showinsummaryind = 1) AND        
        NOT EXISTS (SELECT * FROM gentablesitemtype gi 
          WHERE gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode 
          AND gi.itemtypecode = @v_itemtype AND gi.itemtypesubcode IN (@v_filter_usageclass, 0)) AND
        (v.itemdetailcode IS NOT NULL OR v.decimalvalue IS NOT NULL 
          OR v.quantity IS NOT NULL OR v.description IS NOT NULL OR v.description2 IS NOT NULL)
      ORDER BY Sort_Summary ASC, item_sort ASC
    ELSE
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitem v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND ((gi.itemtypesubcode = @v_filter_usageclass)
                OR 
                (gi.itemtypesubcode = 0 
                AND NOT EXISTS (SELECT * FROM gentablesitemtype gi2 WHERE gi2.tableid = s.tableid 
                                AND gi2.datacode = s.datacode 
                                AND gi2.datasubcode = s.datasubcode
                                AND gi2.itemtypecode = @v_itemtype
                                AND gi2.itemtypesubcode = @v_filter_usageclass)))
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE
        (v.taqversionspecategorykey = @v_categorykey OR a.showinsummaryind = 1)
      ORDER BY Sort_Summary ASC, item_sort ASC
  END
  
  
  ELSE BEGIN	-- @v_showinsummaryind <> 1
  
  SELECT v.*
  INTO #temp_taqversionspecitemShowSum
  FROM taqversionspecitems_view v
  WHERE v.taqversionspecategorykey = @v_categorykey
  
	--related project 
	;WITH CTE_relatedCategory
	AS
	(
		SELECT 
			c.taqprojectkey,
			sc.relatedspeccategorykey AS relatedcategorykey,
			c.taqversionspecategorykey,
			CASE WHEN gen.datacode IS NOT NULL THEN 0 ELSE 1 END activeind,
			tp.taqprojecttitle
		FROM 
			taqversionspeccategory c
		INNER JOIN taqversionspeccategory sc
			ON c.relatedspeccategorykey = sc.taqversionspecategorykey
		INNER JOIN taqproject tp
			ON c.taqprojectkey = tp.taqprojectkey		
		LEFT JOIN gentables gen 
			ON tp.taqprojectstatuscode = gen.datacode
			AND gen.tableid = 522 
			AND gen.qsicode = 10
		WHERE c.relatedspeccategorykey IS NOT NULL 
		AND c.relatedspeccategorykey != 0
	)
	SELECT TOP 1 r.taqprojecttitle,v.taqversionspecategorykey
	INTO #temp_taqversionspecitemShowSumRel
	FROM #temp_taqversionspecitemShowSum v
	INNER JOIN CTE_relatedCategory r
		ON r.relatedcategorykey = v.taqversionspecategorykey
		AND r.relatedcategorykey <> r.taqversionspecategorykey 
	ORDER BY r.activeind DESC 
	
    IF @v_itemtype = @v_spectemplate_itemtype
      SELECT s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitemShowSum v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode        
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemShowSumRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE v.taqversionspecategorykey = @v_categorykey        
      ORDER BY s.sortorder ASC
    ELSE IF @v_itemtype = @v_proj_itemtype
      SELECT COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitemShowSum v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND ((gi.itemtypesubcode = @v_filter_usageclass)
                OR 
                (gi.itemtypesubcode = 0 
                AND NOT EXISTS (SELECT * FROM gentablesitemtype gi2 WHERE gi2.tableid = s.tableid 
                                AND gi2.datacode = s.datacode 
                                AND gi2.datasubcode = s.datasubcode
                                AND gi2.itemtypecode = @v_itemtype
                                AND gi2.itemtypesubcode = @v_filter_usageclass)))
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemShowSumRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey
      WHERE v.taqversionspecategorykey = @v_categorykey
      UNION
      SELECT s.sortorder item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitemShowSum v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode       
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemShowSumRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey		
      WHERE v.taqversionspecategorykey = @v_categorykey AND        
        NOT EXISTS (SELECT * FROM gentablesitemtype gi 
          WHERE gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode 
          AND gi.itemtypecode = @v_itemtype AND gi.itemtypesubcode IN (@v_filter_usageclass, 0)) AND
        (v.itemdetailcode IS NOT NULL OR v.decimalvalue IS NOT NULL 
          OR v.quantity IS NOT NULL OR v.description IS NOT NULL OR v.description2 IS NOT NULL)
      ORDER BY item_sort ASC
    ELSE
      SELECT COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*,
		--IIF(v.itemdetailcode > 0 AND v.itemdetailsubcode > 0 AND s.numericdesc1 > 0, subs.datadesc, '') itemdetailsubdesc,
        dbo.qutl_check_subgentable_value_security(@v_userkey,@v_windowname,s.tableid,s.datacode,s.datasubcode) accesscode,
        si.taqprojecttitle AS relatedprojectname
		--(SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view r WHERE p.taqprojectkey = r.taqprojectkey AND r.relatedcategorykey = v.taqversionspecategorykey AND r.relatedcategorykey <> r.taqversionspecategorykey ORDER BY r.activeind DESC) relatedprojectname
      FROM #temp_taqversionspecitemShowSum v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @v_itemtype
          -- If the item is filtered in for both the specific usageclass and all usagesclasses, the specific class takes precedence
          AND ((gi.itemtypesubcode = @v_filter_usageclass)
                OR 
                (gi.itemtypesubcode = 0 
                AND NOT EXISTS (SELECT * FROM gentablesitemtype gi2 WHERE gi2.tableid = s.tableid 
                                AND gi2.datacode = s.datacode 
                                AND gi2.datasubcode = s.datasubcode
                                AND gi2.itemtypecode = @v_itemtype
                                AND gi2.itemtypesubcode = @v_filter_usageclass)))
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @v_culturecode
		LEFT JOIN subgentables subs ON subs.tableid = s.numericdesc1 AND subs.datacode = v.itemdetailcode AND subs.datasubcode = v.itemdetailsubcode
		LEFT JOIN #temp_taqversionspecitemShowSumRel si ON si.taqversionspecategorykey = v.taqversionspecategorykey		
      WHERE v.taqversionspecategorykey = @v_categorykey
      ORDER BY item_sort ASC
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@v_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@v_plstagecode AS VARCHAR) + ', taqversionkey=' + CAST(@v_taqversionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@v_formatkey AS VARCHAR) + ').'
  END
  
END
go

GRANT EXEC ON qpl_get_productionspecitems TO PUBLIC
go
