if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionspeccategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionspeccategories
GO

CREATE PROCEDURE qpl_get_taqversionspeccategories
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_taqversionkey  integer,
  @i_formatkey      integer,
  @i_categorycode	integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_get_taqversionspeccategories
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: February 28, 2012
**********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  IF @i_categorycode > 0
  BEGIN
    SELECT 
      (SELECT TOP(1) taqprojectkey FROM taqversionrelatedcomponents_view v WHERE v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectkey,
      (SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view v WHERE p.taqprojectkey = v.taqprojectkey AND v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectname,
      (SELECT TOP(1) taqprojectstatuscode FROM taqproject p, taqversionrelatedcomponents_view v WHERE p.taqprojectkey = v.taqprojectkey AND v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectstatus,
      (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10) voidstatus,
      CASE WHEN itemcategorycode = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1) THEN 1 ELSE 0 END is_summary,
      c.taqversionspecategorykey, c.relatedspeccategorykey, c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, COALESCE(c.vendorcontactkey, 0) as vendorcontactkey, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, coalesce(c.finishedgoodind,0) as 'finishedgoodind', COALESCE(c.sortorder, 999) AS sort
    FROM taqversionspeccategory c INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
    WHERE c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstagecode AND
      c.taqversionkey = @i_taqversionkey AND
      c.taqversionformatkey = @i_formatkey AND
      c.itemcategorycode = @i_categorycode AND
      COALESCE(c.relatedspeccategorykey,0) = 0
    UNION
    SELECT
      c.taqprojectkey relatedprojectkey,
      (SELECT taqprojecttitle FROM taqproject p WHERE p.taqprojectkey = c.taqprojectkey) relatedprojectname,
      (SELECT taqprojectstatuscode FROM taqproject p WHERE p.taqprojectkey = c.taqprojectkey) relatedprojectstatus,
      (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10) voidstatus,
      CASE WHEN c.itemcategorycode = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1) THEN 1 ELSE 0 END is_summary,
      c2.taqversionspecategorykey, c2.relatedspeccategorykey, c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, COALESCE(c.vendorcontactkey, 0) as vendorcontactkey, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, coalesce(c.finishedgoodind,0) as 'finishedgoodind', COALESCE(c.sortorder, 999) AS sort
    FROM taqversionspeccategory c INNER JOIN taqversionspeccategory c2 ON c.taqversionspecategorykey = c2.relatedspeccategorykey
								  INNER JOIN gentables g ON c.itemcategorycode = g.datacode	AND g.tableid = 616 
    WHERE c2.taqprojectkey = @i_projectkey AND
      c2.plstagecode = @i_plstagecode AND
      c2.taqversionkey = @i_taqversionkey AND
      c2.taqversionformatkey = @i_formatkey AND
      c2.itemcategorycode = @i_categorycode AND
      c2.relatedspeccategorykey > 0    
    ORDER BY sort ASC, is_summary DESC, taqversionspecategorykey
  END
  ELSE BEGIN
    SELECT 
      (SELECT TOP(1) taqprojectkey FROM taqversionrelatedcomponents_view v WHERE v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectkey,
      (SELECT TOP(1) taqprojecttitle FROM taqproject p, taqversionrelatedcomponents_view v WHERE p.taqprojectkey = v.taqprojectkey AND v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectname,
      (SELECT TOP(1) taqprojectstatuscode FROM taqproject p, taqversionrelatedcomponents_view v WHERE p.taqprojectkey = v.taqprojectkey AND v.relatedcategorykey = c.taqversionspecategorykey AND v.relatedcategorykey <> v.taqversionspecategorykey ORDER BY v.activeind DESC) relatedprojectstatus,
      (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10) voidstatus,
      (SELECT qsicode FROM gentables WHERE tableid = 616 AND qsicode = 1), qsicode,
      CASE WHEN c.itemcategorycode = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1) THEN 1 ELSE 0 END is_summary,
      c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c.taqversionspecategorykey, c.relatedspeccategorykey, COALESCE(c.relatedspeccategorykey, c.taqversionspecategorykey) categorykey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, COALESCE(c.vendorcontactkey, 0) as vendorcontactkey, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, coalesce(c.finishedgoodind,0) as 'finishedgoodind', COALESCE(c.sortorder, 999) AS sort
    FROM taqversionspeccategory c INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
    WHERE c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstagecode AND
      c.taqversionkey = @i_taqversionkey AND
      c.taqversionformatkey = @i_formatkey AND
      COALESCE(c.relatedspeccategorykey,0) = 0
    UNION
    SELECT
      c.taqprojectkey relatedprojectkey,
      (SELECT taqprojecttitle FROM taqproject p WHERE p.taqprojectkey = c.taqprojectkey) relatedprojectname,
      (SELECT taqprojectstatuscode FROM taqproject p WHERE p.taqprojectkey = c.taqprojectkey) relatedprojectstatus,
      (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10) voidstatus,
      (SELECT qsicode FROM gentables WHERE tableid = 616 AND qsicode = 1), qsicode,
      CASE WHEN c.itemcategorycode = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1) THEN 1 ELSE 0 END is_summary,
      c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c2.taqversionspecategorykey, c2.relatedspeccategorykey, COALESCE(c2.relatedspeccategorykey, c2.taqversionspecategorykey) categorykey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, COALESCE(c.vendorcontactkey, 0) as vendorcontactkey, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, coalesce(c.finishedgoodind,0) as 'finishedgoodind', COALESCE(c.sortorder, 999) AS sort
    FROM taqversionspeccategory c INNER JOIN taqversionspeccategory c2 ON c.taqversionspecategorykey = c2.relatedspeccategorykey
    							  INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
    WHERE c2.taqprojectkey = @i_projectkey AND
      c2.plstagecode = @i_plstagecode AND
      c2.taqversionkey = @i_taqversionkey AND
      c2.taqversionformatkey = @i_formatkey AND
      c2.relatedspeccategorykey > 0    
    ORDER BY sort ASC, is_summary DESC, categorykey
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspeccategories table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstagecode AS VARCHAR) + ', taqversionkey=' + CAST(@i_taqversionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END
  
END
go

GRANT EXEC ON qpl_get_taqversionspeccategories TO PUBLIC
go
