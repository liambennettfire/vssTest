if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_element_comment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_element_comment_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qelement_get_element_comment_types
 (@i_elementkey     integer,
  @i_existingonly   bit,
  @i_itemtype       integer,
  @i_usageclass     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: qelement_get_element_comment_types.sql
**  Name: qelement_get_element_comment_types
**  Desc: This stored procedure returns all of the valid comment types
**        for an element comment based on subgentables.subgen1ind.
**
**  ElementKey is the key from table Element
**  ElementCommentKey is the Comment type from subjentables 
**
**    Auth: Lisa Cormier
**    Date: 29 May 2008
*******************************************************************************
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_itemtypefilterind INT,
          @v_count INT

  if (@i_existingonly = 1)
  BEGIN
    SELECT	subgentables.tableid, subgentables.datacode, subgentables.datasubcode, 
			subgentables.datadesc, subgentablesorglevel.orgentrykey, COALESCE(qsicomments.commentkey, 0) as commentsexist, subgentables.sortorder
      FROM	qsicomments
	  join	subgentables 
		on qsicomments.commentkey = @i_elementkey and
			subgentables.datacode = qsicomments.commenttypecode and
			subgentables.datasubcode = qsicomments.commenttypesubcode
	  left outer JOIN subgentablesorglevel on 
			subgentables.tableid = subgentablesorglevel.tableid and 
            subgentables.datacode = subgentablesorglevel.datacode and 
            subgentables.datasubcode = subgentablesorglevel.datasubcode  
      WHERE qsicomments.commentkey = @i_elementkey and
			subgentables.tableid = 284 and 
	    (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
      ORDER BY commentsexist desc,(CASE WHEN subgentables.sortorder IS NULL then 9999 ELSE subgentables.sortorder END) ASC, subgentables.datadesc asc 
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  END
  ELSE
  BEGIN
     -- only do item type filtering if it is turned on and at least one comment type is setup 
     SELECT @v_itemtypefilterind = COALESCE(itemtypefilterind,0)
       FROM gentablesdesc 
      WHERE tableid = 284
      
     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
     IF @error_var <> 0 or @rowcount_var = 0 BEGIN
       SET @v_itemtypefilterind = 0
     END 

     SELECT @v_count = count(*)
       FROM gentablesitemtype 
      WHERE tableid = 284
        AND itemtypecode = 7
        
     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
     IF @error_var <> 0 or @rowcount_var = 0 BEGIN
       SET @v_itemtypefilterind = 0
     END 
       
     IF @i_itemtype > 0 AND @v_itemtypefilterind = 3 AND @v_count > 0 BEGIN
        SELECT subgentables.tableid, subgentables.datacode, subgentables.datasubcode, 
			   subgentables.datadesc, subgentablesorglevel.orgentrykey, qsicomments.commentkey,
			   COALESCE(qsicomments.commentkey, 0) as commentsexist, subgentables.sortorder
        FROM subgentables LEFT OUTER JOIN subgentablesorglevel on
              subgentables.tableid = subgentablesorglevel.tableid and 
              subgentables.datacode = subgentablesorglevel.datacode and 
              subgentables.datasubcode = subgentablesorglevel.datasubcode
         left outer join qsicomments 
            on qsicomments.commentkey = @i_elementkey and
			         qsicomments.commenttypecode = subgentables.datacode and
               qsicomments.commenttypesubcode = subgentables.datasubcode 
         join gentablesitemtype
           on subgentables.tableid = gentablesitemtype.tableid and
              subgentables.datacode = gentablesitemtype.datacode and
              subgentables.datasubcode = gentablesitemtype.datasubcode and
              gentablesitemtype.itemtypecode = @i_itemtype and
              COALESCE(gentablesitemtype.itemtypesubcode,0) in (@i_usageclass,0)
        WHERE subgentables.tableid = 284 and --subgentables.datacode = 7 and
              (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
        ORDER BY commentsexist desc,(CASE WHEN subgentables.sortorder IS NULL then 9999 ELSE subgentables.sortorder END) ASC, subgentables.datadesc asc 
      
        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      END
--      ELSE BEGIN
--        SELECT subgentables.tableid, subgentables.datacode, subgentables.datasubcode, 
--			   subgentables.datadesc, subgentablesorglevel.orgentrykey, qsicomments.commentkey,
--			   COALESCE(qsicomments.commentkey, 0) as commentsexist
--        FROM subgentables LEFT OUTER JOIN subgentablesorglevel on
--              subgentables.tableid = subgentablesorglevel.tableid and 
--              subgentables.datacode = subgentablesorglevel.datacode and 
--              subgentables.datasubcode = subgentablesorglevel.datasubcode
--         left outer join qsicomments 
--            on qsicomments.commentkey = @i_elementkey and
--			   qsicomments.commenttypecode = subgentables.datacode and
--               qsicomments.commenttypesubcode = subgentables.datasubcode 
--        WHERE subgentables.tableid = 284 and --subgentables.datacode = 7 and
--              (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
--        ORDER BY subgentables.datacode asc, subgentables.sortorder asc
--      
--      -- Save the @@ERROR and @@ROWCOUNT values in local 
--      -- variables before they are cleared.
--      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--    END
  END
  
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: comment types on subgentables (for qproject_get_project_comment_types).'   
  END 

GO
GRANT EXEC ON qelement_get_element_comment_types TO PUBLIC
GO

