if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_bookcomment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_title_bookcomment_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_title_bookcomment_types
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_title_bookcomment_types
**  Desc: This stored procedure returns a list of book comment types
**        from bookcomments. 
**
**
**    Auth: Alan Katzen
**    Date: 28 April 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
    @v_itemtype INT,
    @v_usageclass INT

  -- Get Item Type and Usage Class for the passed title
  SELECT @v_itemtype = itemtypecode, @v_usageclass = usageclasscode 
  FROM coretitleinfo
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- Get comments based on the titles's item type and usage class  
  SELECT DISTINCT g.*,s.*,g.datadesc gentables_datadesc,s.datadesc subgentables_datadesc,
         CASE WHEN (COALESCE(s.exporteloquenceind,0) = 1 AND COALESCE(s.acceptedbyeloquenceind,0) = 1) THEN 1 
              ELSE 0 END elocommentind  ,
         c.releasetoeloquenceind releasetoeloquenceind, COALESCE(s.sortorder, 9999) distinct_itemtype,
         dbo.qutl_check_subgentable_value_security_by_status(@i_userkey,'titlesummary',s.tableid,s.datacode,s.datasubcode,@i_bookkey,@i_printingkey,0) accesscode,
		 dbo.qtitle_get_bookcomment_count(@i_bookkey, @i_printingkey, s.datacode, s.datasubcode) commentsexist, s.sortorder
    FROM gentables g, subgentables s, bookcomments c, gentablesitemtype i 
   WHERE c.commenttypecode = s.datacode and
         c.commenttypesubcode = s.datasubcode and
         g.tableid = s.tableid and
         g.datacode = s.datacode and
         g.tableid = 284 and
         (s.deletestatus is null OR upper(s.deletestatus) = 'N') and
         c.bookkey = @i_bookkey and
         c.printingkey = @i_printingkey and
         s.tableid = i.tableid  and
         s.datacode = i.datacode  and 
         s.datasubcode = i.datasubcode and 
         i.itemtypecode = @v_itemtype  and 
         COALESCE(i.itemtypesubcode,0) in (@v_usageclass,0)
  ORDER BY commentsexist DESC, COALESCE(s.sortorder, 9999) ASC, s.datadesc ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: title comments on bookcomments.'   
  END 

GO
GRANT EXEC ON qtitle_get_title_bookcomment_types TO PUBLIC
GO

