if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_task_selectlist_for_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_task_selectlist_for_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_task_selectlist_for_list
 (@i_key                integer,
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
**  Name: qproject_get_task_selectlist_for_list
**  Desc: This gets general information needed for the Task Tracking 
**        Selected List.
**
**  NOTE: @i_itemtype_qsicode is the itemtype of the objects in the list   
**
**
**    Auth: Alan Katzen
**    Date: 23 October 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT * FROM dbo.qproject_get_task_selectlist_list(@i_key,@i_itemtype_qsicode,
                                                      @i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,
                                                      @i_related_works,@i_related_contracts,
                                                      @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: Item Type (qsicode) = ' + cast(@i_itemtype_qsicode AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_task_selectlist_for_list TO PUBLIC
GO


