IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_get_project_comment_types]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_get_project_comment_types]
/****** Object:  StoredProcedure [dbo].[qproject_get_project_comment_types]    Script Date: 07/16/2008 10:33:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE qproject_get_project_comment_types
 (@i_projectkey     integer,
  @i_existingonly   bit,
  @i_itemtype       integer,
  @i_usageclass     integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: qproject_get_project_comment_types.sql
**  Name: qproject_get_project_comment_types
**  Desc: This stored procedure returns all of the valid comment types
**        for a project comment based on subgentables.subgen1ind.
**
**    Auth: James Weber
**    Date: 13 May 2004
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      ----------------------------------------------------
**  03/22/17   Uday A. Khisty   Case 43840     
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_itemtypefilterind INT,
          @v_count INT

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
		AND datacode = 6  -- Project/Journal Comment Types
        
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
					 dbo.qproject_project_comment_exists(@i_projectkey, subgentables.datacode, subgentables.datasubcode) commentsexist,
					 dbo.qproject_project_html_comment_key(@i_projectkey, subgentables.datacode, subgentables.datasubcode) commentkey,
					 dbo.qproject_is_sent_to_tmm(N'gentables',subgentables.tableid,subgentables.datacode,subgentables.datasubcode) sendtotmm,
           CASE 
             WHEN @i_itemtype = 3 OR @i_itemtype = 9 THEN  
			         dbo.qutl_check_subgentable_value_security(@i_userkey,'projectcomments',subgentables.tableid,subgentables.datacode,subgentables.datasubcode)
             WHEN @i_itemtype = 6 THEN  
			         dbo.qutl_check_subgentable_value_security(@i_userkey,'journalcomments',subgentables.tableid,subgentables.datacode,subgentables.datasubcode)
             ELSE 2
           END accesscode, subgentables.sortorder				 
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
--						   subgentables.subgen1ind = 1 and
					  (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
				ORDER BY commentsexist desc, COALESCE(gentablesitemtype.sortorder, subgentables.sortorder, 9999) asc, subgentables.datadesc asc
	    
		  -- Save the @@ERROR and @@ROWCOUNT values in local 
		  -- variables before they are cleared.
		  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		END
	END
  
  ELSE 
	BEGIN		
		IF @i_itemtype > 0 AND @v_itemtypefilterind = 3 AND @v_count > 0
		BEGIN	
	    SELECT subgentables.tableid, subgentables.datacode, subgentables.datasubcode, subgentables.datadesc, subgentablesorglevel.orgentrykey,
		       dbo.qproject_is_sent_to_tmm(N'gentables',subgentables.tableid,subgentables.datacode,subgentables.datasubcode) sendtotmm,
		        dbo.qproject_project_comment_exists(@i_projectkey, subgentables.datacode, subgentables.datasubcode) commentsexist,
           CASE 
             WHEN @i_itemtype = 3 OR @i_itemtype = 9 THEN  
			         dbo.qutl_check_subgentable_value_security(@i_userkey,'projectcomments',subgentables.tableid,subgentables.datacode,subgentables.datasubcode) 
             WHEN @i_itemtype = 6 THEN  
			         dbo.qutl_check_subgentable_value_security(@i_userkey,'journalcomments',subgentables.tableid,subgentables.datacode,subgentables.datasubcode) 
             ELSE 2
           END accesscode, subgentables.sortorder				 
	      FROM subgentables LEFT OUTER JOIN subgentablesorglevel on
		       subgentables.tableid = subgentablesorglevel.tableid and 
		       subgentables.datacode = subgentablesorglevel.datacode and 
		       subgentables.datasubcode = subgentablesorglevel.datasubcode,
			     taqprojectcomments,
					 gentablesitemtype  
	     WHERE taqprojectcomments.taqprojectkey = @i_projectkey and 
		       taqprojectcomments.commenttypecode = subgentables.datacode and
		       taqprojectcomments.commenttypesubcode = subgentables.datasubcode and
				   subgentables.tableid = gentablesitemtype.tableid and 
					 subgentables.datacode = gentablesitemtype.datacode and 
					 subgentables.datasubcode = gentablesitemtype.datasubcode and
					 gentablesitemtype.itemtypecode = @i_itemtype and
					 COALESCE(gentablesitemtype.itemtypesubcode,0) in (@i_usageclass,0) and
		       subgentables.tableid = 284 and 
--			       subgentables.subgen1ind = 1 and
		       (subgentables.deletestatus is null OR upper(subgentables.deletestatus) = 'N')
	    ORDER BY commentsexist desc, COALESCE(gentablesitemtype.sortorder, subgentables.sortorder, 9999) asc, subgentables.datadesc asc
  	      
	    -- Save the @@ERROR and @@ROWCOUNT values in local 
	    -- variables before they are cleared.
	    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    END			
	END
  
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: comment types on subgentables (for qproject_get_project_comment_types).'   
  END 

GO

GRANT EXEC ON qproject_get_project_comment_types TO PUBLIC
GO
