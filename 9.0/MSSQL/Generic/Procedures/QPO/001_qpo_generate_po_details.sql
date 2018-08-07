/****** Object:  StoredProcedure [dbo].[qpo_generate_po_details]    Script Date: 04/01/2015 15:23:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_generate_po_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_generate_po_details]
GO


/****** Object:  StoredProcedure [dbo].[qpo_generate_po_details]    Script Date: 04/01/2015 15:23:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qpo_generate_po_details]
 (@i_projectkey           integer,
  @i_related_projectkey   integer,
  @i_gpokey               integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: po_generate_po_details
**  Desc: This procedure will be called from the Generate PO Report Function.
**        New projectkey key, related project key and gpokey will be passed in. 
**
**	Auth: Kusum
**	Date: 06 August 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT,
          @v_count INT,
          @v_count2 INT,
          @v_count3 INT,
          @v_count4 INT,
          @v_count5 INT,
          @v_component_section_count INT,
          @v_report_display_type INT,
          @v_misc_report_specification_datacode INT,
          @v_misckey INT,
          @v_report_detail_display_type INT,
          @v_printing_itemtypecode INT,
          @v_printing_usageclasscode INT,
          @v_taqprojectkey INT,
          @v_title_printing_section INT,
          @v_title_printing_component_section INT,
          @v_taqprojecttitle VARCHAR(255),
          @v_quantity INT,
          @new_gposectionkey INT,
          @lastuserid_var VARCHAR(30),
          @v_culturecode INT,
          @v_userkey INT,
          @v_selected_versionkey INT,
          @v_summary_component INT,
          @v_projectkey INT,
          @v_taqversionspecategorykey INT,
          @v_taqversionformatkey INT,
          @v_numericdesc1 INT,
          @v_scalevaluetype INT, 
          @v_datadesc VARCHAR(40),
          @v_location VARCHAR(25),
          @v_value VARCHAR(40),
          @v_detail VARCHAR(2000),
          @v_detaillinenbr INT,
          @v_itemcategorycode INT,
          @v_plstagecode INT,
          @v_bookkey INT,
          @v_printingkey INT,
          @v_unitofmeasurecode INT,
          @v_showqtyind INT,
          @v_showqtylabel VARCHAR(255),
          @v_showdecimalind INT,
          @v_showdecimallabel VARCHAR(255),
          @v_showdescind INT,
          @v_showdesclabel VARCHAR(255),
          @v_showvalidprtgsind INT,
          @v_defaultvalidforprtgscode INT,
          @v_showunitofmeasureind INT,
          @v_defaultunitofmeasurecode INT,
          @v_showdesc2ind INT,
          @v_showdesc2label VARCHAR(255),
          @v_datacode INT,
          @v_datasubcode INT,
          @v_datadescshort VARCHAR(20),
          @v_componenttype INT,
          @new_detailkey INT,
          @new_gposubsectionkey INT,
          @v_gpodetail_written INT,
          @v_speccategorydescription VARCHAR(255),
          @v_spec_description VARCHAR(2000),
          @v_spec_description2 VARCHAR(2000),
          @v_itemcode INT,
          @v_itemdesc VARCHAR(50),
          @v_itemdetaildesc VARCHAR(50),
          @v_showinsummaryind INT,
          @v_count_detail INT,
          @v_count_gposubsection INT,
          @v_sortorder INT,
          @v_saved_detaillinenbr INT,
          @v_po_itemtypecode INT,
          @v_po_proforma INT,
          @v_po_final INT,
          @v_project_usageclasscode INT,
          @v_productnumber VARCHAR(50),
          @v_title VARCHAR(255),
          @v_purchase_order_for_printings INT,
          @v_printing_for_purchase_orders INT,
          @v_quantity2 INT,
          @v_relatedspeccategorykey INT,
          @v_instructionkey  INT,
          @v_commentkey	INT,
          @v_commenttext NVARCHAR(MAX),
          @v_length INT,
          @v_sequence INT,
          @v_string VARCHAR(250),
          @v_pos INT,
          @v_space CHAR(1),
          @v_string2 VARCHAR(255),
          @v_pos2 INT,
          @substring VARCHAR(255),
          @reversestring varchar(400),
		  @spacepos int,
		  @length int,
		  @trimmedreversestring VARCHAR(500),
		  @trimmednormalreversestring varchar(255),
		  @remainder varchar(200),
		  @v_count_instr INT,
		  @v_gpo_section_desc VARCHAR(100),
		  @v_first_component INT,
		  @v_unitofmeasuredesc VARCHAR(40),
		  @v_unitofmeasuredesc_spec VARCHAR(40),
		  @v_itemtypecode INT,
		  @v_usageclasscode INT,
          @v_itemlabel VARCHAR(255),
          @v_externalcode INT,
          @v_coverdue DATETIME,
          @v_jacketdue DATETIME,
          @v_miscdue DATETIME,
          @v_filmreprodue DATETIME ,
          @v_date_string VARCHAR(10)  ,
          @v_taqtasknote   VARCHAR(2000),
          @v_taskdesc varchar(255),
          @v_count6 INT,
          @v_decimalvalue FLOAT,
          @v_specitem_sort INT,
          @v_component_sortorder INT
          
  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT @v_count = COUNT(*) 
    FROM taqversionrelatedcomponents_view
   WHERE taqprojectkey = @i_related_projectkey 
     --AND relatedprojectkey = @i_related_projectkey
  

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to generate po details: Error accessing taqversionrelatedcomponents view to verify components'
    RETURN  
  END 
  
  IF @v_count <= 0 BEGIN
    print 'No taqversionrelatedcomponents exist for the related projectkey: ' + cast(@i_related_projectkey as varchar) + '.'
    RETURN    
  END

  print 'INFO: Need to add gpo sections for ' + cast(@v_count as varchar) + ' taqversionrelatedcomponents'
  
  IF @i_lastuserid IS NULL BEGIN
	SELECT @lastuserid_var = 'QSIADMIN'
  END
  ELSE BEGIN
    SET @lastuserid_var = @i_lastuserid
  END
  
  SELECT @v_userkey = userkey FROM qsiusers WHERE userid = @lastuserid_var
  
  SELECT @v_misc_report_specification_datacode = datacode FROM gentables WHERE tableid = 525 AND qsicode = 1  --Report Specification Detail Type
  
  SELECT @v_misckey = misckey FROM bookmiscitems WHERE datacode = @v_misc_report_specification_datacode  --Report Specification Detail Type
  
  SELECT @v_report_detail_display_type = longvalue FROM taqprojectmisc where taqprojectkey = @i_projectkey AND misckey = @v_misckey
  IF @v_report_detail_display_type IS NULL OR @v_report_detail_display_type = 0 
	SELECT @v_report_detail_display_type = longvalue FROM bookmiscdefaults WHERE misckey = @v_misckey
	
  --IF @v_report_detail_display_type <= 0 BEGIN
  --  print 'No Report Detail Type has been specified for: ' + cast(@i_projectkey as varchar) + '.'
  --  RETURN    
  --END
  
  SELECT @v_printing_itemtypecode = datacode FROM gentables WHERE tableid = 550 AND qsicode = 14 --Printing
  
  SELECT @v_printing_usageclasscode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 40 --Printing
  
  SELECT @v_title_printing_section = datacode FROM gentables WHERE tableid = 249 and LOWER(datadesc) = 'title/printing'
  
  SELECT @v_title_printing_component_section = datacode FROM gentables WHERE tableid = 249 and LOWER(datadesc) = 'title/printing component'
  
  SELECT @v_summary_component = datacode FROM gentables WHERE tableid = 616 and qsicode = 1
  
  SELECT @v_po_itemtypecode = datacode FROM gentables WHERE tableid = 550 AND qsicode = 15 --Purchase Orders
  
  SELECT @v_po_proforma = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 42 --Proforma PO Report
  
  SELECT @v_po_final = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 43--Final PO Report
  
  SELECT @v_project_usageclasscode = usageclasscode FROM taqproject WHERE taqprojectkey = @i_projectkey -- current report project class
  
  SELECT @v_purchase_order_for_printings = datacode FROM gentables WHERE tableid =  582 and qsicode = 25 --Purchase Orders (for Printings)
  
  SELECT @v_printing_for_purchase_orders = datacode FROM gentables WHERE tableid =  582 and qsicode = 26 --Printing (for Purchase Orders)
  
  IF @v_report_detail_display_type IS NULL
	SET @v_report_detail_display_type = 0
  
  IF @v_report_detail_display_type = 1 BEGIN  --Title/Printing and/or Project
  
    DELETE FROM gpodetail WHERE gpokey = @i_gpokey 
      
    DELETE FROM gposubsection WHERE gpokey = @i_gpokey 
     
    DELETE FROM gposection WHERE gpokey = @i_gpokey 
        
    DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype IS NULL
    
    DELETE FROM gpocost WHERE gpokey = @i_gpokey
  
    SET @v_count = 0
    SET @v_detaillinenbr = 0
    
    DECLARE taqversionrelatedcomponents_cur CURSOR FOR 
	    SELECT DISTINCT t.relatedprojectkey, t.taqversionspecategorykey, t.sortorder
		  FROM taqversionrelatedcomponents_view t
		 WHERE t.taqprojectkey =  @i_related_projectkey 
		 ORDER BY t.relatedprojectkey, t.sortorder
		
    OPEN taqversionrelatedcomponents_cur
    
    FETCH taqversionrelatedcomponents_cur INTO @v_projectkey, @v_taqversionspecategorykey, @v_sortorder    
    
    WHILE @@fetch_status = 0 BEGIN
    
		SELECT DISTINCT @v_count = COUNT(*)
		  FROM projectrelationshipview r , taqproject t 
		 WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
			AND r.relatedprojectkey = t.taqprojectkey
			AND t.searchitemcode = @v_printing_itemtypecode
			AND t.usageclasscode = @v_printing_usageclasscode
		   
		IF @v_count > 0 BEGIN
			DECLARE projects_cur CURSOR FOR 
			   SELECT DISTINCT t.taqprojectkey, t.taqprojecttitle
				FROM projectrelationshipview r , taqproject t 
			    WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
			      AND r.relatedprojectkey = t.taqprojectkey
			      AND t.searchitemcode = @v_printing_itemtypecode
			      AND t.usageclasscode = @v_printing_usageclasscode
				  
			OPEN projects_cur 

			FETCH projects_cur INTO @v_taqprojectkey,@v_taqprojecttitle
			
			WHILE @@fetch_status = 0 BEGIN
			  SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
				FROM taqprojectprinting_view
			   WHERE taqprojectkey = @v_taqprojectkey
			   
			  SET @v_count2 = 0
			   
			  SELECT @v_count2 = COUNT(*)
				FROM taqversionrelatedcomponents_view, taqversionspeccategory
			   WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				 AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
				 AND taqversionspeccategory.quantity > 0
			     
			  IF @v_count2 = 1 BEGIN --only one component for this title/printing for this project on taqversionrelatedcomponents that 
									 -- has a taqversionspeccategory.quantity
				 SELECT @v_quantity = taqversionspeccategory.quantity
			 	   FROM taqversionrelatedcomponents_view, taqversionspeccategory
				  WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				    AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
				    AND taqversionspeccategory.quantity > 0
			  END  ---@v_count2 = 1
			  
			  ELSE IF @v_count2 > 1 BEGIN  -- multiple components
				 SET @v_count3 = 0
			     
				 SELECT @v_count3 = COUNT(*)
				   FROM taqversionrelatedcomponents_view , taqversionspeccategory 
				  WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				    AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					AND taqversionspeccategory.quantity > 0
					GROUP BY taqversionspeccategory.taqversionspecategorykey 
					HAVING COUNT(distinct taqversionspeccategory.quantity) > 1
				 
				 IF @v_count3 = 0 BEGIN -- all same quantity pick for first row
					SELECT TOP 1 @v_quantity = taqversionspeccategory.quantity
					  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
					 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				       AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					   AND taqversionspeccategory.quantity > 0
				 END   
				 ELSE IF @v_count3 >= 1 BEGIN  --multiple components with different quantities -- select quantity for finished good component
					SELECT @v_count4 = 0 
				    
					SELECT @v_count4 = COUNT(*)
					  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
					 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				       AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					   AND taqversionspeccategory.quantity > 0
					   AND taqversionspeccategory.finishedgoodind = 1
				       
					IF @v_count4 = 1 BEGIN   
						SELECT @v_quantity = taqversionspeccategory.quantity
						  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
						 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
				           AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
						   AND taqversionspeccategory.quantity > 0
						   AND taqversionspeccategory.finishedgoodind = 1
					END
					ELSE IF @v_count4 = 0 BEGIN
						SET @v_quantity = NULL
					END 
				 END
			  END  --@v_count2 > 1 (multiple components)
			  ELSE
				SET @v_quantity = NULL
			  
			  exec get_next_key @lastuserid_var, @new_gposectionkey output
			  INSERT INTO gposection (gpokey,sectionkey,sectiontype,key1,key2,key3,lastuserid,lastmaintdate)
				VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,@v_bookkey,@v_printingkey,NULL,@lastuserid_var,getdate())
				
				
			 -- EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,0,
				--@v_quantity,@v_taqversionspecategorykey,NULL,NULL,@v_report_detail_display_type,@v_sortorder,@v_gpo_section_desc,
				--@lastuserid_var,@o_error_code,@o_error_desc	
				
			 -- EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,0,
				--@v_quantity,@v_taqversionspecategorykey,NULL,NULL,@v_report_detail_display_type,
				--@lastuserid_var,@o_error_code,@o_error_desc	
							
			  SELECT @o_error_code = @@ERROR
		      IF @o_error_code <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Could not get generate gpocost rows'
			  END
				
			  SELECT @v_productnumber = productnumber, @v_title = title
				FROM coretitleinfo WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
			  SET @v_detail = ''
			  
			  SET @v_detail = @v_productnumber + ' ' + ' Prtg: ' + cast(@v_printingkey as varchar) + ' ' + @v_title
			  
			  IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
				SET @v_detaillinenbr = @v_detaillinenbr + 100
							    
				INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
				 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
						
				SET @v_detail =  ''
				SET @v_detaillinenbr = @v_detaillinenbr + 100
					    
				INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
				 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1) 
										  
			  END
		
			  FETCH projects_cur INTO @v_taqprojectkey,@v_taqprojecttitle
			END --@@fetch_status = 0 for projects_cur
			
			CLOSE projects_cur 
			DEALLOCATE projects_cur 
		
		END --@v_count > 0
		
		FETCH taqversionrelatedcomponents_cur INTO @v_projectkey, @v_taqversionspecategorykey, @v_sortorder
	END --@@fetch_status = 0 for taqversionrelatedcomponents_cur
		
	CLOSE taqversionrelatedcomponents_cur 
	DEALLOCATE taqversionrelatedcomponents_cur
  END  --@v_report_detail_display_type = 1
  
  ELSE IF @v_report_detail_display_type = 2 BEGIN  --Summary Component Item Detail only
  
    DELETE FROM gpodetail WHERE gpokey = @i_gpokey 
      
    DELETE FROM gposubsection WHERE gpokey = @i_gpokey 
     
    DELETE FROM gposection WHERE gpokey = @i_gpokey 
        
    DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype IS NULL
    
    DELETE FROM gpocost WHERE gpokey = @i_gpokey
     
    SET @v_detaillinenbr = 0
  
	SET @v_count = 0
    
	SELECT @v_count = COUNT(*)
	  FROM taqversionrelatedcomponents_view c, taqproject t
	 WHERE c.relatedprojectkey = t.taqprojectkey
	   AND c.relatedprojectkey = @i_related_projectkey
	   AND searchitemcode = @v_printing_itemtypecode
	   AND usageclasscode = @v_printing_usageclasscode
	   
	IF @v_count = 1 BEGIN
		SELECT @v_taqprojectkey = t.taqprojectkey,@v_taqprojecttitle = t.taqprojecttitle,
		     @v_taqversionspecategorykey =c.taqversionspecategorykey
		  FROM taqversionrelatedcomponents_view c, taqproject t
		 WHERE c.taqprojectkey = @i_related_projectkey
		   AND c.relatedprojectkey = t.taqprojectkey
		   AND t.searchitemcode = @v_printing_itemtypecode
		   AND t.usageclasscode = @v_printing_usageclasscode
		   
		SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
		  FROM taqprojectprinting_view
		 WHERE taqprojectkey = @v_taqprojectkey
			   
	    SET @v_count2 = 0
		   
		SELECT @v_count2 = COUNT(*)
		  FROM taqversionrelatedcomponents_view, taqversionspeccategory
	     WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		   AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
		   AND taqversionspeccategory.quantity > 0
		     
		IF @v_count2 = 1 BEGIN --only one component for this title/printing for this project on taqversionrelatedcomponents that 
		                         -- has a taqversionspeccategory.quantity
			SELECT @v_quantity = taqversionspeccategory.quantity
			 FROM taqversionrelatedcomponents_view, taqversionspeccategory
			 WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		       AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
			   AND taqversionspeccategory.quantity > 0
	    END  ---@v_count2 = 1
		ELSE IF @v_count2 > 1 BEGIN  -- multiple components
			SET @v_count3 = 0
		     
			SELECT @v_count3 = COUNT(*)
			  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
			 WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		       AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
			   AND taqversionspeccategory.quantity > 0
			   GROUP BY taqversionspeccategory.taqversionspecategorykey 
			   HAVING COUNT(distinct taqversionspeccategory.quantity) > 1
			 
			IF @v_count3 = 0 BEGIN -- all same quantity pick for first row
				SELECT TOP 1 @v_quantity = taqversionspeccategory.quantity
				  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
			     WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		           AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
			       AND taqversionspeccategory.quantity > 0
			END   
			ELSE IF @v_count3 >= 1 BEGIN  --multiple components with different quantities -- select quantity for finished good component
			    SELECT @v_count4 = 0 
			    
			    SELECT @v_count4 = COUNT(*)
			      FROM taqversionrelatedcomponents_view , taqversionspeccategory 
			     WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		           AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
			       AND taqversionspeccategory.quantity > 0
			       AND taqversionspeccategory.finishedgoodind = 1
			       
			    IF @v_count4 = 1 BEGIN   
					SELECT @v_quantity = taqversionspeccategory.quantity
					  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
					 WHERE taqversionrelatedcomponents_view.taqversionspecategorykey = taqversionspeccategory.taqversionspecategorykey
		               AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					   AND taqversionspeccategory.quantity > 0
					   AND taqversionspeccategory.finishedgoodind = 1
			    END
			    ELSE IF @v_count4 = 0 BEGIN
					SET @v_quantity = NULL
			    END 
			 END
		   END  --@v_count2 > 1 (multiple components)
		   ELSE --@v_count2 = 0
				SET @v_quantity = NULL
		   
		   -- create a gposection row
		   exec get_next_key @lastuserid_var, @new_gposectionkey output
		   
		   INSERT INTO gposection (gpokey,sectionkey,sectiontype,key1,key2,key3,quantity,lastuserid,lastmaintdate)
			 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,@v_bookkey,@v_printingkey,NULL,@v_quantity,@lastuserid_var,getdate())
			
		   SELECT @v_culturecode = projectculturecode FROM dbo.get_culture(0,0,0)
		   
		   SELECT @v_selected_versionkey = dbo.qpl_get_selected_version(@i_projectkey)
		   
		  -- EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,0,
				--@v_quantity,@v_taqversionspecategorykey,NULL,NULL,@v_report_detail_display_type,
				--@lastuserid_var,@o_error_code,@o_error_desc	
		   
		   
		   EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,0,
				@v_quantity,@v_taqversionspecategorykey,NULL,@v_selected_versionkey,@v_report_detail_display_type,@v_sortorder,
				@v_gpo_section_desc,@lastuserid_var,@o_error_code,@o_error_desc
				
		   SELECT @o_error_code = @@ERROR
		   IF @o_error_code <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Could not get generate gpocost rows'
		   END	
		 	 		   
		   SELECT @v_detaillinenbr = 0
		   SET @v_detail = ''
		   
		   DECLARE specs_category_cursor CURSOR FOR 
			  SELECT DISTINCT taqversionspecategorykey, plstagecode, taqversionformatkey,s.itemcategorycode,speccategorydescription,
		            s.itemcode, itemdesc, itemdetaildesc, quantity,description,unitofmeasuredesc
			   FROM taqversionspecitems_view  s,  taqspecadmin t
			  WHERE s.taqprojectkey = @v_taqprojectkey
			    AND s.taqversionkey = @v_selected_versionkey
			    AND s.itemcategorycode = @v_summary_component
			    AND t.showinsummaryind = 1
			    AND s.itemcategorycode = t.itemcategorycode
				AND s.itemcode = t.itemcode
			    AND t.culturecode = @v_culturecode
			  
		   OPEN specs_category_cursor 

		   FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
				 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2,@v_spec_description,
				 @v_unitofmeasuredesc
					
		   WHILE @@fetch_status = 0 BEGIN
		   
		     SELECT @v_count5 = 0
			
			 SELECT @v_count5 = COUNT(*)
			   FROM taqversionspecitems_view  s, taqspecadmin t
			  WHERE s.taqprojectkey = @v_taqprojectkey
		 		AND s.taqversionkey = @v_selected_versionkey
				AND s.itemcategorycode = @v_componenttype
				AND (s.itemdetaildesc IS NOT NULL OR s.description IS NOT NULL)
				AND s.itemcategorycode = t.itemcategorycode
				AND s.itemcode = t.itemcode
				AND t.culturecode = @v_culturecode
				AND t.showdescind = 1
				AND s.itemcode = @v_itemcode
				AND s.itemcategorycode = @v_componenttype
							  
			 IF @v_count5 > 0 BEGIN 
				SELECT @v_showqtyind=showqtyind,@v_showqtylabel=showqtylabel,@v_showdecimalind=showdecimalind,
					   @v_showdecimallabel=showdecimallabel,@v_showdescind=showdescind,@v_showdecimallabel=showdecimalind,
					   @v_showdescind=showdescind,@v_showdesclabel=showdesclabel,@v_showunitofmeasureind=showunitofmeasureind,
					   @v_defaultunitofmeasurecode=defaultunitofmeasurecode,@v_showinsummaryind=showinsummaryind,
					   @v_showdesc2ind=showdesc2ind,@v_showdesc2label=showdesc2label
				   FROM taqspecadmin
				  WHERE itemcategorycode = @v_itemcategorycode
					AND itemcode = @v_itemcode
					AND culturecode = @v_culturecode  
							  
				IF @v_itemdetaildesc IS NOT NULL OR @v_quantity2 IS NOT NULL OR @v_spec_description IS NOT NULL BEGIN
					IF @v_showdescind > 0 OR @v_showdesc2ind > 0 BEGIN
						IF @v_showdescind > 0 AND (@v_showdesclabel IS NOT NULL OR @v_showdesclabel <> '') BEGIN
						IF @v_showdesclabel IS NOT NULL OR @v_showdesclabel <> ''
						    SET @v_detail = @v_showdesclabel + ': '
						ELSE
							SET @v_detail = @v_itemdesc + ': '
										
						IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '')  BEGIN
							SET @v_detail = @v_detail +  @v_itemdetaildesc
													  
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
								SET @v_detail = @v_detail + ', ' + @v_spec_description
												
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
						ELSE IF @v_itemdetaildesc IS NULL BEGIN
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
							  SET @v_detail = @v_detail +  @v_spec_description
							IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 
							  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> ''
								SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
							  ELSE
								SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
											
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
						END 			
						ELSE IF @v_showdesc2ind > 0 AND (@v_showdesc2label IS NOT NULL OR @v_showdesc2label <> '') BEGIN
						 IF @v_showdesc2label IS NOT NULL OR @v_showdesc2label <> ''
							SET @v_detail = @v_showdesc2label + ': '
						ELSE
							SET @v_detail = @v_itemdesc + ': '
										
						IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '')BEGIN
							SET @v_detail = @v_detail +  @v_itemdetaildesc
													  
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
								SET @v_detail = @v_detail + ', ' + @v_spec_description
											
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
						ELSE IF @v_itemdetaildesc IS NULL BEGIN
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <>'')
							  SET @v_detail = @v_detail +  @v_spec_description
							IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 
							   IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
								SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
							  ELSE
								SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
					  END
					  END	--IF @v_showdescind > 0 OR @v_show2descind > 0
					  ELSE BEGIN
						IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '') BEGIN
							SET @v_detail = @v_itemdesc + ': ' 
									     
							SET @v_detail =  @v_detail +  @v_itemdetaildesc
													  
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
								SET @v_detail = @v_detail + ', ' + @v_spec_description
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
						ELSE IF @v_itemdetaildesc IS NULL BEGIN
							SET @v_detail = @v_itemdesc + ': ' 
							IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
							  SET @v_detail = @v_detail +  @v_spec_description
							IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 
								SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
							IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
							  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
							END 
						END
					  END
				  END  --IF @v_itemdetaildesc IS NOT NULL OR @v_quantity2 IS NOT NULL OR @v_spec_description IS NOT NULL
				  								   
				   IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
					SET @v_detaillinenbr = @v_detaillinenbr + 100
					
					SET @v_detail =  ''
					
						    
					INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
					 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1) 
						    
					INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
					 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
					
					SET @v_detail =  ''
					SET @v_detaillinenbr = @v_detaillinenbr + 100
						    
					INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
					 VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1) 
									  
				  END
			  END
				   
			  FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
				 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2,@v_spec_description,
				 @v_unitofmeasuredesc
			END
			
			CLOSE specs_category_cursor 
		    DEALLOCATE specs_category_cursor 
	END --@v_count = 1
  END --IF @v_report_detail_display_type = 2
  
  ELSE IF @v_report_detail_display_type = 3 OR @v_report_detail_display_type = 0 BEGIN  --Specification Item Detail
  
    DELETE FROM gpodetail WHERE gpokey = @i_gpokey 
      
    DELETE FROM gposubsection WHERE gpokey = @i_gpokey 
     
    DELETE FROM gposection WHERE gpokey = @i_gpokey AND sectiontype = @v_title_printing_section
    
    DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype IS NULL
    
    DELETE FROM gpocost WHERE gpokey = @i_gpokey
     
    SET @v_detaillinenbr = 0   
	SET @v_count = 0
	
	SELECT DISTINCT @v_count = COUNT(*)
		  FROM projectrelationshipview r , taqproject t 
		 WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
			AND r.relatedprojectkey = t.taqprojectkey
			AND t.searchitemcode = @v_printing_itemtypecode
			AND t.usageclasscode = @v_printing_usageclasscode
			
	IF @v_count > 1 BEGIN
	
		DECLARE taqversionrelatedcomponents_cur CURSOR FOR 
			SELECT DISTINCT t.relatedprojectkey, t.relatedcategorykey, t.sortorder
			  FROM taqversionrelatedcomponents_view t
			 WHERE t.taqprojectkey =  @i_related_projectkey 
			ORDER BY t.relatedprojectkey, t.sortorder
			
		OPEN taqversionrelatedcomponents_cur
	    
		FETCH taqversionrelatedcomponents_cur INTO @v_projectkey, @v_taqversionspecategorykey, @v_sortorder    
	    
		WHILE @@fetch_status = 0 BEGIN
	    
			SELECT DISTINCT @v_count = COUNT(*)
			  FROM projectrelationshipview r , taqproject t 
			 WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
				AND r.relatedprojectkey = t.taqprojectkey
				AND t.searchitemcode = @v_printing_itemtypecode
				AND t.usageclasscode = @v_printing_usageclasscode
			   
			IF @v_count > 0 BEGIN
				DECLARE projects_cur CURSOR FOR 
				  SELECT DISTINCT r.relatedprojectkey, t.taqprojecttitle
					FROM projectrelationshipview r , taqproject t 
					WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
					  AND r.relatedprojectkey = t.taqprojectkey
					  AND t.searchitemcode = @v_printing_itemtypecode
					  AND t.usageclasscode = @v_printing_usageclasscode
					  
				OPEN projects_cur 

				FETCH projects_cur INTO @v_taqprojectkey,@v_taqprojecttitle   -- Printing taqproject
				
				WHILE @@fetch_status = 0 BEGIN
				  SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
					FROM taqprojectprinting_view
				   WHERE taqprojectkey = @v_taqprojectkey
				   
				  SET @v_count2 = 0
				
					 
				  SELECT @v_count2 = COUNT(*)
					FROM taqversionrelatedcomponents_view, taqversionspeccategory
				   WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
					 AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					 AND taqversionspeccategory.quantity > 0
				     
				  IF @v_count2 = 1 BEGIN --only one component for this title/printing for this project on taqversionrelatedcomponents that 
										 -- has a taqversionspeccategory.quantity
					 SELECT @v_quantity = taqversionspeccategory.quantity
					 FROM taqversionrelatedcomponents_view, taqversionspeccategory
					 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
					   AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
					   AND taqversionspeccategory.quantity > 0
				  END  ---@v_count2 = 1
				  
				  ELSE IF @v_count2 > 1 BEGIN  -- multiple components
					 SET @v_count3 = 0
				     
					 SELECT @v_count3 = COUNT(*)
					   FROM taqversionrelatedcomponents_view , taqversionspeccategory 
					  WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
						AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
						AND taqversionspeccategory.quantity > 0
						GROUP BY taqversionspeccategory.taqversionspecategorykey 
						HAVING COUNT(distinct taqversionspeccategory.quantity) > 1
					 
					 IF @v_count3 = 0 BEGIN -- all same quantity pick for first row
						SELECT TOP 1 @v_quantity = taqversionspeccategory.quantity
						  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
						 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
						   AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
						   AND taqversionspeccategory.quantity > 0
					 END   
					 ELSE IF @v_count3 >= 1 BEGIN  --multiple components with different quantities -- select quantity for finished good component
						SELECT @v_count4 = 0 
					    
						SELECT @v_count4 = COUNT(*)
						  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
						 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
						   AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
						   AND taqversionspeccategory.quantity > 0
						   AND taqversionspeccategory.finishedgoodind = 1
					       
						IF @v_count4 = 1 BEGIN   
							SELECT @v_quantity = taqversionspeccategory.quantity
							  FROM taqversionrelatedcomponents_view , taqversionspeccategory 
							 WHERE taqversionrelatedcomponents_view.relatedcategorykey = taqversionspeccategory.taqversionspecategorykey
							   AND taqversionrelatedcomponents_view.taqprojectkey = @i_related_projectkey
							   AND taqversionspeccategory.quantity > 0
							   AND taqversionspeccategory.finishedgoodind = 1
						END
						ELSE IF @v_count4 = 0 BEGIN
							SET @v_quantity = NULL
						END 
					 END
				  END  --@v_count2 > 1 (multiple components)
				  ELSE
					SET @v_quantity = NULL
					
				  IF @v_taqversionspecategorykey > 0 
					SELECT @v_gpo_section_desc = speccategorydescription
					  FROM taqversionspeccategory WHERE taqversionspecategorykey = @v_taqversionspecategorykey
					
				  
				  -- write gposection row
				  exec get_next_key @lastuserid_var, @new_gposectionkey output
				  INSERT INTO gposection (gpokey,sectionkey,sectiontype,key1,key2,key3,description, lastuserid,lastmaintdate)
					VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_section,@v_bookkey,@v_printingkey,NULL,@v_gpo_section_desc,
					@lastuserid_var,getdate())
					
				  SELECT @v_culturecode = projectculturecode FROM dbo.get_culture(0,0,0)
				   
				  SELECT @v_selected_versionkey = dbo.qpl_get_selected_version(@v_taqprojectkey)
				   
				  IF @v_selected_versionkey = -1 BEGIN
					GOTO next_row
				  END
				  
				  DECLARE components_cur CURSOR FOR
					SELECT distinct c.itemcategorycode
					  FROM taqversionspecitems_view c
					 WHERE taqprojectkey = @i_related_projectkey
									  
				   OPEN components_cur 

				   FETCH components_cur INTO @v_componenttype
					
				   WHILE @@fetch_status = 0 BEGIN
				   
					SELECT @v_taqversionspecategorykey = taqversionspecategorykey, @v_plstagecode = plstagecode,
						   @v_taqversionformatkey = taqversionformatkey,
						   @v_itemcategorycode = itemcategorycode, @v_speccategorydescription = ltrim(rtrim(speccategorydescription)),
						   @v_itemcode = itemcode, @v_itemdesc = itemdesc, @v_itemdetaildesc= itemdetaildesc, @v_quantity2 = quantity,
						   @v_spec_description = description
					 FROM taqversionspecitems_view  s
					WHERE s.taqprojectkey = @i_related_projectkey
					  AND s.taqversionkey = @v_selected_versionkey
					  AND s.itemcategorycode = @v_componenttype
						
					  
					SELECT @v_count_gposubsection = COUNT(*)
					  FROM gposubsection
					 WHERE gpokey = @i_gpokey
					   AND key1 = @v_bookkey
					   AND key2 = @v_printingkey
					   AND key3 = @v_taqversionspecategorykey
					   
					SET @v_gpodetail_written = 0
					SET @v_detail = ''
					--SET @v_detaillinenbr = 0
					   
					IF @v_count_gposubsection = 0 BEGIN
				    
						--write gposubsection row for the component 
						exec get_next_key @lastuserid_var, @new_gposubsectionkey output
					    
						INSERT INTO gposubsection (gpokey,sectionkey,subsectionkey,subsectiontype,key1,key2,key3,quantity,lastuserid,lastmaintdate)
							VALUES(@i_gpokey,@new_gposectionkey,@new_gposubsectionkey,@v_title_printing_component_section,@v_bookkey,@v_printingkey,
							   @v_taqversionspecategorykey,@v_quantity,@lastuserid_var,getdate())
							   
							   
				 		EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,@new_gposubsectionkey,
							@v_quantity,@v_taqversionspecategorykey,@v_itemcategorycode,@v_selected_versionkey,@v_report_detail_display_type,
							@v_sortorder,@v_gpo_section_desc,@lastuserid_var,@o_error_code,@o_error_desc
							
						SELECT @o_error_code = @@ERROR
						IF @o_error_code <> 0 BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'Could not get generate gpocost rows'
						END
					    				 	
						DECLARE specs_category_cursor CURSOR FOR 
						  SELECT DISTINCT taqversionspecategorykey, plstagecode, taqversionformatkey,s.itemcategorycode,speccategorydescription,
								s.itemcode, itemdesc, itemdetaildesc, quantity,unitofmeasuredesc,description2
						   FROM taqversionspecitems_view  s, taqspecadmin t
						  WHERE s.taqprojectkey = @i_related_projectkey
							AND s.taqversionkey = @v_selected_versionkey
							AND s.itemcategorycode = @v_componenttype
						  
						  OPEN specs_category_cursor 

						  FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
							 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2,@v_unitofmeasuredesc_spec,
							 @v_spec_description2
										
						  WHILE @@fetch_status = 0 BEGIN
						  
							SET @v_count_detail = 0
							    
							SELECT @v_count_detail = COUNT(*)
							  FROM gpodetail
							 WHERE gpokey = @i_gpokey
							   AND sectionkey = @new_gposectionkey
							   AND detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
								       
							IF @v_count_detail = 0 BEGIN
								SET @v_detaillinenbr = @v_detaillinenbr + 100
								
								IF @v_detaillinenbr > 100 BEGIN
									SET @v_detaillinenbr = @v_detaillinenbr + 100
									SET @v_detail = ''
									
									exec get_next_key @lastuserid_var, @new_detailkey output
														
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
								END
								
								SET @v_detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
								
								exec get_next_key @lastuserid_var, @new_detailkey output
														
								INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
								 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
								 
								SET @v_detaillinenbr = @v_detaillinenbr + 100
								SET @v_detail = ''
								
								exec get_next_key @lastuserid_var, @new_detailkey output
													
								INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
								 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
							 END	
						  
							 SET @v_count5 = 0
						     			 	
							 SELECT @v_count5 = COUNT(*)
							   FROM taqversionspecitems_view  s, taqspecadmin t
							  WHERE s.taqprojectkey = @i_related_projectkey
		 						AND s.taqversionkey = @v_selected_versionkey
								AND s.itemcategorycode = @v_componenttype
								AND s.itemcategorycode = t.itemcategorycode
								AND s.itemcode = t.itemcode
								AND t.culturecode = @v_culturecode
								AND s.itemcode = @v_itemcode
										 
												
							  IF @v_count5 > 0 BEGIN 
								  SELECT DISTINCT @v_spec_description = description,@v_itemdetaildesc = itemdetaildesc,
									@v_unitofmeasuredesc = unitofmeasuredesc, @v_relatedspeccategorykey = COALESCE(relatedspeccategorykey,0)
									FROM taqversionspecitems_view  s, taqspecadmin t
								   WHERE s.taqprojectkey = @i_related_projectkey
									 AND s.taqversionkey = @v_selected_versionkey
									 AND s.itemcategorycode = @v_componenttype
									 AND s.itemcode = @v_itemcode
									 AND s.itemcategorycode = t.itemcategorycode
									 AND s.itemcode = t.itemcode
									 
							  
								  SET @v_detail = ''
							      
								  SELECT @v_showqtyind=showqtyind,@v_showqtylabel=showqtylabel,@v_showdecimalind=showdecimalind,
									   @v_showdecimallabel=showdecimallabel,@v_showdescind=showdescind,@v_showdecimallabel=showdecimalind,
									   @v_showdescind=showdescind,@v_showdesclabel=showdesclabel,@v_showunitofmeasureind=showunitofmeasureind,
									   @v_defaultunitofmeasurecode=defaultunitofmeasurecode,@v_showinsummaryind=showinsummaryind,
									   @v_showdesc2ind=showdesc2ind,@v_showdesc2label=showdesc2label
								   FROM taqspecadmin
								  WHERE itemcategorycode = @v_itemcategorycode
									AND itemcode = @v_itemcode
									AND culturecode = @v_culturecode  
									
								  IF @v_unitofmeasuredesc_spec IS NOT NULL AND @v_unitofmeasuredesc_spec <> '' 
									SET @v_unitofmeasuredesc = @v_unitofmeasuredesc_spec
									
								  IF @v_itemdetaildesc IS NOT NULL OR @v_quantity2 IS NOT NULL OR @v_spec_description IS NOT NULL BEGIN
									 IF @v_showdescind > 0 OR @v_showdesc2ind > 0 BEGIN
									--IF @v_showdescind > 0 AND (@v_showdesclabel IS NOT NULL OR @v_showdesclabel <> '') BEGIN
										IF @v_showdescind > 0  BEGIN
											IF @v_showdesclabel IS NOT NULL OR @v_showdesclabel <> ''
												SET @v_detail = @v_showdesclabel + ': '
											ELSE
												SET @v_detail = @v_itemdesc + ': '
																		
											IF @v_itemdetaildesc IS NOT NULL BEGIN
												SET @v_detail = @v_detail + ', ' +  @v_itemdetaildesc
																					  
												IF @v_spec_description IS NOT NULL AND (@v_spec_description <> @v_itemdetaildesc) BEGIN
													SET @v_detail = @v_detail + ' ' + @v_spec_description
													
													IF @v_spec_description2 IS NOT NULL AND @v_showdesc2ind > 0 AND 
													 (@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '')
													  SET @v_detail = @v_detail + ' ' + @v_showdesc2label + ' ' + @v_spec_description2
													 
												END	 
												ELSE IF @v_spec_description IS NULL
													SET @v_spec_description = ''
														
												IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 
													 AND ((CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_itemdetaildesc))) 
												  --SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
												  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
													SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
												  ELSE
													SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)
																					
												IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
												  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
												END 
											END
											ELSE IF @v_itemdetaildesc IS NULL BEGIN
												IF @v_spec_description IS NOT NULL BEGIN
												  SET @v_detail = @v_detail +  @v_spec_description
												  
												  IF @v_spec_description2 IS NOT NULL AND @v_showdesc2ind > 0 AND 
													(@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '')
													  SET @v_detail = @v_detail + ' ' + @v_showdesc2label + ' ' + @v_spec_description2
												END
												ELSE 
												  SET @v_spec_description = ''
															  
												IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND ((CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description))
												  --SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
												 IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
													SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
												  ELSE
													SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)
																			
												IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
												  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
												END 
											END
										END 			
										--ELSE IF @v_showdesc2ind > 0 AND (@v_showdesc2label IS NOT NULL OR @v_showdesc2label <> '') BEGIN
										ELSE IF @v_showdesc2ind > 0 BEGIN
										 IF @v_showdesc2label IS NOT NULL AND @v_showdesc2label <> ''
											SET @v_detail = @v_showdesc2label + ': '
										 ELSE
											SET @v_detail = @v_itemdesc + ': '
																		
										IF @v_itemdetaildesc IS NOT NULL BEGIN
											SET @v_detail = @v_detail +  @v_itemdetaildesc
																					  
											IF @v_spec_description IS NOT NULL AND (@v_spec_description <> @v_itemdetaildesc)
												SET @v_detail = @v_detail + ', ' + @v_spec_description
											ELSE IF @v_spec_description IS NULL
												SET @v_spec_description = ''
																
											IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description AND  CONVERT(VARCHAR(20),@v_quantity2) <> @v_itemdetaildesc) 
											  --SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
											  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
												SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
											  ELSE
												SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2) 
																			
											IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
											  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
											END 
										END
										ELSE IF @v_itemdetaildesc IS NULL BEGIN
											IF @v_spec_description IS NOT NULL
											  SET @v_detail = @v_detail +  @v_spec_description
											ELSE
											  SET @v_spec_description = ''
											  IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND ((CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description)) 
												  --SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2) 
												  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
													SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
												  ELSE
													SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)
													
											  IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
												  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
				   							  END 
										END
									  END
									END	--IF @v_showdescind > 0 OR @v_show2descind > 0
									ELSE BEGIN
										IF @v_itemdetaildesc IS NOT NULL BEGIN
											SET @v_detail = @v_itemdesc + ': ' 
																	     
											SET @v_detail =  @v_detail +  @v_itemdetaildesc
																					  
											IF @v_spec_description IS NOT NULL AND (@v_spec_description <> @v_itemdetaildesc)
												SET @v_detail = @v_detail + ', ' + @v_spec_description
											ELSE IF @v_spec_description IS NULL
												SET @v_spec_description = ''

											IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (cast(@v_quantity2 as varchar) <> @v_itemdetaildesc AND cast(@v_quantity2 as varchar) <> @v_spec_description) BEGIN
												--SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
												IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
													SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
											    ELSE
													SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)
											END

											IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
												SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
											END 
										END
										ELSE IF @v_itemdetaildesc IS NULL BEGIN
											SET @v_detail = @v_itemdesc + ': ' 
											IF @v_spec_description IS NOT NULL 
											  SET @v_detail = @v_detail +  @v_spec_description
											ELSE
											  SET @v_spec_description = ''
											IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND ((CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description))
												--SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2)
												IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
													SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
												ELSE
													SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)				
											IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
											  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
											END 
										END
									   END
								   END  --IF @v_itemdetaildesc IS NOT NULL OR @v_quantity2 IS NOT NULL OR @v_spec_description IS NOT NULL
									 
									 
											   
								   IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
								  
									SET @v_detaillinenbr = @v_detaillinenbr + 100
								    
									exec get_next_key @lastuserid_var, @new_detailkey output
									    
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
									 
									SET @v_gpodetail_written = @v_gpodetail_written + 1
										  
								  END
							  END
														
							  FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
								 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2,
								 @v_unitofmeasuredesc_spec,@v_spec_description2
							END --@@fetch_status = 0 for specs_category_cursor
							
						CLOSE specs_category_cursor 
						DEALLOCATE specs_category_cursor 
					END			--@v_count_gposubsection = 0
					
					IF @v_relatedspeccategorykey > 0 BEGIN
					
				    DECLARE notes_cur CURSOR FOR
						  SELECT [text]
						    FROM taqversionspecnotes 
						   WHERE taqversionspecategorykey = @v_relatedspeccategorykey
						     AND showonpoind = 1 
						     ORDER BY sortorder ASC
									  
				     OPEN notes_cur 

				     FETCH notes_cur INTO @v_commenttext
  					
				     WHILE @@fetch_status = 0 BEGIN							 
						   IF LEN(CONVERT(VARCHAR(250), @v_commenttext)) > 0 BEGIN
							  SET @v_sequence = @v_sequence + 1
							  SET @v_length = 250
  										
						   WHILE LEN(@v_commenttext) > 0 BEGIN
							  IF LEN(@v_commenttext) <= 250 BEGIN
   							  SET @length = 0
							    SET @v_string = @v_commenttext
							    SET @v_commenttext = right(@v_commenttext,(len(@v_commenttext) - @length))
  										      
							    IF @v_string <> '' BEGIN
  								  
								  SET @v_detaillinenbr = @v_detaillinenbr + 100
  											    
								  exec get_next_key @lastuserid_var, @new_detailkey output
  												    
								  INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									   VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_string,@lastuserid_var,getdate(),1)
  												 
								  SET @v_gpodetail_written = @v_gpodetail_written + 1
  													  
							    END
							    BREAK
							  END
							  ELSE BEGIN  
								  SET @substring = LEFT(@v_commenttext,@v_length)
  								
								  --check if last pos is a space
								  IF RIGHT(@v_commenttext,@v_length) <> ' ' BEGIN
  												
									  SET @reversestring = REVERSE(@substring)
									  SET @spacepos = CHARINDEX(' ',@reversestring)
									  SET @trimmedreversestring = SUBSTRING(@reversestring,@spacepos,len(@reversestring))
									  SET @trimmednormalreversestring = REVERSE(@trimmedreversestring)
									  SET @v_string =  @trimmednormalreversestring
									  SET @length = len(@trimmednormalreversestring)
									  SET @v_commenttext = right(@v_commenttext,(len(@v_commenttext) - @length))
  														
								  END
								  ELSE BEGIN
									  SET @v_string =  @v_string
									  IF LEN(@v_commenttext) = @v_length OR LEN(@v_commenttext) > @v_length
										  SET @v_commenttext = RIGHT(@v_commenttext,LEN(@v_commenttext) - (@v_length - 1))
									  ELSE
										  SET @v_commenttext = @v_commenttext
									  END  
								  END							
  											
								  IF @v_string <> '' BEGIN
  								 
									  SET @v_detaillinenbr = @v_detaillinenbr + 100
									  exec get_next_key @lastuserid_var, @new_detailkey output
									  INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									   VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_string,@lastuserid_var,getdate(),1)
									  SET @v_gpodetail_written = @v_gpodetail_written + 1
								  END
								  IF (LEN(@v_commenttext)= 0)
									  BREAK
  											
								  SET @v_sequence = @v_sequence + 1
							  END
						   END
						   
 				       FETCH notes_cur INTO @v_commenttext
						  END -- cursor
						  
  	  			  CLOSE notes_cur 
	  	  			DEALLOCATE notes_cur 
						END --IF @v_relatedspeccategorykey> 0 BEGIN
				
					FETCH components_cur INTO @v_componenttype	  
				   END  --@@fetch_status = 0 for components_cur
			       
				   CLOSE components_cur 
				   DEALLOCATE components_cur
					
				  next_row:
				  FETCH projects_cur INTO @v_taqprojectkey,@v_taqprojecttitle
				END --@@fetch_status = 0 for projects_cur
				
				CLOSE projects_cur 
				DEALLOCATE projects_cur 
			END --@v_count > 0
			
			FETCH taqversionrelatedcomponents_cur INTO @v_projectkey, @v_taqversionspecategorykey, @v_sortorder
		END --@@fetch_status = 0 for taqversionrelatedcomponents_cur
			
		CLOSE taqversionrelatedcomponents_cur 
		DEALLOCATE taqversionrelatedcomponents_cur
	END --@v_count > 1
 	--ELSE IF @v_count = 1 BEGIN
 	ELSE BEGIN
	  --Single title printing 
		DELETE FROM gpodetail WHERE gpokey = @i_gpokey 
	      
		DELETE FROM gposubsection WHERE gpokey = @i_gpokey 
	     
		DELETE FROM gposection WHERE gpokey = @i_gpokey 
	        
		DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype IS NULL
	    
		DELETE FROM gpocost WHERE gpokey = @i_gpokey
	    
		SET @v_detaillinenbr = 0
		
		SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode
		  FROM taqproject
		 WHERE taqprojectkey = @i_related_projectkey
		 
		IF @v_itemtypecode = @v_printing_itemtypecode AND @v_usageclasscode = @v_printing_usageclasscode  BEGIN
			SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
		      FROM taqprojectprinting_view
			 WHERE taqprojectkey = @i_related_projectkey
			 
			SET @v_taqprojectkey = @i_related_projectkey
		END
	    ELSE BEGIN
			SELECT DISTINCT @v_taqprojectkey = r.relatedprojectkey, @v_taqprojecttitle=t.taqprojecttitle
 			  FROM projectrelationshipview r , taqproject t 
			 WHERE r.taqprojectkey = @i_related_projectkey and r.relationshipcode = @v_purchase_order_for_printings
			   AND r.relatedprojectkey = t.taqprojectkey
			   AND t.searchitemcode = @v_printing_itemtypecode
			   AND t.usageclasscode = @v_printing_usageclasscode
			   
			SELECT @v_bookkey = bookkey, @v_printingkey = printingkey
			  FROM taqprojectprinting_view
			 WHERE taqprojectkey = @v_taqprojectkey
		END
	      
		SELECT @v_culturecode = projectculturecode FROM dbo.get_culture(0,0,0)
				   
		SELECT @v_selected_versionkey = dbo.qpl_get_selected_version(@v_taqprojectkey)
	     
		DECLARE components_cur CURSOR FOR
			SELECT distinct c.itemcategorycode, c.sortorder
			  FROM taqversionspecitems_view c
			 WHERE taqprojectkey = @i_related_projectkey
			   AND c.speccategorydescription IS NOT NULL
			 ORDER BY c.sortorder
					  
			OPEN components_cur 

			FETCH components_cur INTO @v_componenttype, @v_component_sortorder
				
			WHILE @@fetch_status = 0 BEGIN
			   
			   DECLARE specs_cursor CURSOR FOR
			   SELECT DISTINCT taqversionspecategorykey,  COALESCE(relatedspeccategorykey,0)
				 FROM taqversionspecitems_view  s
				WHERE s.taqprojectkey = @i_related_projectkey
				  AND s.taqversionkey = @v_selected_versionkey
				  AND s.itemcategorycode = @v_componenttype
				  
			   OPEN specs_cursor
			   
			   FETCH specs_cursor INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey
			   
			   WHILE @@fetch_status = 0 BEGIN
			      
				   IF @v_taqversionspecategorykey > 0 BEGIN
						SELECT @v_gpo_section_desc = speccategorydescription
						  FROM taqversionspecitems_view WHERE taqversionspecategorykey = @v_taqversionspecategorykey
						  
						SELECT @v_sortorder = sortorder
						  FROM taqversionspeccategory WHERE taqversionspecategorykey = @v_taqversionspecategorykey
						  
						IF @v_sortorder IS NULL
						  SELECT @v_sortorder = sortorder FROM gentables WHERE tableid = 616 AND datacode = @v_componenttype
						  -- SELECT @v_sortorder = itemcategorycode
							 --FROM taqversionspeccategory WHERE taqversionspecategorykey = @v_taqversionspecategorykey
						   --SET @v_sortorder = 0
									  
						SELECT @v_quantity = quantity
						  FROM taqversionspeccategory WHERE taqversionspecategorykey = @v_relatedspeccategorykey
						  
						  IF coalesce(@v_relatedspeccategorykey,0)=0
						  begin
							SELECT @v_quantity = quantity
							FROM taqversionspeccategory WHERE taqversionspecategorykey = @v_taqversionspecategorykey
						  end
						   
				   END 		   
				   
				   
				   SELECT @v_component_section_count = COUNT(*) FROM gposection
				   WHERE gpokey = @i_gpokey AND sectiontype = @v_title_printing_component_section
				     AND key1 = @v_bookkey AND key2 = @v_printingkey AND key3 = @v_taqversionspecategorykey
				     
				   IF @v_component_section_count = 0
				   BEGIN
				     
				   	
				   --write gposection row for the component 
				   exec get_next_key @lastuserid_var, @new_gposectionkey output
				    
				   INSERT INTO gposection (gpokey,sectionkey,sectiontype,key1,key2,key3,quantity,description,lastuserid,lastmaintdate)
						VALUES(@i_gpokey,@new_gposectionkey,@v_title_printing_component_section,@v_bookkey,@v_printingkey,
						   @v_taqversionspecategorykey,@v_quantity,@v_gpo_section_desc,@lastuserid_var,getdate())
							  			   
				   EXEC qpo_generate_gpocost @i_related_projectkey,@v_taqprojectkey,@i_gpokey,@new_gposectionkey,0,
					@v_quantity,@v_taqversionspecategorykey,@v_itemcategorycode,@v_selected_versionkey,@v_report_detail_display_type,@v_sortorder,
					@v_gpo_section_desc,@lastuserid_var,@o_error_code,@o_error_desc
					
				   SELECT @o_error_code = @@ERROR
				   IF @o_error_code <> 0 BEGIN
					SET @o_error_code = -1
					SET @o_error_desc = 'Could not get generate gpocost rows'
				   END
				   
				   
				   SET @v_count5 = 0
				   SET @v_gpodetail_written = 0
				   SET @v_detail = 0
			         
			        IF @v_relatedspeccategorykey > 0 
					   DECLARE specs_category_cursor CURSOR FOR 
						  SELECT distinct i.taqversionspecategorykey, i.plstagecode, i.taqversionformatkey,i.itemcategorycode,COALESCE(i.speccategorydescription,''),
								COALESCE(i.itemcode,0),COALESCE(i.itemdesc,''), COALESCE(i.itemdetaildesc,''),COALESCE(i.quantity,0), COALESCE(description,''),
								COALESCE(i.unitofmeasuredesc,''),COALESCE(i.description2,''),COALESCE(i.decimalvalue,0),
								COALESCE(sg.sortorder , gi.sortorder) itemsortorder
						   FROM taqversionspecitems_view  i
						   INNER JOIN subgentables sg ON i.itemcode = sg.datasubcode AND i.itemcategorycode = sg.datacode AND sg.tableid = 616
                           INNER JOIN gentablesitemtype gi ON gi.tableid = sg.tableid AND gi.datacode = sg.datacode AND gi.datasubcode = sg.datasubcode
						  WHERE i.taqprojectkey = @i_related_projectkey
							AND i.taqversionkey = @v_selected_versionkey
							AND i.itemcategorycode = @v_componenttype
							AND i.taqversionspecategorykey = @v_taqversionspecategorykey
							AND i.relatedspeccategorykey = @v_relatedspeccategorykey
 						    AND i.itemcode > 0
 						    --AND sg.sortorder > 0
							AND gi.itemtypecode = (select datacode from subgentables where tableid = 550 and qsicode = 40)
							ORDER BY itemsortorder
			  	    ELSE
						DECLARE specs_category_cursor CURSOR FOR 
						  SELECT distinct i.taqversionspecategorykey, i.plstagecode, i.taqversionformatkey,i.itemcategorycode,COALESCE(i.speccategorydescription,''),
								COALESCE(i.itemcode,0),COALESCE(i.itemdesc,''), COALESCE(i.itemdetaildesc,''),COALESCE(i.quantity,0), COALESCE(description,''),
								COALESCE(i.unitofmeasuredesc,''),COALESCE(i.description2,''),COALESCE(i.decimalvalue,0),
								COALESCE(sg.sortorder , gi.sortorder) itemsortorder
						   FROM taqversionspecitems_view  i
						   INNER JOIN subgentables sg ON i.itemcode = sg.datasubcode AND i.itemcategorycode = sg.datacode AND sg.tableid = 616
                           INNER JOIN gentablesitemtype gi ON gi.tableid = sg.tableid AND gi.datacode = sg.datacode AND gi.datasubcode = sg.datasubcode
						  WHERE i.taqprojectkey = @i_related_projectkey
							AND i.taqversionkey = @v_selected_versionkey
							AND i.itemcategorycode = @v_componenttype
							AND i.taqversionspecategorykey = @v_taqversionspecategorykey
							AND (i.relatedspeccategorykey IS NULL OR i.relatedspeccategorykey = 0)
							AND i.itemcode > 0
							--AND sg.sortorder > 0
							AND gi.itemtypecode = (select datacode from subgentables where tableid = 550 and qsicode = 40)
							ORDER BY itemsortorder

							
					  
				   OPEN specs_category_cursor 

				   FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
						 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2, @v_spec_description,
						 @v_unitofmeasuredesc_spec,@v_spec_description2,@v_decimalvalue,@v_specitem_sort
							
				   WHILE @@fetch_status = 0 BEGIN
				 	     					 	
					 SELECT @v_count5 = COUNT(*)
					   FROM taqversionspecitems_view  s, taqspecadmin t
					  WHERE s.taqprojectkey = @i_related_projectkey
		 				AND s.taqversionkey = @v_selected_versionkey
						AND s.itemcategorycode = @v_componenttype
						AND s.itemcategorycode = t.itemcategorycode
						AND s.itemcode = t.itemcode
						AND t.culturecode = @v_culturecode
								 
					  SET @v_count_detail = 0
								  			  
					  IF @v_count5 > 0 AND (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '') OR 
					      (@v_quantity2 IS NOT NULL AND @v_quantity2 <> '') OR 
					      (@v_spec_description IS NOT NULL AND @v_spec_description <> '') BEGIN  -- specitems exist for this component
					  
					      IF ltrim(rtrim(@v_speccategorydescription)) <> '' BEGIN
								    
							  SELECT @v_count_detail = COUNT(*)
								FROM gpodetail
							   WHERE gpokey = @i_gpokey
								 AND sectionkey = @new_gposectionkey
								 AND detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
							 
							  IF @v_count_detail = 0 BEGIN
								SET @v_detaillinenbr = @v_detaillinenbr + 100
							    
								IF @v_detaillinenbr > 100 BEGIN
									
									SET @v_detail = ''
											
									exec get_next_key @lastuserid_var, @new_detailkey output
																
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
								END
							  
								
								SET @v_detaillinenbr = @v_detaillinenbr + 100
								SET @v_detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
												
												
								exec get_next_key @lastuserid_var, @new_detailkey output
								
								INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
									
								SET @v_detaillinenbr = @v_detaillinenbr + 100
								SET @v_detail = ''
												
												
								exec get_next_key @lastuserid_var, @new_detailkey output
								
								INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
							END
							 
						  END  --@v_count_detail = 0
					 END  -- @v_count5 > 0
					 ELSE BEGIN --@v_count5 = 0 No specitems for this component
						SELECT @v_count6 = 0 
					 
						IF @v_relatedspeccategorykey > 0 OR @v_taqversionspecategorykey > 0 BEGIN									  
							IF @v_relatedspeccategorykey > 0 
					  			  SELECT @v_count6 = COUNT(*)
									FROM taqversionspecnotes 
								   WHERE taqversionspecategorykey = @v_relatedspeccategorykey
									 AND showonpoind = 1 
									  		  
						ELSE
							IF @v_taqversionspecategorykey > 0 
								  SELECT @v_count6 = COUNT(*)
									FROM taqversionspecnotes 
								   WHERE taqversionspecategorykey = @v_taqversionspecategorykey
									 AND showonpoind = 1 
									 
						END
						IF @v_count6 > 0  BEGIN  -- notes exist
							IF ltrim(rtrim(@v_speccategorydescription)) = '' BEGIN
							
							    SELECT @v_speccategorydescription = datadesc
							      FROM gentables WHERE tableid = 616 AND datacode = @v_componenttype
							END
							      
								SELECT @v_count_detail = COUNT(*)
									FROM gpodetail
								   WHERE gpokey = @i_gpokey
									 AND sectionkey = @new_gposectionkey
									 AND detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
								 
								  IF @v_count_detail = 0 BEGIN
									SET @v_detaillinenbr = @v_detaillinenbr + 100
								    
									IF @v_detaillinenbr > 100 BEGIN
										
										SET @v_detail = ''
												
										exec get_next_key @lastuserid_var, @new_detailkey output
																	
										INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
										 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
									END
								  
									
									SET @v_detaillinenbr = @v_detaillinenbr + 100
									SET @v_detail = '**** ' + ltrim(rtrim(@v_speccategorydescription)) + ' ****'
													
													
									exec get_next_key @lastuserid_var, @new_detailkey output
									
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
										VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
										
									SET @v_detaillinenbr = @v_detaillinenbr + 100
									SET @v_detail = ''
													
													
									exec get_next_key @lastuserid_var, @new_detailkey output
									
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
										VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,@lastuserid_var,getdate(),1)
								END
							--END --IF ltrim(rtrim(@v_speccategorydescription)) = '' BEGIN
						END --@v_count6 > 0  No specitems but notes exist
					 END --@v_count5 = 0 No specitems
							
					 IF @v_count5 > 0 AND ltrim(rtrim(@v_speccategorydescription)) <> '' BEGIN  
					   SET @v_detail = ''
					   
					   SELECT @v_showqtyind=COALESCE(showqtyind,0),@v_showqtylabel=COALESCE(ltrim(rtrim(showqtylabel)),''),@v_showdecimalind=COALESCE(showdecimalind,0),
						   @v_showdecimallabel=COALESCE(ltrim(rtrim(showdecimallabel)),''),
						   --@v_showdecimallabel=COALESCE(showdecimalind,0),
						   @v_showdescind=COALESCE(showdescind,0),@v_showdesclabel=COALESCE(ltrim(rtrim(showdesclabel)),''),@v_showunitofmeasureind=COALESCE(showunitofmeasureind,0),
						   @v_defaultunitofmeasurecode=COALESCE(defaultunitofmeasurecode,0),@v_showinsummaryind=COALESCE(showinsummaryind,0),
						   @v_showdesc2ind=COALESCE(showdesc2ind,0),@v_showdesc2label=COALESCE(ltrim(rtrim(showdesc2label)),''),@v_itemlabel=COALESCE(ltrim(rtrim(itemlabel)),'')
						   FROM taqspecadmin
						  WHERE itemcategorycode = @v_itemcategorycode
							AND itemcode = @v_itemcode
							AND culturecode = @v_culturecode
							
					   IF @v_unitofmeasuredesc_spec IS NOT NULL AND @v_unitofmeasuredesc_spec <> '' 
						 SET @v_unitofmeasuredesc = @v_unitofmeasuredesc_spec
					    
					    
					   IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '') OR 
					      (@v_quantity2 IS NOT NULL AND @v_quantity2 <> '') OR 
					      (@v_spec_description IS NOT NULL AND @v_spec_description <> '') BEGIN
					    
						 IF @v_itemlabel IS NOT NULL AND @v_itemlabel <> ''
							SET @v_detail = @v_itemlabel + ': '
						 ELSE
							SET @v_detail = @v_itemdesc + ': '
							
						IF @v_showdescind > 0 OR @v_showdesc2ind > 0 BEGIN
						--IF @v_showdescind > 0 AND (@v_showdesclabel IS NOT NULL OR @v_showdesclabel <> '') BEGIN
							IF @v_showdescind > 0 BEGIN
																						
								IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '') BEGIN
									SET @v_detail = @v_detail +  @v_itemdetaildesc
									
																		
									IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 
										 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description AND CONVERT(VARCHAR(20),@v_quantity2) <> @v_itemdetaildesc) 
									  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
										SET @v_detail = @v_detail + ', ' + @v_showqtylabel + CONVERT(VARCHAR(20),@v_quantity2)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_quantity2)
										
									IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
									  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
										SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
																									  
									IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
									    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
											SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
										ELSE
											SET @v_detail = @v_detail + ' ' + @v_spec_description
									ELSE IF @v_spec_description IS NULL
										SET @v_spec_description = ''
										
									IF (@v_spec_description2 IS NOT NULL AND @v_spec_description2 <> '') AND @v_showdesc2ind > 0 AND 
										 (@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '')
									    SET @v_detail = @v_detail + ', ' + @v_showdesc2label + ' ' + @v_spec_description2
																																											
									IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
									  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
									END 
								END
								ELSE IF @v_itemdetaildesc IS NULL OR @v_itemdetaildesc = '' BEGIN
								
								    IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description)
									  IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
									    SET @v_detail = @v_detail + ', ' + @v_showqtylabel +  CONVERT(VARCHAR(20),@v_quantity2)
									  ELSE
										SET @v_detail = @v_detail +  ', ' + CONVERT(VARCHAR(20),@v_quantity2)
										
									IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
									  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
										SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
										
									IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
									    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
											SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
										ELSE
											SET @v_detail = @v_detail + ' ' + @v_spec_description
									ELSE IF @v_spec_description IS NULL
										SET @v_spec_description = ''
									  
									IF (@v_spec_description2 IS NOT NULL AND @v_spec_description2 <> '')AND @v_showdesc2ind > 0 AND 
										(@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '')
									   SET @v_detail = @v_detail + ' ' + @v_showdesc2label + ' ' + @v_spec_description2
																								
									IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
									  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
									END 
								END
							END 			
							--ELSE IF @v_showdesc2ind > 0 AND (@v_showdesc2label IS NOT NULL OR @v_showdesc2label <> '') BEGIN
							ELSE IF @v_showdesc2ind > 0 BEGIN
							 															
								IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '') BEGIN
									SET @v_detail = @v_detail +  @v_itemdetaildesc
									
									
								IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description AND  CONVERT(VARCHAR(20),@v_quantity2) <> @v_itemdetaildesc) 
								   IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
									SET @v_detail = @v_detail + ', ' + @v_showqtylabel + CONVERT(VARCHAR(20),@v_quantity2)
								   ELSE
									SET @v_detail = @v_detail +  ', ' +CONVERT(VARCHAR(20),@v_quantity2) 
									
								IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
									  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
										SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
																																	  
								IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
								    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
										SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
									ELSE
										SET @v_detail = @v_detail + ' ' + @v_spec_description
								ELSE IF @v_spec_description IS NULL
									SET @v_spec_description = ''
																								
								IF (@v_spec_description2 IS NOT NULL AND @v_spec_description2 <> '') AND (@v_spec_description2 <> @v_itemdetaildesc) AND (@v_spec_description2 <> @v_spec_description)
								    IF (@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '') 
										SET @v_detail =  @v_detail + ', ' +@v_showdesc2label  +  @v_spec_description2
									ELSE
										SET @v_detail = @v_detail + ', ' + @v_spec_description2
																								
								IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 
								  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
								 
							END
							ELSE IF @v_itemdetaildesc IS NULL OR @v_itemdetaildesc = '' BEGIN
							   IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description) 
								       IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
									    SET @v_detail = @v_detail + ', ' + @v_showqtylabel + CONVERT(VARCHAR(20),@v_quantity2)
									  ELSE
										SET @v_detail = @v_detail +  CONVERT(VARCHAR(20),@v_quantity2) 
									
								IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
									  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
										SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
							
								IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
								    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
										SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
									ELSE
										SET @v_detail = @v_detail + ' ' + @v_spec_description
								ELSE IF @v_spec_description IS NULL
									SET @v_spec_description = ''
									
								IF (@v_spec_description2 IS NOT NULL AND @v_spec_description2 <> '') AND (@v_spec_description2 <> @v_itemdetaildesc) AND (@v_spec_description2 <> @v_spec_description)
								    IF (@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '') 
										SET @v_detail =  @v_detail + ', ' +@v_showdesc2label  +  @v_spec_description2
									ELSE
										SET @v_detail = @v_detail + ', ' + @v_spec_description2
								  
								IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
								  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
				   				END 
							END
						  END
						END	--IF @v_showdescind > 0 OR @v_show2descind > 0
						ELSE BEGIN
							IF (@v_itemdetaildesc IS NOT NULL AND @v_itemdetaildesc <> '' )BEGIN
								SET @v_detail = @v_itemdesc + ': ' 
														     
								SET @v_detail =  @v_detail +  @v_itemdetaildesc
								
								IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (@v_quantity2 <> @v_itemdetaildesc AND @v_quantity2 <> @v_spec_description)
									 IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
									    SET @v_detail = @v_detail + ', ' + @v_showqtylabel + CONVERT(VARCHAR(20),@v_quantity2)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_quantity2)
										
								IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
									  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
										SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
									  ELSE
										SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
																		  
								IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
								    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
										SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
									ELSE
										SET @v_detail = @v_detail + ' ' + @v_spec_description
								ELSE IF @v_spec_description IS NULL
									SET @v_spec_description = ''
									
								IF (@v_spec_description2 IS NOT NULL AND @v_spec_description2 <> '') AND (@v_spec_description2 <> @v_itemdetaildesc) AND (@v_spec_description2 <> @v_spec_description)
								    IF (@v_showdesc2label IS NOT NULL AND @v_showdesc2label <> '') 
										SET @v_detail =  @v_detail + ', ' +@v_showdesc2label  +  @v_spec_description2
									ELSE
										SET @v_detail = @v_detail + ', ' + @v_spec_description2
									
																	
								IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
									SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
								END 
							END
							ELSE IF (@v_itemdetaildesc IS NULL OR @v_itemdetaildesc =  '') BEGIN
								SET @v_detail = @v_itemdesc + ': ' 
								
								IF @v_quantity2 IS NOT NULL AND @v_showqtyind = 1 AND (CONVERT(VARCHAR(20),@v_quantity2) <> @v_spec_description)
								     IF @v_showqtylabel IS NOT NULL AND @v_showqtylabel <> '' 
									    SET @v_detail = @v_detail + ', ' + @v_showqtylabel + CONVERT(VARCHAR(20),@v_quantity2)
									 ELSE
										SET @v_detail = @v_detail + ' ' + CONVERT(VARCHAR(20),@v_quantity2)
										
								IF (@v_decimalvalue IS NOT NULL AND @v_decimalvalue > 0) AND (@v_showdecimalind = 1) 
								  IF @v_showdecimallabel IS NOT NULL AND @v_showdecimallabel <> ''
									SET @v_detail = @v_detail + ', ' + @v_showdecimallabel + CONVERT(VARCHAR(20),@v_decimalvalue)
								  ELSE
									SET @v_detail = @v_detail + ', ' + CONVERT(VARCHAR(20),@v_decimalvalue)
										
								IF (@v_spec_description IS NOT NULL AND @v_spec_description <> '') AND (@v_spec_description <> @v_itemdetaildesc) 
								    IF (@v_showdesclabel IS NOT NULL AND @v_showdesclabel <> '') AND (@v_spec_description IS NOT NULL AND @v_spec_description <> '')
										SET @v_detail = @v_detail + ', ' + @v_showdesclabel + ' ' + @v_spec_description	
									ELSE
										SET @v_detail = @v_detail + ' ' + @v_spec_description
								ELSE IF @v_spec_description IS NULL
									SET @v_spec_description = ''
									
													
								IF @v_showunitofmeasureind = 1 AND @v_defaultunitofmeasurecode > 0 BEGIN
								  SET @v_detail = @v_detail + ' ' + @v_unitofmeasuredesc
								END 
							END
						   END
						 END  --IF @v_itemdetaildesc IS NOT NULL OR @v_quantity2 IS NOT NULL OR @v_spec_description IS NOT NULL
										 
										 
								   
						 IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
						  SET @v_detaillinenbr = @v_detaillinenbr + 100
						  
						  exec get_next_key @lastuserid_var, @new_detailkey output
						    
						  INSERT INTO gpodetail(gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,detailtype,lastuserid,lastmaintdate)
							VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,1,@lastuserid_var,getdate())
							  
						END
					 END  --@v_count5 > 0
										
					 			 
					 FETCH specs_category_cursor INTO @v_taqversionspecategorykey,@v_plstagecode,@v_taqversionformatkey,@v_itemcategorycode,
						 @v_speccategorydescription,@v_itemcode,@v_itemdesc,@v_itemdetaildesc,@v_quantity2, @v_spec_description,
						 @v_unitofmeasuredesc_spec,@v_spec_description2,@v_decimalvalue,@v_specitem_sort
					END --@@fetch_status = 0 for specs_category_cursor
						
					CLOSE specs_category_cursor 
					DEALLOCATE specs_category_cursor 
					
					SELECT @v_externalcode = externalcode FROM gentables WHERE tableid = 616 and datacode = @v_componenttype
					
					IF @v_externalcode = 2 BEGIN  --Bind PO
						SELECT @v_coverdue = COALESCE(activedate, NULL), @v_taqtasknote = COALESCE(taqtasknote,NULL) from taqprojecttask WHERE datetypecode in
						   (SELECT datetypecode FROM datetype WHERE qsicode = 25) AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						   
						   select @v_taskdesc = description from datetype where qsicode=25
						  
						 IF  @v_coverdue IS NOT NULL OR @v_taqtasknote IS NOT NULL  BEGIN
						    SET @v_detail = '* '+@v_taskdesc+': '--'* Cover Due Date: '   
						    
						    IF @v_coverdue IS NOT NULL BEGIN
								SELECT @v_date_string = CONVERT(VARCHAR, @v_coverdue, 101)
								SET @v_detail = @v_detail + @v_date_string
							END
							IF @v_taqtasknote IS NOT NULL
								SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)
								
						    IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
								  SET @v_detaillinenbr = @v_detaillinenbr + 100
								  
								  exec get_next_key @lastuserid_var, @new_detailkey output
								    
								  INSERT INTO gpodetail(gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,detailtype,lastuserid,lastmaintdate)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,1,@lastuserid_var,getdate())
							END
						 END  -- Cover Due is not null
						
						SELECT @v_jacketdue = COALESCE(activedate, NULL), @v_taqtasknote = COALESCE(taqtasknote,NULL)  from taqprojecttask WHERE datetypecode in
						   (SELECT datetypecode FROM datetype WHERE qsicode = 26) AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						   
						   select @v_taskdesc= null
						   select @v_taskdesc = description from datetype where qsicode=26
						  
						IF  @v_jacketdue IS NOT NULL OR @v_taqtasknote IS NOT NULL BEGIN
						     SET @v_detail = '* '+@v_taskdesc+': '--'* Jacket Due Date: '   
						    IF  @v_jacketdue IS NOT NULL BEGIN 
								SELECT @v_date_string = CONVERT(VARCHAR, @v_jacketdue, 101)
								SET @v_detail = '* '+@v_taskdesc+': '/*'* Jacket Due Date: '*/ + @v_date_string
							END
							IF @v_taqtasknote IS NOT NULL
								SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)
						    IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
								  SET @v_detaillinenbr = @v_detaillinenbr + 100
								  
								  exec get_next_key @lastuserid_var, @new_detailkey output
								    
								  INSERT INTO gpodetail(gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,detailtype,lastuserid,lastmaintdate)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,1,@lastuserid_var,getdate())
							END
						 END  -- Jacket Due is not null
						
						
						 SELECT @v_miscdue = COALESCE(activedate, NULL), @v_taqtasknote = COALESCE(taqtasknote,NULL)  from taqprojecttask WHERE datetypecode in
						   (SELECT datetypecode FROM datetype WHERE qsicode = 27) AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						   
						   select @v_taskdesc= null
						   select @v_taskdesc = description from datetype where qsicode=27
						   
						 IF  @v_miscdue IS NOT NULL OR @v_taqtasknote IS NOT NULL BEGIN
						    SET @v_detail = '* '+@v_taskdesc+': '--'* Miscellaneous Due Date: '  
						     IF  @v_miscdue IS NOT NULL BEGIN
								SELECT @v_date_string = CONVERT(VARCHAR, @v_miscdue, 101)
								SET @v_detail = @v_detail + @v_date_string
							END
							IF @v_taqtasknote IS NOT NULL
								SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)
								
						    IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
								  SET @v_detaillinenbr = @v_detaillinenbr + 100
								  
								  exec get_next_key @lastuserid_var, @new_detailkey output
								    
								  INSERT INTO gpodetail(gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,detailtype,lastuserid,lastmaintdate)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,1,@lastuserid_var,getdate())
							END
						 END  -- Miscellaneous Due is not null 
						
						
						SELECT @v_filmreprodue  = COALESCE(activedate, NULL), @v_taqtasknote = COALESCE(taqtasknote,NULL)  from taqprojecttask WHERE datetypecode in
						   (SELECT datetypecode FROM datetype WHERE qsicode = 34) AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						   
						   select @v_taskdesc= null
						   select @v_taskdesc = description from datetype where qsicode=34
						   
						 IF  @v_filmreprodue  IS NOT NULL OR @v_taqtasknote IS NOT NULL BEGIN
						    SET @v_detail = '* '+@v_taskdesc+': '--'* Film/Repro Due: '  
						     IF  @v_filmreprodue IS NOT NULL BEGIN
								SELECT @v_date_string = CONVERT(VARCHAR, @v_filmreprodue, 101)
								SET @v_detail = @v_detail + @v_date_string
							END
							IF @v_taqtasknote IS NOT NULL
								SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)
								
						    IF @v_detail <> '' AND @v_detail IS NOT NULL BEGIN
								  SET @v_detaillinenbr = @v_detaillinenbr + 100
								  
								  exec get_next_key @lastuserid_var, @new_detailkey output
								    
								  INSERT INTO gpodetail(gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,detailtype,lastuserid,lastmaintdate)
									VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,0,@v_detaillinenbr,@v_detail,1,@lastuserid_var,getdate())
							END
						 END  -- Miscellaneous Due is not null  
					END -- Bind PO
					
					
					IF @v_relatedspeccategorykey > 0 OR @v_taqversionspecategorykey > 0 BEGIN									  
					  IF @v_relatedspeccategorykey > 0 
						DECLARE notes_cur CURSOR FOR
							  SELECT [text]
								FROM taqversionspecnotes 
							   WHERE taqversionspecategorykey = @v_relatedspeccategorykey
								 AND showonpoind = 1 
								  ORDER BY sortorder ASC			  
					  ELSE
						DECLARE notes_cur CURSOR FOR
							  SELECT [text]
								FROM taqversionspecnotes 
							   WHERE taqversionspecategorykey = @v_taqversionspecategorykey
								 AND showonpoind = 1 
								  ORDER BY sortorder ASC
								 
					  OPEN notes_cur 

					  FETCH notes_cur INTO @v_commenttext
	  					
					  WHILE @@fetch_status = 0 BEGIN							 
								 
						 IF LEN(CONVERT(VARCHAR(250), @v_commenttext)) > 0 BEGIN
							SET @v_sequence = @v_sequence + 1
							SET @v_length = 250
											
							WHILE LEN(@v_commenttext) > 0 BEGIN
								IF LEN(@v_commenttext) <= 250 BEGIN
   							  SET @length = 0
								  SET @v_string = @v_commenttext
								  SET @v_commenttext = right(@v_commenttext,(len(@v_commenttext) - @length))
											      
								  IF @v_string <> '' BEGIN
									  
									SET @v_detaillinenbr = @v_detaillinenbr + 100
												    
									exec get_next_key @lastuserid_var, @new_detailkey output
													    
									INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
										 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_string,@lastuserid_var,getdate(),1)
													 
									SET @v_gpodetail_written = @v_gpodetail_written + 1
														  
								  END
								  BREAK
								END
								ELSE BEGIN  
									SET @substring = LEFT(@v_commenttext,@v_length)
									
									--check if last pos is a space
									IF RIGHT(@v_commenttext,@v_length) <> ' ' BEGIN
													
										SET @reversestring = REVERSE(@substring)
										SET @spacepos = CHARINDEX(' ',@reversestring)
										SET @trimmedreversestring = SUBSTRING(@reversestring,@spacepos,len(@reversestring))
										SET @trimmednormalreversestring = REVERSE(@trimmedreversestring)
										SET @v_string =  @trimmednormalreversestring
										SET @length = len(@trimmednormalreversestring)
										SET @v_commenttext = right(@v_commenttext,(len(@v_commenttext) - @length))
															
									END
									ELSE BEGIN
										SET @v_string =  @v_string
										IF LEN(@v_commenttext) = @v_length OR LEN(@v_commenttext) > @v_length
											SET @v_commenttext = RIGHT(@v_commenttext,LEN(@v_commenttext) - (@v_length - 1))
										ELSE
											SET @v_commenttext = @v_commenttext
										END  
									END							
												
									IF @v_string <> '' AND @v_string IS NOT NULL BEGIN
									 
										SET @v_detaillinenbr = @v_detaillinenbr + 100
										exec get_next_key @lastuserid_var, @new_detailkey output
										INSERT INTO gpodetail (gpokey,detailkey,sectionkey,subsectionkey,detaillinenbr,detail,lastuserid,lastmaintdate,detailtype)
										 VALUES(@i_gpokey,@new_detailkey,@new_gposectionkey,COALESCE(@new_gposubsectionkey,0),@v_detaillinenbr,@v_string,@lastuserid_var,getdate(),1)
										SET @v_gpodetail_written = @v_gpodetail_written + 1
									END
									IF (LEN(@v_commenttext)= 0)
										BREAK
												
									SET @v_sequence = @v_sequence + 1
								END
							 END
							 
  						 FETCH notes_cur INTO @v_commenttext	 
						END -- cursor
					    
						CLOSE notes_cur 
						DEALLOCATE notes_cur 
				    
					END --IF @v_relatedspeccategorykey> 0 BEGIN
					
					END --IF @v_component_section_count = 0
				   
				    FETCH specs_cursor INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey
			    	   
			    END --@@fetch_status = 0 for specs_cursor
					
			    CLOSE specs_cursor 
			    DEALLOCATE specs_cursor 	
	 						  
				FETCH components_cur INTO @v_componenttype, @v_component_sortorder	  
			   END  --@@fetch_status = 0 for components_cur
		       
			   CLOSE components_cur 
			   DEALLOCATE components_cur
	END --@v_count = 1
END --IF @v_report_detail_display_type = 3 OR @v_report_detail_display_type = 0

GO

GRANT EXEC ON [dbo].[qpo_generate_po_details] to PUBLIC
GO
