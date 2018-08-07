if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qutl_get_datetype_itemtype_filtering') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qutl_get_datetype_itemtype_filtering
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
CREATE FUNCTION qutl_get_datetype_itemtype_filtering(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_bookkey integer,
  @i_printingkey integer,
  @i_itemtype	integer,
  @i_usageclass	integer)
  
RETURNS @datetypelist TABLE(
	tableid INT,
	desc_tablemnemonic VARCHAR(10),
	itemtypefilterind TINYINT,
	datacode SMALLINT,
	datadesc VARCHAR(100),
	sortorder INT,
	deletestatus VARCHAR(1),
	accesscode INT, 
	datetypecode smallint,
	description varchar(100),
	printkeydependent tinyint,
	changetitlestatusind tinyint,
	datelabel varchar(30),
	datelabelshort varchar(10),
	lastuserid varchar(30),
	lastmaintdate datetime,
	acceptedbyeloquenceind int,
	exporteloquenceind int,
	lockbyqsiind int,
	lockbyeloquenceind int,
	eloquencefieldtag varchar(25),
	activeind tinyint,
	date1ind int,
	qsicode int,
	contractind tinyint,
	fieldsecurityname varchar(30),
	taqtotmmind tinyint,
	taqkeyind tinyint,
	taqprimaryformatind tinyint,
	alternatedesc1 varchar(255),
	alternatedesc2 varchar(255),
	reportcode int,
	advanceind tinyint,
	showintaqind tinyint,
	cstransactioncode int,
	csstatuscode int,
	externalcode varchar(30),
	usedexclusivelybycsind tinyint,
	linkworktotitleind tinyint,
	defaultduration int,
	showallsectionsind tinyint,
	milestoneind tinyint,
	distributionprocessedind int,
	triggerdateind tinyint
)
AS
/****************************************************************************************************************************
**  File: 
**  Name: qutl_get_datetype_itemtype_filtering
**  Desc: Function to return datetype values based on
**        itemtype/usageclass filtering.
**
**
**  Auth: Uday A. Khisty
**  Date: 05/12/2016
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    
*****************************************************************************************************************************/

