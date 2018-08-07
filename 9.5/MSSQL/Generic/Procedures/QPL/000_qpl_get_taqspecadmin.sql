if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqspecadmin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqspecadmin
GO

CREATE PROCEDURE qpl_get_taqspecadmin
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_taqversionkey  integer,
  @i_formatkey      integer,
  @i_categorycode		integer,
  @i_itemtype     integer,
  @i_usageclass   integer,
  @i_culturecode  integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)

AS

/********************************************************************************************************************
**  Name: qpl_get_taqspecadmin
**  Desc: This procedure retrieves all taqspecadmin items for the given category and culture that are active, 
**        valid for this Item Type/Usage Class, and not blocked from access (prodspecsaccessind = 0 is no access).
**        In addition, it also gets valid spec items for the current Item Type/Usage Class that are not currently
**        set up for display for this culture (second part of UNION), and any existing saved spec items 
**        that are currently blocked from access for this Item Type/Usage Class but which have a value on the database.
**
**  Auth: Kate W.
**  Date: August 25 2014
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  07/11/2016   Colman      Case 39064 Deactivated Spec Items showing up on Summary Specs
**********************************************************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT s.datacode, s.datasubcode, COALESCE(a.itemlabel, s.datadesc) itemlabel, 0 invalid, 0 cult_unset
  FROM taqspecadmin a, subgentables s, gentablesitemtype g
  WHERE a.itemcategorycode = s.datacode AND 
    a.itemcode = s.datasubcode AND 
    g.tableid = s.tableid AND
    g.datacode = s.datacode AND
    g.datasubcode = s.datasubcode AND
    g.itemtypecode = @i_itemtype AND (g.itemtypesubcode = @i_usageclass OR g.itemtypesubcode = 0) AND
    s.tableid = 616 AND 
    s.datacode = @i_categorycode AND
    s.deletestatus = 'N' AND
    COALESCE(s.subgen4ind,0) = 1 AND -- Show as Spec
    a.culturecode = @i_culturecode AND
    (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0)
  UNION
  SELECT s.datacode, s.datasubcode, s.datadesc + '*' itemlabel, 0 invalid, 1 cult_unset
  FROM subgentables s, gentablesitemtype g
  WHERE g.tableid = s.tableid AND
    g.datacode = s.datacode AND
    g.datasubcode = s.datasubcode AND
    g.itemtypecode = @i_itemtype AND (g.itemtypesubcode = @i_usageclass OR g.itemtypesubcode = 0) AND
    s.tableid = 616 AND 
    s.datacode = @i_categorycode AND
    s.deletestatus = 'N' AND
    COALESCE(s.subgen4ind,0) = 1 AND -- Show as Spec
    NOT EXISTS (SELECT * FROM taqspecadmin a 
      WHERE a.itemcategorycode = s.datacode AND a.itemcode = s.datasubcode AND a.culturecode = @i_culturecode)
  UNION
  SELECT s.datacode, s.datasubcode, COALESCE(a.itemlabel, s.datadesc) + '**' itemlabel, 1 invalid, 0 cult_unset
  FROM taqversionspecitems i
    INNER JOIN subgentables s ON i.itemcode = s.datasubcode
    INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
    LEFT OUTER JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode
      AND (a.prodspecsaccessind IS NULL OR a.prodspecsaccessind <> 0) AND a.culturecode = 3
  WHERE s.tableid = 616 AND        
    c.taqprojectkey = @i_projectkey AND
    c.plstagecode = @i_plstagecode AND
    c.taqversionkey = @i_taqversionkey AND
    c.taqversionformatkey = @i_formatkey AND
    c.itemcategorycode = @i_categorycode AND
    NOT EXISTS (SELECT * FROM gentablesitemtype gi 
      WHERE gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode 
      AND gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)) AND
    (i.itemdetailcode IS NOT NULL OR i.decimalvalue IS NOT NULL 
      OR i.quantity IS NOT NULL OR i.description IS NOT NULL OR i.description2 IS NOT NULL)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqspecadmin table.'
  END
  
END
go

GRANT EXEC ON qpl_get_taqspecadmin TO PUBLIC
go
