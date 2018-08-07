IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_create_work_for_primary_titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_create_work_for_primary_titles]
/****** Object:  StoredProcedure [dbo].[qproject_create_work_for_primary_titles]    Script Date: 07/16/2008 10:32:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_create_work_for_primary_titles]
AS

/******************************************************************************
**  Name: [qproject_create_work_for_primary_titles]
**  Desc: This stored procedure will create a work for all primary titles that
**        do not already have one.  Info will be copied from the title acquisition
**        project, if one exists for the title.
**
**    Auth: Alan Katzen
**    Date: 5 December 2011
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    --------------------------------------------------
**  01/12/18     Colman      Case 48228
*******************************************************************************/

DECLARE
  @v_count  INT,
  @v_work_projectkey  INT,
  @v_title_acq_projectkey INT,
  @v_primary_title_bookkey INT,
  @error_var    INT,
  @rowcount_var INT,     
  @error_desc varchar(2000),  
  @v_work_project_role INT,
  @v_title_title_role INT,
  @v_titleacq_usageclasscode INT,
  @projecttitle_var varchar(255),
  @lastuserid_var varchar(30),
  @new_taqprojectformatkey INT,
  @taqelementkey_var INT,
  @elementtypecode_var INT,
  @elementtypesubcode_var INT,
  @v_work_cnt INT,
  @work_itemtype INT,
  @work_usageclass INT,
  @work_project_statuscode INT,
  @work_project_type INT,
  @userkey INT,
  @v_filterorglevelkey INT,
  @TranName VARCHAR(20),
  @v_bookkey INT,
  @v_printingkey INT,
  @v_taqprojectowner_userid varchar(30)
  
