/****** Object:  StoredProcedure [dbo].[qpo_generate_po_report]    Script Date: 03/11/2015 10:58:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_generate_po_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_generate_po_report]
GO

/****** Object:  StoredProcedure [dbo].[qpo_generate_po_report]    Script Date: 6/26/2017 4:50:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[qpo_generate_po_report]
 (@i_projectkey           integer,	--PO Report project
  @i_related_projectkey   integer,	--related PO project
  @i_gpokey               integer,
  @i_report_detail_type   integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/************************************************************************************************
**  Name: qpo_generate_po_report
**  Desc: This procedure will be called from the when a project that is a PO
**        Report Class is created.
**        New projectkey key, related project key, gpokey and lastuserid 
**        will be passed in.
**	Auth: Kusum
**	Date: 12 August 2014
*************************************************************************************************
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:      Case #:      Description:
**    --------    --------     -------     ------------------------------------------------------
**    1/21/2016	  UK		    35983  gpo status not being updated when Po Report is amended
**    3/08/2016   Kusum			36152  Use clientdefaultvalue from clientdefaults (clientdefaultid = 83)
**                                     for production bound book date type code
**    4/06/2016   Kusum         36178  Keys Table at S&S Getting Close to Max Value     
**    06/29/2016  Uday		    38904     historychanges not updating lastmaintdate when po amended
**    01/12/2017  Uday		    42641
**    06/26/2017  BL            45987  added vendorid2 column to gpo    
**    03/13/2018  BA            50229  selected address for vendor not being used    
*******************************************************************************/
BEGIN 
  DECLARE
    @v_count  INT,
    @v_count2 INT,
    @v_count_gpo INT,
    @v_count_rows INT,
    @lastuserid_var   VARCHAR(30),
    @v_gpokey INT,
    @v_gponumber VARCHAR(50),
    @v_gpochangenumber_str VARCHAR(50),
    @v_gpochangenumber INT,
    @v_gponumber_productid INT,
    @v_gpochangenumber_productid INT,
    @v_gpodate DATETIME,
    @v_po_itemtypecode_CurrentReport INT,
    @v_po_usageclasscode_CurrentReport INT,
    @v_po_proforma INT,
    @v_po_final INT,
    @v_gpostatus CHAR(1),
    @v_warehousedate DATETIME,
    @v_boundbookdate DATETIME,
    @v_taqprojectstatuscode INT,
    @v_searchitemcode INT,
    @v_usageclasscode INT,
    @v_usageclasscode_desc VARCHAR(40),
    @v_taqtaskkey INT,
    @count_var INT,
    @error_var INT,
    @rowcount_var INT,
    @v_warehousedatecode INT,
    @v_prodboundbookdate_value INT,
    @v_boundbookdatecode INT,
    @v_requireddatecode INT,
    @v_requireddate DATETIME,
    @v_roletypecode INT,
    @v_globalcontactkey INT,
    @v_vendor_globalcontactkey INT,    
    @v_taqprojecttitle VARCHAR(255),
    @v_vendorname VARCHAR(255),
    @v_address1  VARCHAR(50),
    @v_address2	 VARCHAR(50),
    @v_city	VARCHAR(25),
    @v_statecode INT,
    @v_state VARCHAR(2),
    @v_zipcode VARCHAR(10),
    @v_vendorid VARCHAR(255),
	@v_vendorid2 VARCHAR(255),
    @v_vendorattn VARCHAR(255),
    @v_number_of_shiplocations INT,
    @v_potypekey	INT,
    @v_bookkey INT,
    @v_printingkey INT,
    @v_project_usageclasscode INT,
    @v_prev_gpostatus VARCHAR(1),
    @v_elementkey INT,
    @v_relatedprojectkey	INT,
    @v_keyind INT,
    @v_printing_for_po_reports INT,
    @v_po_reports_for_printing INT,
    @v_new_taqprojecctrelationshipkey INT,
    @v_taqprojectcontactrolekey	INT,
    @v_rolecode	INT,
    @v_taqprojectcontactkey INT,
    @v_taqelementkey INT,
    @v_datetypecode INT,
    @v_datetypecode_CreateDate INT,
    @v_datetypecode_PODate INT,
    @v_datetypecode_AmendedDate INT,
    @v_count_task INT,
    @v_newkey INT,
    @v_poreportprojectkey_for_amendment INT,
    @v_ponumber_from_report VARCHAR(50),    
	@v_datacode INT,
	@v_datasubcode INT,
    @v_qsicode_project INT,
    @v_printingprojectkey INT,
    @i_globalcontactrelationshipkey INT,
    @i_attncontactkey INT ,
    @i_contactrelationshipcode1 int,
    @i_contactrelationshipcode2 int,
    @v_addresskey int  
    
  SET @o_error_code = 0
  SET @o_error_desc = '' 
  SET @v_count_task = 0
  
  SELECT @v_datetypecode_CreateDate = datetypecode FROM datetype where qsicode = 17
  SELECT @v_datetypecode_PODate = datetypecode FROM datetype where qsicode = 28
  SELECT @v_datetypecode_AmendedDate = datetypecode FROM datetype where qsicode = 29
  
  SELECT @v_datacode = COALESCE(searchitemcode, 0), @v_datasubcode = COALESCE(usageclasscode, 0) 
  FROM coreprojectinfo 
  WHERE projectkey = @i_projectkey
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning coreprojectinfo row for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END       
  
  SELECT @v_qsicode_project = qsicode
  FROM subgentables 
  WHERE tableid = 550 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning finding subgentable 550 entry for ItemType/UsageClass for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END       
      
  IF @i_lastuserid IS NULL BEGIN
	SELECT @lastuserid_var = 'QSIADMIN'
  END
  ELSE BEGIN
    SET @lastuserid_var = @i_lastuserid
  END
     
  SELECT @v_count_gpo = 0
  
  SELECT @v_count_gpo = COUNT(*)
    FROM gpo
   WHERE gpokey = @i_projectkey
   
   
  IF @v_count_gpo = 0 
    SELECT @v_gpokey = @i_projectkey
  ELSE IF @i_gpokey > 0 
	SELECT @v_gpokey = @i_gpokey
  ELSE 
    SELECT @v_gpokey = @i_projectkey
    
  SELECT @v_po_proforma = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 42 --Proforma PO Report
  
  SELECT @v_po_final = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 43--Final PO Report
  
 --PO Report 
  SELECT @v_project_usageclasscode = usageclasscode
   FROM taqproject WHERE taqprojectkey = @i_projectkey 
    
 SELECT @v_count = COUNT(*) FROM taqproject WHERE taqprojectkey = @i_projectkey
 
 IF @v_count = 0 BEGIN
	SET @v_taqprojectstatuscode = 0
	SET @v_taqprojecttitle = ''
 END 
 ELSE BEGIN       
  SELECT @v_taqprojectstatuscode = taqprojectstatuscode, @v_taqprojecttitle = taqprojecttitle
    FROM taqproject WHERE taqprojectkey = @i_projectkey
 END
  
  --project status is locked
  IF @v_taqprojectstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1) BEGIN
    SELECT @v_searchitemcode = searchitemcode, @v_usageclasscode = usageclasscode FROM taqproject WHERE taqprojectkey = @i_projectkey
    SELECT @v_usageclasscode_desc = datadesc FROM subgentables WHERE tableid = 550 and datacode = @v_searchitemcode AND datasubcode = @v_usageclasscode
	SET @o_error_code = -1
    SET @o_error_desc = CONVERT(varchar,@v_usageclasscode_desc) + ' has a locked status; cannot refresh'
    RETURN
  END
  
  -- Delete and replace all dates and contacts from related project if project status is not locked
  IF @v_taqprojectstatuscode NOT IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1) BEGIN
   	--PRINT 'Deleting taqprojectcontact...'

	SELECT @count_var = count(*)
 	  FROM taqprojectcontact
	 WHERE taqprojectkey = @i_projectkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to copy contacts from related project: Error accessing taqprojectcontact table (' + cast(@error_var AS VARCHAR) + ').'
	 RETURN
	END 
	IF @count_var > 0 BEGIN
		DELETE FROM taqprojectcontact
		WHERE taqprojectkey = @i_projectkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to copy contacts from related project: Error deleting taqprojectcontact table (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
		END 
	END
	
	-- taqprojectcontactrole
	--PRINT 'Deleting taqprojectcontactrole...'

	SELECT @count_var = count(*)
	  FROM taqprojectcontactrole
	 WHERE taqprojectkey = @i_projectkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to copy contacts from related project: Error accessing taqprojectcontactrole table (' + cast(@error_var AS VARCHAR) + ').'
		RETURN
	END 
	IF @count_var > 0 BEGIN
		DELETE FROM taqprojectcontactrole
		WHERE taqprojectkey = @i_projectkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to copy contacts from related project: Error deleting taqprojectcontactrole table (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
		END 
    END
	
	--PRINT 'Copying taqprojectcontact and taqprojectcontactrole.....'
	
	EXEC qproject_copy_project_contacts @i_related_projectkey,NULL,@i_projectkey,@lastuserid_var,'',@o_error_code,@o_error_desc
	
	IF @o_error_code <> 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to copy contacts from related project: Error returned from qproject_copy_project_contacts (' + cast(@error_var AS VARCHAR) + ').'
	 RETURN
	END
	
	--Delete rows not for the purchase order usageclasscode and itemtype
	SELECT @v_count_rows = COUNT(*)
	  FROM taqprojectcontactrole 
	 WHERE taqprojectcontactkey in 
       (SELECT taqprojectcontactkey FROM taqprojectcontact WHERE taqprojectkey =  @i_projectkey )
       
    IF @v_count_rows > 0 BEGIN
    
		DECLARE taqprojectcontact_cur CURSOR FOR
			SELECT taqprojectcontactrolekey,rolecode,taqprojectcontactkey
			  FROM taqprojectcontactrole 
			 WHERE taqprojectcontactkey in 
				(SELECT taqprojectcontactkey FROM taqprojectcontact WHERE taqprojectkey =  @i_projectkey )
				
		OPEN taqprojectcontact_cur
		
		FETCH taqprojectcontact_cur INTO @v_taqprojectcontactrolekey,@v_rolecode,@v_taqprojectcontactkey 
    
        WHILE @@fetch_status = 0 BEGIN
            IF NOT EXISTS (SELECT * from gentablesitemtype g WHERE tableid = 285 AND g.datacode = @v_rolecode 
                AND g.itemtypecode = 15 AND g.itemtypesubcode IN (@v_project_usageclasscode, 0)) BEGIN

				DELETE FROM taqprojectcontactrole WHERE taqprojectcontactrolekey = @v_taqprojectcontactrolekey
	        
				DELETE FROM taqprojectcontact WHERE taqprojectcontactkey = @v_taqprojectcontactkey
            END
			FETCH taqprojectcontact_cur INTO @v_taqprojectcontactrolekey,@v_rolecode,@v_taqprojectcontactkey 
        END
        
        CLOSE taqprojectcontact_cur
        DEALLOCATE taqprojectcontact_cur
    END
	
	-- taqprojecttask 
    --PRINT 'Deleting taqprojecttask...'

    
    SELECT @count_var = count(*)
   	  FROM taqprojecttask
	 WHERE taqprojectkey = @i_projectkey
	   AND COALESCE(bookkey,0) <= 0

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to copy dates for related project: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
	  RETURN
	END 
	IF @count_var > 0 BEGIN

		--PRINT 'Deleting taqprojecttaskoverride...'

		DELETE FROM taqprojecttaskoverride
		WHERE taqelementkey in (SELECT taqelementkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey AND COALESCE(bookkey,0) <= 0)
		  AND taqtaskkey in (SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey AND COALESCE(bookkey,0) <= 0)

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to copy dates for related project: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
		END 
			    
		DELETE FROM taqprojecttask
		WHERE taqprojectkey = @i_projectkey
		  AND COALESCE(bookkey,0) <= 0
		  AND taqtaskkey NOT IN 
		  (SELECT taqtaskkey 
		   FROM taqprojecttask 
	       WHERE datetypecode = @v_datetypecode_CreateDate AND 
			  taqprojectkey = @i_projectkey AND
			  COALESCE(bookkey,0) <= 0 AND
			  COALESCE(taqelementkey, 0) = 0) 
	 
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to copy dates for related project: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
		END  
	 END
 
	--PRINT 'Copying taqprojecttask.....'
	  
	EXEC qproject_copy_project_element  @i_related_projectkey,0,NULL,NULL,NULL,@i_projectkey,NULL,NULL,@lastuserid_var,'','',@v_elementkey,@o_error_code,@o_error_desc
	
	IF @o_error_code <> 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to copy tasks from related project: Error returned from qproject_copy_project_tasks (' + cast(@error_var AS VARCHAR) + ').'
	 RETURN
	END
	
	EXEC qproject_copy_project_nonelement_tasks @i_related_projectkey,@i_projectkey,@lastuserid_var,'','',@o_error_code,@o_error_desc
	
	IF @o_error_code <> 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to copy tasks from related project: Error returned from qproject_copy_project_tasks (' + cast(@error_var AS VARCHAR) + ').'
	 RETURN
	END
	
	--Delete rows not for the purchase order usageclasscode and itemtype
	SELECT @v_count_rows = COUNT(*)
	  FROM taqprojecttask 
	 WHERE taqprojectkey =  @i_projectkey
       
    IF @v_count_rows > 0 BEGIN
    
		DECLARE taqprojecttask_cur CURSOR FOR
			SELECT taqtaskkey,taqelementkey,datetypecode
			  FROM taqprojecttask 
	         WHERE taqprojectkey =  @i_projectkey
				
		OPEN taqprojecttask_cur
		
		FETCH taqprojecttask_cur INTO @v_taqtaskkey,@v_taqelementkey,@v_datetypecode
    
        WHILE @@fetch_status = 0 BEGIN
            IF NOT EXISTS (SELECT * from gentablesitemtype g WHERE tableid = 323 AND g.datacode = @v_datetypecode 
                AND g.itemtypecode = 15 AND g.itemtypesubcode IN (@v_project_usageclasscode, 0)) BEGIN
            
				IF @v_taqelementkey > 0 
					DELETE FROM taqprojecttaskoverride WHERE taqelementkey = @v_taqelementkey
	        
				DELETE FROM taqprojecttask WHERE taqtaskkey = @v_taqtaskkey
			END
            
			FETCH taqprojecttask_cur INTO @v_taqtaskkey,@v_taqelementkey,@v_datetypecode 
        END
        
        CLOSE taqprojecttask_cur
        DEALLOCATE taqprojecttask_cur
    END

	--PRINT 'Finished copying taqprojecttask.....'
  END  -- if project status is not locked
  
  
  -- copy project relationships from Purchase Order to Report
  --print 'copying taqprojectrelationship rows'
  
  SELECT @v_printing_for_po_reports = datacode FROM gentables WHERE tableid =  582 and qsicode = 29 --Printing (for PO Reports)
  
  
  SELECT @v_po_reports_for_printing = datacode FROM gentables WHERE tableid =  582 and qsicode = 30 --PO Reports (for Printings)
  
  DECLARE taqprojectrelationship_cur CURSOR FOR
	SELECT  relatedprojectkey,keyind 
	  FROM projectrelationshipview 
     WHERE taqprojectkey = @i_related_projectkey 
       AND relationshipcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 25) --Printing (for Purchase Orders)
       
    OPEN taqprojectrelationship_cur
    
	FETCH taqprojectrelationship_cur INTO @v_relatedprojectkey,@v_keyind
	  
	WHILE @@fetch_status = 0 BEGIN
	    SET @v_count2 = 0
	    
	        
	    SELECT @v_count2 = COUNT(*)
	      FROM taqprojectrelationship
	     WHERE taqprojectkey1 = @v_relatedprojectkey
	       AND taqprojectkey2 = @i_projectkey
	       AND relationshipcode1 = @v_printing_for_po_reports
	       AND relationshipcode2 = @v_po_reports_for_printing
	       
	    IF @v_count2 = 1 BEGIN  -- delete existing row and readd it
			DELETE FROM taqprojectrelationship
			 WHERE taqprojectkey1 = @v_relatedprojectkey
	           AND taqprojectkey2 = @i_projectkey
	           AND relationshipcode1 = @v_printing_for_po_reports
	           AND relationshipcode2 = @v_po_reports_for_printing
	           
	           
	        exec get_next_key @lastuserid_var, @v_new_taqprojecctrelationshipkey output
		    
			INSERT INTO taqprojectrelationship (taqprojectrelationshipkey,taqprojectkey1, taqprojectkey2, relationshipcode1,
			  relationshipcode2, keyind, lastuserid, lastmaintdate)
			VALUES(@v_new_taqprojecctrelationshipkey,@v_relatedprojectkey,@i_projectkey,@v_printing_for_po_reports,
			  @v_po_reports_for_printing,@v_keyind,@lastuserid_var,getdate())  
	    END 
	       
	    IF @v_count2 = 0 BEGIN  -- add row
	       
			exec get_next_key @lastuserid_var, @v_new_taqprojecctrelationshipkey output
		    
			INSERT INTO taqprojectrelationship (taqprojectrelationshipkey,taqprojectkey1, taqprojectkey2, relationshipcode1,
			  relationshipcode2, keyind, lastuserid, lastmaintdate)
			VALUES(@v_new_taqprojecctrelationshipkey,@v_relatedprojectkey,@i_projectkey,@v_printing_for_po_reports,
			  @v_po_reports_for_printing,@v_keyind,@lastuserid_var,getdate())  
	    END
		    
		FETCH taqprojectrelationship_cur INTO @v_relatedprojectkey,@v_keyind    
	END --end of taqprojecttask_cur loop

    CLOSE taqprojectrelationship_cur
    DEALLOCATE taqprojectrelationship_cur
    --PRINT 'Finished copying taqprojectrelationship rows.....'
    
  --gponumber   
  SELECT @v_gponumber_productid = datacode FROM gentables WHERE tableid = 594 AND qsicode = 7 --PO#
  
  SELECT @v_gponumber = productnumber FROM taqproductnumbers WHERE taqprojectkey = @i_projectkey  
     AND productidcode = @v_gponumber_productid
  
  --gpochangenumber   
  SELECT @v_gpochangenumber_productid = datacode FROM gentables WHERE tableid = 594 AND qsicode = 13 --PO Amendment #
  
  SELECT @v_gpochangenumber_str = productnumber FROM taqproductnumbers WHERE taqprojectkey = @i_projectkey  
     AND productidcode = @v_gpochangenumber_productid
     
  IF @v_gpochangenumber_str IS NOT NULL AND @v_gpochangenumber_str <> '' 
	SET @v_gpochangenumber = CAST(CAST(@v_gpochangenumber_str as float) as int)
  ELSE 
    SET @v_gpochangenumber = 0
  
  --gpodate   
  SELECT @v_gpodate = getdate()
  
  -- gpostatus        
  IF @v_project_usageclasscode = @v_po_proforma
	SET @v_gpostatus = 'P'
  ELSE IF @v_project_usageclasscode = @v_po_final
	SET @v_gpostatus = 'F'
	
  -- Printing project associated with the PO 
  SELECT @v_printingprojectkey =  relatedprojectkey FROM projectrelationshipview WHERE taqprojectkey = @i_related_projectkey
	 AND relationshipcode in (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 25) --Printing (for Purchase Orders)
	
  -- warehousedate
  SELECT @v_warehousedatecode = datetypecode FROM datetype WHERE qsicode = 20
  
  -- BL: commented this part out will not be on the po report project nor the po summary project
  --SELECT @v_warehousedate = dbo.qproject_get_taskdate(@i_projectkey,@v_warehousedatecode,0) 
  
   select @v_bookkey = bookkey, @v_printingkey=printingkey from taqprojectprinting_view where taqprojectkey=@v_printingprojectkey
   
   select @v_warehousedate = [dbo].[get_title_task_by_bookkey_printingkey] (@v_bookkey,@v_printingkey,@v_warehousedatecode,'B')    
  
  
 -- IF @v_warehousedate IS NULL BEGIN
 --   SELECT @v_count = COUNT(*) FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
 --   IF @v_count = 1 
	-- SELECT @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey  --PO Report
	--ELSE IF @v_count > 1 
	-- SELECT TOP 1 @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
	--ELSE IF @v_count = 0 
	--	SELECT @v_bookkey = bookkey, @v_printingkey =  printingkey 
	--	  FROM taqprojectprinting_view WHERE taqprojectkey=@v_printingprojectkey
		 
	--IF @v_bookkey > 0 AND @v_printingkey > 0 
	--	SELECT @v_warehousedate = dbo.qtitle_get_last_taskdate(@v_bookkey,@v_printingkey,@v_warehousedatecode)
 -- END
  
  -- boundbookdate
  SELECT @v_boundbookdatecode = COALESCE(clientdefaultvalue,0) FROM clientdefaults WHERE clientdefaultname = 'Production Bound Book Date Type Code'
  
  IF @v_boundbookdatecode > 0 
	SELECT @v_boundbookdate = dbo.qproject_get_taskdate(@i_projectkey,@v_boundbookdatecode,0)
  
   IF @v_boundbookdate IS NULL BEGIN
    SELECT @v_count = COUNT(*) FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
    IF @v_count = 1 
	 SELECT @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
	ELSE IF @v_count > 1 
	 SELECT TOP 1 @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
	ELSE IF @v_count = 0 
		SELECT @v_bookkey = bookkey, @v_printingkey =  printingkey 
		  FROM taqprojectprinting_view WHERE taqprojectkey=@v_printingprojectkey
	 
	IF @v_bookkey > 0 AND @v_printingkey > 0 
		SELECT @v_boundbookdate = dbo.qtitle_get_last_taskdate(@v_bookkey,@v_printingkey,@v_boundbookdatecode) 
   END
  
  -- date required
  SELECT @v_requireddatecode = datetypecode FROM datetype WHERE qsicode = 24
  
  SELECT @v_requireddate = dbo.qproject_get_taskdate(@i_projectkey, @v_requireddatecode, 0)
  
  IF @v_requireddate IS NULL BEGIN
    SELECT @v_count = COUNT(*) FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
    IF @v_count = 1 
	 SELECT @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
	ELSE IF @v_count > 1 
	 SELECT TOP 1 @v_bookkey = bookkey , @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
	ELSE IF @v_count = 0 
		SELECT @v_bookkey = bookkey, @v_printingkey =  printingkey 
		  FROM taqprojectprinting_view WHERE taqprojectkey=@v_printingprojectkey
	 
	IF @v_bookkey > 0 AND @v_printingkey > 0 
		SELECT @v_requireddate = dbo.qtitle_get_last_taskdate(@v_bookkey,@v_printingkey,@v_requireddatecode)
  END
  
  --print 'prodcontact'
  -- Prodcontact 
  SELECT @v_roletypecode = datacode FROM gentables WHERE tableid = 285 AND qsicode = 22 -- Production Manager
  
  IF @v_roletypecode > 0   
	  SELECT @v_globalcontactkey = c.globalcontactkey
	    FROM taqprojectcontact c, taqprojectcontactrole r
	    WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
	  	  c.taqprojectkey = @i_related_projectkey AND
		    r.rolecode = @v_roletypecode
	    
   -- Vendor Information
   SELECT @v_roletypecode = datacode FROM gentables WHERE tableid = 285 and qsicode = 15 -- Vendor
   
   IF @v_roletypecode > 0 BEGIN
	    SELECT @v_vendor_globalcontactkey = c.globalcontactkey, @i_globalcontactrelationshipkey = r.globalcontactrelationshipkey, @v_addresskey=c.addresskey
	      FROM taqprojectcontact c, taqprojectcontactrole r
	      WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
		      c.taqprojectkey = @i_related_projectkey AND
		      r.rolecode = @v_roletypecode
   
      IF @v_vendor_globalcontactkey > 0 BEGIN
		    SELECT @v_vendorname = gc.displayname
		      FROM globalcontact gc
		     WHERE globalcontactkey = @v_vendor_globalcontactkey

		    IF @v_addresskey is not null BEGIN
		      SELECT @v_address1 = address1,@v_address2 = address2, @v_city = city, @v_statecode = statecode, @v_zipcode = zipcode
		        FROM globalcontactaddress
		       WHERE globalcontactkey = @v_vendor_globalcontactkey and globalcontactaddresskey=@v_addresskey
        END
		    ELSE BEGIN
		      SELECT @v_address1 = address1,@v_address2 = address2, @v_city = city, @v_statecode = statecode, @v_zipcode = zipcode
		        FROM globalcontactaddress
		       WHERE globalcontactkey = @v_vendor_globalcontactkey 
		 	  END	
		 
		    SELECT  @i_contactrelationshipcode1 = datacode from gentables where tableid=519 and qsicode=2 --employee
		    SELECT  @i_contactrelationshipcode2 = datacode from gentables where tableid=519 and qsicode=3 --corporate
		
		    SELECT @i_attncontactkey = globalcontactkey2, @v_vendorattn = globalcontactname2 from globalcontactrelationship 
		    where globalcontactrelationshipkey = @i_globalcontactrelationshipkey and contactrelationshipcode1=@i_contactrelationshipcode1 and contactrelationshipcode2=@i_contactrelationshipcode2
		
		    IF coalesce(@i_attncontactkey,0)<>0 
			    SELECT @v_vendorattn = displayname from globalcontact where globalcontactkey = @i_attncontactkey
			
		    SELECT @v_state = datadesc FROM gentables WHERE tableid = 160 and datacode = @v_statecode
			  
		    SELECT @v_vendorid = textvalue FROM globalcontactmisc WHERE misckey IN 
		     (SELECT misckey FROM bookmiscitems WHERE qsicode = 13)	 AND globalcontactkey = @v_vendor_globalcontactkey
	    END
	    ELSE BEGIN  --vendorkey does not allow nulls on the gpo table
	      SET @o_error_code = -1
	      SET @o_error_desc = 'Participant with role of Vendor required for insert to gpo table.'
	      RETURN
	    END
    END
  
  -- maxshiptovendorkey
  SELECT @v_number_of_shiplocations = COUNT(*)
    FROM taqprojectcontact c, taqprojectcontactrole r
	  WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
		  c.taqprojectkey = @i_projectkey AND
		  r.rolecode in (SELECT datacode FROM gentables WHERE tableid = 285 and qsicode in (17,18))
		  
  -- sapstatus - determined at future date when HMH is implemented
  
  -- potypekey
  SELECT @v_potypekey = g.externalcode
  FROM taqproject t, gentables g
  WHERE t.taqprojecttype = g.datacode
    AND g.tableid = 521  -- Project Type
    AND t.taqprojectkey = @i_related_projectkey
     
  IF @v_potypekey = 0 OR @v_potypekey IS NULL 
    SET @v_potypekey = 1  --Regular PO
      
  -- create gpo row
  IF @v_count_gpo = 0 BEGIN
      --print 'inserting gpo row......'
      
      --print '@v_gpokey: ' + CONVERT(VARCHAR, @v_gpokey)
      --print '@v_gponumber ' + @v_gponumber
      --print '@v_gpochangenumber ' + CONVERT(VARCHAR, @v_gpochangenumber)
      ----print '@v_gpodate ' + @v_gpodate
      --print '@v_gpostatus ' + @v_gpostatus
      ----print '@v_warehousedate ' + @v_warehousedate
      --print '@v_globalcontactkey ' + CONVERT(VARCHAR,@v_globalcontactkey)
      ----print '@v_boundbookdate ' + @v_boundbookdate
      ----print '@v_requireddate ' + @v_requireddate
      --print '@v_taqprojecttitle ' + @v_taqprojecttitle
      --print '@v_vendor_globalcontactkey ' + CONVERT(VARCHAR,@v_vendor_globalcontactkey)
      --print '@v_vendorname ' + @v_vendorname
      --print '@v_address1 ' + @v_address1
      --print '@v_address2 ' + @v_address2
      --print '@v_city ' + @v_city
      --print '@v_state ' + @v_state
      --print '@v_zipcode ' + @v_zipcode
      --print '@v_number_of_shiplocations ' + CONVERT(VARCHAR,@v_number_of_shiplocations)
      --print '@v_potypekey ' + CONVERT(VARCHAR,@v_potypekey)
      --print '@v_vendorid ' + @v_vendorid     
      
	  INSERT INTO gpo (gpokey,gponumber,gpochangenum,gpodate,gpostatus,warehousedate,prodcontact,
		lastuserid,lastmaintdate,boundbookdate,daterequired,gpodescription,vendorkey,vendorname,vendoraddress1,
		vendoraddress2,vendorattn, vendorcity,vendorstate,vendorzipcode,vendorid,maxshiptovendorkey,potypekey,vendorid2)
		VALUES (@v_gpokey,@v_gponumber,@v_gpochangenumber,@v_gpodate, @v_gpostatus,@v_warehousedate,@v_globalcontactkey,
		  @lastuserid_var,getdate(),@v_boundbookdate,@v_requireddate,@v_taqprojecttitle,@v_vendor_globalcontactkey,@v_vendorname,@v_address1,
		  @v_address2,@v_vendorattn,@v_city,@v_state,@v_zipcode,@v_vendorid,@v_number_of_shiplocations,@v_potypekey,@v_vendorid2)
  END
  ELSE BEGIN
    SELECT @v_prev_gpostatus = gpostatus
      FROM gpo
     WHERE gpokey = @v_gpokey
    
    IF @v_gpostatus = @v_prev_gpostatus BEGIN
		UPDATE gpo
		   SET gponumber = @v_gponumber,
			   gpochangenum = @v_gpochangenumber,
			   --gpostatus = @v_gpostatus,
			   warehousedate = @v_warehousedate,
			   prodcontact = @v_globalcontactkey,
			   lastuserid = @lastuserid_var,
			   lastmaintdate = getdate(),
			   boundbookdate = @v_boundbookdate,
			   daterequired = @v_requireddate,
			   gpodescription = @v_taqprojecttitle,
			   vendorkey = @v_vendor_globalcontactkey,
			   vendorname = @v_vendorname,
			   vendoraddress1 = @v_address1,
			   vendoraddress2 = @v_address2,
			   vendorcity = @v_city,
			   vendorstate = @v_state,
			   vendorzipcode = @v_zipcode,
			   vendorid = @v_vendorid,
			   vendorattn = @v_vendorattn,
			   maxshiptovendorkey = @v_number_of_shiplocations,
			   potypekey = @v_potypekey,
			   vendorid2 = @v_vendorid2
		 WHERE gpokey = @v_gpokey
	END
	ELSE BEGIN
		UPDATE gpo
		   SET gponumber = @v_gponumber,
			   gpochangenum = @v_gpochangenumber,
			   gpostatus = @v_gpostatus,
			   warehousedate = @v_warehousedate,
			   prodcontact = @v_globalcontactkey,
			   lastuserid = @lastuserid_var,
			   lastmaintdate = getdate(),
			   boundbookdate = @v_boundbookdate,
			   daterequired = @v_requireddate,
			   gpodescription = @v_taqprojecttitle,
			   vendorkey = @v_vendor_globalcontactkey,
			   vendorname = @v_vendorname,
			   vendoraddress1 = @v_address1,
			   vendoraddress2 = @v_address2,
			   vendorcity = @v_city,
			   vendorstate = @v_state,
			   vendorzipcode = @v_zipcode,
			   vendorid = @v_vendorid,
			   vendorattn= @v_vendorattn,
			   maxshiptovendorkey = @v_number_of_shiplocations,
			   potypekey = @v_potypekey,
			   vendorid2=@v_vendorid2
		 WHERE gpokey = @v_gpokey
	
	END		   
  END 
	    	          
      
  EXEC dbo.qpo_generate_po_details @i_projectkey, @i_related_projectkey, @v_gpokey, @i_report_detail_type, @i_lastuserid, @o_error_code output, @o_error_desc output
  IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error generating PO Details. ' + @o_error_desc
	  RETURN
  END 	  
      
  EXEC dbo.qpo_generate_gpoinstructions @i_projectkey,@i_related_projectkey,@v_gpokey ,@i_lastuserid,  @o_error_code output, @o_error_desc output  
  IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error generating PO Instructions. ' + @o_error_desc
	  RETURN
  END 	  

  EXEC dbo.qpo_generate_gposhiptovendor @i_projectkey,@i_related_projectkey,@v_gpokey ,@i_lastuserid,  @o_error_code output, @o_error_desc output    
  IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error generating PO Ship to Vendor. ' + @o_error_desc
	  RETURN
  END
  
  EXEC dbo.qpo_generate_gpoimportvendors @i_related_projectkey,@v_gpokey ,@i_lastuserid,  @o_error_code output, @o_error_desc output    
  IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error generating PO Import Vendors. ' + @o_error_desc
	  RETURN
  END 	  
   
  -- Create Date - set to system date (this should not be deleted when generate PO routine runs). Gets set once and not updated after that.   
  SELECT @v_count_task = COUNT (*) 
  FROM taqprojecttask 
  WHERE datetypecode = @v_datetypecode_CreateDate AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0

  IF @v_count_task = 0 BEGIN
	 exec get_next_key 'taqprojecttask', @v_newkey output
	 
	 insert into taqprojecttask
			(taqtaskkey, taqprojectkey, 
			datetypecode, 
			activedate, 
			keyind, 
			originaldate, 		
			lastuserid, lastmaintdate)	
	  VALUES (@v_newkey, @i_projectkey, @v_datetypecode_CreateDate, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE()) 		
  END
  
  -- PO Date - set to system date (this should happen in generate PO routine so it is updated every time the routine runs)  
  SELECT @v_count_task = COUNT (*) 
  FROM taqprojecttask 
  WHERE datetypecode = @v_datetypecode_PODate AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
	  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
	  RETURN
  END 	  
  	  
  IF @v_count_task = 0 BEGIN
	 exec get_next_key 'taqprojecttask', @v_newkey output
	 
	 insert into taqprojecttask
			(taqtaskkey, taqprojectkey, 
			datetypecode, 
			activedate, 
			keyind, 
			originaldate, 		
			lastuserid, lastmaintdate)	
	  VALUES (@v_newkey, @i_projectkey, @v_datetypecode_PODate, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE())   
  END 
  ELSE BEGIN
	 UPDATE taqprojecttask 
	 SET activedate = GETDATE(), lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	 WHERE datetypecode = @v_datetypecode_PODate AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
  END	  
  
  -- Set the Status on PO Report to Pending - if this is the first time generating details
  IF @v_taqprojectstatuscode = 0
  BEGIN
    SELECT @v_taqprojectstatuscode = datacode 
    FROM gentables 
    WHERE tableid = 522 AND qsicode = 4
  
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'Error accessing gentables table 522 (' + cast(@error_var AS VARCHAR) + ').'
	    RETURN
    END
    
    UPDATE taqproject
    SET taqprojectstatuscode = @v_taqprojectstatuscode, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
    WHERE taqprojectkey = @i_projectkey
  END
  
  SELECT @v_po_itemtypecode_CurrentReport = searchitemcode, @v_po_usageclasscode_CurrentReport = usageclasscode 
  FROM coreprojectinfo 
  WHERE projectkey = @i_projectkey
  
  -- Copy the 1st PO number of the 1st created report to the Purchase Order.
  SELECT  @v_count = COUNT(*)
  FROM projectrelationshipview v, taqproject p, coreprojectinfo c
  WHERE v.relatedprojectkey = p.taqprojectkey
      AND v.taqprojectkey = c.projectkey
	  AND v.taqprojectkey = @i_related_projectkey
	  AND p.searchitemcode = c.searchitemcode
	  AND p.usageclasscode <> c.usageclasscode
	  
   IF @v_count = 1 BEGIN 
    SELECT @v_ponumber_from_report = productnumber
    FROM projectrelationshipview v, taqproject p, coreprojectinfo c, taqproductnumbers n
    WHERE v.relatedprojectkey = p.taqprojectkey
      AND v.taqprojectkey = c.projectkey
	  AND v.relatedprojectkey = n.taqprojectkey
	  AND v.taqprojectkey = @i_related_projectkey
	  AND p.searchitemcode = c.searchitemcode
	  AND p.usageclasscode <> c.usageclasscode
	  AND n.productidcode in (select datacode from gentables where tableid = 594 and qsicode = 7)	--PO #
	  
    UPDATE taqproductnumbers
    SET productnumber = @v_ponumber_from_report 
    WHERE taqprojectkey = @i_related_projectkey 	
    AND productidcode in (select datacode from gentables where tableid = 594 and qsicode = 7)  
  END	    
  
  --If other PO reports exist for this Purchase Order that are Approved
  --        Change existing PO Report status to Amended (this is currently being done)
  --        Auto generate\update Amended Date on the AMENDED PO Report 
  --        Set the status on the Purchase Order Summary to 'Amended; PO Report Pending'
  --    Else
  --        PO Summary Status = ‘Proforma Pending’ if Proforma; ‘Final Pending’ if Final
  
  SELECT  @v_count = COUNT(*)
  FROM projectrelationshipview v, taqproject p, coreprojectinfo c, taqproductnumbers n
  WHERE v.relatedprojectkey = p.taqprojectkey
      AND v.taqprojectkey = c.projectkey
	  AND v.relatedprojectkey = n.taqprojectkey
	  AND v.taqprojectkey = @i_related_projectkey
	  AND p.searchitemcode = c.searchitemcode
	  AND p.usageclasscode <> c.usageclasscode
	  AND n.productidcode in (select datacode from gentables where tableid = 594 and qsicode = 13)	--PO Amendment #
	  AND p.taqprojectstatuscode = (select datacode from gentables where tableid = 522 and qsicode = 13)	--Sent to Vendor
    
  IF @v_count > 0 BEGIN
	SELECT TOP 1 @v_poreportprojectkey_for_amendment = n.taqprojectkey
	FROM projectrelationshipview v, taqproject p, coreprojectinfo c, taqproductnumbers n
	WHERE v.relatedprojectkey = p.taqprojectkey
	    AND v.taqprojectkey = c.projectkey
		AND v.relatedprojectkey = n.taqprojectkey
		AND v.taqprojectkey = @i_related_projectkey
		AND p.searchitemcode = c.searchitemcode
		AND p.usageclasscode <> c.usageclasscode
		AND n.productidcode in (select datacode from gentables where tableid = 594 and qsicode = 13)
		AND p.taqprojectstatuscode = (select datacode from gentables where tableid = 522 and qsicode = 13)	
	ORDER BY cast(coalesce(productnumber, '0') AS INTEGER) DESC    
	
	  -- Change existing PO Report status to Amended
	  SELECT @v_taqprojectstatuscode = datacode 
	  FROM gentables 
	  WHERE tableid = 522 AND qsicode = 11
	  
	  SELECT @error_var = @@ERROR
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error accessing gentables table 522 (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
	  END
	    
	  UPDATE taqproject
	  SET taqprojectstatuscode = @v_taqprojectstatuscode, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	  WHERE taqprojectkey = @v_poreportprojectkey_for_amendment	
	  
	  UPDATE gpo
	  SET gpostatus = 'A',
	  	  lastuserid = @lastuserid_var,
		  lastmaintdate = getdate()
	  WHERE gpokey = @v_poreportprojectkey_for_amendment	
		  
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to set gpostatus on gpo (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END 	
	  
	  -- Auto generate\update Amended Date on the AMENDED PO Report 
	  SELECT @v_count_task = COUNT (*) 
	  FROM taqprojecttask 
	  WHERE datetypecode = @v_datetypecode_AmendedDate AND 
		  taqprojectkey = @v_poreportprojectkey_for_amendment AND
		  COALESCE(bookkey,0) <= 0 AND
		  COALESCE(taqelementkey, 0) = 0  
		  
	  SELECT @error_var = @@ERROR
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
	  END 	  
		  
	  IF @v_count_task = 0 BEGIN
		 exec get_next_key 'taqprojecttask', @v_newkey output
	 
		 insert into taqprojecttask
				(taqtaskkey, taqprojectkey, 
				datetypecode, 
				activedate, 
				keyind, 
				originaldate, 		
				lastuserid, lastmaintdate)	
		  VALUES (@v_newkey, @v_poreportprojectkey_for_amendment, @v_datetypecode_AmendedDate, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE())   
	  END 
	  ELSE BEGIN
		 UPDATE taqprojecttask 
		 SET activedate = GETDATE(), lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
		 WHERE datetypecode = @v_datetypecode_AmendedDate AND 
		  taqprojectkey = @v_poreportprojectkey_for_amendment AND
		  COALESCE(bookkey,0) <= 0 AND
		  COALESCE(taqelementkey, 0) = 0  
	  END	  
	  
	 -- Set the status on the Purchase Order Summary to 'Amended; PO Report Pending'	  
	  SELECT @v_taqprojectstatuscode = datacode 
	  FROM gentables 
	  WHERE tableid = 522 AND qsicode = 14
	  
	  SELECT @error_var = @@ERROR
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error accessing gentables table 522 (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN
	  END
	    
	  UPDATE taqproject
	  SET taqprojectstatuscode = @v_taqprojectstatuscode, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	  WHERE taqprojectkey = @i_related_projectkey		 
	 
  END
  ELSE BEGIN
	 --  PO Summary Status = ‘Proforma Pending’ if Proforma; ‘Final Pending’ if Final
	  SELECT  @v_count = COUNT(*)
	  FROM projectrelationshipview v, taqproject p
	  WHERE v.relatedprojectkey = p.taqprojectkey
		  AND v.taqprojectkey = @i_related_projectkey
		  AND p.searchitemcode = @v_po_itemtypecode_CurrentReport
		  AND p.usageclasscode = @v_po_usageclasscode_CurrentReport
		  AND p.taqprojectstatuscode = (select datacode from gentables where tableid = 522 and qsicode = 4)	 -- Pending	 
	 
	  IF @v_count = 1 BEGIN	  
		  IF @v_qsicode_project = 42 BEGIN  -- Proforma PO Report	  
			  SELECT @v_taqprojectstatuscode = datacode 
			  FROM gentables 
			  WHERE tableid = 522 AND qsicode = 6
		  	  
			  UPDATE taqproject 
			  SET taqprojectstatuscode = @v_taqprojectstatuscode, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
			  WHERE taqprojectkey = @i_related_projectkey  
		  END
		  ELSE IF @v_qsicode_project = 43 BEGIN  -- Final PO Report
			  SELECT @v_taqprojectstatuscode = datacode 
			  FROM gentables 
			  WHERE tableid = 522 AND qsicode = 8	  
			  
			  UPDATE taqproject 
			  SET taqprojectstatuscode = @v_taqprojectstatuscode, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
			  WHERE taqprojectkey = @i_related_projectkey  
		  END  	 	 
	  END
  END  
			  
END


GO

GRANT EXECUTE ON [dbo].[qpo_generate_po_report] TO [public] AS [dbo]
GO


