IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_datetypes_by_itemtype')
  DROP PROCEDURE  qutl_get_datetypes_by_itemtype
GO

CREATE PROCEDURE qutl_get_datetypes_by_itemtype
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_bookkey integer,
  @i_printingkey integer,
  @i_itemtype	integer,
  @i_usageclass	integer,
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

/******************************************************************************
**  Name: qutl_get_datetypes_by_itemtype
**  Desc: This stored procedure returns a list of datetype (task) values based off the
**				itemtype filtering in gentables, as well as security
**
**    Auth: Dustin Miller
**    Date: 11/13/12
*******************************************************************************/

BEGIN  
  DECLARE 
    @error_var  INT,
    @rowcount_var INT,
    @v_class  INT,
    @v_itemtype INT,
    @v_tableid	INT,
    @v_qsicode INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_qsicode = 0
  
  SET @v_tableid = 323 --datetype

  SET NOCOUNT ON
  
  SELECT @v_qsicode = qsicode 
  FROM gentables 
  WHERE tableid = 550 AND datacode =  @i_itemtype
  
  IF @v_qsicode = 9 AND @i_bookkey > 0  --adding task on work w/selected title - filter by both works and titles
  BEGIN
    SELECT @v_itemtype = itemtypecode, @v_class = usageclasscode 
    FROM coretitleinfo
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
    
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
        ELSE 2
      END accesscode,     
      d.*
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
        ELSE 2
      END accesscode,     
      d.*
    FROM gentablesdesc gd, datetype d, gentablesitemtype i
    WHERE d.tableid = gd.tableid
		  AND i.tableid = gd.tableid
		  AND i.datacode = d.datetypecode
		  AND i.itemtypecode = @v_itemtype
		  AND (i.itemtypesubcode = @v_class OR i.itemtypesubcode = 0 OR @v_class = 0)	  
  END
  
  ELSE IF @v_qsicode = 2 BEGIN
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
         ELSE 2
       END accesscode,     
       d.*
     FROM gentablesdesc gd, datetype d, gentablesitemtype i
		--LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
     WHERE d.tableid = gd.tableid
	   	AND i.tableid = gd.tableid
	   	AND i.datacode = d.datetypecode	
     END	  
  ELSE
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
      ELSE 2
    END accesscode,     
    d.*
  FROM gentablesdesc gd, datetype d, gentablesitemtype i
		--LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
  WHERE d.tableid = gd.tableid
		AND i.tableid = gd.tableid
		AND i.datacode = d.datetypecode
		AND i.itemtypecode = @i_itemtype
		AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0 OR @i_usageclass = 0)
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables tableid=' + cast(@v_tableid AS VARCHAR)
  END     

END
GO

GRANT EXEC ON qutl_get_datetypes_by_itemtype TO PUBLIC
GO
