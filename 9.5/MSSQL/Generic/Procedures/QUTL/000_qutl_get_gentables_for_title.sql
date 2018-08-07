PRINT 'STORED PROCEDURE : qutl_get_gentables_for_title'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentables_for_title')
  DROP PROCEDURE  qutl_get_gentables_for_title
GO

CREATE PROCEDURE qutl_get_gentables_for_title
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_bookkey integer,
  @i_printingkey integer,
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

  IF @i_tableid = 323 -- datetype - fake gentable
    SELECT d.tableid,
      'DATETYPE' desc_tablemnemonic,
      gd.itemtypefilterind,
      d.datetypecode datacode,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datadesc,
      0 sortorder,
      o.orgentrykey orgentrykey,
      CASE d.activeind
        WHEN 1 THEN 'N'
        ELSE 'Y'
      END AS deletestatus,
      CASE 
        WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@i_tableid,d.datetypecode,@i_bookkey,@i_printingkey,0)
        ELSE 2
      END accesscode,     
      d.*
    FROM gentablesdesc gd, datetype d 
      LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
    WHERE d.tableid = gd.tableid
    
  ELSE BEGIN
    -- gentable
    SELECT DISTINCT g.tableid,
      d.tablemnemonic desc_tablemnemonic,
      d.itemtypefilterind,
      g.datacode,
      g.datadesc,
      COALESCE(g.sortorder,0) sortorder,
      o.orgentrykey,
      g.deletestatus,
      CASE 
        WHEN @i_bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(@i_userkey,@i_windowname,@i_tableid,g.datacode,@i_bookkey,@i_printingkey,0)
        ELSE 2
      END accesscode,     
      g.*
    FROM gentables g 
        LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid AND g.datacode = o.datacode)  
        LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
    WHERE g.tableid = @i_tableid 
    ORDER BY g.tableid ASC, COALESCE(g.sortorder,0) ASC, g.datadesc ASC, g.datacode ASC
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables tableid=' + cast(@i_tableid AS VARCHAR)
  END     

END
GO

GRANT EXEC ON qutl_get_gentables_for_title TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qutl_get_gentables_for_title'
GO


