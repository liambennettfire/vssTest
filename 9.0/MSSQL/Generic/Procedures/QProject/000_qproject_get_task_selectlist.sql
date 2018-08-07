if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_task_selectlist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_task_selectlist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_task_selectlist
 (@i_key1               integer,
  @i_key2               integer,
  @i_related_projects   integer,
  @i_related_journals   integer,
  @i_related_contacts   integer,
  @i_related_titles     integer,
  @i_related_works      integer,
  @i_related_contracts  integer,
  @i_related_printings  integer,  
  @i_related_purchaseorder  integer,  
  @i_related_useradmin  integer,    
  @i_itemtype_qsicode   integer,
  @i_usageclass_qsicode integer,
  @o_error_code         integer       output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_task_selectlist
**  Desc: This gets general information needed for the Task Tracking 
**        Selected List.
**
**    Auth: Alan Katzen
**    Date: 24 March 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_itemtype_qsicode = 1 BEGIN
    -- title
    SELECT * FROM dbo.qproject_get_task_selectlist_title(@i_key1,@i_key2,@i_related_projects,@i_related_journals,
                                                         @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 2 BEGIN
    -- contact
    SELECT * FROM dbo.qproject_get_task_selectlist_contact(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 3 OR @i_itemtype_qsicode = 11 BEGIN
    -- project
    SELECT * FROM dbo.qproject_get_task_selectlist_project(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 4 BEGIN
    -- lists
    return
  END
  ELSE IF @i_itemtype_qsicode = 6 BEGIN
    -- journal
    SELECT * FROM dbo.qproject_get_task_selectlist_journal(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 9 BEGIN
    -- work
    SELECT * FROM dbo.qproject_get_task_selectlist_work(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 10 BEGIN
    -- contract
    SELECT * FROM dbo.qproject_get_task_selectlist_contract(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END
  ELSE IF @i_itemtype_qsicode = 14 BEGIN
    -- printing
    SELECT * FROM dbo.qproject_get_task_selectlist_printing(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END  
  ELSE IF @i_itemtype_qsicode = 15 BEGIN
    -- purchase order
    SELECT * FROM dbo.qproject_get_task_selectlist_purchaseorder(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END  
  ELSE IF @i_itemtype_qsicode = 5 BEGIN
    -- User Admin
    SELECT * FROM dbo.qproject_get_task_selectlist_useradmin(@i_key1,@i_related_projects,@i_related_journals,
                                                           @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  END                                                             
  ELSE BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error: Unknown Item Type (qsicode) = ' + cast(@i_itemtype_qsicode AS VARCHAR)   
    RETURN
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: Item Type (qsicode) = ' + cast(@i_itemtype_qsicode AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_task_selectlist TO PUBLIC
GO


