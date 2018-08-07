if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distinct_bookcomment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_distinct_bookcomment_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_distinct_bookcomment_types
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_distinct_bookcomment_types
**  Desc: This stored procedure returns a list of distinct book comment types
**        from gentables. 
**
**  Auth: Alan Katzen
**  Date: 28 April 2004
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:              Description:
** ---------    ----------------     ----------------------------------------------------
**  6/2/11      Kate                 Get comments for the title's item type/usage class.
**  7/29/15	    JR		             Add 'DISTINCT' clause to eliminate dup types
** 03/22/17     Uday A. Khisty       Case 43840 
*******************************************************************************/

  DECLARE @error_var    INT,
    @rowcount_var INT,
    @v_itemtype INT,
    @v_usageclass INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Get Item Type and Usage Class for the passed title
  SELECT @v_itemtype = itemtypecode, @v_usageclass = usageclasscode 
  FROM coretitleinfo
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- Get comments based on the titles's item type and usage class  
  SELECT DISTINCT o.orgentrykey, g.datadesc gentables_datadesc, s.datadesc subgentables_datadesc, s.datacode, s.datasubcode, s.sortorder,
    dbo.qtitle_get_bookcomment_count(@i_bookkey, @i_printingkey, s.datacode, s.datasubcode) commentsexist, COALESCE(s.sortorder, 9999),
    COALESCE((SELECT overridepropagationind FROM bookcomments WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
      AND commenttypecode = s.datacode AND commenttypesubcode = s.datasubcode),0) overridepropagationind,    
    CASE 
      WHEN (COALESCE(s.exporteloquenceind,0) = 1 AND COALESCE(s.acceptedbyeloquenceind,0) = 1) THEN 1 
      ELSE 0
    END elocommentind,
    dbo.qutl_check_subgentable_value_security_by_status(@i_userkey,'titlesummary',s.tableid,s.datacode,s.datasubcode,@i_bookkey,@i_printingkey,0) accesscode,
	COALESCE(i.sortorder, s.sortorder, 9999) displaysort
  FROM subgentables s
    LEFT OUTER JOIN subgentablesorglevel o ON s.tableid = o.tableid AND s.datacode = o.datacode AND s.datasubcode = o.datasubcode,   
    gentables g, 
    gentablesitemtype i
  WHERE g.tableid = s.tableid
    AND g.datacode = s.datacode  
    AND g.tableid = 284
    AND (s.deletestatus is null OR upper(s.deletestatus) = 'N')
    AND s.tableid = i.tableid  
    AND s.datacode = i.datacode  
    AND s.datasubcode = i.datasubcode 
    AND i.itemtypecode = @v_itemtype 
    AND COALESCE(i.itemtypesubcode,0) in (@v_usageclass,0)
    AND (COALESCE(o.orgentrykey,0) in (select orgentrykey from bookorgentry where bookkey = @i_bookkey) OR COALESCE(o.orgentrykey,0) = 0)
  ORDER BY commentsexist DESC, displaysort ASC, s.datadesc ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: comment types on subgentables.'   
  END 
GO

GRANT EXEC ON qtitle_get_distinct_bookcomment_types TO PUBLIC
GO
