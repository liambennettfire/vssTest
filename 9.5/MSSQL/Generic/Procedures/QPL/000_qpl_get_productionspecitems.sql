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
**********************************************************************************/
  
DECLARE
  @v_categorycode INT,
  @v_error    INT,
  @v_formatkey  INT,
  @v_plstagecode  INT,
  @v_projectkey INT,
  @v_proj_itemtype  INT,
  @v_proj_usageclass  INT,
  @v_rowcount INT,
  @v_taqversionkey  INT,
  @v_spectemplate_itemtype INT,
  @v_spectemplate_usageclass INT  

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
  WHERE taqversionspecategorykey = @i_categorykey

  -- Check if the passed Item Type/Usage Class matches this project's item type/class
  -- NOTE: The taqversionspeccategorykey passed in (@i_categorykey) may be the relatedspeccategorykey - ex. on Purchase Order summary,
  -- specs may really be coming from the Printing project, but we still need to filter the specs based on Purchase Order item type
  SELECT @v_proj_itemtype = searchitemcode, @v_proj_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @v_projectkey
    
  -- For Specification Templates, show items regardless of item type filter.
  -- In all other cases, show the items based on item type filter regardless if value is filled in (first part of union)
  -- and, if passed item type matches the project's item type, any existing items that have a value filled 
  -- even though item type filter would normally not show that item (second part of union)
  -- NOTE: We need to keep any specs with values in case that spec item was valid at some point but is not valid now - users should be able to view these
   
  IF @i_showinsummaryind = 1 BEGIN
    IF @i_itemtype = @v_spectemplate_itemtype
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, 
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode        
      WHERE v.taqprojectkey = @v_projectkey AND
        v.plstagecode = @v_plstagecode AND
        v.taqversionkey = @v_taqversionkey AND
        v.taqversionformatkey = @v_formatkey AND
        (v.taqversionspecategorykey = @i_categorykey OR a.showinsummaryind = 1)         
      ORDER BY Sort_Summary ASC
    ELSE IF @i_itemtype = @v_proj_itemtype
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode  
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqprojectkey = @v_projectkey AND
        v.plstagecode = @v_plstagecode AND
        v.taqversionkey = @v_taqversionkey AND
        v.taqversionformatkey = @v_formatkey AND
        (v.taqversionspecategorykey = @i_categorykey OR a.showinsummaryind = 1) 
      UNION
      SELECT COALESCE(a.summarysortorder, 9999) Sort_Summary, s.sortorder item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode 
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqprojectkey = @v_projectkey AND
        v.plstagecode = @v_plstagecode AND
        v.taqversionkey = @v_taqversionkey AND
        v.taqversionformatkey = @v_formatkey AND
        (v.taqversionspecategorykey = @i_categorykey OR a.showinsummaryind = 1) AND        
        NOT EXISTS (SELECT * FROM gentablesitemtype gi 
          WHERE gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode 
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)) AND
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
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqprojectkey = @v_projectkey AND
        v.plstagecode = @v_plstagecode AND
        v.taqversionkey = @v_taqversionkey AND
        v.taqversionformatkey = @v_formatkey AND
        (v.taqversionspecategorykey = @i_categorykey OR a.showinsummaryind = 1)
      ORDER BY Sort_Summary ASC, item_sort ASC
  END
  ELSE BEGIN	
    IF @i_itemtype = @v_spectemplate_itemtype
      SELECT s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode        
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqversionspecategorykey = @i_categorykey        
      ORDER BY s.sortorder ASC
    ELSE IF @i_itemtype = @v_proj_itemtype
      SELECT COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqversionspecategorykey = @i_categorykey
      UNION
      SELECT s.sortorder item_sort,
        s.numericdesc1, COALESCE(a.itemlabel, s.datadesc) itemlabel, 
        (SELECT COUNT(*) FROM sub2gentables WHERE tableid=616 AND datacode = s.datacode AND datasubcode = s.datasubcode) num_sub2rows,
        a.itemcategorycode AS admincategorycode, a.itemcode AS adminitemcode, a.showqtyind, a.showqtylabel, a.showdecimalind, a.showdecimallabel,
        a.showdescind, a.showdesclabel, a.showvalidprtgsind, a.defaultvalidforprtgscode, a.showunitofmeasureind, a.defaultunitofmeasurecode,
        a.showdesc2ind, a.showdesc2label,  v.*, 
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode        
      WHERE v.taqversionspecategorykey = @i_categorykey AND        
        NOT EXISTS (SELECT * FROM gentablesitemtype gi 
          WHERE gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode 
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)) AND
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
        dbo.qutl_check_subgentable_value_security(@i_userkey,@i_windowname,s.tableid,s.datacode,s.datasubcode) accesscode
      FROM taqversionspecitems_view v
        INNER JOIN subgentables s ON s.tableid = 616 AND s.datacode = v.itemcategorycode AND s.datasubcode = v.itemcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
          AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
        LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = v.itemcategorycode AND a.itemcode = v.itemcode
          AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = @i_culturecode
      WHERE v.taqversionspecategorykey = @i_categorykey
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
