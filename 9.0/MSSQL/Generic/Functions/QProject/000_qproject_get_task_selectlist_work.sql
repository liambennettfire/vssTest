if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_task_selectlist_work') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_task_selectlist_work
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_task_selectlist_work(
  @i_projectkey         integer,
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
          @v_usageclassdesc varchar(255)
          
  -- add this work info        
  SELECT @v_itemdesc = c.projecttitle, @v_itemtypecode = c.searchitemcode, 
         @v_usageclasscode = COALESCE(c.usageclasscode,0), @v_usageclassdesc = usageclasscodedesc,
         @v_projectkey = projectkey, @v_contactkey = 0, 
         @v_bookkey = 0, @v_printingkey = 0
    FROM coreprojectinfo c
   WHERE c.projectkey = @i_projectkey    

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
       
    DECLARE project_cur CURSOR fast_forward FOR
      SELECT relatedprojectkey projectkey,
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.relatedprojectkey = c.projectkey
         AND r.taqprojectkey > 0 
         AND r.taqprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    UNION
      SELECT taqprojectkey projectkey, 
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.taqprojectkey = c.projectkey
         AND r.relatedprojectkey > 0 
         AND r.relatedprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    ORDER BY r.keyind DESC, sortorder ASC

    OPEN project_cur

    FETCH from project_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from project_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE project_cur
    DEALLOCATE project_cur
  END
  
  IF (@i_related_journals > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 6 -- journals
       
    DECLARE journal_cur CURSOR fast_forward FOR
      SELECT relatedprojectkey projectkey,
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.relatedprojectkey = c.projectkey
         AND r.taqprojectkey > 0 
         AND r.taqprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    UNION
      SELECT taqprojectkey projectkey, 
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.taqprojectkey = c.projectkey
         AND r.relatedprojectkey > 0 
         AND r.relatedprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    ORDER BY r.keyind DESC, sortorder ASC

    OPEN journal_cur

    FETCH from journal_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from journal_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE journal_cur
    DEALLOCATE journal_cur
  END

  --IF (@i_related_works > 0) BEGIN
  --  SELECT @v_itemtypecode = datacode
  --    FROM gentables
  --   WHERE tableid = 550
  --     AND qsicode = 9 -- works
       
  --  DECLARE work_cur CURSOR fast_forward FOR
    --  SELECT relatedprojectkey projectkey,
    --         0 contactkey, 0 bookkey, 0 printingkey,
    --         c.projecttitle itemdesc,
    --         c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
    --         r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
    --    FROM projectrelationshipview r, coreprojectinfo c 
    --   WHERE r.relatedprojectkey = c.projectkey
    --     AND r.taqprojectkey > 0 
    --     AND r.taqprojectkey = @i_projectkey
    --     AND c.searchitemcode = @v_itemtypecode
    --UNION
    --  SELECT taqprojectkey projectkey, 
    --         0 contactkey, 0 bookkey, 0 printingkey,
    --         c.projecttitle itemdesc,
    --         c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
    --         r.keyind, COALESCE(r.sortorder,0) sortorder, c.usageclasscodedesc
    --    FROM projectrelationshipview r, coreprojectinfo c 
    --   WHERE r.taqprojectkey = c.projectkey
    --     AND r.relatedprojectkey > 0 
    --     AND r.relatedprojectkey = @i_projectkey
    --     AND c.searchitemcode = @v_itemtypecode
    --ORDER BY r.keyind DESC, sortorder ASC

  --  OPEN work_cur

  --  FETCH from work_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
  --    @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

  --  WHILE @@fetch_status = 0 BEGIN
  --    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
  --    VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
  --    FETCH from work_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
  --      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
  --  END
    
  --  CLOSE work_cur
  --  DEALLOCATE work_cur
  --END
       
  IF (@i_related_contracts > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 10 -- contracts

    DECLARE contract_cur CURSOR fast_forward FOR
      SELECT r.relatedprojectkey projectkey,
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.relatedprojectkey = c.projectkey
         AND r.taqprojectkey > 0 
         AND r.taqprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
      UNION
      SELECT taqprojectkey projectkey, 
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.taqprojectkey = c.projectkey
         AND r.relatedprojectkey > 0 
         AND r.relatedprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    ORDER BY r.keyind DESC, sortorder ASC
    
    OPEN contract_cur

    FETCH from contract_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from contract_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE contract_cur
    DEALLOCATE contract_cur    
  END
  
  IF (@i_related_printings > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 14 -- printings

    DECLARE printing_cur CURSOR fast_forward FOR
      SELECT r.relatedprojectkey projectkey,
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.relatedprojectkey = c.projectkey
         AND r.taqprojectkey > 0 
         AND r.taqprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
      UNION
      SELECT taqprojectkey projectkey, 
             0 contactkey, 0 bookkey, 0 printingkey,
             c.projecttitle itemdesc,
             c.searchitemcode itemtypecode, COALESCE(c.usageclasscode,0) usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder, usageclasscodedesc
        FROM projectrelationshipview r, coreprojectinfo c 
       WHERE r.taqprojectkey = c.projectkey
         AND r.relatedprojectkey > 0 
         AND r.relatedprojectkey = @i_projectkey
         AND c.searchitemcode = @v_itemtypecode
    ORDER BY r.keyind DESC, sortorder ASC
    
    OPEN printing_cur

    FETCH from printing_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from printing_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE printing_cur
    DEALLOCATE printing_cur    
  END  
       
  IF (@i_related_contacts > 0) BEGIN
    DECLARE contact_cur CURSOR fast_forward FOR
     SELECT c.displayname itemdesc, 2 itemtypecode, 0 usageclasscode,
            0 projectkey, contactkey, 0 bookkey, 0 printingkey, null usageclassdesc
       FROM corecontactinfo c, taqprojectcontact pc
      WHERE pc.globalcontactkey = c.contactkey
        AND pc.taqprojectkey = @i_projectkey
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN contact_cur

    FETCH from contact_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from contact_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
    END
    
    CLOSE contact_cur
    DEALLOCATE contact_cur
  END
          
  IF (@i_related_titles > 0) BEGIN
    INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
    SELECT 0, 0, c.bookkey, c.printingkey, c.itemtypecode, c.usageclasscode, 
      c.title + ' / ' + COALESCE(c.productnumber + ' / ', '') + c.formatname itemdesc, c.formatname
      FROM taqprojecttitle t, coretitleinfo c
     WHERE t.bookkey = c.bookkey
       AND t.printingkey = c.printingkey
       AND t.taqprojectkey = @i_projectkey 
       AND t.bookkey > 0
    ORDER BY t.primaryformatind DESC, lastmaintdate DESC
  END
          
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

