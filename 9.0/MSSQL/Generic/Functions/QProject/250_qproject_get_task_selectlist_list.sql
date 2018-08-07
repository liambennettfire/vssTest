if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_task_selectlist_list') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_task_selectlist_list
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_task_selectlist_list(
  @i_listkey            integer,
  @i_list_itemtype      integer,
  @i_related_projects   integer,
  @i_related_journals   integer,
  @i_related_contacts   integer,
  @i_related_titles     integer,
  @i_related_works      integer,
  @i_related_contracts  integer,
  @i_related_printings  integer,
  @i_related_purchaseorder  integer,
  @i_related_useradmin  integer)
RETURNS @selectionlist TABLE(
  projectkey INT,
  contactkey INT,
  bookkey INT,
  printingkey INT,
  itemtypecode INT,
  usageclasscode INT,
  itemdesc VARCHAR(255),
  usageclassdesc VARCHAR(255)
)
AS
BEGIN
  DECLARE @v_listkey integer,
          @v_key1 integer,
          @v_key2 integer,
          @error_var    integer,
          @rowcount_var integer
      
  DECLARE list_cur CURSOR fast_forward FOR
   SELECT listkey,key1,key2
     FROM qse_searchresults 
    WHERE listkey = @i_listkey

  OPEN list_cur

  FETCH from list_cur INTO @v_listkey,@v_key1,@v_key2

  WHILE @@fetch_status = 0 BEGIN
    IF @i_list_itemtype = 1 BEGIN
      -- titles
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_title(@v_key1,@v_key2,@i_related_projects,@i_related_journals,
                                                    @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END
    ELSE IF @i_list_itemtype = 2 BEGIN
      -- contacts
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_contact(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END
    ELSE IF @i_list_itemtype = 3 BEGIN
      -- projects
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_project(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END
    ELSE IF @i_list_itemtype = 6 BEGIN
      -- journals
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_journal(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END
    ELSE IF @i_list_itemtype = 14 BEGIN
      -- printings
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_printing(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END    
    ELSE IF @i_list_itemtype = 15 BEGIN
      -- printings
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_printing(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END  
    ELSE IF @i_list_itemtype = 5 BEGIN
      -- printings
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      SELECT projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc
        FROM dbo.qproject_get_task_selectlist_printing(@v_key1,@i_related_projects,@i_related_journals,
                                                      @i_related_contacts,@i_related_titles,@i_related_works,@i_related_contracts, @i_related_printings, @i_related_purchaseorder, @i_related_useradmin)
    END          
    FETCH from list_cur INTO @v_listkey,@v_key1,@v_key2
  END
  
  CLOSE list_cur
  DEALLOCATE list_cur

  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

