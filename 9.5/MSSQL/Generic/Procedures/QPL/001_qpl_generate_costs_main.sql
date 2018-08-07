if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_generate_costs_main') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_generate_costs_main
GO

CREATE PROCEDURE qpl_generate_costs_main (  
  @i_taqversionformatyearkey   INT,
  @i_date		DATETIME,
  @i_processtype	INT,
  @i_userid 			VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_generate_cost_main_process
**  Desc: This stored procedure will be called for each unique format/year for the selected 
**        version that has a printing associated with it to generate costs.
**
**  Auth: Kusum Basra
**  Date: March 14 2012
*******************************************************************************************
*******************************************************************************************
**  Change History
*******************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/25/2016    Kusum       Case 38290
**  06/21/16     Kate        Fixes for related specs - see case 29764.
**  07/28/2016   Alan        Case 39356
*******************************************************************************************/

DECLARE
  @v_count	INT,
  @v_count1	INT,
  @v_count2	INT,
  @v_count3 INT,
  @v_count4 INT,
  @v_scaleprojectkey	INT,
  @v_taqprojectkey INT,  
  @v_plstagecode  INT,
  @v_taqversionkey  INT,
  @v_new_taqversionspecategorykey	INT,
  @v_new_taqversionspecitemkey	INT,
  @v_error  INT,
  @v_summarydatacode     INT,
  @v_prodqtydatacode     INT,
  @v_taqversiontype	INT,
  @v_taqprojectformatkey	INT,
  @v_taqversionspecategorykey	INT, 
  @v_relatedspeccategorykey INT,
  @v_itemcategorycode	INT,
  @v_specitemkey	INT, 
  @v_validforprtgs	INT,  
  @v_itemcode	INT, 
  @v_itemdetailcode	INT,
  @v_scaleprojecttype	INT,
  @v_speccategorydescription	VARCHAR(255),
  @v_specs_formatyearkey INT,
  @v_taqprojecttitle	VARCHAR(255),
  @v_message  VARCHAR(2000),
  @v_taqdetailscalekey	INT, 
  @v_calculationtypecode	INT,
  @v_calcind TINYINT,
  @v_calcsecqsicode FLOAT,
  @v_perqty	FLOAT,
  @v_specialprocess VARCHAR(255),
  @v_taqversionspecitemkey	INT,
  @v_parametertypecode	INT,
  @v_messagetypecode	INT,
  @v_scaletabkey	INT,
  @v_scaletype	INT,
  @v_autoapplyind	TINYINT,
  @error_var    INT,
  @rowcount_var INT,
  @v_printing INT,
  @v_bucket_format			INT,
  @v_bucket_internal		INT,
  @v_bucket_cost				FLOAT,
  @v_bucket_validprtgs	INT,
  @v_bucket_calccost		INT,
  @v_acceptgenind INT,
  @v_quantity INT,
  @v_unitcost	FLOAT,
  @v_prodqtyitemcategorycode INT,
  @v_prodqtyitemcode INT,
  @v_sortorder INT,
  @v_costcompkey INT,
  @v_compunitcost INT,
  @v_compqty INT,
  @v_compkey INT,
  @v_speccategorykey INT

    
BEGIN
	IF COALESCE(@i_taqversionformatyearkey,0) = 0 BEGIN
		return
	END

  --PRINT '@i_taqversionformatyearkey=' + convert(varchar, @i_taqversionformatyearkey)
  --PRINT '@i_processtype=' + convert(varchar, @i_processtype)

	SELECT @v_taqprojectkey = taqprojectkey, @v_plstagecode = plstagecode, @v_taqversionkey = taqversionkey,
       @v_taqprojectformatkey = taqprojectformatkey
      FROM taqversionformatyear
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey
     
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to select from taqversionformatyear.'
	  RETURN
	END 
	
  --PRINT '@v_taqprojectkey=' + convert(varchar, @v_taqprojectkey)
  --PRINT '@v_plstagecode=' + convert(varchar, @v_plstagecode)
  --PRINT '@v_taqversionkey=' + convert(varchar, @v_taqversionkey)
  --PRINT '@v_taqprojectformatkey=' + convert(varchar, @v_taqprojectformatkey)	

	DELETE FROM taqversioncostmessages 
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey
       AND (processtype = @i_processtype OR processtype IS NULL)

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to delete from taqversioncostmessages.'
		RETURN
	END 

	IF @i_processtype = 1 BEGIN
		DELETE FROM taqversioncosts 
			WHERE taqversionformatyearkey = @i_taqversionformatyearkey
			  AND acceptgenerationind = 1

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to delete from taqversioncosts.'
		  RETURN
		END 
	END

	-- table to save all unique scaleprojectkeys
	CREATE TABLE #tmp_scaleprojectkeys
	(scaleprojectkey	INT		NOT NULL)

	-- table to mimic the spec item/ scale detail structure - will have rows inserted by the GET SPEC DETAIL procedure
	CREATE TABLE #tmp_structure 
	(taqdetailscalekey		INT  NOT NULL,
	 taqversionspecitemkey	INT	 NULL,
	 autoapplyind			TINYINT	NULL,
	 calculationtypecode	INT		NULL,
	 itemcategorycode		INT		NULL,
	 itemcode				INT		NULL)

	CREATE TABLE #scalecostbucket_table (formatkey INT,internalcode INT,cost FLOAT,validforprtgs INT,calccostcode    TINYINT)
	 
	SELECT @v_taqversiontype = taqversiontype
	FROM taqversion 
	WHERE taqprojectkey = @v_taqprojectkey AND plstagecode = @v_plstagecode AND taqversionkey = @v_taqversionkey

  --PRINT '@v_taqversiontype=' + convert(varchar, @v_taqversiontype)

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to access taqversion table.'
		RETURN
	END 

	--Make sure all Prod Qty Spec Items exist
	--IF @v_taqversiontype = 1 BEGIN	
		EXEC qpl_create_prod_qty_specitem @v_taqprojectformatkey,@i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
		IF @o_error_code = -1 BEGIN
			SET @v_message = @o_error_desc

			INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
				VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
			RETURN
		END 
	--END

  DECLARE versionspeccategory_cur CURSOR FOR
    SELECT DISTINCT taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, scaleprojecttype, speccategorydescription
    FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey)

  OPEN versionspeccategory_cur 

  FETCH versionspeccategory_cur 
  INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_scaleprojecttype, @v_speccategorydescription

  WHILE (@@FETCH_STATUS=0) BEGIN
		
    --PRINT ' ---'
    --PRINT ' @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
    --PRINT ' @v_relatedspeccategorykey=' + convert(varchar, @v_relatedspeccategorykey)
    --PRINT ' @v_itemcategorycode=' + convert(varchar, @v_itemcategorycode)
    --PRINT ' @v_scaleprojecttype=' + convert(Varchar, @v_scaleprojecttype)
    --PRINT ' @v_speccategorydescription=' + @v_speccategorydescription
    
    -- Get the taqversionformatyearkey for the first encountered printing on the project holding the actual spec
    -- NOTE: @v_relatedspeccategorykey equals @v_taqversionspecategorykey if there is no related spec.
    SELECT @v_specs_formatyearkey = firstprtg_taqversionformatyearkey
    FROM taqversionrelatedcomponents_view
    WHERE taqversionspecategorykey = @v_relatedspeccategorykey     
    
		IF @v_scaleprojecttype IS NULL BEGIN
			SELECT @v_count = count(*) FROM taqscaleadminspecitem WHERE itemcategorycode = @v_itemcategorycode
	 --        AND itemcode = @v_itemcode
	 		IF @v_count IS NULL SELECT @v_count = 0
		 	IF @v_count > 0 BEGIN
				SELECT  @v_count1 = count(*) FROM taqscaleadminspecitem WHERE itemcategorycode = @v_itemcategorycode
					AND (messagetypecode = 0 OR messagetypecode IS NULL)

				IF @v_count1 IS NULL SELECT @v_count1 = 0
			END
			ELSE BEGIN
				SELECT @v_count1 = 0
			END 
			IF @v_count = @v_count1 BEGIN  --All spec. items are not scales items - no cost generation necessary
				GOTO READ_AGAIN	
			END
			IF @v_count <> @v_count1 BEGIN
				SELECT @v_count2 = count(*) FROM taqscaleadminspecitem WHERE itemcategorycode = @v_itemcategorycode
				   AND messagetypecode = 2  --2 Errors, 3-Warnings 4-Information
				IF @v_count2 IS NULL SELECT @v_count2 = 0
				IF @v_count2 > 0 BEGIN
					SET @v_message = 'No scale type exist for ' + @v_speccategorydescription + '; cannot generate costs for this component/process.'

					INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
						VALUES (@i_taqversionformatyearkey, @v_message, 2, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
							
					GOTO READ_AGAIN				
				END ---@v_count2 > 0
				ELSE BEGIN  -- @v_count2 = 0
					SELECT @v_count3 = count(*) FROM taqscaleadminspecitem WHERE itemcategorycode = @v_itemcategorycode AND messagetypecode = 3
					IF @v_count3 IS NULL SELECT @v_count3 = 0
						IF @v_count3 > 0 BEGIN
							SET @v_message = 'No scale type exist for ' + @v_speccategorydescription + '; cannot generate costs for this component/process.'

							INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
								VALUES (@i_taqversionformatyearkey, @v_message, 3, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
			  					
							GOTO READ_AGAIN	
						END  --@v_count3 > 0
						ELSE BEGIN  --@v_count2 = 0 AND @v_count3 = 0
							SELECT @v_count4 = count(*) FROM taqscaleadminspecitem WHERE itemcategorycode = @v_itemcategorycode AND messagetypecode = 4

							IF @v_count4 IS NULL SELECT @v_count4 = 0

							IF @v_count4 > 0 BEGIN
								SET @v_message = 'No scale type exist for ' + @v_speccategorydescription + '; cannot generate costs for this component/process.'

								INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
									VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
			  					
								GOTO READ_AGAIN	
							END  --@v_count4 > 0
							ELSE BEGIN
								SET @v_message = 'No scale type exist for ' + @v_speccategorydescription + '; cannot generate costs for this component/process.'

								INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
									VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
				  					
								GOTO READ_AGAIN	

							END
						END --@v_count2 = 0 AND @v_count3 = 0
					END  -- @v_count2 > 0
				END  ---@v_count1 <> @v_count
			END  --@v_scaleprojecttype = NULL

			-- Get Scale for Spec Category
			-- Returns @v_scaleprojectkey
			EXEC qscale_get_scale_for_speccategory @v_taqversionspecategorykey, @i_processtype, 
			  @v_scaleprojectkey output, @o_error_code output, @o_error_desc output

			IF @v_scaleprojectkey = 0 OR @v_scaleprojectkey IS NULL BEGIN
				GOTO READ_AGAIN	
			END
			ELSE BEGIN
				SELECT @v_taqprojecttitle = taqprojecttitle FROM taqproject WHERE taqprojectkey = @v_scaleprojectkey

				SET @v_message = 'Scale chosen for ' + @v_speccategorydescription + '  is: ' + @v_taqprojecttitle

				INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
					VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)

				IF NOT EXISTS (SELECT * FROM #tmp_scaleprojectkeys WHERE scaleprojectkey=@v_scaleprojectkey)
					INSERT INTO  #tmp_scaleprojectkeys (scaleprojectkey) VALUES(@v_scaleprojectkey)

				-- Get all spec items for this version/format/printing/year/spec/category
				DECLARE specitems_by_printing_cur CURSOR FOR
				  SELECT itemcategorycode, itemcode,itemdetailcode, taqversionspecitemkey
					FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey)
				 WHERE taqversionspecategorykey = @v_taqversionspecategorykey

				OPEN specitems_by_printing_cur

				FETCH specitems_by_printing_cur INTO @v_itemcategorycode,@v_itemcode,@v_itemdetailcode,@v_taqversionspecitemkey

				WHILE (@@FETCH_STATUS=0) BEGIN
					SELECT @v_count = count(*)
					  FROM taqscaleadminspecitem
					 WHERE scaletypecode = @v_scaleprojecttype AND itemcategorycode = @v_itemcategorycode AND itemcode = @v_itemcode

					 IF @v_count > 0 BEGIN
						 SELECT @v_messagetypecode = messagetypecode,@v_scaletabkey = scaletabkey,@v_parametertypecode=parametertypecode
						   FROM taqscaleadminspecitem
						  WHERE scaletypecode = @v_scaleprojecttype AND itemcategorycode = @v_itemcategorycode AND itemcode = @v_itemcode
					END 
			  					
					-- Parameter type 1(Scale), 2 (Grid) Messagetypecode = 0(Not a scale item)
					IF (@v_count > 0) AND (@v_parametertypecode NOT IN (1,2)) AND (@v_messagetypecode <> 0) BEGIN 
					-- GET SCALE DETAIL FOR SPEC ITEMS - will write to the #tmp_structure table
					-- pass @v_scaleprojecttype,@v_taqprojecttitle,@v_scaletabkey,@v_taqversionspecitemkey,@v_messagetypecode,@v_itemcategorycode,
					-- @v_itemcode,@v_itemdetailcode,0(autoapplyind)
						EXEC qscale_get_scale_detail @v_specs_formatyearkey, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
						   @v_taqversionspecitemkey, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, @v_itemdetailcode, 0, @i_processtype,
						   @o_error_code OUTPUT, @o_error_desc OUTPUT
			            
						IF @o_error_code = -1 BEGIN
							SET @v_message = @o_error_desc

							INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
								VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
  						END
					END
			  			
					FETCH specitems_by_printing_cur INTO @v_itemcategorycode,@v_itemcode,@v_itemdetailcode,@v_taqversionspecitemkey
				END --specitems_by_printing_cur

				CLOSE specitems_by_printing_cur
				DEALLOCATE specitems_by_printing_cur

				GOTO READ_AGAIN
  			END
		    
			READ_AGAIN:
	    FETCH versionspeccategory_cur 
      INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_scaleprojecttype, @v_speccategorydescription
		END

		CLOSE versionspeccategory_cur
		DEALLOCATE versionspeccategory_cur 

		SELECT @v_count = 0

		IF @i_processtype = 1 BEGIN
			SELECT DISTINCT @v_count = COUNT(*) FROM #tmp_scaleprojectkeys

			IF @v_count = 0 BEGIN
			  SET @o_error_code = 0
			  SET @o_error_desc = ''
			  RETURN
			END
		END

		IF @i_processtype = 1 BEGIN  --Cost Generation
		-- Get all auto apply items for scales used by spec categories for this version/format/year that have not already
		-- been added and add them to the spec item/scale detail structure. They will not have a corresponding spec
		-- item, but will have an autoapply ind set to yes and a taqscaledetailkey
			DECLARE scaleprojectkey_cursor CURSOR FOR
				SELECT DISTINCT scaleprojectkey
				  FROM #tmp_scaleprojectkeys
				ORDER BY scaleprojectkey

			OPEN scaleprojectkey_cursor 

			FETCH scaleprojectkey_cursor INTO @v_scaleprojectkey

			WHILE (@@FETCH_STATUS=0)
			BEGIN
				SELECT @v_taqprojecttitle = taqprojecttitle, @v_scaletype = taqprojecttype FROM taqproject WHERE taqprojectkey = @v_scaleprojectkey
				
				DECLARE taqprojectscaledetails_cur CURSOR FOR
					SELECT DISTINCT itemcategorycode,itemcode
					  FROM taqprojectscaledetails 
					 WHERE taqprojectkey = @v_scaleprojectkey AND autoapplyind = 1
				   ORDER BY itemcategorycode,itemcode

				OPEN taqprojectscaledetails_cur 

				FETCH taqprojectscaledetails_cur INTO @v_itemcategorycode,@v_itemcode

				WHILE (@@FETCH_STATUS=0)BEGIN
				
					SELECT @v_count = count(*)FROM #tmp_structure WHERE itemcategorycode = @v_itemcategorycode AND itemcode = @v_itemcode

					IF @v_count = 0 BEGIN 
					  SELECT @v_count2 = count(*)
						FROM taqscaleadminspecitem
					   WHERE scaletypecode = @v_scaletype
						 AND itemcategorycode = @v_itemcategorycode
						 AND itemcode = @v_itemcode

						IF @v_count2 = 0 BEGIN
							SET @v_message = 'Taqscaleadminspecitem record does not exist for ' + CAST(@v_itemcategorycode AS VARCHAR) +
							'/' + CAST(@v_itemcode AS VARCHAR) + '; Cannot process autoapply item.'

							INSERT INTO taqversioncostmessages 
								(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
								VALUES
								(@i_taqversionformatyearkey, @v_message, 2, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
							
						END
						ELSE BEGIN
							SELECT @v_messagetypecode =  messagetypecode, @v_scaletabkey = scaletabkey
							  FROM taqscaleadminspecitem
							 WHERE scaletypecode = @v_scaletype
							   AND itemcategorycode = @v_itemcategorycode
							   AND itemcode = @v_itemcode

							-- GET SCALE DETAIL FOR SPEC ITEMS - will write to the #tmp_structure table
							-- pass @i_taqversionformatyearkey,@v_scaleprojecttype,@v_taqprojecttitle,@v_scaletabkey,@v_taqversionspecitemkey(NULL),@v_messagetypecode,@v_itemcategorycode,
							-- @v_itemcode,@v_itemdetailcode(NULL),1(autoapplyind)
							EXEC qscale_get_scale_detail @v_specs_formatyearkey, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
								NULL, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, NULL, 1, @i_processtype, @o_error_code OUTPUT, @o_error_desc OUTPUT

							IF @o_error_code = -1 BEGIN
								SET @v_message = @o_error_desc

								INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
									VALUES (@i_taqversionformatyearkey, @v_message, @v_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
		  			      	
							END
						END
		 			END
					
					FETCH taqprojectscaledetails_cur INTO @v_itemcategorycode,@v_itemcode
			   END  --taqprojectscaledetails_cur

			   CLOSE taqprojectscaledetails_cur
			   DEALLOCATE taqprojectscaledetails_cur 

			   FETCH scaleprojectkey_cursor INTO @v_scaleprojectkey
			END   --scaleprojectkey_cursor

			CLOSE scaleprojectkey_cursor
			DEALLOCATE scaleprojectkey_cursor 

			-- Generate costs
			--SELECT * FROM #tmp_structure
		    
			-- Sort the spec item/scale detail structure by the sort order on the gentables tableid 627 for 
			-- taqprojectscaledetails.calculationtype		
			DECLARE calctype_cur CURSOR FOR
				SELECT DISTINCT t.calculationtypecode, g.sortorder
				  FROM #tmp_structure t, gentables g
				 WHERE t.calculationtypecode = g.datacode
				   AND g.tableid = 627
				  ORDER BY g.sortorder, t.calculationtypecode

			OPEN calctype_cur
			FETCH calctype_cur INTO @v_calculationtypecode,@v_sortorder

			WHILE (@@FETCH_STATUS=0) BEGIN
				SELECT @v_calcind=g.gen1ind,@v_calcsecqsicode=g.numericdesc1,@v_perqty=g.numericdesc2,@v_specialprocess=e.gentext1
				  FROM gentables g, gentables_ext e
				 WHERE g.tableid = 627 
				   AND g.datacode = @v_calculationtypecode
				   AND g.tableid = e.tableid 
				   AND g.datacode = e.datacode

		--print '**@v_calculationtypecode= ' + cast(@v_calculationtypecode as varchar)

				DECLARE tmpstructure_cur CURSOR FOR
					SELECT taqdetailscalekey,taqversionspecitemkey,autoapplyind
					  FROM #tmp_structure
					 WHERE calculationtypecode = @v_calculationtypecode

				OPEN tmpstructure_cur

				FETCH tmpstructure_cur INTO @v_taqdetailscalekey,@v_taqversionspecitemkey,@v_autoapplyind

				WHILE (@@FETCH_STATUS=0) BEGIN
		--print '**@v_calcsecqsicode= ' + cast(@v_calcsecqsicode as varchar)
		--print '**@v_taqdetailscalekey= ' + cast(@v_taqdetailscalekey as varchar)
					
					-----  GENERATE COSTS (pass in taqdetailscalkey,autoapplyind,taqversionspecitemkey,calcind,
					-----  calcsecqsicode,perqty,specialprocess,taqversionformatkey
					EXEC qpl_generate_scale_costs @v_taqversionspecitemkey,@v_taqdetailscalekey,@v_autoapplyind,@v_calcind,
					 @v_calcsecqsicode,@v_perqty,@v_specialprocess, @v_specs_formatyearkey,
					@o_error_code output,@o_error_desc output

					FETCH tmpstructure_cur INTO @v_taqdetailscalekey,@v_taqversionspecitemkey,@v_autoapplyind
				END
				CLOSE tmpstructure_cur
				DEALLOCATE tmpstructure_cur 

				FETCH calctype_cur INTO @v_calculationtypecode,@v_sortorder
			END   --calctype_cur

			CLOSE calctype_cur
			DEALLOCATE calctype_cur 

			-- Write costs
			SELECT @v_prodqtyitemcategorycode = datacode,@v_prodqtyitemcode = datasubcode FROM subgentables  WHERE tableid = 616 AND qsicode = 6
				
			SELECT @v_printing = printingnumber,@v_quantity = quan
			  FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey)
			 WHERE itemcategorycode = @v_prodqtyitemcategorycode
			   AND itemcode = @v_prodqtyitemcode

		--print '@v_printing= ' + cast(@v_printing as varchar)
		--print '@v_production_quantity= ' + cast(@v_quantity as varchar)

			DECLARE bucketcosts_cursor CURSOR FOR
				SELECT formatkey, internalcode, cost, validforprtgs, calccostcode
	  			  FROM #scalecostbucket_table

				OPEN bucketcosts_cursor
					
				FETCH bucketcosts_cursor
					INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
					
				WHILE (@@FETCH_STATUS = 0) BEGIN
					SET @v_acceptgenind=NULL

					SELECT @v_count = count(*)
					  FROM taqversioncosts
					 WHERE taqversionformatyearkey = @i_taqversionformatyearkey AND acctgcode = @v_bucket_internal
							
					IF @v_count > 0 BEGIN --- acctgcode exists on taqversioncosts already for that version/format/year
						SELECT @v_acceptgenind=acceptgenerationind
						  FROM taqversioncosts
						 WHERE acctgcode = @v_bucket_internal 
						   AND taqversionformatyearkey = @i_taqversionformatyearkey  

						IF @v_acceptgenind IS NOT NULL AND @v_acceptgenind > 0 BEGIN
							IF (@v_quantity IS NOT NULL AND @v_quantity <> 0) BEGIN
								SET @v_unitcost = @v_bucket_cost / @v_quantity --unit cost calculation

								UPDATE taqversioncosts
								   SET versioncostsamount = @v_bucket_cost, unitcost = @v_unitcost
								 WHERE acctgcode = @v_bucket_internal 
								   AND taqversionformatyearkey = @i_taqversionformatyearkey
							END
							ELSE BEGIN
								SET @v_unitcost = 0
							    
								UPDATE taqversioncosts
								   SET versioncostsamount = @v_bucket_cost,unitcost = @v_unitcost
								 WHERE acctgcode = @v_bucket_internal 
								   AND taqversionformatyearkey = @i_taqversionformatyearkey
							END
							INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
								VALUES (@i_taqversionformatyearkey, 'New costs for P&L Spec item have been added to this charge code', 4, @v_bucket_internal, @v_bucket_cost,
									getdate(), 'QSIADMIN', @i_processtype)
						END
						ELSE BEGIN  -- error
         				--write error to taqversioncostmessages
							INSERT INTO taqversioncostmessages 
							(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
							VALUES
							(@i_taqversionformatyearkey, 'Allow Gen? is not selected for this printing. Costs will not be added to the charge code.', 3, @v_bucket_internal, @v_bucket_cost,
							getdate(), 'QSIADMIN', @i_processtype)
						END 
					END
					ELSE BEGIN -- add taqversioncosts row
					  --if there is a quantity, recalculate unit cost and update it
						IF (@v_quantity IS NOT NULL AND @v_quantity <> 0) BEGIN
							SET @v_unitcost = @v_bucket_cost / @v_quantity --unit cost calculation
						END
						ELSE BEGIN
							SET @v_unitcost = @v_bucket_cost						
						END

            -- component unitcost
            SET @v_costcompkey = 0
            SET @v_compunitcost = @v_unitcost

            SELECT @v_compkey = compkey
              FROM cdlist
             WHERE internalcode =  @v_bucket_internal
            
            IF @v_compkey > 0 BEGIN
		          --print '@v_compkey= ' + cast(@v_compkey as varchar)
		          --print '@v_bucket_internal= ' + cast(@v_bucket_internal as varchar)

              SELECT TOP 1 @v_speccategorykey = COALESCE(taqversionspecategorykey,0), @v_compqty = coalesce(quantity,0)
                FROM taqversionspeccategory 
               WHERE taqversionkey = @v_taqversionkey
                 AND taqversionformatkey = @v_taqprojectformatkey
                 AND itemcategorycode = @v_compkey

		          --print '@v_speccategorykey= ' + cast(@v_speccategorykey as varchar)
		          --print '@v_compqty= ' + cast(@v_compqty as varchar)

              IF @v_speccategorykey > 0 BEGIN
                SET @v_costcompkey = @v_speccategorykey
              END
              IF @v_compqty > 0 BEGIN
                SET @v_compunitcost = @v_bucket_cost / @v_compqty
              END
            END

						SET @v_acceptgenind = 1
									
						INSERT INTO taqversioncosts --insert replacement cost with unitcost
							(taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, unitcost, printingnumber, acceptgenerationind, lastuserid, lastmaintdate, taqversionspeccategorykey, compunitcost)
							VALUES (@i_taqversionformatyearkey, @v_bucket_internal, @v_bucket_calccost, @v_bucket_cost, @v_unitcost, @v_printing, @v_acceptgenind, 'QSIADMIN', getdate(), @v_costcompkey, @v_compunitcost)
											
						INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
							VALUES (@i_taqversionformatyearkey, 'Costs for P&L Spec item have been added to this charge code', 4, @v_bucket_internal, @v_bucket_cost,
								getdate(), 'QSIADMIN', @i_processtype)

					END

					FETCH bucketcosts_cursor INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
				END
				CLOSE bucketcosts_cursor
				DEALLOCATE bucketcosts_cursor
		  END --@i_processtype = 1
	ELSE BEGIN
		SET @o_error_code = 0
		SET @o_error_desc = ''
		RETURN
	END

	RETURN
 
 RETURN_ERROR:
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_generate_costs_main TO PUBLIC
GO