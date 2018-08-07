if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_task_selectlist_title') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_task_selectlist_title
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_task_selectlist_title(
  @i_bookkey            integer,
  @i_printingkey        integer,
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
  DECLARE @v_projectkey integer,
          @v_contactkey integer,
          @v_bookkey integer,
          @v_printingkey integer,
          @v_itemtypecode integer,
          @v_usageclasscode integer,
          @v_itemdesc varchar(255),
          @v_keyind integer,
          @v_sortorder integer,
          @v_qsicode integer,
          @error_var    integer,
          @rowcount_var integer,
          @v_workkey integer,
          @v_usageclassdesc varchar(255)
             
  -- add this title info        
  SELECT @v_itemdesc = c.title, @v_itemtypecode = 1, 
         @v_usageclasscode = COALESCE(c.usageclasscode,0), @v_projectkey = 0, 
         @v_contactkey = 0, @v_bookkey = c.bookkey, @v_printingkey = c.printingkey,
         @v_usageclassdesc = c.formatname
    FROM coretitleinfo c
   WHERE c.bookkey = @i_bookkey
     AND c.printingkey = @i_printingkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var = 0 and @rowcount_var > 0 BEGIN
    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
  END 
          
  IF (@i_related_projects > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 3 -- projects

    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT t.taqprojectkey, 0, 0, 0, c.searchitemcode, c.usageclasscode, c.projecttitle, c.usageclasscodedesc
      FROM taqprojecttitle t, coreprojectinfo c
     WHERE t.taqprojectkey = c.projectkey
       AND t.bookkey = @i_bookkey
       AND t.printingkey = @i_printingkey
       AND t.taqprojectkey > 0
       AND c.searchitemcode = @v_itemtypecode
  END
  
  IF (@i_related_journals > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 6 -- journals

    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT t.taqprojectkey, 0, 0, 0, c.searchitemcode, c.usageclasscode, c.projecttitle, c.usageclasscodedesc
      FROM taqprojecttitle t, coreprojectinfo c
     WHERE t.taqprojectkey = c.projectkey
       AND t.bookkey = @i_bookkey
       AND t.printingkey = @i_printingkey
       AND t.taqprojectkey > 0
       AND c.searchitemcode = @v_itemtypecode
  END

  IF (@i_related_works > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 9 -- works

    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT t.taqprojectkey, 0, 0, 0, c.searchitemcode, c.usageclasscode, c.projecttitle, c.usageclasscodedesc
      FROM taqprojecttitle t, coreprojectinfo c
     WHERE t.taqprojectkey = c.projectkey
       AND t.bookkey = @i_bookkey
       AND t.printingkey = @i_printingkey
       AND t.taqprojectkey > 0
       AND c.searchitemcode = @v_itemtypecode
       AND t.projectrolecode in (select datacode from gentables where tableid = 604 and qsicode = 1)
  END
  
  IF (@i_related_printings > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 14 -- printings

    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT t.taqprojectkey, 0, 0, 0, c.searchitemcode, c.usageclasscode, c.projecttitle, c.usageclasscodedesc
      FROM taqprojecttitle t, coreprojectinfo c
     WHERE t.taqprojectkey = c.projectkey
       AND t.bookkey = @i_bookkey
       AND t.printingkey = @i_printingkey
       AND t.taqprojectkey > 0
       AND c.searchitemcode = @v_itemtypecode
       AND t.projectrolecode in (select datacode from gentables where tableid = 604 and qsicode = 3)
  END  

  IF (@i_related_contracts > 0) BEGIN
    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT t.contractprojectkey, 0, 0, 0, c.searchitemcode, c.usageclasscode, c.projecttitle, c.usageclasscodedesc
      FROM contractstitlesview t, coreprojectinfo c
     WHERE t.contractprojectkey = c.projectkey
       AND t.bookkey = @i_bookkey
       AND t.printingkey = @i_printingkey
       AND t.contractprojectkey > 0
  END
       
  IF (@i_related_contacts > 0) BEGIN
    -- need to check bookauthor and bookcontact tables
    DECLARE author_cur CURSOR fast_forward FOR
      SELECT 0 projectkey,
             c.contactkey,
             0 bookkey, 
             0 printingkey,
             c.displayname itemdesc,
             2 itemtypecode, 0 usageclasscode, null usageclassdesc
        FROM bookauthor ba, corecontactinfo c 
       WHERE ba.authorkey = c.contactkey
         AND ba.bookkey = @i_bookkey
    ORDER BY ba.sortorder ASC

    OPEN author_cur

    FETCH from author_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from author_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_usageclassdesc
    END
    
    CLOSE author_cur
    DEALLOCATE author_cur    
    
    DECLARE contributor_cur CURSOR fast_forward FOR
      SELECT DISTINCT 0 projectkey,
             c.contactkey,
             0 bookkey,
             0 printingkey, 
             c.displayname itemdesc,
             2 itemtypecode, 0 usageclasscode,
             bc.sortorder, null usageclassdesc
        FROM bookcontact bc, corecontactinfo c 
       WHERE bc.globalcontactkey = c.contactkey
         AND bc.bookkey = @i_bookkey
         AND bc.printingkey = @i_printingkey
    ORDER BY bc.sortorder ASC

    OPEN contributor_cur

    FETCH from contributor_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from contributor_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE contributor_cur
    DEALLOCATE contributor_cur     
  END
          
  IF (@i_related_titles > 0) BEGIN
    -- get workkey for the title
    SELECT @v_workkey = COALESCE(c.workkey,0)
      FROM coretitleinfo c 
     WHERE c.bookkey = @i_bookkey AND
           c.printingkey = @i_printingkey
     
    IF @v_workkey > 0 BEGIN
      -- find related titles
      DECLARE titles_cur CURSOR fast_forward FOR
        SELECT 0 projectkey,
               0 contactkey,
               c.bookkey, 
               c.printingkey,
               c.title itemdesc,
               1 itemtypecode, 
               0 usageclasscode, 
               c.formatname usageclassdesc
          FROM coretitleinfo c 
         WHERE c.workkey = @v_workkey
           AND c.bookkey <> @i_bookkey  -- the main title is already in the list
      ORDER BY c.title ASC

      OPEN titles_cur

      FETCH from titles_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_usageclassdesc

      WHILE @@fetch_status = 0 BEGIN
        INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
        VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc, @v_usageclassdesc)
        
        FETCH from titles_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_usageclassdesc
      END
      
      CLOSE titles_cur
      DEALLOCATE titles_cur        
    END
  END
          
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

