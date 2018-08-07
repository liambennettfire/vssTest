if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_apply_specificationtemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_apply_specificationtemplate
GO

CREATE PROCEDURE qspec_apply_specificationtemplate
 (@i_projectkey     integer,
  @i_specificationtemplatekey integer, 
  @i_taqprojectformatkey integer,
  @i_itemtype     integer,
  @i_usageclass   integer,
  @i_userid        VARCHAR(30),
  @i_actionvalue integer,  
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qspec_apply_specificationtemplate
**  Desc: This stored procedure applies the P&L spec items for given version/format.
**       @i_actionvalue = 1 - Overwrite Existing data
**				   = 2 - Leave Existing Data, Add New Values
**  Auth: Uday A. Khisty
**  Date: June 5, 2014
******************************************************************************************************************
**  Change History
******************************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------------------
**  04/14/16     Kusum       Case 37540 - Issues with copying component notes when apply spec template
**
*****************************************************************************************************************/

  
DECLARE
  @v_isopentrans TINYINT,
  @v_error    INT,
  @v_rowcount INT,
  @v_categorykey_template INT,
  @v_categorykey_project INT,  
  @v_itemkey INT,  
  @v_notekey INT,  
  @v_taqversionkey INT,
  @v_taqversionspecategorykey_new INT,
  @v_taqversionspecitemkey_new INT,
  @v_taqversionspecnotekey_new INT,
  @v_maxsortoder_notes INT,
  @v_plstage INT,
  @v_versionkey INT,
  @v_itemtype_template INT,
  @v_usageclass_template INT,
  @v_qsicode_template INT,
  @v_qsicode_project INT,
  @v_isApplySpecficationByFormat INT,
  @v_mediatypecode_project INT,
  @v_mediatypesubcode_project INT,  
  @v_taqprojectformatkey_template INT,
  @v_Is_Destination_Printing INT,
  @v_Is_Destination_PurchaseOrder INT, 
  @v_clientoption_Production_On_Web INT,
  @v_itemtype_Printing INT,
  @v_itemtype_Title INT,
  @v_summary_itemcategorycode INT,
  @v_exists_summary_component INT,
  @v_summary_ItemcategorycodeWithDescription VARCHAR(300),
  @v_itemcategorycode INT,
  @v_speccategorydescription VARCHAR(255),
  @v_vendorcontactkey INT,
  @v_globalcontactkey_for_vendor INT,
  @v_copynextprtgind INT
  
BEGIN

    SELECT @v_clientoption_Production_On_Web = COALESCE(optionvalue, 0) 
    FROM clientoptions where optionid = 117
 
	IF @v_clientoption_Production_On_Web = 0 BEGIN
	  RETURN
	END
 
 	SET @v_isopentrans = 0
	SET @o_error_code = 0
	SET @o_error_desc = ''
    SET @v_maxsortoder_notes = 0
    SET @v_isApplySpecficationByFormat = 0
    SET @v_Is_Destination_Printing = 0
    SET @v_Is_Destination_PurchaseOrder = 0
    SET @v_exists_summary_component = 0
    SET @v_globalcontactkey_for_vendor = NULL
    
	IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
		SET @o_error_desc = 'Invalid projectkey.'
		GOTO RETURN_ERROR
	END
	 
	SELECT @v_plstage = plstagecode, @v_versionkey = taqversionkey 
	FROM taqversionformat 
	WHERE taqprojectkey = @i_projectkey AND  taqprojectformatkey = @i_taqprojectformatkey
 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
		RETURN  -- Not always guaranteed to have a format row (because of client option 119 that inserts row in code)
	END  

  --PRINT '--- INSIDE qspec_apply_specificationtemplate ---'
  --PRINT '@i_projectkey: ' + convert(varchar, @i_projectkey)	
  --PRINT '@i_taqprojectformatkey: ' + convert(Varchar, @i_taqprojectformatkey)  
  --PRINT '@v_plstage: ' + convert(varchar, @v_plstage)
  --PRINT '@v_versionkey: ' + convert(varchar, @v_versionkey)
  --PRINT '@i_itemtype: ' + convert(varchar, @i_itemtype)
  --PRINT '@i_usageclass: ' + convert(Varchar, @i_usageclass)
  --PRINT '@i_actionvalue: ' + convert(varchar, @i_actionvalue)
  --PRINT '@i_specificationtemplatekey: ' + convert(varchar, @i_specificationtemplatekey)
	
	SELECT @v_itemtype_template = searchitemcode, @v_usageclass_template = usageclasscode 
	FROM coreprojectinfo  
	WHERE projectkey = @i_specificationtemplatekey
 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not access coreprojectinfo to get itemtype and usageclass.'
	 GOTO RETURN_ERROR
	END  	
	
	SELECT @v_qsicode_template = COALESCE(qsicode, 0)
	FROM subgentables  
	WHERE tableid = 550 AND datacode = @v_itemtype_template AND datasubcode = @v_usageclass_template
 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not access subgentables 550 to get qsicode.'
	 GOTO RETURN_ERROR
	END  
	
	SELECT @v_qsicode_project = COALESCE(qsicode, 0)
	FROM subgentables  
	WHERE tableid = 550 AND datacode = @i_itemtype AND datasubcode = @i_usageclass
 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not access subgentables 550 to get qsicode.'
	 GOTO RETURN_ERROR
	END 	
	
	SELECT @v_summary_itemcategorycode = datacode, @v_summary_ItemcategorycodeWithDescription = convert(VARCHAR,COALESCE(datacode, -99)) + convert(VARCHAR,COALESCE(datadesc, ''))
	FROM gentables  
	WHERE tableid = 616 AND qsicode = 1
 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not access gentables 616 to get datacode based on qsicode 1.'
	 GOTO RETURN_ERROR
	END  	
	
  --PRINT '@v_qsicode_template: ' + convert(varchar, @v_qsicode_template)
  --PRINT '@v_qsicode_project: ' + convert(varchar, @v_qsicode_project)
	
	IF @v_qsicode_template = 29 OR (@v_qsicode_project = 40 AND @v_qsicode_template = 1) BEGIN
		SET @v_isApplySpecficationByFormat = 1
		SELECT @v_mediatypecode_project = mediatypecode, @v_mediatypesubcode_project = mediatypesubcode
		FROM taqversionformat
		WHERE taqprojectformatkey = @i_taqprojectformatkey
		
		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
			RETURN  -- Not always guaranteed to have a format row (because of client option 119 that inserts row in code)
		END  		
		
		SELECT @v_taqprojectformatkey_template = taqprojectformatkey
		FROM taqversionformat
		WHERE mediatypecode = @v_mediatypecode_project AND 	mediatypesubcode = @v_mediatypesubcode_project
		AND taqprojectkey = @i_specificationtemplatekey
		
		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
			RETURN  -- Not always guaranteed to have a format row (because of client option 119 that inserts row in code)
		END 

    --PRINT '@v_mediatypecode_project: ' + convert(Varchar, @v_mediatypecode_project)
    --PRINT '@v_mediatypesubcode_project: ' + convert(Varchar, @v_mediatypesubcode_project)
    --PRINT '@v_taqprojectformatkey_template: ' + convert(varchar, @v_taqprojectformatkey_template)
	END
	
	IF @v_qsicode_project = 40 BEGIN
		SET @v_Is_Destination_Printing = 1
		SET @v_itemtype_Printing = @i_itemtype
		
		SELECT @v_itemtype_Title = datacode 
		FROM gentables 
		WHERE tableid = 550 AND qsicode = 1
	END		
	ELSE IF @v_qsicode_project = 41 BEGIN
		SET @v_Is_Destination_PurchaseOrder = 1
		
		IF EXISTS(SELECT globalcontactkey FROM taqprojectcontactrole r, taqprojectcontact c
				  WHERE r.taqprojectcontactkey = c.taqprojectcontactkey AND r.taqprojectkey = @i_projectkey
				  AND r.rolecode IN (SELECT datacode FROM gentables WHERE tableid=285 AND qsicode=15) AND globalcontactkey IS NOT NULL) BEGIN
				  
			SELECT TOP(1) @v_globalcontactkey_for_vendor = globalcontactkey FROM taqprojectcontactrole r, taqprojectcontact c
		    WHERE r.taqprojectcontactkey = c.taqprojectcontactkey AND
		          r.taqprojectkey = @i_projectkey AND 
		          r.rolecode IN (SELECT datacode FROM gentables WHERE tableid=285 AND qsicode=15) AND globalcontactkey IS NOT NULL		
		END
	END		
	

-- ***** BEGIN TRANSACTION ****  
 BEGIN TRANSACTION

 SET @v_isopentrans = 1  

 IF @i_actionvalue = 1 OR @v_isApplySpecficationByFormat = 1
 BEGIN		
   
  IF EXISTS (SELECT *
			 FROM taqversionspeccategory
			 WHERE taqprojectkey = @i_projectkey AND 
				   plstagecode = @v_plstage AND 
				   taqversionkey = @v_versionkey AND 
				   taqversionformatkey = @i_taqprojectformatkey AND
				   itemcategorycode = @v_summary_itemcategorycode) BEGIN
				   
	         SET @v_exists_summary_component = 1        	
   END				   

				   
-- taqversionspeccategory and taqversionspecitems
  --PRINT 'Deleting taqversionspeccategory and taqversionspecitems...'

  DECLARE speccategory_cursor_delete CURSOR FOR
	SELECT taqversionspecategorykey
	FROM taqversionspeccategory
	WHERE taqprojectkey = @i_projectkey AND 
		  plstagecode = @v_plstage AND 
		  taqversionkey = @v_versionkey AND 
		  taqversionformatkey = @i_taqprojectformatkey AND
		  itemcategorycode <> @v_summary_itemcategorycode

	OPEN speccategory_cursor_delete

	FETCH speccategory_cursor_delete
	INTO @v_categorykey_project

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

    --PRINT 'DELETE cursor - taqversionspecategorykey: ' + convert(varchar, @v_categorykey_project)
	
		DELETE FROM taqversionspecitems
		WHERE taqversionspecategorykey = @v_categorykey_project
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END  
		
		DELETE FROM taqversionspeccategory
		WHERE taqversionspecategorykey = @v_categorykey_project
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END  
		
		DELETE FROM taqversionspecnotes
		WHERE taqversionspecategorykey = @v_categorykey_project
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			SET @o_error_desc = 'Error deleting from taqversionspecnotes table (Error ' + cast(@v_error AS VARCHAR) + ').'
			GOTO RETURN_ERROR
		END  		
		
		FETCH speccategory_cursor_delete
		INTO @v_categorykey_project
	END

	CLOSE speccategory_cursor_delete
	DEALLOCATE speccategory_cursor_delete 
	
  -- taqversionspeccategory and taqversionspecitems
  --PRINT 'Inserting taqversionspeccategory and taqversionspecitems...'

	IF @v_isApplySpecficationByFormat = 1 BEGIN
	  DECLARE speccategory_cursor_insert CURSOR FOR
		SELECT taqversionspecategorykey, itemcategorycode, speccategorydescription, vendorcontactkey
		FROM taqversionspeccategory
		WHERE taqprojectkey = @i_specificationtemplatekey AND taqversionformatkey = @v_taqprojectformatkey_template
		  AND relatedspeccategorykey IS NULL
    END
	ELSE BEGIN
	  DECLARE speccategory_cursor_insert CURSOR FOR
		SELECT taqversionspecategorykey, itemcategorycode, speccategorydescription, vendorcontactkey
		FROM taqversionspeccategory
		WHERE taqprojectkey = @i_specificationtemplatekey
		  AND relatedspeccategorykey IS NULL
	END

	OPEN speccategory_cursor_insert

	FETCH speccategory_cursor_insert
	INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	
    --PRINT 'INSERT cursor - taqversionspecategorykey: ' + convert(varchar, @v_categorykey_template)
    --PRINT '@v_itemcategorycode: ' + convert(varchar, @v_itemcategorycode) + ' ' + @v_speccategorydescription
    --PRINT '@v_vendorcontactkey: ' + convert(varchar, @v_vendorcontactkey)
	  
	  IF @v_exists_summary_component = 1 BEGIN
	      IF @v_summary_ItemcategorycodeWithDescription = convert(VARCHAR,COALESCE(@v_itemcategorycode, -99)) + convert(VARCHAR,COALESCE(@v_speccategorydescription, '')) BEGIN
			  FETCH speccategory_cursor_insert
			  INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
			  CONTINUE
		  END
	  END 
	  
      EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecategorykey_new OUT	
      
        IF @v_Is_Destination_PurchaseOrder = 1 BEGIN
			SET @v_vendorcontactkey = @v_globalcontactkey_for_vendor
        END
      
		INSERT INTO taqversionspeccategory
				   (taqversionspecategorykey
				   ,taqprojectkey
				   ,plstagecode
				   ,taqversionkey
				   ,taqversionformatkey
				   ,itemcategorycode
				   ,speccategorydescription
				   ,scaleprojecttype
				   ,vendorcontactkey
				   ,lastuserid
				   ,lastmaintdate
				   ,finishedgoodind
				   ,sortorder
				   ,deriveqtyfromfgqty
				   ,spoilagepercentage)
				SELECT            
				   @v_taqversionspecategorykey_new
				   ,@i_projectkey
				   ,@v_plstage
				   ,@v_versionkey
				   ,@i_taqprojectformatkey
				   ,itemcategorycode
				   ,speccategorydescription
				   ,scaleprojecttype
				   ,@v_vendorcontactkey
				   ,@i_userid
				   ,getdate()
				   ,finishedgoodind
				   ,sortorder
				   ,deriveqtyfromfgqty
				   ,spoilagepercentage
		FROM taqversionspeccategory		   
		WHERE taqversionspecategorykey = @v_categorykey_template
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Could not access taqversionspeccategory table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
			', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
			', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + ').'
			GOTO RETURN_ERROR			
		END				
			      
      -- Spec Items
	IF @v_Is_Destination_Printing = 1 BEGIN      
	  DECLARE specitems_cursor_insert CURSOR FOR
		SELECT DISTINCT taqversionspecitemkey
		FROM taqversionspecitems i 
		  INNER JOIN subgentables s ON i.itemcode = s.datasubcode
		  INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
		  INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
		WHERE s.tableid = 616 AND		
		  gi.itemtypecode IN(@v_itemtype_Printing, @v_itemtype_Title) AND		
		  c.taqprojectkey = @i_specificationtemplatekey AND 
		  i.taqversionspecategorykey = @v_categorykey_template     
    END
    ELSE BEGIN    
	  DECLARE specitems_cursor_insert CURSOR FOR
		SELECT DISTINCT taqversionspecitemkey
		FROM taqversionspecitems i 
		  INNER JOIN subgentables s ON i.itemcode = s.datasubcode
		  INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
		  INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
		WHERE s.tableid = 616 AND		
		  gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) AND		
		  c.taqprojectkey = @i_specificationtemplatekey AND 
		  i.taqversionspecategorykey = @v_categorykey_template    
    END  

	  
		OPEN specitems_cursor_insert
	   
		FETCH specitems_cursor_insert
		INTO @v_itemkey

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
	 		EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecitemkey_new OUT	
	 		
				INSERT INTO taqversionspecitems
						   (taqversionspecitemkey
						   ,taqversionspecategorykey
						   ,itemcode
						   ,itemdetailcode
						   ,itemdetailsubcode
						   ,itemdetailsub2code
						   ,quantity
						   ,validforprtgscode
						   ,description
						   ,description2
						   ,decimalvalue
						   ,unitofmeasurecode
						   ,lastuserid
						   ,lastmaintdate)
				   SELECT  @v_taqversionspecitemkey_new
						   ,@v_taqversionspecategorykey_new
						   ,itemcode
						   ,itemdetailcode
						   ,itemdetailsubcode
						   ,itemdetailsub2code						   
						   ,quantity
						   ,validforprtgscode
						   ,description
						   ,description2
						   ,decimalvalue
						   ,unitofmeasurecode
						   ,@i_userid
						   ,getdate()
				FROM taqversionspecitems  
				WHERE taqversionspecitemkey = @v_itemkey  		
				
				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
					', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
					', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + ').'
				  GOTO RETURN_ERROR					
				END							
			
			FETCH specitems_cursor_insert
			INTO @v_itemkey
		END

		CLOSE specitems_cursor_insert
		DEALLOCATE specitems_cursor_insert 	 	
		
      SET @v_maxsortoder_notes = 0			
	  SELECT @v_maxsortoder_notes = COALESCE(MAX(sortorder), 0) + 1
	  FROM taqversionspecnotes 
	  WHERE taqversionspecategorykey = @v_categorykey_project		
		-- Spec Notes
	  DECLARE specnotes_cursor_insert CURSOR FOR
		SELECT taqversionspecnotekey, COALESCE(copynextprtgind,1)
		FROM taqversionspecnotes
		WHERE taqversionspecategorykey = @v_categorykey_template

		OPEN specnotes_cursor_insert

		FETCH specnotes_cursor_insert
		INTO @v_notekey, @v_copynextprtgind

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF @v_copynextprtgind = 0 AND @v_qsicode_template <> 44 --Copy all notes from specification template regardless of copynextprtgind value 
			BEGIN
				FETCH specnotes_cursor_insert
				INTO @v_notekey, @v_copynextprtgind
				CONTINUE
			END
	 		EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecnotekey_new OUT	
			
				INSERT INTO taqversionspecnotes
						   (taqversionspecnotekey
						   ,taqversionspecategorykey
						   ,text
						   ,showonpoind
						   ,copynextprtgind
						   ,sortorder
						   ,lastuserid
						   ,lastmaintdate)
				SELECT     @v_taqversionspecnotekey_new
						   ,@v_taqversionspecategorykey_new
						   ,text
						   ,showonpoind
						   ,copynextprtgind
						   ,@v_maxsortoder_notes
						   ,@i_userid
						   ,getdate()
				FROM taqversionspecnotes 
				WHERE taqversionspecategorykey = @v_categorykey_template AND  taqversionspecnotekey = @v_notekey   	
						
			  SELECT @v_error = @@ERROR
			  IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Could not access taqversionspecnotes table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
				  ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
				  ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_taqversionspecategorykey_new AS VARCHAR) +  ').'					
			    GOTO RETURN_ERROR
			  END				  	
			  	
              SET @v_maxsortoder_notes = @v_maxsortoder_notes + 1						
			FETCH specnotes_cursor_insert
			INTO @v_notekey, @v_copynextprtgind
		END

		CLOSE specnotes_cursor_insert
		DEALLOCATE specnotes_cursor_insert 	
				
		
		FETCH speccategory_cursor_insert
		INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
	END

	CLOSE speccategory_cursor_insert
	DEALLOCATE speccategory_cursor_insert 	
  END
 ELSE BEGIN	
  
	  --PRINT 'Inserting taqversionspeccategory...'

	  DECLARE speccategory_cursor_insert CURSOR FOR
		SELECT taqversionspecategorykey, vendorcontactkey
		FROM taqversionspeccategory
		WHERE taqprojectkey = @i_specificationtemplatekey
		AND relatedspeccategorykey IS NULL
		AND (LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))))) IN		
						((SELECT LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))))
						  FROM taqversionspeccategory  
								WHERE taqprojectkey = @i_specificationtemplatekey
						)	
			 EXCEPT (SELECT convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))
					 FROM taqversionspeccategory
					 WHERE taqprojectkey = @i_projectkey AND
						   plstagecode  =  @v_plstage AND
						   taqversionkey = @v_versionkey AND
						   taqversionformatkey = @i_taqprojectformatkey AND
						   COALESCE(relatedspeccategorykey,0) = 0						   
					 UNION	   
					 SELECT convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))
					 FROM taqversionspeccategory  WHERE taqversionspecategorykey IN  (SELECT relatedspeccategorykey 
													FROM taqversionspeccategory
													WHERE taqprojectkey = @i_projectkey AND
														  plstagecode  =  @v_plstage AND
														  taqversionkey = @v_versionkey AND
														  taqversionformatkey = @i_taqprojectformatkey AND
														  COALESCE (relatedspeccategorykey, 0) > 0)								   
					  ))			  

		OPEN speccategory_cursor_insert

		FETCH speccategory_cursor_insert
		INTO @v_categorykey_template, @v_vendorcontactkey

		WHILE (@@FETCH_STATUS = 0)
		BEGIN		
		  
		  EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecategorykey_new OUT

      --PRINT 'INSERT cursor - taqversionspecategorykey: ' + convert(varchar, @v_categorykey_template)
      --PRINT '@v_vendorcontactkey: ' + convert(varchar, @v_vendorcontactkey)

          IF @v_Is_Destination_PurchaseOrder = 1 BEGIN
			  SET @v_vendorcontactkey = @v_globalcontactkey_for_vendor
          END		  	  
		  
			INSERT INTO taqversionspeccategory
					   (taqversionspecategorykey
					   ,taqprojectkey
					   ,plstagecode
					   ,taqversionkey
					   ,taqversionformatkey
					   ,itemcategorycode
					   ,speccategorydescription
					   ,scaleprojecttype
					   ,vendorcontactkey
					   ,lastuserid
					   ,lastmaintdate
					   ,sortorder
				       ,deriveqtyfromfgqty
				       ,spoilagepercentage)
					SELECT            
					   @v_taqversionspecategorykey_new
					   ,@i_projectkey
					   ,@v_plstage
					   ,@v_versionkey
					   ,@i_taqprojectformatkey
					   ,itemcategorycode
					   ,speccategorydescription
					   ,scaleprojecttype
					   ,@v_vendorcontactkey
					   ,@i_userid
					   ,getdate()
					   ,sortorder
					   ,deriveqtyfromfgqty
					   ,spoilagepercentage					   
			FROM taqversionspeccategory		   
			WHERE taqversionspecategorykey = @v_categorykey_template		

		    SELECT @v_error = @@ERROR
		    IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Could not access taqversionspeccategory table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
			    ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
			    ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + ').'
			  GOTO RETURN_ERROR
		    END	
		    
		    IF NOT EXISTS(SELECT * 
						  FROM taqversionspeccategory 
						  WHERE taqprojectkey = @i_projectkey AND 
							  plstagecode = @v_plstage AND 
							  taqversionkey = @v_versionkey AND 
							  taqversionformatkey = @i_taqprojectformatkey AND
							  finishedgoodind = 1) BEGIN
								UPDATE taqversionspeccategory SET finishedgoodind = (SELECT finishedgoodind
																					 FROM taqversionspeccategory  						
																					 WHERE taqversionspecategorykey = @v_categorykey_template)	
															  WHERE taqversionspecategorykey =	@v_taqversionspecategorykey_new																				 
							  END			
			  
			FETCH speccategory_cursor_insert
			INTO @v_categorykey_template, @v_vendorcontactkey
		END

		CLOSE speccategory_cursor_insert
		DEALLOCATE speccategory_cursor_insert 	  
		
	    --PRINT 'Inserting taqversionspecitems...'		
				
	  DECLARE speccategory_cursor_insert_outer CURSOR FOR
		SELECT c1.taqversionspecategorykey, c2.taqversionspecategorykey
		FROM taqversionspeccategory c1
		JOIN taqversionspeccategory c2 
		ON LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, ''))))  = LTRIM(RTRIM(convert(VARCHAR,COALESCE(c2.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c2.speccategorydescription, ''))))
		WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
			  c2.taqprojectkey = @i_projectkey AND
			  c2.plstagecode  =  @v_plstage AND
			  c2.taqversionkey = @v_versionkey AND
			  c2.taqversionformatkey = @i_taqprojectformatkey			  

		OPEN speccategory_cursor_insert_outer

		FETCH speccategory_cursor_insert_outer
		INTO @v_categorykey_template, @v_categorykey_project

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
				
		  -- Spec Items
		IF @v_Is_Destination_Printing = 1 BEGIN      
		  DECLARE specitems_cursor_insert CURSOR FOR
			SELECT DISTINCT i.taqversionspecitemkey 
			FROM taqversionspecitems i 
			  INNER JOIN subgentables s ON i.itemcode = s.datasubcode
			  INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
			  INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
			WHERE s.tableid = 616 AND		
			  gi.itemtypecode IN(@v_itemtype_Printing, @v_itemtype_Title) AND		
			  c.taqprojectkey = @i_specificationtemplatekey AND
			  c.taqversionspecategorykey = @v_categorykey_template AND 
			  i.itemcode IN
				((SELECT itemcode FROM taqversionspecitems  
						WHERE  taqversionspecategorykey = @v_categorykey_template
				  )	
			 EXCEPT (SELECT itemcode 
												 FROM taqversionspecitems
												 WHERE taqversionspecategorykey IN (SELECT DISTINCT taqversionspecategorykey
																					FROM taqversionspeccategory
																					WHERE taqprojectkey = @i_projectkey AND
																						   plstagecode  =  @v_plstage AND
																						   taqversionkey = @v_versionkey AND  	
																						   taqversionspecategorykey = @v_categorykey_project))	
				 )			    
		END
		ELSE BEGIN 
		  DECLARE specitems_cursor_insert CURSOR FOR
			SELECT DISTINCT i.taqversionspecitemkey 
			FROM taqversionspecitems i 
			  INNER JOIN subgentables s ON i.itemcode = s.datasubcode
			  INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
			  INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
			WHERE s.tableid = 616 AND		
			  gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) AND		
			  c.taqprojectkey = @i_specificationtemplatekey AND
			  c.taqversionspecategorykey = @v_categorykey_template AND 
			  i.itemcode IN
				((SELECT itemcode FROM taqversionspecitems  
						WHERE  taqversionspecategorykey = @v_categorykey_template
				  )	
			 EXCEPT (SELECT itemcode 
												 FROM taqversionspecitems
												 WHERE taqversionspecategorykey IN (SELECT DISTINCT taqversionspecategorykey
																					FROM taqversionspeccategory
																					WHERE taqprojectkey = @i_projectkey AND
																						   plstagecode  =  @v_plstage AND
																						   taqversionkey = @v_versionkey AND  	
																						   taqversionspecategorykey = @v_categorykey_project))	
				 )				
		END		   	 
		  
			OPEN specitems_cursor_insert
		   
			FETCH specitems_cursor_insert
			INTO @v_itemkey

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
 				EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecitemkey_new OUT	
		 		
					INSERT INTO taqversionspecitems
							   (taqversionspecitemkey
							   ,taqversionspecategorykey
							   ,itemcode
							   ,itemdetailcode
							   ,itemdetailsubcode
							   ,itemdetailsub2code							   
							   ,quantity
							   ,validforprtgscode
							   ,description
							   ,description2
							   ,decimalvalue
							   ,unitofmeasurecode
							   ,lastuserid
							   ,lastmaintdate)
					   SELECT  @v_taqversionspecitemkey_new
							   ,@v_categorykey_project
							   ,itemcode
							   ,itemdetailcode
						       ,itemdetailsubcode
						       ,itemdetailsub2code							   
							   ,quantity
							   ,validforprtgscode
							   ,description
							   ,description2
							   ,decimalvalue
							   ,unitofmeasurecode
							   ,@i_userid
							   ,getdate()
					FROM taqversionspecitems  
					WHERE taqversionspecitemkey = @v_itemkey  	
					
				  SELECT @v_error = @@ERROR
				  IF @v_error <> 0 BEGIN
					SET @o_error_code = -1
					SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
					  ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
					  ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				  END							
				
				FETCH specitems_cursor_insert
				INTO @v_itemkey
			END

			CLOSE specitems_cursor_insert
			DEALLOCATE specitems_cursor_insert 	 	
						
	      -- Spec Notes
	      SET @v_maxsortoder_notes = 0			
		  SELECT @v_maxsortoder_notes = COALESCE(MAX(sortorder), 0) + 1 
		  FROM taqversionspecnotes 
		  WHERE taqversionspecategorykey = @v_categorykey_project	
		  		
		  DECLARE specnotes_cursor_insert CURSOR FOR
			SELECT taqversionspecnotekey, COALESCE(copynextprtgind,1)
			FROM taqversionspecnotes
			WHERE taqversionspecategorykey = @v_categorykey_template
			AND text NOT IN (SELECT DISTINCT text 
							 FROM taqversionspecnotes 
							 WHERE taqversionspecategorykey = @v_categorykey_project)
            ORDER BY sortorder ASC, lastmaintdate ASC						 

			OPEN specnotes_cursor_insert

			FETCH specnotes_cursor_insert
			INTO @v_notekey, @v_copynextprtgind

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF @v_copynextprtgind = 0 
				BEGIN
					FETCH specnotes_cursor_insert
					INTO @v_notekey, @v_copynextprtgind
					CONTINUE
				END
 				
				EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecnotekey_new OUT	
					INSERT INTO taqversionspecnotes
							   (taqversionspecnotekey
							   ,taqversionspecategorykey
							   ,text
							   ,showonpoind
							   ,copynextprtgind
							   ,sortorder
							   ,lastuserid
							   ,lastmaintdate)
					SELECT     @v_taqversionspecnotekey_new
							   ,@v_categorykey_project
							   ,text
							   ,showonpoind
							   ,copynextprtgind
							   ,@v_maxsortoder_notes
							   ,@i_userid
							   ,getdate()
					FROM taqversionspecnotes 
					WHERE taqversionspecategorykey = @v_categorykey_template AND  taqversionspecnotekey = @v_notekey   	
							
				  SELECT @v_error = @@ERROR
				  IF @v_error <> 0 BEGIN
					SET @o_error_code = -1
					SET @o_error_desc = 'Could not access taqversionspecnotes table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
					  ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
					  ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_categorykey_project AS VARCHAR) +  ').'					
					GOTO RETURN_ERROR
				  END	
				  
				SET @v_maxsortoder_notes = @v_maxsortoder_notes + 1	  							
				FETCH specnotes_cursor_insert
				INTO @v_notekey, @v_copynextprtgind
			END

			CLOSE specnotes_cursor_insert
			DEALLOCATE specnotes_cursor_insert 				
			
			FETCH speccategory_cursor_insert_outer
			INTO @v_categorykey_template, @v_categorykey_project
		END

		CLOSE speccategory_cursor_insert_outer
		DEALLOCATE speccategory_cursor_insert_outer 				
  END
  
	IF @v_isopentrans = 1
		COMMIT
    
  --PRINT 'END inside qspec_apply_specificationtemplate'   
   
	RETURN  

RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK
    
  SET @o_error_code = -1
  RETURN  
  
END
go

GRANT EXEC ON qspec_apply_specificationtemplate TO PUBLIC
go
