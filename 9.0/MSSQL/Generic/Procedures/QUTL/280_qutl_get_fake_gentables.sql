PRINT 'STORED PROCEDURE : qutl_get_fake_gentables'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_fake_gentables')
  DROP PROCEDURE  qutl_get_fake_gentables
GO

CREATE PROCEDURE qutl_get_fake_gentables
(
  @i_tableid        INT,
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

BEGIN  
  DECLARE 
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET NOCOUNT ON

  IF @i_tableid = 323 -- datetype
    SELECT d.tableid,
      'DATETYPE' desc_tablemnemonic,
      gd.itemtypefilterind,
      d.datetypecode datacode,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datadesc,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      CASE d.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      d.*
    FROM gentablesdesc gd, datetype d 
      LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
    WHERE d.tableid = gd.tableid
    
  ELSE IF @i_tableid = 329  --season
    SELECT s.tableid,
      'SEASON' desc_tablemnemonic,
      gd.itemtypefilterind,
      s.seasonkey datacode,        
      s.seasondesc datadesc,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      CASE s.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      s.*
    FROM gentablesdesc gd, season s 
      LEFT OUTER JOIN gentablesorglevel o ON s.tableid = o.tableid AND s.seasonkey = o.datacode
    WHERE s.tableid = gd.tableid
    
  ELSE IF @i_tableid = 340 --personnel
    SELECT p.tableid,
      'PERSON' desc_tablemnemonic,
      gd.itemtypefilterind,
      p.contributorkey datacode,
      p.displayname datadesc,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      CASE p.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      p.*
    FROM gentablesdesc gd, person p 
      LEFT OUTER JOIN gentablesorglevel o ON p.tableid = o.tableid AND p.contributorkey = o.datacode
    WHERE p.tableid = gd.tableid

  ELSE IF @i_tableid = 356 --filelocationtable
    SELECT fl.tableid,
      'FILELOCA' desc_tablemnemonic,
      gd.itemtypefilterind,
      fl.filelocationkey datacode,
      fl.logicaldesc datadesc,
      fl.sortorder,
      o.orgentrykey orgentrykey,
      CASE fl.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      fl.*
    FROM gentablesdesc gd, filelocationtable fl 
      LEFT OUTER JOIN gentablesorglevel o ON fl.tableid = o.tableid AND fl.filelocationkey = o.datacode
    WHERE fl.tableid = gd.tableid
      AND gd.tableid = @i_tableid

  ELSE IF @i_tableid = 572 --cdlist
    SELECT gd.tableid,
      'CDLIST' desc_tablemnemonic,
      gd.itemtypefilterind,
      c.internalcode datacode,
      c.externaldesc datadesc,
      c.externalcode externalcode,
      CASE
        WHEN c.externalcode IS NULL OR LTRIM(RTRIM(c.externalcode)) = '' THEN c.externaldesc
        ELSE c.externaldesc + ' / ' + COALESCE(c.externalcode,'')
      END AS alternatedesc1,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      CASE c.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      c.*
    FROM gentablesdesc gd, cdlist c 
      LEFT OUTER JOIN gentablesorglevel o ON c.tableid = o.tableid AND c.internalcode = o.datacode
    WHERE c.tableid = gd.tableid
    
  ELSE IF @i_tableid = 1014 --inks
    SELECT i.tableid,
      'INKS' desc_tablemnemonic,
      gd.itemtypefilterind,
      i.inkkey datacode,
      i.inkdesc datadesc,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      i.inactiveind deletestatus,
      i.*
    FROM gentablesdesc gd, ink i
      LEFT OUTER JOIN gentablesorglevel o ON i.tableid = o.tableid AND i.inkkey = o.datacode
    WHERE i.tableid = gd.tableid
    
  ELSE IF @i_tableid = 330 --vendor
    SELECT v.tableid,
      'VENDOR' desc_tablemnemonic,
      gd.itemtypefilterind,
      v.vendorkey datacode,
      v.name datadesc,
      NULL sortorder,
      o.orgentrykey orgentrykey,
      CASE v.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      v.*
    FROM gentablesdesc gd, vendor v 
      LEFT OUTER JOIN gentablesorglevel o ON v.tableid = o.tableid AND v.vendorkey = o.datacode
    WHERE v.tableid = gd.tableid              
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'No data found - fake gentables tableid=' + cast(@i_tableid AS VARCHAR)
  END     

END
GO

GRANT EXEC ON qutl_get_fake_gentables TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qutl_get_fake_gentables'
GO


