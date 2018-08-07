if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_task_selectlist_contact') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_task_selectlist_contact
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_task_selectlist_contact(
  @i_contactkey         integer,
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
          
  -- add this contact info        
  SELECT @v_itemdesc = c.displayname, @v_itemtypecode = 2, 
         @v_usageclasscode = 0, @v_projectkey = 0, 
         @v_contactkey = c.contactkey, @v_bookkey = 0, @v_printingkey = 0, @v_usageclassdesc = null
    FROM corecontactinfo c
   WHERE c.contactkey = @i_contactkey 

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
     SELECT c.projecttitle itemdesc, c.searchitemcode itemtypecode, 
            COALESCE(c.usageclasscode,0) usageclasscode,
            c.projectkey, 0 contactkey, 0 bookkey, 0 printingkey, c.usageclasscodedesc
       FROM coreprojectinfo c, taqprojectcontact pc
      WHERE pc.taqprojectkey = c.projectkey
        AND pc.globalcontactkey = @i_contactkey
        AND c.searchitemcode = @v_itemtypecode
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN project_cur

    FETCH from project_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
      @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from project_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
        @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
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
     SELECT c.projecttitle itemdesc, c.searchitemcode itemtypecode, 
            COALESCE(c.usageclasscode,0) usageclasscode,
            c.projectkey, 0 contactkey, 0 bookkey, 0 printingkey, usageclasscodedesc
       FROM coreprojectinfo c, taqprojectcontact pc
      WHERE pc.taqprojectkey = c.projectkey
        AND pc.globalcontactkey = @i_contactkey
        AND c.searchitemcode = @v_itemtypecode
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN journal_cur

    FETCH from journal_cur 
    INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from journal_cur 
      INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
    END
    
    CLOSE journal_cur
    DEALLOCATE journal_cur              
  END
   
  IF (@i_related_works > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 9 -- works
       
    DECLARE work_cur CURSOR fast_forward FOR
     SELECT c.projecttitle itemdesc, c.searchitemcode itemtypecode, 
            COALESCE(c.usageclasscode,0) usageclasscode,
            c.projectkey, 0 contactkey, 0 bookkey, 0 printingkey, c.usageclasscodedesc
       FROM coreprojectinfo c, taqprojectcontact pc
      WHERE pc.taqprojectkey = c.projectkey
        AND pc.globalcontactkey = @i_contactkey
        AND c.searchitemcode = @v_itemtypecode
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN work_cur

    FETCH from work_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
      @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from work_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
        @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
    END
    
    CLOSE work_cur
    DEALLOCATE work_cur       
  END

  IF (@i_related_contracts > 0) BEGIN
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 10 -- contracts
       
    DECLARE contract_cur CURSOR fast_forward FOR
     SELECT c.projecttitle itemdesc, c.searchitemcode itemtypecode, 
            COALESCE(c.usageclasscode,0) usageclasscode,
            c.projectkey, 0 contactkey, 0 bookkey, 0 printingkey, c.usageclasscodedesc
       FROM coreprojectinfo c, taqprojectcontact pc
      WHERE pc.taqprojectkey = c.projectkey
        AND pc.globalcontactkey = @i_contactkey
        AND c.searchitemcode = @v_itemtypecode
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN contract_cur

    FETCH from contract_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
      @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from contract_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
        @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
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
     SELECT c.projecttitle itemdesc, c.searchitemcode itemtypecode, 
            COALESCE(c.usageclasscode,0) usageclasscode,
            c.projectkey, 0 contactkey, 0 bookkey, 0 printingkey, c.usageclasscodedesc
       FROM coreprojectinfo c, taqprojectcontact pc
      WHERE pc.taqprojectkey = c.projectkey
        AND pc.globalcontactkey = @i_contactkey
        AND c.searchitemcode = @v_itemtypecode
   ORDER BY COALESCE(pc.sortorder, 0)

    OPEN printing_cur

    FETCH from printing_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
      @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH NEXT from printing_cur INTO @v_itemdesc,@v_itemtypecode,@v_usageclasscode,@v_projectkey,
        @v_contactkey,@v_bookkey,@v_printingkey,@v_usageclassdesc
    END
    
    CLOSE printing_cur
    DEALLOCATE printing_cur       
  END  
       
  IF (@i_related_contacts > 0) BEGIN
    DECLARE contact_cur CURSOR fast_forward FOR
      SELECT 0 projectkey,
             globalcontactkey2 contactkey,
             0 bookkey, 
             0 printingkey,
             c.displayname itemdesc,
             2 itemtypecode, 0 usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder,
             null usageclassdesc
        FROM globalcontactrelationship r, corecontactinfo c 
       WHERE r.globalcontactkey2 = c.contactkey
         AND r.globalcontactkey1 > 0 
         AND r.globalcontactkey1 = @i_contactkey
    UNION
      SELECT 0 projectkey, 
             globalcontactkey1 contactkey, 
             0 bookkey, 
             0 printingkey,
             c.displayname itemdesc,
             2 itemtypecode, 0 usageclasscode,
             r.keyind, COALESCE(r.sortorder,0) sortorder,
             null usageclassdesc
        FROM globalcontactrelationship r, corecontactinfo c 
       WHERE r.globalcontactkey1 = c.contactkey
         AND r.globalcontactkey2 > 0 
         AND r.globalcontactkey2 = @i_contactkey
    ORDER BY r.keyind DESC, sortorder ASC

    OPEN contact_cur

    FETCH from contact_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from contact_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_keyind,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE contact_cur
    DEALLOCATE contact_cur    
  END
          
  IF (@i_related_titles > 0) BEGIN
    -- need to check bookauthor and bookcontact tables
    DECLARE author_cur CURSOR fast_forward FOR
      SELECT 0 projectkey,
             0 contactkey,
             c.bookkey, 
             c.printingkey,
             c.title itemdesc,
             1 itemtypecode, 0 usageclasscode, c.formatname usageclassdesc
        FROM bookauthor ba, coretitleinfo c 
       WHERE ba.bookkey = c.bookkey
         AND ba.authorkey = @i_contactkey
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
             0 contactkey,
             c.bookkey, 
             c.printingkey,
             c.title itemdesc,
             1 itemtypecode, 0 usageclasscode,
             bc.sortorder, c.formatname usageclassdesc
        FROM bookcontact bc, coretitleinfo c 
       WHERE bc.bookkey = c.bookkey
         AND bc.printingkey = c.printingkey
         AND bc.globalcontactkey = @i_contactkey
    ORDER BY bc.sortorder ASC

    OPEN contributor_cur

    FETCH from contributor_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
      @v_usageclasscode,@v_sortorder,@v_usageclassdesc

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @selectionlist (projectkey,contactkey,bookkey,printingkey,itemtypecode,usageclasscode,itemdesc,usageclassdesc)
      VALUES (@v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemtypecode,@v_usageclasscode,@v_itemdesc,@v_usageclassdesc)
      
      FETCH from contributor_cur INTO @v_projectkey,@v_contactkey,@v_bookkey,@v_printingkey,@v_itemdesc,@v_itemtypecode,
        @v_usageclasscode,@v_sortorder,@v_usageclassdesc
    END
    
    CLOSE contributor_cur
    DEALLOCATE contributor_cur     
  END
          
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