BEGIN  
  SET @lastuserid_var = 'CREATE_WORK'
  SET @TranName = 'PrimTitleWorkConv'
  
  -- make sure there are primary titles that are not already on a work
  SELECT @v_count = count(*)
    FROM book
   WHERE bookkey = workkey --linklevelcode = 10
     and bookkey not in (select workkey from taqproject where workkey > 0 and searchitemcode = 9)
     and COALESCE(standardind,'N') = 'N'
     and (title is not null and title <> '')

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    print 'Unable to create works: Error accessing book table to verify primary titles.'
    RETURN
  END 

  IF @v_count <= 0 BEGIN
    print 'No primary titles exist that are not linked to a work'
    RETURN    
  END

  print 'INFO: Need to add a work for ' + cast(@v_count as varchar) + ' primary titles'
  
  SELECT @v_work_project_role = datacode
    FROM gentables
   WHERE tableid = 604
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    print 'Unable to create works: Error getting work project role.'
    RETURN
  END 
     
  SELECT @v_title_title_role = datacode
    FROM gentables
   WHERE tableid = 605
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    print 'Unable to create works: Error getting title title role.'
    RETURN
  END 

  SELECT @v_titleacq_usageclasscode = datasubcode
    FROM subgentables
   WHERE tableid = 550
     and datacode = 3
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    print 'Unable to create works: Error getting title acquisition usageclasscode (subgentables).'
    RETURN
  END 

  IF @v_titleacq_usageclasscode is null OR @v_titleacq_usageclasscode <= 0 BEGIN
    print 'Unable to create works: Could not find title acquisition usageclasscode (subgentables).'
    RETURN
  END 

  -- create works for all primary titles that are not already on a work
  DECLARE primary_titles_cur CURSOR FOR 
   SELECT bookkey
     FROM book
    WHERE bookkey = workkey --linklevelcode = 10
      and bookkey not in (select workkey from taqproject where workkey > 0 and searchitemcode = 9)
      and COALESCE(standardind,'N') = 'N'
      and (title is not null and title <> '')

  OPEN primary_titles_cur 

  FETCH primary_titles_cur 
   INTO @v_primary_title_bookkey

  WHILE @@fetch_status = 0 BEGIN
    -- see if the title is on a title acquisition
    SELECT @v_count = count(*)
      FROM taqprojecttitle tpt, taqproject tp
    WHERE tpt.taqprojectkey = tp.taqprojectkey
      AND tp.searchitemcode = 3
      AND tp.usageclasscode = @v_titleacq_usageclasscode
      AND tpt.bookkey = @v_primary_title_bookkey
      AND EXISTS (SELECT 1 FROM gentables where tableid = 604 and qsicode = 2 and datacode = tpt.projectrolecode) -- TAQ project role
      AND EXISTS (SELECT 1 FROM gentables where tableid = 605 and qsicode = 2 and datacode = tpt.titlerolecode) -- format

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      print 'Unable to create works: Error determining if title is on title acquisition'
      goto ExitHandler
    END 

    print 'Primary Title Bookkey: ' + cast(@v_primary_title_bookkey as varchar)
    
    BEGIN TRANSACTION @TranName
           
    IF @v_count > 0 BEGIN
      -- title is on a title aquisition - copy title aquisition details to new work project 
      SELECT @v_title_acq_projectkey = tpt.taqprojectkey
        FROM taqprojecttitle tpt, taqproject tp
      WHERE tpt.taqprojectkey = tp.taqprojectkey
        AND tp.searchitemcode = 3
        AND tp.usageclasscode = @v_titleacq_usageclasscode
        AND tpt.bookkey = @v_primary_title_bookkey
        AND EXISTS (SELECT 1 FROM gentables where tableid = 604 and qsicode = 2 and datacode = tpt.projectrolecode) -- TAQ project role
        AND EXISTS (SELECT 1 FROM gentables where tableid = 605 and qsicode = 2 and datacode = tpt.titlerolecode) -- format

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        print 'Unable to create works: Error determining if title is on title acquisition (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
        rollback TRANSACTION @TranName
        goto ExitHandler
      END 

      IF @v_title_acq_projectkey > 0 BEGIN
        -- need to create Work Project before creating titles
        SET @v_work_projectkey = 0
        
        SELECT @projecttitle_var = taqprojecttitle, @userkey = taqprojectownerkey
          FROM taqproject
         WHERE taqprojectkey = @v_title_acq_projectkey
         
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          print 'Error creating work: Error accessing taqproject table (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
          rollback TRANSACTION @TranName
          goto ExitHandler
        END 
        
        SELECT @v_taqprojectowner_userid  = userid
          FROM qsiusers
         WHERE userkey = @userkey

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @v_taqprojectowner_userid is null BEGIN
          SET @v_taqprojectowner_userid = @lastuserid_var
        END 

        print 'Creating Work From Title Acquisition (projectkey: ' + cast(@v_title_acq_projectkey as varchar) + ')'

        exec qproject_create_work @v_title_acq_projectkey,0,@v_taqprojectowner_userid,0,@projecttitle_var,@v_work_projectkey output,@error_var output,@error_desc output
        
        IF @error_var < 0 BEGIN
          print 'Error creating work: ' + @error_desc + '.'
          rollback TRANSACTION @TranName
          goto ExitHandler
        END
          
        IF @v_work_projectkey is null OR @v_work_projectkey <= 0 BEGIN
          print 'Error creating work: New Projectkey is empty (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
          rollback TRANSACTION @TranName
          goto ExitHandler
        END  
        
        -- set workkey on taqproject with primary bookkey (not done inside qproject_create_work)
        UPDATE taqproject
           SET workkey = @v_primary_title_bookkey
         WHERE taqprojectkey = @v_work_projectkey 

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          print 'Error creating work: Error updating taqproject table (' + cast(@error_var AS VARCHAR) + ').'
          rollback TRANSACTION @TranName
          goto ExitHandler
        END                 
      END
    END
    ELSE BEGIN
      -- title is not on a title acquisition - create a new work project
      exec get_next_key @lastuserid_var, @v_work_projectkey output

      SELECT @work_itemtype = datacode
        FROM gentables
       WHERE tableid = 550
         and qsicode = 9

      if @work_itemtype is null or @work_itemtype = 0
      begin
	      print 'Error creating work: Work Item Type could not be found: primary bookkey = ' + cast(@v_primary_title_bookkey AS VARCHAR)   
        rollback TRANSACTION @TranName
        goto ExitHandler
      end

      SELECT @work_usageclass = datasubcode
        FROM subgentables
       WHERE tableid = 550
         and datacode = @work_itemtype
         and qsicode = 28

      if @work_usageclass is null or @work_usageclass = 0
      begin
	      print 'Error creating work: Work Usage Class could not be found: primary bookkey = ' + cast(@v_primary_title_bookkey AS VARCHAR)   
        rollback TRANSACTION @TranName
        goto ExitHandler
      end

      -- set initial status to "Active"
      SELECT @work_project_statuscode = datacode
        FROM gentables
       WHERE tableid = 522
         and qsicode = 3

      if @work_project_statuscode is null or @work_project_statuscode = 0
      begin
	      print 'Error creating work: Initial Work Project Status could not be found: primary bookkey = ' + cast(@v_primary_title_bookkey AS VARCHAR)   
        rollback TRANSACTION @TranName
        goto ExitHandler
      end      
      
      SELECT @work_project_type = datacode 
        FROM gentables
       WHERE tableid = 521
         and qsicode = 2

      if @work_project_type is null or @work_project_type = 0
      begin
	      print 'Error creating work: Initial Work Project Type could not be found: primary bookkey = ' + cast(@v_primary_title_bookkey AS VARCHAR)   
        rollback TRANSACTION @TranName
        goto ExitHandler
      end      

      SELECT @userkey = clientdefaultvalue
        FROM clientdefaults
       WHERE clientdefaultid = 48

      if @userkey is null 
      begin
        SET @userkey = -1
	      -- print 'Error creating work: Initial Work Project Userkey could not be found on clientdefaults: primary bookkey = ' + cast(@v_primary_title_bookkey AS VARCHAR)   
        -- rollback TRANSACTION @TranName
        -- goto ExitHandler
      end      

	    INSERT INTO taqproject
		      (taqprojectkey,taqprojectownerkey,taqprojecttitle,taqprojectsubtitle,taqprojecttype,taqprojecteditionnumcode,
		      taqprojectseriescode,taqprojectstatuscode,templateind,lockorigdateind,lastuserid,lastmaintdate,
		      taqprojecttitleprefix,taqprojecteditiontypecode,taqprojecteditiondesc,taqprojectvolumenumber,
		      termsofagreement,subsidyind,idnumber,usageclasscode,searchitemcode,additionaleditioninfo,defaulttemplateind,workkey) 
	    SELECT @v_work_projectkey, @userkey, title, subtitle,
		         @work_project_type, bd.editionnumber, c.seriescode, @work_project_statuscode, 
		         0, 0, @lastuserid_var, getdate(),c.titleprefix, bd.editioncode, 
		         bd.editiondescription, bd.volumenumber, null, null,null, 
		         @work_usageclass, @work_itemtype, bd.additionaleditinfo, 0,@v_primary_title_bookkey
	     FROM coretitleinfo c, bookdetail bd
	    WHERE c.bookkey = bd.bookkey 
	      and c.bookkey = @v_primary_title_bookkey
	      and c.printingkey = 1
  
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        print 'Unable to create works: Error inserting into taqproject (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
        rollback TRANSACTION @TranName
        goto ExitHandler
      END 
      
      -- orgentry 
      SELECT @v_filterorglevelkey = filterorglevelkey
        FROM filterorglevel
       WHERE filterkey = 7

      IF @v_filterorglevelkey is null OR @v_filterorglevelkey = 0 BEGIN
        SELECT @v_filterorglevelkey = max(orglevelkey)
          FROM bookorgentry
         WHERE bookkey = @v_primary_title_bookkey
      END      

      INSERT INTO taqprojectorgentry (taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
      SELECT @v_work_projectkey, orgentrykey, orglevelkey, @lastuserid_var, getdate()
        FROM bookorgentry
       WHERE bookkey = @v_primary_title_bookkey
         AND orglevelkey <= @v_filterorglevelkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        print 'Unable to create works: Error inserting into taqprojectorgentry (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
        rollback TRANSACTION @TranName
        goto ExitHandler
      END 
    END

    IF @v_work_projectkey > 0 BEGIN
      -- need to relate all the titles in the work to the new work project 
      DECLARE titles_cur CURSOR FOR 
       SELECT bookkey,printingkey
         FROM coretitleinfo
        WHERE workkey = @v_primary_title_bookkey 
          and printingkey = 1

      OPEN titles_cur 

      FETCH titles_cur INTO @v_bookkey,@v_printingkey

      WHILE @@fetch_status = 0 BEGIN 
        print 'Bookkey: ' + cast(@v_bookkey as varchar) + ' / Printingkey: ' + cast(@v_printingkey as varchar)
           
        IF @v_work_project_role > 0 and @v_title_title_role > 0 BEGIN
          exec get_next_key @lastuserid_var, @new_taqprojectformatkey output

          --print '@new_taqprojectformatkey: ' + cast(@new_taqprojectformatkey as varchar)
      
          insert into taqprojecttitle
		          (taqprojectformatkey ,taqprojectkey, seasoncode ,seasonfirmind ,mediatypecode ,
		          mediatypesubcode ,discountcode ,price ,initialrun ,projectdollars ,marketingplancode ,
		          primaryformatind ,isbn ,isbn10 ,ean ,ean13 ,gtin ,bookkey ,
              taqprojectformatdesc ,
		          isbnprefixcode ,lastuserid ,lastmaintdate ,gtin14 ,lccn ,dsmarc ,itemnumber ,upc ,eanprefixcode,
		          printingkey, projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
		          quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, decimal1, decimal2)
          select @new_taqprojectformatkey, @v_work_projectkey, c.bestseasonkey, CASE WHEN c.seasonkey > 0 THEN 1 ELSE 0 END, 
              c.mediatypecode, c.mediatypesubcode, discountcode, 
              (SELECT distinct budgetprice FROM bookprice bp, filterpricetype f
                WHERE bp.pricetypecode = f.pricetypecode
                  and bp.currencytypecode = f.currencytypecode
                  and bp.bookkey = c.bookkey 
                  and f.filterkey = 7
                  and bp.activeind = 1),
              (SELECT p.tentativeqty FROM printing p WHERE p.bookkey = c.bookkey and p.printingkey = c.printingkey),null, null, 
		          CASE WHEN c.bookkey = @v_primary_title_bookkey THEN 1 ELSE 0 END, null, null, null, null, null,c.bookkey, 
              SUBSTRING(c.formatname, 1, 120),
		          null, @lastuserid_var, getdate(), null, null, null, null, null, null,
		          c.printingkey, @v_work_project_role, @v_title_title_role, 0, 0, null, null,
		          null, null, null, null, null, null, null
          from coretitleinfo c, isbn i, bookdetail bd, printing p
          where c.bookkey = i.bookkey
            and c.bookkey = bd.bookkey 
            and c.bookkey = p.bookkey 
            and c.printingkey = p.printingkey
            and c.bookkey = @v_bookkey
            and c.printingkey = @v_printingkey

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            print 'Unable to create works: Error inserting into taqprojecttitle (primary bookkey: ' + cast(@v_primary_title_bookkey as varchar) + ')'
            rollback TRANSACTION @TranName
            CLOSE titles_cur 
            DEALLOCATE titles_cur   
            goto ExitHandler
          END 
	      END
      
        -- add work projectkey to all tasks that have link to work indicator turned on and are not on an element
        UPDATE taqprojecttask
           SET taqprojectkey = @v_work_projectkey
         WHERE datetypecode IN (SELECT datetypecode FROM datetype WHERE linkworktotitleind = 1)
           AND bookkey = @v_bookkey
           AND COALESCE(taqelementkey,0) = 0
           
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          print 'Unable to create works: Error updating taqprojecttask (' + cast(@error_var AS VARCHAR) + ').'
          rollback TRANSACTION @TranName
          CLOSE titles_cur 
          DEALLOCATE titles_cur   
          GOTO ExitHandler
        END
       
        -- add work projectkey to all elements that have link to work indicator turned on
        DECLARE element_cur CURSOR FOR 
         SELECT e.taqelementkey,e.taqelementtypecode,0 elementtypesubcode
           FROM gentables_ext g, taqprojectelement e, coretitleinfo c
          WHERE e.bookkey = c.bookkey and
                e.printingkey = c.printingkey and
                e.taqelementtypecode = g.datacode and
               (e.taqelementtypesubcode is null OR e.taqelementtypesubcode = 0) and         
                g.tableid = 287 and
                g.gen3ind = 1 and   -- worktotitleind
                c.bookkey = @v_bookkey and
                c.printingkey = @v_printingkey
         UNION
         SELECT e.taqelementkey,e.taqelementtypecode,e.taqelementtypesubcode elementtypesubcode
           FROM subgentables s, taqprojectelement e, coretitleinfo c
          WHERE e.bookkey = c.bookkey and
                e.printingkey = c.printingkey and
                e.taqelementtypecode = s.datacode and
                e.taqelementtypesubcode = s.datasubcode and         
                s.tableid = 287 and 
                s.subgen3ind = 1 and  -- worktotitleind
                c.bookkey = @v_bookkey and
                c.printingkey = @v_printingkey

        OPEN element_cur 
        FETCH element_cur INTO @taqelementkey_var,@elementtypecode_var,@elementtypesubcode_var

        WHILE @@fetch_status = 0 BEGIN  
          -- make sure the elementtype has been setup for a work
          select @v_work_cnt = count(*)
            from gentablesitemtype
           where tableid = 287
             and datacode = @elementtypecode_var
             and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
             and itemtypecode = 9
             and itemtypesubcode in (1,0)

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            print 'Unable to create works: Error counting gentablesitemtype table - elementtype works(' + cast(@error_var AS VARCHAR) + ').'
            rollback TRANSACTION @TranName
            CLOSE titles_cur 
            DEALLOCATE titles_cur   
            CLOSE element_cur 
            DEALLOCATE element_cur 
            GOTO ExitHandler
          END
                     
          IF @v_work_cnt > 0 BEGIN
            UPDATE taqprojectelement
               SET taqprojectkey = @v_work_projectkey
             WHERE taqelementkey = @taqelementkey_var

            SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
            IF @error_var <> 0 BEGIN
              print 'Unable to create works: Error updating taqprojectelement (' + cast(@error_var AS VARCHAR) + ').'
              rollback TRANSACTION @TranName
              CLOSE titles_cur 
              DEALLOCATE titles_cur   
              CLOSE element_cur 
              DEALLOCATE element_cur 
              GOTO ExitHandler
            END      
            
            -- add work projectkey to all tasks for the element that have link to work indicator turned on
            UPDATE taqprojecttask
               SET taqprojectkey = @v_work_projectkey
             WHERE datetypecode IN (SELECT datetypecode FROM datetype WHERE linkworktotitleind = 1)
               AND taqelementkey = @taqelementkey_var
               
            SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
            IF @error_var <> 0 BEGIN
              print 'Unable to create works: Error updating taqprojecttask (' + cast(@error_var AS VARCHAR) + ').'
              rollback TRANSACTION @TranName
              CLOSE titles_cur 
              DEALLOCATE titles_cur   
              CLOSE element_cur 
              DEALLOCATE element_cur 
              GOTO ExitHandler
            END                 
          END
                       
          FETCH element_cur INTO @taqelementkey_var,@elementtypecode_var,@elementtypesubcode_var
        END
            
        CLOSE element_cur 
        DEALLOCATE element_cur            

        FETCH titles_cur INTO @v_bookkey,@v_printingkey      
      END

      CLOSE titles_cur 
      DEALLOCATE titles_cur   
    END
      
    commit TRANSACTION @TranName
        
    FETCH primary_titles_cur INTO @v_primary_title_bookkey
  END
  
  ExitHandler:
  
  CLOSE primary_titles_cur 
  DEALLOCATE primary_titles_cur 

END
