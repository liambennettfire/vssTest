-- Set up calculations
--delete from miscitemcalc where misckey in (select misckey from bookmiscitems where lastmaintdate > '2014-04-30')
DECLARE
  @v_count  INT,
  @v_misckey  INT,
  @v_miscname VARCHAR(40)
     
BEGIN

  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Acquisitions Currently Active'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Acquisitions Currently Active'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqproject WHERE searchitemcode = (SELECT datacode FROM subgentables WHERE tableid=550 AND qsicode=1) AND usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid=550 AND qsicode=1) AND taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode=3) AND templateind = 0', 
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END

  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Idea Phase Acquisitions'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Idea Phase Acquisitions'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqproject WHERE searchitemcode = (SELECT datacode FROM subgentables WHERE tableid=550 AND qsicode=1) AND usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid=550 AND qsicode=1) AND taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode=4) AND templateind = 0', 
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END

  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Acquisitions Approved in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Acquisitions Approved in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqproject WHERE searchitemcode = (SELECT datacode FROM subgentables WHERE tableid=550 AND qsicode=1) AND usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid=550 AND qsicode=1) AND taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode=1) AND templateind = 0 AND lastmaintdate > DATEADD(dd, -30, getdate())', 
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Contracts Signed in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Contracts Signed in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqproject WHERE searchitemcode = (SELECT datacode FROM gentables WHERE tableid=550 and qsicode=10) AND taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND datadesc=''Contract Signed'') AND templateind = 0 AND lastmaintdate > DATEADD(dd, -30, getdate())', 
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Contracts Pending'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Contracts Pending'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqproject WHERE searchitemcode = (SELECT datacode FROM gentables WHERE tableid=550 and qsicode=10) AND taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND datadesc=''In Contracts Dept'') AND templateind = 0', 
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Active Titles'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Active Titles'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM coretitleinfo c, bookorgentry bo WHERE c.bookkey = bo.bookkey AND (c.printingkey=1 OR c.issuenumber > 1) AND standardind = ''N'' AND usageclasscode = 1 AND bo.orgentrykey IN @userorgsecurityfilter',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Titles Publishing in next 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Titles Publishing in next 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM coretitleinfo c, bookorgentry bo WHERE c.bookkey = bo.bookkey AND (c.printingkey=1 OR c.issuenumber > 1) AND standardind = ''N'' AND usageclasscode = 1 AND (c.bestpubdate BETWEEN getdate() AND DATEADD(dd, 30, getdate())) AND bo.orgentrykey IN @userorgsecurityfilter',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Titles in Outbox'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Titles in Outbox'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(bd.bookkey) FROM bookdetail bd, bookorgentry bo WHERE bd.bookkey = bo.bookkey AND (bd.csmetadatastatuscode = 5 OR bd.csassetstatuscode = 5) AND bd.csapprovalcode = 1 AND bo.orgentrykey IN @userorgsecurityfilter',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Distributions in Outbox'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Distributions in Outbox'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(t.assetkey) FROM taqprojectelementpartner t INNER JOIN bookdetail bd ON bd.bookkey = t.bookkey INNER JOIN bookorgentry bo ON bo.bookkey = t.bookkey INNER JOIN taqprojectelement e ON t.assetkey = e.taqelementkey WHERE t.cspartnerstatuscode = 5 AND t.resendind=1 AND bd.csapprovalcode = 1 AND bo.orgentrykey IN @userorgsecurityfilter',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Total Gross Margin for Transmittals/last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Total Gross Margin for Transmittals/last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT SUM(decimalvalue) FROM taqplsummaryitems i, taqplstage s WHERE i.taqprojectkey = s.taqprojectkey AND i.plstagecode = s.plstagecode AND i.plsummaryitemkey = (SELECT plsummaryitemkey FROM plsummaryitemdefinition WHERE itemname=''Stage - Gross Margin'') AND i.plstagecode = (SELECT datacode FROM gentables WHERE tableid=562 AND datadescshort=''transmittal'') AND (s.lastmaintdate BETWEEN DATEADD(dd, -30, getdate()) AND getdate())',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END 
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Titles Sent in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Titles Sent in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(DISTINCT bookkey) FROM taqprojecttask WHERE datetypecode IN (SELECT datetypecode FROM datetype WHERE qsicode = 11) AND (activedate BETWEEN DATEADD(dd, -30, getdate()) AND getdate()) AND actualind = 1',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Distributions in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Distributions in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqprojecttask WHERE datetypecode IN (SELECT datetypecode FROM datetype WHERE qsicode = 11) AND (activedate BETWEEN DATEADD(dd, -30, getdate()) AND getdate()) AND actualind = 1',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END  
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Assets uploaded in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Assets uploaded in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqprojecttask t, taqprojectelement e WHERE t.taqelementkey = e.taqelementkey AND t.datetypecode IN (SELECT datetypecode FROM datetype WHERE qsicode = 12) AND (t.activedate BETWEEN DATEADD(dd, -30, getdate()) AND getdate()) AND actualind = 1 AND (e.taqelementtypecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3))',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Jobs with Errors in last 7 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Jobs with Errors in last 7 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM jobsummary_view WHERE errorind = 1 AND (startdatetime BETWEEN DATEADD(dd, -7, getdate()) AND getdate())',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Distribution Failures in last 7 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Distribution Failures in last 7 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM taqprojecttask WHERE datetypecode IN (SELECT datetypecode FROM datetype WHERE eloquencefieldtag = ''CLD_DS_Failed'') AND (activedate BETWEEN DATEADD(dd, -30, getdate()) AND getdate()) AND actualind = 1',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Cloud Approved Titles failing Verification'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Cloud Approved Titles failing Verification'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT COUNT(*) FROM bookverification  v, bookdetail bd WHERE v.bookkey = bd.bookkey AND v.verificationtypecode IN (SELECT datacode FROM gentables WHERE tableid = 556 AND qsicode = 3) AND v.titleverifystatuscode IN (SELECT datacode FROM gentables WHERE tableid = 513 AND qsicode = 2) AND bd.csapprovalcode = 1',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'Transmittal P&L Approved in last 30 days'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'Transmittal P&L Approved in last 30 days'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT 2',
      'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
END
go