BEGIN
  DECLARE @error_var    integer,
          @rowcount_var integer,
          @v_itemtypefilterind integer
  DECLARE 
    @v_class  INT,
    @v_itemtype INT,
    @v_tableid	INT,
    @v_qsicode INT

  SET @v_qsicode = 0
  
  SET @v_tableid = 323 --datetype
  
  SELECT @v_qsicode = qsicode 
  FROM gentables 
  WHERE tableid = 550 AND datacode =  @i_itemtype
  
  IF @v_qsicode = 9 AND @i_bookkey > 0  --adding task on work w/selected title - filter by both works and titles
  BEGIN
    SELECT @v_itemtype = itemtypecode, @v_class = usageclasscode 
    FROM coretitleinfo
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
    
    INSERT INTO @datetypelist (tableid, desc_tablemnemonic, itemtypefilterind, datacode, datadesc, sortorder,
		deletestatus, accesscode, datetypecode, description, printkeydependent, changetitlestatusind,
		datelabel, datelabelshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind,
		lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, activeind, date1ind, qsicode, contractind,
		fieldsecurityname, taqtotmmind, taqkeyind, taqprimaryformatind, alternatedesc1, alternatedesc2,
		reportcode, advanceind, showintaqind, cstransactioncode, csstatuscode, externalcode, usedexclusivelybycsind,
		linkworktotitleind, defaultduration, showallsectionsind, milestoneind, distributionprocessedind, triggerdateind)    
    
    SELECT d.tableid,
      'DATETYPE' desc_tablemnemonic,
      gd.itemtypefilterind,
      d.datetypecode datacode,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datadesc,
      0 sortorder,
      CASE d.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      CASE 
        WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@v_tableid,d.datetypecode,@i_bookkey,@i_printingkey,0)
        ELSE dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@v_tableid,d.datetypecode)
      END accesscode,     
      d.datetypecode,
	  d.description,
	  d.printkeydependent,
	  d.changetitlestatusind,
	  d.datelabel,
	  d.datelabelshort,
	  d.lastuserid,
	  d.lastmaintdate,
	  d.acceptedbyeloquenceind,
	  d.exporteloquenceind,
	  d.lockbyqsiind,
	  d.lockbyeloquenceind,
	  d.eloquencefieldtag,
	  d.activeind,
	  d.date1ind,
	  d.qsicode,
	  d.contractind,
	  d.fieldsecurityname,
	  d.taqtotmmind,
	  d.taqkeyind,
	  d.taqprimaryformatind,
	  d.alternatedesc1,
	  d.alternatedesc2,
	  d.reportcode,
	  d.advanceind,
	  d.showintaqind,
	  d.cstransactioncode,
	  d.csstatuscode,
	  d.externalcode,
	  d.usedexclusivelybycsind,
	  d.linkworktotitleind,
	  d.defaultduration,
	  d.showallsectionsind,
	  d.milestoneind,
	  d.distributionprocessedind,
	  d.triggerdateind
    FROM gentablesdesc gd, datetype d, gentablesitemtype i
    WHERE d.tableid = gd.tableid
		  AND i.tableid = gd.tableid
		  AND i.datacode = d.datetypecode
		  AND i.itemtypecode = @i_itemtype
		  AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0 OR @i_usageclass = 0)
    UNION
    SELECT d.tableid,
      'DATETYPE' desc_tablemnemonic,
      gd.itemtypefilterind,
      d.datetypecode datacode,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datadesc,
      0 sortorder,
      CASE d.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      CASE 
        WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@v_tableid,d.datetypecode,@i_bookkey,@i_printingkey,0)
        ELSE dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@v_tableid,d.datetypecode)
      END accesscode,     
      d.datetypecode,
	  d.description,
	  d.printkeydependent,
	  d.changetitlestatusind,
	  d.datelabel,
	  d.datelabelshort,
	  d.lastuserid,
	  d.lastmaintdate,
	  d.acceptedbyeloquenceind,
	  d.exporteloquenceind,
	  d.lockbyqsiind,
	  d.lockbyeloquenceind,
	  d.eloquencefieldtag,
	  d.activeind,
	  d.date1ind,
	  d.qsicode,
	  d.contractind,
	  d.fieldsecurityname,
	  d.taqtotmmind,
	  d.taqkeyind,
	  d.taqprimaryformatind,
	  d.alternatedesc1,
	  d.alternatedesc2,
	  d.reportcode,
	  d.advanceind,
	  d.showintaqind,
	  d.cstransactioncode,
	  d.csstatuscode,
	  d.externalcode,
	  d.usedexclusivelybycsind,
	  d.linkworktotitleind,
	  d.defaultduration,
	  d.showallsectionsind,
	  d.milestoneind,
	  d.distributionprocessedind,
	  d.triggerdateind
    FROM gentablesdesc gd, datetype d, gentablesitemtype i
    WHERE d.tableid = gd.tableid
		  AND i.tableid = gd.tableid
		  AND i.datacode = d.datetypecode
		  AND i.itemtypecode = @v_itemtype
		  AND (i.itemtypesubcode = @v_class OR i.itemtypesubcode = 0 OR @v_class = 0)	  
  END
  
  ELSE IF @v_qsicode = 2 BEGIN
    INSERT INTO @datetypelist (tableid, desc_tablemnemonic, itemtypefilterind, datacode, datadesc, sortorder,
		deletestatus, accesscode, datetypecode, description, printkeydependent, changetitlestatusind,
		datelabel, datelabelshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind,
		lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, activeind, date1ind, qsicode, contractind,
		fieldsecurityname, taqtotmmind, taqkeyind, taqprimaryformatind, alternatedesc1, alternatedesc2,
		reportcode, advanceind, showintaqind, cstransactioncode, csstatuscode, externalcode, usedexclusivelybycsind,
		linkworktotitleind, defaultduration, showallsectionsind, milestoneind, distributionprocessedind, triggerdateind)    
     SELECT d.tableid,
       'DATETYPE' desc_tablemnemonic,
       gd.itemtypefilterind,
       d.datetypecode datacode,
       CASE
         WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
         ELSE d.datelabel
       END AS datadesc,
       0 sortorder,
       --o.orgentrykey orgentrykey,
       CASE d.activeind
         WHEN 1 THEN 'N'
         ELSE 'Y'
       END AS deletestatus,
       CASE 
        WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@v_tableid,d.datetypecode,@i_bookkey,@i_printingkey,0)
        ELSE dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@v_tableid,d.datetypecode)
       END accesscode,     
      d.datetypecode,
	  d.description,
	  d.printkeydependent,
	  d.changetitlestatusind,
	  d.datelabel,
	  d.datelabelshort,
	  d.lastuserid,
	  d.lastmaintdate,
	  d.acceptedbyeloquenceind,
	  d.exporteloquenceind,
	  d.lockbyqsiind,
	  d.lockbyeloquenceind,
	  d.eloquencefieldtag,
	  d.activeind,
	  d.date1ind,
	  d.qsicode,
	  d.contractind,
	  d.fieldsecurityname,
	  d.taqtotmmind,
	  d.taqkeyind,
	  d.taqprimaryformatind,
	  d.alternatedesc1,
	  d.alternatedesc2,
	  d.reportcode,
	  d.advanceind,
	  d.showintaqind,
	  d.cstransactioncode,
	  d.csstatuscode,
	  d.externalcode,
	  d.usedexclusivelybycsind,
	  d.linkworktotitleind,
	  d.defaultduration,
	  d.showallsectionsind,
	  d.milestoneind,
	  d.distributionprocessedind,
	  d.triggerdateind
     FROM gentablesdesc gd, datetype d, gentablesitemtype i
		--LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
     WHERE d.tableid = gd.tableid
	   	AND i.tableid = gd.tableid
	   	AND i.datacode = d.datetypecode	
     END	  
  ELSE
    INSERT INTO @datetypelist (tableid, desc_tablemnemonic, itemtypefilterind, datacode, datadesc, sortorder,
		deletestatus, accesscode, datetypecode, description, printkeydependent, changetitlestatusind,
		datelabel, datelabelshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind,
		lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, activeind, date1ind, qsicode, contractind,
		fieldsecurityname, taqtotmmind, taqkeyind, taqprimaryformatind, alternatedesc1, alternatedesc2,
		reportcode, advanceind, showintaqind, cstransactioncode, csstatuscode, externalcode, usedexclusivelybycsind,
		linkworktotitleind, defaultduration, showallsectionsind, milestoneind, distributionprocessedind, triggerdateind)    
  SELECT d.tableid,
    'DATETYPE' desc_tablemnemonic,
    gd.itemtypefilterind,
    d.datetypecode datacode,
    CASE
      WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
      ELSE d.datelabel
    END AS datadesc,
    0 sortorder,
    --o.orgentrykey orgentrykey,
    CASE d.activeind
      WHEN 1 THEN 'N'
      ELSE 'Y'
    END AS deletestatus,
    CASE 
      WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@v_tableid,d.datetypecode,@i_bookkey,@i_printingkey,0)
      ELSE dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@v_tableid,d.datetypecode)
    END accesscode,     
      d.datetypecode,
	  d.description,
	  d.printkeydependent,
	  d.changetitlestatusind,
	  d.datelabel,
	  d.datelabelshort,
	  d.lastuserid,
	  d.lastmaintdate,
	  d.acceptedbyeloquenceind,
	  d.exporteloquenceind,
	  d.lockbyqsiind,
	  d.lockbyeloquenceind,
	  d.eloquencefieldtag,
	  d.activeind,
	  d.date1ind,
	  d.qsicode,
	  d.contractind,
	  d.fieldsecurityname,
	  d.taqtotmmind,
	  d.taqkeyind,
	  d.taqprimaryformatind,
	  d.alternatedesc1,
	  d.alternatedesc2,
	  d.reportcode,
	  d.advanceind,
	  d.showintaqind,
	  d.cstransactioncode,
	  d.csstatuscode,
	  d.externalcode,
	  d.usedexclusivelybycsind,
	  d.linkworktotitleind,
	  d.defaultduration,
	  d.showallsectionsind,
	  d.milestoneind,
	  d.distributionprocessedind,
	  d.triggerdateind
  FROM gentablesdesc gd, datetype d, gentablesitemtype i
		--LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
  WHERE d.tableid = gd.tableid
		AND i.tableid = gd.tableid
		AND i.datacode = d.datetypecode
		AND i.itemtypecode = @i_itemtype
		AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0 OR @i_usageclass = 0)    
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--GRANT EXEC ON qutl_get_datetype_itemtype_filtering TO PUBLIC
--GO
