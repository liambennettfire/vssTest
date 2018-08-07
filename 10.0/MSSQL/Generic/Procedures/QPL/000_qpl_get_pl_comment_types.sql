if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_comment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_comment_types
GO

CREATE PROCEDURE qpl_get_pl_comment_types
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_taqversionkey  integer,
  @i_existingonly   bit,
  @i_itemtype       integer,
  @i_usageclass     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qpl_get_pl_comment_types
**  Desc: This stored procedure returns all of the valid P&L comment types.
**
**  Auth: Kate
**  Date: April 2 2010
*******************************************************************************/

DECLARE
  @error_var    INT,
  @rowcount_var INT,
  @v_itemtypefilterind INT,
  @v_count INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- only do item type filtering if it is turned on and at least one comment type is setup 
  SELECT @v_itemtypefilterind = COALESCE(itemtypefilterind,0)
  FROM gentablesdesc 
  WHERE tableid = 284
    
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 
  BEGIN
    SET @v_itemtypefilterind = 0
  END 

  SELECT @v_count = count(*)
  FROM gentablesitemtype 
  WHERE tableid = 284
    --AND datacode IN (SELECT datacode FROM gentables WHERE tableid = 284 AND externalcode = 'PL')
      
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 
  BEGIN
    SET @v_itemtypefilterind = 0
  END 

  IF (@i_existingonly = 0) 
  BEGIN	       
    IF @i_itemtype > 0 AND @v_itemtypefilterind = 3 AND @v_count > 0
    BEGIN	
      SELECT subgentables.tableid, subgentables.datacode, subgentables.datasubcode, subgentables.datadesc, subgentablesorglevel.orgentrykey, 
        dbo.qpl_version_comment_exists(@i_projectkey, @i_plstagecode, @i_taqversionkey, subgentables.datacode, subgentables.datasubcode) commentsexist,
        dbo.qpl_version_html_commentkey(@i_projectkey, @i_plstagecode, @i_taqversionkey, subgentables.datacode, subgentables.datasubcode) commentkey, subgentables.sortorder
      FROM subgentables LEFT OUTER JOIN subgentablesorglevel on 
        subgentables.tableid = subgentablesorglevel.tableid and 
        subgentables.datacode = subgentablesorglevel.datacode and 
        subgentables.datasubcode = subgentablesorglevel.datasubcode,
        gentablesitemtype 
      WHERE subgentables.tableid = gentablesitemtype.tableid and 
        subgentables.datacode = gentablesitemtype.datacode and 
        subgentables.datasubcode = gentablesitemtype.datasubcode and
        gentablesitemtype.itemtypecode = @i_itemtype and
        COALESCE(gentablesitemtype.itemtypesubcode,0) in (@i_usageclass,0) and
        subgentables.tableid = 284 and 
        --subgentables.datacode IN (SELECT datacode FROM gentables WHERE tableid = 284 AND externalcode = 'PL') AND
        (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
      ORDER BY commentsexist desc,(CASE WHEN subgentables.sortorder IS NULL then 9999 ELSE subgentables.sortorder END) ASC, subgentables.datadesc asc 

      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    END
  END
  
  ELSE 
  BEGIN		
    IF @i_itemtype > 0 AND @v_itemtypefilterind = 3 AND @v_count > 0
    BEGIN	
      SELECT subgentables.tableid, subgentables.datacode, subgentables.datasubcode, subgentables.datadesc, subgentablesorglevel.orgentrykey, subgentables.sortorder,
			 dbo.qpl_version_comment_exists(@i_projectkey, @i_plstagecode, @i_taqversionkey, subgentables.datacode, subgentables.datasubcode) commentsexist
      FROM subgentables LEFT OUTER JOIN subgentablesorglevel on
        subgentables.tableid = subgentablesorglevel.tableid and 
        subgentables.datacode = subgentablesorglevel.datacode and 
        subgentables.datasubcode = subgentablesorglevel.datasubcode,
        taqversioncomments,
        gentablesitemtype  
      WHERE taqversioncomments.taqprojectkey = @i_projectkey and 
        taqversioncomments.plstagecode = @i_plstagecode and
        taqversioncomments.taqversionkey = @i_taqversionkey and
        taqversioncomments.commenttypecode = subgentables.datacode and
        taqversioncomments.commenttypesubcode = subgentables.datasubcode and
        subgentables.tableid = gentablesitemtype.tableid and 
        subgentables.datacode = gentablesitemtype.datacode and 
        subgentables.datasubcode = gentablesitemtype.datasubcode and
        gentablesitemtype.itemtypecode = @i_itemtype and
        COALESCE(gentablesitemtype.itemtypesubcode,0) in (@i_usageclass,0) and
        subgentables.tableid = 284 and
        --subgentables.datacode IN (SELECT datacode FROM gentables WHERE tableid = 284 AND externalcode = 'PL') AND 
        (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
      ORDER BY commentsexist desc,(CASE WHEN subgentables.sortorder IS NULL then 9999 ELSE subgentables.sortorder END) ASC, subgentables.datadesc asc 
          
      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    END
  END
  
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: comment types on subgentables (for qproject_get_project_comment_types).'   
  END 

END
GO

GRANT EXEC ON qpl_get_pl_comment_types TO PUBLIC
GO
