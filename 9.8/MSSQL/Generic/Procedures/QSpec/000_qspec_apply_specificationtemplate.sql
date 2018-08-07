if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_apply_specificationtemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_apply_specificationtemplate
GO

CREATE PROCEDURE qspec_apply_specificationtemplate
 (@i_projectkey     integer,
  @i_specificationtemplatekey integer, 
  @i_taqprojectformatkey integer,
  @i_itemtype     integer,
  @i_usageclass   integer,
  @i_userid       VARCHAR(30),
  @i_actionvalue  integer,  
  @i_optionflags  integer,  
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qspec_apply_specificationtemplate
**  Desc: This stored procedure applies the P&L spec items for given version/format.
**       @i_actionvalue = 1 - Overwrite Existing data
**                      = 2 - Leave Existing Data, Add New Values
**  Auth: Uday A. Khisty
**  Date: June 5, 2014
**
**  Modified: CO'C Oct 27, 2015
**       @i_actionvalue = 1 - Overwrite - All
**                      = 2 - Overwrite - All But Summary Component
**                      = 3 - Overwrite - Only Like Components
**                      = 4 - Leave Existing Data, Add New Values
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**  04/05/2016   Kate        Case 37356 - Issues with apply spec template for more than 1 format
**  04/14/16     Kusum       Case 37540 - Issues with copying component notes when apply spec template
**  05/04/16     Uday        Case 37831 - Issues with applying spec templates in the P&L for non production on the web clients 
**  07/12/16     Colman      Case 39064 - Deactivated Spec Items showing up on Summary Specs 
**  04/19/17     Colman      Case 44464 - Costs are not being copied when a component is copied
**  04/27/17     Colman      Case 44464 - Recalculate component quantities after applying template
**  05/08/17     Colman      Case 44464 - Apply specs from template selected version
**  06/14/17     Colman      Case 45536 - Comp Quantity needs to be copied in some Copy Specs situations and not in others
**  08/09/17     Colman      Case 46540 - Copy quantity flag applies to spec categories only, not spec items
**  08/24/17     Colman      Case 46785 - Printing costs appearing on Purchase Order and not actually copied
**  09/27/17     Colman      Case 46419 - Allow for copy components and costs from PO template for components that exist on the PO 
**  01/10/17     Colman      Case 49067 - Prevent duplicate key errors in taqversioncosts
**  02/23/18     Colman      Case 49637 - Prevent users from adding the summary component to purchase orders
*****************************************************************************************************/
  
DECLARE
  @v_isopentrans TINYINT,
  @v_error    INT,
  @v_rowcount INT,
  @v_categorykey_template INT,
  @v_categorykey_project INT,
  @v_categorykey_temp INT,
  @v_itemkey INT,  
  @v_notekey INT,  
  @v_taqversionspecategorykey_new INT,
  @v_taqversionspecitemkey_new INT,
  @v_taqversionspecnotekey_new INT,
  @v_maxsortoder_notes INT,
  @v_plstage_project INT,
  @v_plstage_template INT,
  @v_versionkey_project INT,
  @v_versionkey_template INT,
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
  @v_speccategorydescription2 VARCHAR(255),
  @v_vendorcontactkey INT,
  @v_globalcontactkey_for_vendor INT,
  @v_copynextprtgind INT,
  @v_add_multiples INT,
  @v_count INT,
  @v_categoriesaffected INT,
  @v_printingnum INT,
  @v_flag_dontcopyquantities INT,
  @v_copyquantitiesind INT,
  @v_isrelated TINYINT,
  @v_debug INT
  
BEGIN

   -- exec qutl_trace 'qspec_apply_specificationtemplate',
     -- '@i_projectkey', @i_projectkey, NULL,
     -- '@i_taqprojectformatkey', @i_taqprojectformatkey, NULL,
     -- '@i_actionvalue', @i_actionvalue, NULL,
     -- '@i_specificationtemplatekey', @i_specificationtemplatekey, NULL

  SET @v_debug = 0
  
  IF @v_debug = 1 BEGIN
    DECLARE @v_dbgstr1 varchar(100), @v_dbgstr2 varchar(100)
    SET NOCOUNT ON
  END
   
  SET @v_isopentrans = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_maxsortoder_notes = 0
  SET @v_isApplySpecficationByFormat = 0
  SET @v_Is_Destination_Printing = 0
  SET @v_Is_Destination_PurchaseOrder = 0
  SET @v_exists_summary_component = 0
  SET @v_add_multiples = 0;
  SET @v_globalcontactkey_for_vendor = NULL
  SET @v_categoriesaffected = 0
  SET @v_copyquantitiesind = 1

  -- Option flag values
  SET @v_flag_dontcopyquantities = 0x01

  IF (@i_optionflags & @v_flag_dontcopyquantities) > 0
    SET @v_copyquantitiesind = 0
    
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
   
  SELECT @v_plstage_project = plstagecode, @v_versionkey_project = taqversionkey 
  FROM taqversionformat 
  WHERE taqprojectkey = @i_projectkey AND  taqprojectformatkey = @i_taqprojectformatkey
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Invalid plstagecode.'
    RETURN
  END

  IF @v_rowcount <= 0 BEGIN
    EXEC qpl_check_taqversion @i_projectkey, 0, 0, @i_taqprojectformatkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

    SELECT @v_plstage_project = plstagecode, @v_versionkey_project = taqversionkey 
    FROM taqversionformat 
    WHERE taqprojectformatkey = @i_taqprojectformatkey
  END

  SELECT @v_plstage_template = dbo.qpl_get_most_recent_stage(@i_specificationtemplatekey)
  SELECT @v_versionkey_template = dbo.qpl_get_selected_version(@i_specificationtemplatekey)
  
  IF @v_debug = 1 BEGIN
    PRINT '@i_projectkey: ' + convert(varchar, @i_projectkey)  
    PRINT '@i_taqprojectformatkey: ' + convert(Varchar, @i_taqprojectformatkey)  
    PRINT '@v_plstage_project: ' + convert(varchar, @v_plstage_project)
    PRINT '@v_versionkey_project: ' + convert(varchar, @v_versionkey_project)
    PRINT '@i_itemtype: ' + convert(varchar, @i_itemtype)
    PRINT '@i_usageclass: ' + convert(Varchar, @i_usageclass)
    PRINT '@i_actionvalue: ' + convert(varchar, @i_actionvalue)
    PRINT '@i_specificationtemplatekey: ' + convert(varchar, @i_specificationtemplatekey)
    PRINT '@v_plstage_template: ' + convert(varchar, @v_plstage_template)
    PRINT '@v_versionkey_template: ' + convert(varchar, @v_versionkey_template)
  END
  
   -- exec qutl_trace 'qspec_apply_specificationtemplate',
     -- '@v_plstage_project', @v_plstage_project, NULL,
     -- '@v_versionkey_project', @v_versionkey_project, NULL,
     -- '@i_itemtype', @i_itemtype, NULL,
     -- '@i_usageclass', @i_usageclass, NULL,
     -- '@v_plstage_template', @v_plstage_template, NULL,
     -- '@v_versionkey_template', @v_versionkey_template, NULL
  
  -- If Title Acquisition, need at least one format
  IF @i_itemtype = 3 AND @i_usageclass = 1 BEGIN
    IF NOT EXISTS (SELECT 1 FROM taqprojecttitle tpt 
       WHERE tpt.taqprojectkey = @i_projectkey and titlerolecode = 2)
    BEGIN
      SET @o_error_desc = 'You cannot add specifications without at least 1 acquisition Format.'
      GOTO RETURN_ERROR
    END
  END
  
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
  
  IF @v_debug = 1 BEGIN
    PRINT '@v_qsicode_template: ' + convert(varchar, @v_qsicode_template)
    PRINT '@v_qsicode_project: ' + convert(varchar, @v_qsicode_project)
  END
  
  -- exec qutl_trace 'qspec_apply_specificationtemplate',
    -- '@v_qsicode_template', @v_qsicode_template, NULL,
    -- '@v_qsicode_project', @v_qsicode_project, NULL
  
  -- @v_qsicode_template = 29: 'P&L Templates'
  -- @v_qsicode_project = 40: 'Printing' AND @v_qsicode_template = 1: 'Title Acquisition'
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
    WHERE mediatypecode = @v_mediatypecode_project 
      AND mediatypesubcode = @v_mediatypesubcode_project
      AND taqprojectkey = @i_specificationtemplatekey
      AND plstagecode = @v_plstage_template
      AND taqversionkey = @v_versionkey_template
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      RETURN  -- Not always guaranteed to have a format row (because of client option 119 that inserts row in code)
    END 

    IF @v_debug = 1 BEGIN
      PRINT '@v_mediatypecode_project: ' + convert(Varchar, @v_mediatypecode_project)
      PRINT '@v_mediatypesubcode_project: ' + convert(Varchar, @v_mediatypesubcode_project)
      PRINT '@v_taqprojectformatkey_template: ' + convert(varchar, @v_taqprojectformatkey_template)
	    PRINT '@v_isApplySpecficationByFormat: ' + convert(varchar, @v_isApplySpecficationByFormat)
    END
    
     -- exec qutl_trace 'qspec_apply_specificationtemplate',
       -- '@v_mediatypecode_project', @v_mediatypecode_project, NULL,
       -- '@v_mediatypesubcode_project', @v_mediatypesubcode_project, NULL,
       -- '@v_taqprojectformatkey_template', @v_taqprojectformatkey_template, NULL,
       -- '@v_isApplySpecficationByFormat', @v_isApplySpecficationByFormat
  END
  
  SET @v_printingnum = 1
  
  IF @v_qsicode_project = 40 BEGIN
    SET @v_Is_Destination_Printing = 1
    SET @v_itemtype_Printing = @i_itemtype
    SELECT @v_printingnum = printingnum FROM taqprojectprinting_view WHERE taqprojectkey = @i_projectkey
    
    SELECT @v_itemtype_Title = datacode 
    FROM gentables 
    WHERE tableid = 550 AND qsicode = 1
  END    
  ELSE IF @v_qsicode_project = 41 OR @v_qsicode_project = 51 BEGIN
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

  IF @i_actionvalue = 1 OR @i_actionvalue = 2 OR @i_actionvalue = 3 OR @v_isApplySpecficationByFormat = 1
  BEGIN    
  
    -- Find summary component if any 
    IF EXISTS (SELECT *
      FROM taqversionspeccategory
      WHERE taqprojectkey = @i_projectkey AND 
         plstagecode = @v_plstage_project AND 
         taqversionkey = @v_versionkey_project AND 
         taqversionformatkey = @i_taqprojectformatkey AND
         itemcategorycode = @v_summary_itemcategorycode) BEGIN
       
      SET @v_exists_summary_component = 1          
    END           

	  IF @i_actionvalue = 3 BEGIN
      -- Save keys of template categories that match those in project
		  SELECT * INTO #templatespecategorykey
		  FROM (
        SELECT taqversionspecategorykey
        FROM taqversionspeccategory
        WHERE taqprojectkey = @i_specificationtemplatekey
        AND relatedspeccategorykey IS NULL
        AND    (LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, '')))))    
            NOT IN ((SELECT LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))))
              FROM taqversionspeccategory  
              WHERE taqprojectkey = @i_specificationtemplatekey AND
               plstagecode  =  @v_plstage_template AND
               taqversionkey = @v_versionkey_template
            )  
           EXCEPT (SELECT convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))
             FROM taqversionspeccategory
             WHERE taqprojectkey = @i_projectkey AND
               plstagecode  =  @v_plstage_project AND
               taqversionkey = @v_versionkey_project AND
               taqversionformatkey = @i_taqprojectformatkey AND
               COALESCE(relatedspeccategorykey,0) = 0               
             UNION     
             SELECT convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))
             FROM taqversionspeccategory  WHERE taqversionspecategorykey IN  (SELECT relatedspeccategorykey 
                    FROM taqversionspeccategory
                    WHERE taqprojectkey = @i_projectkey AND
                      plstagecode  =  @v_plstage_project AND
                      taqversionkey = @v_versionkey_project AND
                      taqversionformatkey = @i_taqprojectformatkey AND
                      COALESCE (relatedspeccategorykey, 0) > 0)                   
          ))
		  ) ID

      DECLARE speccategory_cursor_delete CURSOR FOR
      SELECT taqversionspecategorykey
      FROM taqversionspeccategory
      WHERE taqprojectkey = @i_projectkey
      AND relatedspeccategorykey IS NULL
  	  AND (LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))))) IN    
		    ((SELECT LTRIM(RTRIM(convert(VARCHAR,COALESCE(itemcategorycode, -99)) + convert(VARCHAR,COALESCE(speccategorydescription, ''))))
			  FROM taqversionspeccategory  
			  WHERE taqprojectkey = @i_specificationtemplatekey AND taqversionspecategorykey IN (SELECT * FROM #templatespecategorykey)
		    ))

    END -- END IF @v_actionvalue = 3
    ELSE BEGIN
      -- If overwrite all, delete all costs regardless of component
      IF @i_actionvalue = 1 OR @i_actionvalue = 2
      BEGIN
        DELETE FROM taqversioncosts
        WHERE taqversionformatyearkey IN 
          (SELECT taqversionformatyearkey 
           FROM taqversionformatyear 
           WHERE taqprojectkey = @i_projectkey AND 
            plstagecode = @v_plstage_project AND 
            taqversionkey = @v_versionkey_project AND 
            taqprojectformatkey = @i_taqprojectformatkey)
      END
      

      DECLARE speccategory_cursor_delete CURSOR FOR
      SELECT taqversionspecategorykey
      FROM taqversionspeccategory
      WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @v_plstage_project AND 
          taqversionkey = @v_versionkey_project AND 
          taqversionformatkey = @i_taqprojectformatkey AND
          ((@i_actionvalue = 2 AND itemcategorycode <> @v_summary_itemcategorycode) OR @i_actionvalue = 1)

    END
    OPEN speccategory_cursor_delete

    FETCH speccategory_cursor_delete
    INTO @v_categorykey_project

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
      SET @v_categoriesaffected = @v_categoriesaffected + 1
      
      IF @v_debug = 1 BEGIN
        SELECT @v_dbgstr1 = gt.datadesc FROM taqversionspeccategory sc 
        JOIN gentables gt ON gt.tableid=616 AND gt.datacode = sc.itemcategorycode
        WHERE sc.taqversionspecategorykey = @v_categorykey_project
        PRINT 'DELETE FROM taqversionspec(items/categories/notes/costs): '+@v_dbgstr1
      END

      -- exec qutl_trace 'qspec_apply_specificationtemplate',
        -- 'DELETE FROM taqversionspec', NULL, NULL,
        -- '@v_categorykey_project', @v_categorykey_project
      
      DELETE FROM taqversionspecitems
      WHERE taqversionspecategorykey = @v_categorykey_project
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Error deleting from taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END  
      
      DELETE FROM taqversionspecnotes
      WHERE taqversionspecategorykey = @v_categorykey_project
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Error deleting from taqversionspecnotes table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END      
      
      IF @i_actionvalue = 3
      BEGIN
        DELETE FROM taqversioncosts
        WHERE taqversionspeccategorykey = @v_categorykey_project 
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_desc = 'Error deleting from taqversioncosts table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END  

        DELETE FROM taqversioncosts
        WHERE taqversionspeccategorykey IN 
          (SELECT taqversionspecategorykey FROM taqversionspeccategory
           WHERE relatedspeccategorykey = @v_categorykey_project)
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_desc = 'Error deleting from taqversioncosts table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END  
      END

      -- Related categories      
      DELETE FROM taqversionspeccategory
      WHERE taqversionspecategorykey IN 
        (SELECT taqversionspecategorykey FROM taqversionspeccategory
         WHERE relatedspeccategorykey = @v_categorykey_project)
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Error deleting from taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END  
      
      DELETE FROM taqversionspeccategory
      WHERE taqversionspecategorykey = @v_categorykey_project
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Error deleting from taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END  
      
      FETCH speccategory_cursor_delete
      INTO @v_categorykey_project
    END

    CLOSE speccategory_cursor_delete
    DEALLOCATE speccategory_cursor_delete 
    
    IF OBJECT_ID('tempdb.dbo.#templatespecategorykey', 'U') IS NOT NULL
      DROP TABLE #templatespecategorykey

  END -- Delete components

  -----------------------------------------------------------------------------------------------------
  -- Begin insert of spec categories and items that exist in the template but not in the target project
  -----------------------------------------------------------------------------------------------------
  
  IF @v_isApplySpecficationByFormat = 1 BEGIN
    DECLARE speccategory_cursor_insert CURSOR FOR
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.vendorcontactkey
    FROM taqversionspeccategory c
    WHERE c.taqprojectkey = @i_specificationtemplatekey
      AND c.taqversionformatkey = @v_taqprojectformatkey_template
      AND c.plstagecode  =  @v_plstage_template
      AND c.taqversionkey = @v_versionkey_template
      AND c.relatedspeccategorykey IS NULL
  END
  ELSE BEGIN
    -- Check that there are no additional categories in template that are marked finished good when there is an existing finished good
    IF @v_Is_Destination_Printing = 1 BEGIN      
      SELECT @v_speccategorydescription = c1.speccategorydescription, @v_speccategorydescription2 = c2.speccategorydescription
      FROM taqversionspeccategory c1
      JOIN taqversionspeccategory c2 
      ON COALESCE(c1.finishedgoodind,0) = COALESCE(c2.finishedgoodind,0) AND
      LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) <> LTRIM(RTRIM(convert(VARCHAR,COALESCE(c2.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c2.speccategorydescription, ''))))
      WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
          c2.taqprojectkey = @i_projectkey AND
          c2.plstagecode  =  @v_plstage_project AND
          c2.taqversionkey = @v_versionkey_project AND
          c2.taqversionformatkey = @i_taqprojectformatkey AND
          c2.finishedgoodind = 1

      SELECT @v_rowcount = @@ROWCOUNT
      IF @v_rowcount <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'A Printing can only have one finished good component. This Printing has '+@v_speccategorydescription2+' set to finished good and the template has '+@v_speccategorydescription+' set to finished good.<p/>The template will not be applied.'
        GOTO RETURN_ERROR
      END
    END

    -- Select all categories from Template that do not exist in target project
    DECLARE speccategory_cursor_insert CURSOR FOR
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.vendorcontactkey
    FROM taqversionspeccategory c
    WHERE c.taqprojectkey = @i_specificationtemplatekey
      AND c.plstagecode  =  @v_plstage_template
      AND c.taqversionkey = @v_versionkey_template
      AND c.relatedspeccategorykey IS NULL
      AND c.taqversionspecategorykey NOT IN (
        SELECT c1.taqversionspecategorykey
          FROM taqversionspeccategory c1
          JOIN taqversionspeccategory c2 
            ON LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) 
             = LTRIM(RTRIM(convert(VARCHAR,COALESCE(c2.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c2.speccategorydescription, ''))))
          WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
              c1.plstagecode  =  @v_plstage_template AND
              c1.taqversionkey = @v_versionkey_template AND
              c2.taqprojectkey = @i_projectkey AND
              c2.plstagecode  =  @v_plstage_project AND
              c2.taqversionkey = @v_versionkey_project AND
              c2.taqversionformatkey = @i_taqprojectformatkey
      UNION
        SELECT c1.taqversionspecategorykey -- Include related components on the target project
          FROM taqversionspeccategory c1
          JOIN taqversionspeccategory c2
            ON c2.taqprojectkey = @i_projectkey AND
               c2.plstagecode  =  @v_plstage_project AND
               c2.taqversionkey = @v_versionkey_project AND
               c2.taqversionformatkey = @i_taqprojectformatkey        
          JOIN taqversionspeccategory c3 
            ON c3.taqversionspecategorykey = c2.relatedspeccategorykey AND
               LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) 
             = LTRIM(RTRIM(convert(VARCHAR,COALESCE(c3.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c3.speccategorydescription, ''))))
          WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
                c1.plstagecode  =  @v_plstage_template AND
                c1.taqversionkey = @v_versionkey_template
         )
  END

  OPEN speccategory_cursor_insert
  FETCH speccategory_cursor_insert
  INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    IF @v_debug = 1 BEGIN
      PRINT '@v_categorykey_template=' + cast(@v_categorykey_template as varchar) + '(' + @v_speccategorydescription + ')'
    END
    
     -- exec qutl_trace 'qspec_apply_specificationtemplate',
       -- '@v_categorykey_template', @v_categorykey_template, NULL,
       -- '@v_speccategorydescription', NULL, @v_speccategorydescription
  
    SET @v_categoriesaffected = @v_categoriesaffected + 1

    SELECT @v_add_multiples = COALESCE(gen1ind,0), @v_speccategorydescription =  COALESCE(datadesc, '')
    FROM gentables  
    WHERE tableid = 616 AND datacode = @v_itemcategorycode
      
    -- No summary components can be added to POs, they must be related from the printing
    IF @v_Is_Destination_PurchaseOrder = 1 AND @v_itemcategorycode = @v_summary_itemcategorycode BEGIN
      FETCH speccategory_cursor_insert
      INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
      CONTINUE
    END

    -- Skip summary component with same description for action 2
    IF @v_exists_summary_component = 1 AND @i_actionvalue = 2 BEGIN
      IF @v_summary_ItemcategorycodeWithDescription = convert(VARCHAR, COALESCE(@v_itemcategorycode, -99)) + @v_speccategorydescription BEGIN
        FETCH speccategory_cursor_insert
        INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
        CONTINUE
      END
    END 
    -- Check whether category type allows multiple instances with different descriptions
    IF @v_add_multiples = 0 BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqversionspeccategory
      WHERE taqprojectkey = @i_projectkey AND taqversionformatkey = @i_taqprojectformatkey AND itemcategorycode = @v_itemcategorycode
      IF @v_count > 0 BEGIN
        IF @v_debug = 1 BEGIN
          PRINT 'Found '+CAST(@v_count AS VARCHAR)+' existing instances of '+ @v_speccategorydescription+': no multiples allowed'
        END
        FETCH speccategory_cursor_insert
        INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
        CONTINUE
      END
    END
    
    EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecategorykey_new OUT  
      
    IF @v_Is_Destination_PurchaseOrder = 1 BEGIN
      SET @v_vendorcontactkey = @v_globalcontactkey_for_vendor
    END
      
    IF @v_debug = 1 BEGIN
      PRINT 'INSERT INTO taqversionspeccategory: ' + @v_speccategorydescription
    END
    
     -- exec qutl_trace 'qspec_apply_specificationtemplate',
       -- 'INSERT INTO taqversionspeccategory', NULL, NULL,
       -- '@v_taqversionspecategorykey_new', @v_taqversionspecategorykey_new, NULL,
       -- '@v_speccategorydescription', NULL, @v_speccategorydescription
    
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
           ,quantity
           ,deriveqtyfromfgqty
           ,spoilagepercentage)
        SELECT            
           @v_taqversionspecategorykey_new
           ,@i_projectkey
           ,@v_plstage_project
           ,@v_versionkey_project
           ,@i_taqprojectformatkey
           ,itemcategorycode
           ,speccategorydescription
           ,scaleprojecttype
           ,@v_vendorcontactkey
           ,@i_userid
           ,getdate()
           ,finishedgoodind
           ,sortorder
           ,CASE WHEN @v_copyquantitiesind = 1 THEN quantity ELSE NULL END
           ,deriveqtyfromfgqty
           ,spoilagepercentage
    FROM taqversionspeccategory       
    WHERE taqversionspecategorykey = @v_categorykey_template
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access taqversionspeccategory table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
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
        COALESCE(s.subgen4ind,0) = 1 AND -- Do not copy spec items that have since been deactivated
        gi.itemtypecode IN(@v_itemtype_Printing, @v_itemtype_Title) AND    
        c.taqprojectkey = @i_specificationtemplatekey AND 
        c.plstagecode  =  @v_plstage_template AND
        c.taqversionkey = @v_versionkey_template AND
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
        COALESCE(s.subgen4ind,0) = 1 AND -- Do not copy spec items that have since been deactivated
        gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) AND    
        c.taqprojectkey = @i_specificationtemplatekey AND 
        c.plstagecode  =  @v_plstage_template AND
        c.taqversionkey = @v_versionkey_template AND
        i.taqversionspecategorykey = @v_categorykey_template    
    END  

    OPEN specitems_cursor_insert
     
    FETCH specitems_cursor_insert
    INTO @v_itemkey

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
       EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecitemkey_new OUT  
       
      IF @v_debug = 1 BEGIN
        SELECT @v_dbgstr2 = gst.datadesc
        FROM taqversionspeccategory sc
        JOIN taqversionspecitems si on si.taqversionspecategorykey = sc.taqversionspecategorykey
        JOIN subgentables gst ON gst.tableid=616 AND gst.datacode = sc.itemcategorycode AND gst.datasubcode = si.itemcode
        WHERE si.taqversionspecitemkey = @v_itemkey
        PRINT 'INSERT INTO taqversionspecitems: '+@v_speccategorydescription+' - '+@v_dbgstr2
      END
      
      --exec qutl_trace 'qspec_apply_specificationtemplate',
      --  'INSERT INTO taqversionspecitems:', NULL, NULL,
      --  '@v_taqversionspecitemkey_new', @v_taqversionspecitemkey_new
      
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
        ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
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
    
    -- Spec Notes --------------------------------------------------------------------------
    
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
      SELECT  @v_taqversionspecnotekey_new
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
          ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
          ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_taqversionspecategorykey_new AS VARCHAR) +  ').'          
          GOTO RETURN_ERROR
      END            
          
      SET @v_maxsortoder_notes = @v_maxsortoder_notes + 1            
      FETCH specnotes_cursor_insert
      INTO @v_notekey, @v_copynextprtgind
    END

    CLOSE specnotes_cursor_insert
    DEALLOCATE specnotes_cursor_insert   
        
    -- Spec Costs -------------------------------------------------------------------------
    
    IF @v_isApplySpecficationByFormat <> 1 BEGIN
      SELECT @v_taqprojectformatkey_template = taqversionformatkey
      FROM taqversionspeccategory 
      WHERE taqversionspecategorykey = @v_categorykey_template
    END

    SELECT * INTO #tmptaqversioncosts FROM 
    (
      SELECT
        @v_taqversionspecategorykey_new taqversionspeccategorykey,
        yp.taqversionformatyearkey taqversionformatyearkey,
        c.acctgcode,
        c.plcalccostcode,
        versioncostsnote,
        NULL versioncostsamount,
        unitcost,
        acceptgenerationind,
        0 templatechangedind, 
        @i_userid lastuserid,
        getdate() lastmaintdate,
        c.printingnumber,
        plcalccostsubcode,
        compunitcost,
        c.pocostind
        FROM taqversioncosts c
          JOIN taqversionformatyear yt 
            ON yt.taqversionformatyearkey = c.taqversionformatyearkey
          JOIN taqversionformatyear yp  -- join to get project's taqversionformatyearkey for this printing/yearcode
            ON yp.taqprojectformatkey = @i_taqprojectformatkey
        WHERE c.taqversionspeccategorykey = @v_categorykey_template
          AND c.taqversionformatyearkey IN (SELECT taqversionformatyearkey FROM taqversionformatyear WHERE taqprojectformatkey = @v_taqprojectformatkey_template)
          AND NOT EXISTS (SELECT 1 FROM taqversioncosts 
                            WHERE taqversionformatyearkey = yp.taqversionformatyearkey
                            AND acctgcode = c.acctgcode
                            AND taqversionspeccategorykey = @v_taqversionspecategorykey_new)
    ) AS TVC

    -- Delete duplicate rows
    ;WITH cte AS (
      SELECT taqversionspeccategorykey, taqversionformatyearkey, acctgcode, row_number() 
      OVER(PARTITION BY taqversionformatyearkey, acctgcode, taqversionspeccategorykey ORDER BY taqversionformatyearkey) AS [rn]
      FROM #tmptaqversioncosts
    )
    DELETE cte WHERE [rn] > 1

    INSERT INTO taqversioncosts
      (taqversionspeccategorykey,
      taqversionformatyearkey,
      acctgcode,
      plcalccostcode,
      versioncostsnote,
      versioncostsamount,
      unitcost,
      acceptgenerationind,
      templatechangedind,
      lastuserid,
      lastmaintdate,
      printingnumber,
      plcalccostsubcode,
      compunitcost,
      pocostind)
    SELECT
      taqversionspeccategorykey,
      taqversionformatyearkey,
      acctgcode,
      plcalccostcode,
      versioncostsnote,
      versioncostsamount,
      unitcost,
      acceptgenerationind,
      templatechangedind,
      lastuserid,
      lastmaintdate,
      printingnumber,
      plcalccostsubcode,
      compunitcost,
      pocostind
      FROM #tmptaqversioncosts tc

    DROP TABLE #tmptaqversioncosts
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT

    IF @v_debug = 1
      PRINT 'INSERT INTO taqversioncosts: '+cast(@v_rowcount as varchar)+' rows'

       -- exec qutl_trace 'qspec_apply_specificationtemplate',
         -- 'INSERT INTO taqversioncosts', NULL, NULL,
         -- '@v_taqprojectformatkey_template', @v_taqprojectformatkey_template, NULL,
         -- '@v_taqversionspecategorykey_new', @v_taqversionspecategorykey_new, NULL,
         -- 'rows inserted', @v_rowcount

    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access taqversioncosts table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
        ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
        ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_taqversionspecategorykey_new AS VARCHAR) +  ').'          
        GOTO RETURN_ERROR
    END            
    
    -- Fetch next spec category ------------------------------------------------------------
    
    FETCH speccategory_cursor_insert
    INTO @v_categorykey_template, @v_itemcategorycode, @v_speccategorydescription, @v_vendorcontactkey
  END

  CLOSE speccategory_cursor_insert
  DEALLOCATE speccategory_cursor_insert


  IF @i_actionvalue = 4 BEGIN  -- 4: Leave Existing Data, Add New Values
    IF @v_debug = 1
      PRINT '--- Add any additional spec items to existing categories.'
    
    -- Check that there are no additional categories in template that are marked finished good when there is an existing finished good
    IF @v_Is_Destination_Printing = 1 BEGIN      
      SELECT @v_speccategorydescription = c1.speccategorydescription, @v_speccategorydescription2 = c2.speccategorydescription
      FROM taqversionspeccategory c1
      JOIN taqversionspeccategory c2 
      ON COALESCE(c1.finishedgoodind,0) = COALESCE(c2.finishedgoodind,0) AND
      LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) <> LTRIM(RTRIM(convert(VARCHAR,COALESCE(c2.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c2.speccategorydescription, ''))))
      WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
            c1.plstagecode  =  @v_plstage_template AND
            c1.taqversionkey = @v_versionkey_template AND
            c2.taqprojectkey = @i_projectkey AND
            c2.plstagecode  =  @v_plstage_project AND
            c2.taqversionkey = @v_versionkey_project AND
            c2.taqversionformatkey = @i_taqprojectformatkey AND
            c2.finishedgoodind = 1

      SELECT @v_rowcount = @@ROWCOUNT
      IF @v_rowcount <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'A Printing can only have one finished good component. This Printing has '+@v_speccategorydescription2+' set to finished good and the template has '+@v_speccategorydescription+' set to finished good.<p/>The template will not be applied.'
        GOTO RETURN_ERROR
      END
    END

    -- Select all categories from both tables that match on category code and description
    DECLARE speccategory_cursor_insert_outer CURSOR FOR
      SELECT c1.taqversionspecategorykey, c2.taqversionspecategorykey, c2.itemcategorycode, 0
      FROM taqversionspeccategory c1
      JOIN taqversionspeccategory c2 
        ON LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) 
         = LTRIM(RTRIM(convert(VARCHAR,COALESCE(c2.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c2.speccategorydescription, ''))))
      WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
            c1.plstagecode  =  @v_plstage_template AND
            c1.taqversionkey = @v_versionkey_template AND
            c2.taqprojectkey = @i_projectkey AND
            c2.plstagecode  =  @v_plstage_project AND
            c2.taqversionkey = @v_versionkey_project AND
            c2.taqversionformatkey = @i_taqprojectformatkey        
    UNION
      SELECT c1.taqversionspecategorykey, c3.taqversionspecategorykey, c3.itemcategorycode, 1 -- Include related components on the target project
      FROM taqversionspeccategory c1
      JOIN taqversionspeccategory c2
        ON c2.taqprojectkey = @i_projectkey AND
           c2.plstagecode  =  @v_plstage_project AND
           c2.taqversionkey = @v_versionkey_project AND
           c2.taqversionformatkey = @i_taqprojectformatkey        
      JOIN taqversionspeccategory c3 
        ON c3.taqversionspecategorykey = c2.relatedspeccategorykey AND
           LTRIM(RTRIM(convert(VARCHAR,COALESCE(c1.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c1.speccategorydescription, '')))) 
         = LTRIM(RTRIM(convert(VARCHAR,COALESCE(c3.itemcategorycode, -99)) + convert(VARCHAR,COALESCE(c3.speccategorydescription, ''))))
      WHERE c1.taqprojectkey = @i_specificationtemplatekey AND
            c1.plstagecode  =  @v_plstage_template AND
            c1.taqversionkey = @v_versionkey_template

    OPEN speccategory_cursor_insert_outer

    FETCH speccategory_cursor_insert_outer
    INTO @v_categorykey_template, @v_categorykey_project, @v_itemcategorycode, @v_isrelated

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        
      SELECT @v_add_multiples = COALESCE(gen1ind,0)
      FROM gentables  
      WHERE tableid = 616 AND datacode = @v_itemcategorycode
      
    -- Spec Items
    IF @v_Is_Destination_Printing = 1
    BEGIN      
        
      -- Select spec category items from the template that don't exist in the printing target
      DECLARE specitems_cursor_insert CURSOR FOR
      SELECT DISTINCT i.taqversionspecitemkey 
      FROM taqversionspecitems i 
        INNER JOIN subgentables s ON i.itemcode = s.datasubcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
        INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
      WHERE s.tableid = 616 AND    
        COALESCE(s.subgen4ind,0) = 1 AND -- Do not copy spec items that have since been deactivated
        gi.itemtypecode IN(@v_itemtype_Printing, @v_itemtype_Title) AND    
        c.taqprojectkey = @i_specificationtemplatekey AND
        c.plstagecode  =  @v_plstage_template AND
        c.taqversionkey = @v_versionkey_template AND
        c.taqversionspecategorykey = @v_categorykey_template AND 
        i.itemcode IN (
          (SELECT itemcode FROM taqversionspecitems  
            WHERE  taqversionspecategorykey = @v_categorykey_template
          )  
          EXCEPT (SELECT itemcode 
                  FROM taqversionspecitems
                  WHERE taqversionspecategorykey = @v_categorykey_project)
        )          
    END
    ELSE BEGIN 
      -- Select spec category items from the template that don't exist in the (non-printing) target
      DECLARE specitems_cursor_insert CURSOR FOR
      SELECT DISTINCT i.taqversionspecitemkey 
      FROM taqversionspecitems i 
        INNER JOIN subgentables s ON i.itemcode = s.datasubcode
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
        INNER JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey AND c.itemcategorycode = s.datacode
      WHERE s.tableid = 616 AND    
        COALESCE(s.subgen4ind,0) = 1 AND -- Do not copy spec items that have since been deactivated
        gi.itemtypecode = @i_itemtype AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0) AND    
        c.taqprojectkey = @i_specificationtemplatekey AND
        c.plstagecode  =  @v_plstage_template AND
        c.taqversionkey = @v_versionkey_template AND
        c.taqversionspecategorykey = @v_categorykey_template AND 
        i.itemcode IN (
          (SELECT itemcode FROM taqversionspecitems  
            WHERE  taqversionspecategorykey = @v_categorykey_template
          )  
          EXCEPT (SELECT itemcode 
                  FROM taqversionspecitems
                  WHERE taqversionspecategorykey = @v_categorykey_project)
         )        
    END          
      
    OPEN specitems_cursor_insert
     
    FETCH specitems_cursor_insert
    INTO @v_itemkey

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
      SET @v_categoriesaffected = @v_categoriesaffected + 1

      EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecitemkey_new OUT  
         
      IF @v_debug = 1 BEGIN
        SELECT @v_dbgstr1 = gt.datadesc, @v_dbgstr2 = gst.datadesc
        FROM taqversionspeccategory sc
        JOIN taqversionspecitems si on si.taqversionspecategorykey = sc.taqversionspecategorykey
        JOIN gentables gt ON gt.tableid=616 AND gt.datacode = sc.itemcategorycode
        JOIN subgentables gst ON gst.tableid=616 AND gst.datacode = sc.itemcategorycode AND gst.datasubcode = si.itemcode
        WHERE si.taqversionspecitemkey = @v_itemkey
        PRINT 'INSERT INTO taqversionspecitems: '+@v_dbgstr1+' - '+@v_dbgstr2
      END

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
          ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
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
    
    -- Select all template notes that have text that does not exist in target category    
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
         
        SET @v_categoriesaffected = @v_categoriesaffected + 1
        
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
            ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
            ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_categorykey_project AS VARCHAR) +  ').'          
          GOTO RETURN_ERROR
        END  
          
        SET @v_maxsortoder_notes = @v_maxsortoder_notes + 1                  
        FETCH specnotes_cursor_insert
        INTO @v_notekey, @v_copynextprtgind
      END

      CLOSE specnotes_cursor_insert
      DEALLOCATE specnotes_cursor_insert         
      
      -- Spec Costs -------------------------------------------------------------------------
    
      IF @v_isApplySpecficationByFormat <> 1 BEGIN
        SELECT @v_taqprojectformatkey_template = taqversionformatkey
        FROM taqversionspeccategory 
        WHERE taqversionspecategorykey = @v_categorykey_template
      END

      SELECT * INTO #tmptaqversioncosts2 FROM 
      (
        SELECT
          CASE WHEN @v_isrelated = 0 
            THEN @v_categorykey_project 
            ELSE (SELECT taqversionspecategorykey FROM taqversionspeccategory WHERE relatedspeccategorykey = @v_categorykey_project)
          END taqversionspeccategorykey,
          yp.taqversionformatyearkey taqversionformatyearkey,
          c.acctgcode,
          c.plcalccostcode,
          versioncostsnote,
          NULL versioncostsamount,
          unitcost,
          acceptgenerationind,
          0 templatechangedind, 
          @i_userid lastuserid,
          getdate() lastmaintdate,
          c.printingnumber,
          plcalccostsubcode,
          compunitcost,
          c.pocostind
          FROM taqversioncosts c
            JOIN taqversionformatyear yt 
              ON yt.taqversionformatyearkey = c.taqversionformatyearkey
            JOIN taqversionformatyear yp  -- join to get project's taqversionformatyearkey for this printing/yearcode
              ON yp.taqprojectformatkey = @i_taqprojectformatkey AND yp.yearcode = yt.yearcode AND ISNULL(yp.printingnumber,1) = ISNULL(yt.printingnumber,1)
          WHERE c.taqversionspeccategorykey = @v_categorykey_template
            AND c.taqversionformatyearkey IN (SELECT taqversionformatyearkey FROM taqversionformatyear WHERE taqprojectformatkey = @v_taqprojectformatkey_template)
            AND NOT EXISTS (SELECT 1 FROM taqversioncosts 
                            WHERE taqversionformatyearkey = yp.taqversionformatyearkey
                            AND acctgcode = c.acctgcode
                            AND ((@v_isrelated = 0 AND ISNULL(taqversionspeccategorykey,0) = ISNULL(@v_categorykey_project,0))
                                  OR (@v_isrelated <> 0 AND ISNULL(taqversionspeccategorykey,0) = ISNULL((SELECT TOP 1 taqversionspecategorykey FROM taqversionspeccategory WHERE relatedspeccategorykey = @v_categorykey_project),0))))
      ) AS TVC

      -- Delete duplicate rows
      ;WITH cte AS (
        SELECT taqversionspeccategorykey, taqversionformatyearkey, acctgcode, row_number() 
        OVER(PARTITION BY taqversionformatyearkey, acctgcode, taqversionspeccategorykey ORDER BY taqversionformatyearkey) AS [rn]
        FROM #tmptaqversioncosts2
      )
      DELETE cte WHERE [rn] > 1

      INSERT INTO taqversioncosts
        (taqversionspeccategorykey,
        taqversionformatyearkey,
        acctgcode,
        plcalccostcode,
        versioncostsnote,
        versioncostsamount,
        unitcost,
        acceptgenerationind,
        templatechangedind,
        lastuserid,
        lastmaintdate,
        printingnumber,
        plcalccostsubcode,
        compunitcost,
        pocostind)
      SELECT
        taqversionspeccategorykey,
        taqversionformatyearkey,
        acctgcode,
        plcalccostcode,
        versioncostsnote,
        versioncostsamount,
        unitcost,
        acceptgenerationind,
        templatechangedind,
        lastuserid,
        lastmaintdate,
        printingnumber,
        plcalccostsubcode,
        compunitcost,
        pocostind
        FROM #tmptaqversioncosts2 tc

      DROP TABLE #tmptaqversioncosts2
        
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT

      IF @v_debug = 1
        PRINT 'INSERT INTO taqversioncosts: '+cast(@v_rowcount as varchar)+' rows'

      -- exec qutl_trace 'qspec_apply_specificationtemplate',
        -- 'INSERT INTO taqversioncosts', NULL, NULL,
        -- '@v_taqprojectformatkey_template', @v_taqprojectformatkey_template, NULL,
        -- '@v_taqversionspecategorykey_new', @v_categorykey_project, NULL,
        -- '@i_taqprojectformatkey', @i_taqprojectformatkey, NULL,
        -- '@v_categorykey_template', @v_categorykey_template, NULL,
        -- 'rows inserted', @v_rowcount

      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access taqversioncosts table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
          ', plstagecode=' + CAST(@v_plstage_project AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey_project AS VARCHAR) + 
          ', taqprojectformatkey=' + CAST(@i_taqprojectformatkey AS VARCHAR) + 'taqversionspecategorykey=' + CAST(@v_categorykey_project AS VARCHAR) +  ').'          
          GOTO RETURN_ERROR
      END            
      
      FETCH speccategory_cursor_insert_outer
      INTO @v_categorykey_template, @v_categorykey_project, @v_itemcategorycode, @v_isrelated
    END

    CLOSE speccategory_cursor_insert_outer
    DEALLOCATE speccategory_cursor_insert_outer         
  END
  
  IF @v_isopentrans = 1
    COMMIT

  IF @v_categoriesaffected = 0 BEGIN
    --SET @o_error_code = -1
    SET @o_error_desc = 'There was nothing new in the template that needed to be applied.'
  END
  ELSE BEGIN
    exec qpl_update_component_qty 0, @i_projectkey, @v_plstage_project, @v_versionkey_project, @i_taqprojectformatkey, @i_userid, @o_error_code output, @o_error_desc output
  END
  
  RETURN  

RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK
    
  SET @o_error_code = -1
  RETURN  
  
END

GO

GRANT EXEC ON qspec_apply_specificationtemplate TO PUBLIC
GO
