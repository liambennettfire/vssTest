if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionspeccategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionspeccategories
GO

CREATE PROCEDURE [dbo].[qpl_get_taqversionspeccategories]
 (@i_projectkey     INTEGER,
  @i_plstagecode    INTEGER,
  @i_taqversionkey  INTEGER,
  @i_formatkey      INTEGER,
  @i_categorycode  INTEGER,
  @o_error_code     INTEGER OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
--WITH RECOMPILE
AS

/*********************************************************************************
**  Name: qpl_get_taqversionspeccategories
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: February 28, 2012
**********************************************************************************
**    Change History
**********************************************************************************
**    Date:        Author:        Description:
**    ----------   ----------     ------------------------------------------------
**    08/31/2016   Colman         Case 40156
**    01/04/2017   Alan           Case 42487
**    01/05/2017   Dustin      Case 42487
**    01/17/2017   Dustin      Case 42679
**    02/23/2017   Alan         Case 43475
**    04/04/2017   Josh        Case 44188
**    05/25/2017   Colman         Case 45158
**    06/09/2017   Colman         Case 45061 relatedprojectname/type/class was broken
***********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''


DECLARE 
  @v_summary INT,
  @v_voidStatus INT 
SET @v_summary = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1) 
SET @v_voidStatus = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10)
  
SELECT
  c.taqversionspecategorykey,
  c.taqprojectkey
INTO
  #relatedcomponents1
FROM 
  taqversionspeccategory c
WHERE ISNULL(c.relatedspeccategorykey,0) = 0
    AND c.taqprojectkey = @i_projectkey 
    AND c.plstagecode = @i_plstagecode
    AND c.taqversionkey = @i_taqversionkey 
    AND c.taqversionformatkey = @i_formatkey 
  
CREATE NONCLUSTERED INDEX idx1 ON #relatedcomponents1(taqprojectkey)

 SELECT v.taqprojectkey,p.taqprojecttitle,p.taqprojectstatuscode,c.taqversionspecategorykey,v.activeind, 
        p.searchitemcode,p.usageclasscode,v.relatedformatkey,
    ROW_NUMBER() OVER(PARTITION BY c.taqversionspecategorykey ORDER BY v.activeind DESC) rnk
 INTO #relatedcomponents
 FROM #relatedcomponents1 c
INNER JOIN taqversionrelatedcomponents_view v
  ON v.relatedcategorykey = c.taqversionspecategorykey 
  AND v.relatedcategorykey <> v.taqversionspecategorykey 
INNER JOIN taqproject p
  ON v.taqprojectkey = p.taqprojectkey
  
CREATE NONCLUSTERED INDEX idx1 ON #relatedcomponents (taqversionspecategorykey) INCLUDE (taqprojectkey,taqprojecttitle,searchitemcode,usageclasscode,taqprojectstatuscode)

SELECT  
  t.taqversionspecategorykey,
  COUNT(1) cntr
INTO
  #relatedcomponentsCnt
FROM
  #relatedcomponents t 
WHERE
  ISNULL(t.relatedformatkey, 0) > 0
GROUP BY t.taqversionspecategorykey



  IF @i_categorycode > 0
  BEGIN
    SELECT 
      r.taqprojectkey AS relatedprojectkey,
      r.taqprojecttitle AS relatedprojectname,
      r.searchitemcode AS relatedprojecttype,
      r.usageclasscode AS relatedprojectclass,
      r.taqprojectstatuscode AS relatedprojectstatus,
      @v_voidStatus AS voidstatus,
    CASE WHEN rc.cntr IS NOT NULL THEN 1 ELSE 0 END multiplerelatedformats,
    CASE WHEN itemcategorycode = @v_summary THEN 1 ELSE 0 END is_summary,
      c.taqversionspecategorykey, c.relatedspeccategorykey, c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, ISNULL(c.vendorcontactkey, 0) as vendorcontactkey, ISNULL(gc.displayname, '') as vendorname, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, ISNULL(c.finishedgoodind,0) as 'finishedgoodind', ISNULL(c.sortorder, 999) AS sort,
      0 sharedcomponentind
    FROM taqversionspeccategory c 
      INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
      LEFT OUTER JOIN globalcontact gc ON c.vendorcontactkey = gc.globalcontactkey
      LEFT JOIN #relatedcomponents r ON r.taqversionspecategorykey = c.taqversionspecategorykey AND r.rnk = 1
      LEFT JOIN #relatedcomponentsCnt rc ON rc.taqversionspecategorykey = c.taqversionspecategorykey AND rc.cntr > 1
    WHERE c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstagecode AND
      c.taqversionkey = @i_taqversionkey AND
      c.taqversionformatkey = @i_formatkey AND
      c.itemcategorycode = @i_categorycode AND
      ISNULL(c.relatedspeccategorykey,0) = 0
    UNION
    SELECT
      c.taqprojectkey relatedprojectkey,
      p.taqprojecttitle AS relatedprojectname,
      p.searchitemcode AS relatedprojecttype,
      p.usageclasscode AS relatedprojectclass,
      p.taqprojectstatuscode AS relatedprojectstatus,
      @v_voidStatus AS voidstatus,
    CASE WHEN rc.cntr IS NOT NULL THEN 1 ELSE 0 END multiplerelatedformats,
    CASE WHEN c.itemcategorycode = @v_summary THEN 1 ELSE 0 END is_summary,
      c2.taqversionspecategorykey, c2.relatedspeccategorykey, c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, ISNULL(c.vendorcontactkey, 0) as vendorcontactkey, ISNULL(gc.displayname, '') as vendorname, c.sortorder, 
    CASE WHEN ISNULL(c2.quantity, 0) > 0 THEN c2.quantity WHEN ISNULL(c2.relatedspeccategorykey, 0) > 0 THEN c.quantity ELSE c2.quantity END quantity,
      c.deriveqtyfromfgqty, c.spoilagepercentage, ISNULL(c.finishedgoodind,0) as 'finishedgoodind', ISNULL(c.sortorder, 999) AS sort,
      rf.sharedposectionind sharedcomponentind
    FROM taqversionspeccategory c 
    INNER JOIN taqproject p ON p.taqprojectkey = c.taqprojectkey
      INNER JOIN taqversionspeccategory c2 ON c.taqversionspecategorykey = c2.relatedspeccategorykey
      INNER JOIN gentables g ON c.itemcategorycode = g.datacode  AND g.tableid = 616 
      LEFT OUTER JOIN globalcontact gc ON c.vendorcontactkey = gc.globalcontactkey
      LEFT OUTER JOIN taqversionformat rf ON c.taqversionformatkey = rf.taqprojectformatkey
      LEFT JOIN #relatedcomponentsCnt rc ON rc.taqversionspecategorykey = c.taqversionspecategorykey AND rc.cntr > 1
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
      r.taqprojectkey AS relatedprojectkey,
      r.taqprojecttitle AS relatedprojectname,
      r.searchitemcode AS relatedprojecttype,
      r.usageclasscode AS relatedprojectclass,
      r.taqprojectstatuscode AS relatedprojectstatus,
      @v_voidStatus AS voidstatus,
    CASE WHEN rc.cntr IS NOT NULL THEN 1 ELSE 0 END multiplerelatedformats,
      @v_summary, qsicode,
    CASE WHEN c.itemcategorycode = @v_summary THEN 1 ELSE 0 END is_summary,
      c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c.taqversionspecategorykey, c.relatedspeccategorykey, ISNULL(c.relatedspeccategorykey, c.taqversionspecategorykey) categorykey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, ISNULL(c.vendorcontactkey, 0) as vendorcontactkey, ISNULL(gc.displayname, '') as vendorname, c.sortorder, 
      c.quantity, c.deriveqtyfromfgqty, c.spoilagepercentage, ISNULL(c.finishedgoodind,0) as 'finishedgoodind', ISNULL(c.sortorder, 999) AS sort,
      0 sharedcomponentind
    FROM taqversionspeccategory c 
      INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
      LEFT OUTER JOIN globalcontact gc ON c.vendorcontactkey = gc.globalcontactkey
      LEFT JOIN #relatedcomponents r ON r.taqversionspecategorykey = c.taqversionspecategorykey AND r.rnk = 1
      LEFT JOIN #relatedcomponentsCnt rc ON rc.taqversionspecategorykey = c.taqversionspecategorykey AND rc.cntr > 1
    WHERE c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstagecode AND
      c.taqversionkey = @i_taqversionkey AND
      c.taqversionformatkey = @i_formatkey AND
      ISNULL(c.relatedspeccategorykey,0) = 0
    UNION
    SELECT
      c.taqprojectkey relatedprojectkey,
      p.taqprojecttitle AS relatedprojectname,
      p.searchitemcode AS relatedprojecttype,
      p.usageclasscode AS relatedprojectclass,
      p.taqprojectstatuscode AS relatedprojectstatus,
      @v_voidStatus AS voidstatus,
    CASE WHEN rc.cntr IS NOT NULL THEN 1 ELSE 0 END multiplerelatedformats,
      @v_summary, qsicode,
    CASE WHEN c.itemcategorycode = @v_summary THEN 1 ELSE 0 END is_summary,
      c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, 
      c2.taqversionspecategorykey, c2.relatedspeccategorykey, ISNULL(c2.relatedspeccategorykey, c2.taqversionspecategorykey) categorykey,
      c.itemcategorycode, c.speccategorydescription, c.scaleprojecttype, ISNULL(c.vendorcontactkey, 0) as vendorcontactkey, ISNULL(gc.displayname, '') as vendorname, c.sortorder, 
    CASE WHEN ISNULL(c2.quantity, 0) > 0 THEN c2.quantity WHEN ISNULL(c2.relatedspeccategorykey, 0) > 0 THEN c.quantity ELSE c2.quantity END quantity,
      c.deriveqtyfromfgqty, c.spoilagepercentage, ISNULL(c.finishedgoodind,0) as 'finishedgoodind', ISNULL(c.sortorder, 999) AS sort,
      rf.sharedposectionind sharedcomponentind
    FROM taqversionspeccategory c 
    INNER JOIN taqproject p ON p.taqprojectkey = c.taqprojectkey
      INNER JOIN taqversionspeccategory c2 ON c.taqversionspecategorykey = c2.relatedspeccategorykey
      INNER JOIN gentables g ON c.itemcategorycode = g.datacode AND g.tableid = 616 
      LEFT OUTER JOIN globalcontact gc ON c.vendorcontactkey = gc.globalcontactkey
      LEFT OUTER JOIN taqversionformat rf ON c.taqversionformatkey = rf.taqprojectformatkey
      LEFT JOIN #relatedcomponentsCnt rc ON rc.taqversionspecategorykey = c.taqversionspecategorykey AND rc.cntr > 1
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
  
  DROP TABLE #relatedcomponents 

END

go

GRANT EXEC ON qpl_get_taqversionspeccategories TO PUBLIC
go