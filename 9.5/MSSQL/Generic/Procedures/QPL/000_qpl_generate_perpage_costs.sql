if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_generate_perpage_costs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_generate_perpage_costs
GO

CREATE PROCEDURE qpl_generate_perpage_costs (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_generate_perpage_costs
**  Desc: This stored procedure generates the costs perpage for a P&L version. It also generates related
**		messages into taqversioncostmessages.
**
**  Auth: Dustin Miller
**  Date: December 1, 2011
*****************************************************************************************************/

DECLARE
	@v_formatkey					INT,
	@v_formatyearkey			INT,
	@v_printing						INT,
	@v_yearcode						INT,
	@v_quantity						INT,
	@v_pagecount					INT,
	@v_specitemkey				INT,
	@v_validforprtgs			INT,
	@v_itemcode						INT,
	@v_itemdetailcode			INT,
	@v_acctgcatcode				INT,
	@v_cost								FLOAT,
	@v_unitcost						FLOAT,
	@v_costtype						VARCHAR(50),
	@v_ext_chargecode			VARCHAR(255),
	@v_int_chargecode			INT,
	@v_bucket_format			INT,
	@v_bucket_internal		INT,
	@v_bucket_cost				FLOAT,
	@v_bucket_validprtgs	INT,
	@v_bucket_calccost		INT,
	@v_acceptgenind				INT,
	@v_taqversionspecategorykey	INT,
	@v_itemcategorycode	INT

BEGIN
	SET @o_error_code=0
	SET @o_error_desc=NULL

	--create cost bucket
	DECLARE @costbucket_table TABLE
	(
		formatkey			INT,
		internalcode	INT,
		itemcost			FLOAT,
		validforprtgs	INT,
		calccostcode	INT
	)
	
	--Delete all existing taqversionmessages without a formatyearkey
	DELETE FROM taqversioncostmessages WHERE taqversionformatyearkey IS NULL

	DECLARE formats_cursor CURSOR FOR
	SELECT taqprojectformatkey
	FROM taqversionformat
	WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_versionkey
	
	OPEN formats_cursor
	
	FETCH formats_cursor
	INTO @v_formatkey
  
  WHILE (@@FETCH_STATUS = 0)
	BEGIN
	
	DELETE FROM @costbucket_table

	DECLARE versionspeccategory_cur CURSOR FOR
		SELECT taqversionspecategorykey,itemcategorycode
		FROM taqversionspeccategory
		WHERE taqversionformatkey = @v_formatkey 

	OPEN versionspeccategory_cur 

	FETCH versionspeccategory_cur
	 INTO @v_taqversionspecategorykey, @v_itemcategorycode

	WHILE (@@FETCH_STATUS=0)
	BEGIN
	
		DECLARE specitem_cursor CURSOR FOR
			SELECT taqversionspecitemkey, validforprtgscode, itemcode, itemdetailcode
		      FROM taqversionspecitems
		     WHERE taqversionspecategorykey = @v_taqversionspecategorykey
    
		OPEN specitem_cursor
	    
		FETCH specitem_cursor
		INTO @v_specitemkey, @v_validforprtgs,  @v_itemcode, @v_itemdetailcode
	    
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
				SET @v_cost=NULL
				SET @v_ext_chargecode=NULL
				SELECT @v_cost=numericdesc1, @v_ext_chargecode=gentext1
				FROM sub2gentables s, sub2gentables_ext e
				WHERE s.tableid=616 AND e.tableid=616 AND numericdesc1 IS NOT NULL AND numericdesc1 <> 0
					AND s.datacode=@v_itemcategorycode AND s.datasubcode=@v_itemcode AND s.datasub2code=@v_itemdetailcode
					AND e.datacode=@v_itemcategorycode AND e.datasubcode=@v_itemcode AND e.datasub2code=@v_itemdetailcode
				
				IF @v_ext_chargecode IS NOT NULL AND @v_cost IS NOT NULL
				BEGIN
				
					SET @v_acctgcatcode=NULL
					SELECT @v_acctgcatcode=placctgcategorycode
					FROM cdlist
					WHERE externalcode = @v_ext_chargecode 
					AND placctgcategorycode IN (SELECT datacode FROM gentables WHERE tableid = 571 AND qsicode = 2)
					
					IF @v_acctgcatcode IS NOT NULL
					BEGIN

						SELECT @v_pagecount = quantity
                          FROM taqversionspecitems
                         WHERE taqversionspecategorykey = @v_taqversionspecategorykey
                           AND itemcode = (SELECT datasubcode FROM subgentables
                                             WHERE tableid = 616 and qsicode = 2)


						SET @v_cost = @v_cost * @v_pagecount
					
						SELECT @v_int_chargecode=internalcode, @v_costtype=costtype
						FROM cdlist 
						WHERE externalcode = @v_ext_chargecode
						
						IF (LOWER(@v_costtype)='e')
						BEGIN
							SET @v_bucket_calccost=2
						END
						ELSE BEGIN
							SET @v_bucket_calccost=1
						END
			      
						--insert costs into bucket
						SET @v_bucket_cost=NULL
						SELECT @v_bucket_cost=itemcost
						FROM @costbucket_table
						WHERE internalcode=@v_int_chargecode AND formatkey=@v_formatkey
						
						IF @v_bucket_cost IS NULL
						BEGIN --insert value to costbucket
							SET @v_bucket_cost = @v_cost
							INSERT INTO @costbucket_table
							VALUES (@v_formatkey, @v_int_chargecode, @v_bucket_cost, @v_validforprtgs, @v_bucket_calccost)
						END
						ELSE BEGIN --update already existing bucket value
							SET @v_bucket_cost = @v_bucket_cost + @v_cost
							UPDATE @costbucket_table
							SET itemcost=@v_bucket_cost
							WHERE internalcode=@v_int_chargecode
						END
						--end insert costs into bucket
					END
				END
				ELSE BEGIN
					--write error message
					INSERT INTO taqversioncostmessages 
					(message, messagetypecode, acctgcode, lastmaintdate, lastmaintuser)
					VALUES
					('External charge code is not found for P&L spec item', 3, @v_int_chargecode,
					getdate(), 'QSIADMIN')
				END
				
				FETCH specitem_cursor
				INTO @v_specitemkey, @v_validforprtgs, @v_itemcode, @v_itemdetailcode
		END
		CLOSE specitem_cursor
		DEALLOCATE specitem_cursor
    
		FETCH versionspeccategory_cur
			INTO @v_taqversionspecategorykey,@v_itemcategorycode
	  END

	  CLOSE versionspeccategory_cur
	  DEALLOCATE versionspeccategory_cur 
		
		--printing cursor
		DECLARE printings_cursor CURSOR FOR
		SELECT taqversionformatyearkey, printingnumber, yearcode, quantity
		FROM taqversionformatyear 
		WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND 
			taqversionkey = @i_versionkey AND taqprojectformatkey = @v_formatkey --AND printingnumber IS NOT NULL
			
		OPEN printings_cursor
		
		FETCH printings_cursor
		INTO @v_formatyearkey, @v_printing, @v_yearcode, @v_quantity
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			DELETE FROM taqversioncostmessages WHERE taqversionformatyearkey=@v_formatyearkey
			
			DECLARE bucketcosts_cursor CURSOR FOR
			SELECT formatkey, internalcode, itemcost, validforprtgs, calccostcode
			FROM @costbucket_table
			
			OPEN bucketcosts_cursor
			
			FETCH bucketcosts_cursor
			INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
			
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @v_acceptgenind=NULL
					
				SELECT @v_acceptgenind=acceptgenerationind
				FROM taqversioncosts
				WHERE /*printingnumber = @v_printing AND*/ acctgcode = @v_bucket_internal AND
					taqversionformatyearkey = @v_formatyearkey --IN 
					--(SELECT taqversionformatyearkey FROM taqversionformatyear
					--WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND 
					 --taqversionkey = @i_versionkey AND taqprojectformatkey = @v_formatkey)
					 
				IF @v_acceptgenind IS NOT NULL AND @v_acceptgenind > 0
					BEGIN
						DELETE FROM taqversioncosts 
						WHERE /*printingnumber = @v_printing AND*/ acctgcode = @v_bucket_internal AND
							taqversionformatyearkey = @v_formatyearkey --IN 
							--(SELECT taqversionformatyearkey FROM taqversionformatyear
							--WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND 
							 --taqversionkey = @i_versionkey AND taqprojectformatkey = @v_formatkey)
						DELETE FROM taqversioncostmessages 
						WHERE taqversionformatyearkey=@v_formatyearkey
						AND acctgcode = @v_bucket_internal
					END
			
				IF (@v_printing=1 AND (@v_bucket_validprtgs=1 OR @v_bucket_validprtgs=3))
					OR (@v_printing <> 1 AND (@v_bucket_validprtgs=2 OR @v_bucket_validprtgs=3)) --proceed for all that have validforprtgs 1 or 2
				BEGIN  
					IF @v_acceptgenind IS NOT NULL --if acctgcode exists already for version/format/yr
					BEGIN
						IF (@v_acceptgenind > 0)
						BEGIN
							--if there is a quantity, recalculate unit cost and update it
							IF (@v_quantity IS NOT NULL AND @v_quantity <> 0)
							BEGIN
								SET @v_unitcost = @v_bucket_cost / @v_quantity --unit cost calculation
								
								INSERT INTO taqversioncosts --insert replacement cost with unitcost
								(taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, unitcost, printingnumber, acceptgenerationind, lastuserid, lastmaintdate)
								VALUES
								(@v_formatyearkey, @v_bucket_internal, @v_bucket_calccost, @v_bucket_cost, @v_unitcost, @v_printing, @v_acceptgenind, 'QSIADMIN', getdate())
								
								INSERT INTO taqversioncostmessages 
								(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser)
								VALUES
								(@v_formatyearkey, 'Costs for P&L Spec item have been added to this charge code', 4, @v_bucket_internal, @v_bucket_cost,
								getdate(), 'QSIADMIN')
								IF @o_error_code = 0
								BEGIN
									SET @o_error_code = 1
								END
							END
							ELSE BEGIN --otherwise, update costs without unitcost
								INSERT INTO taqversioncosts --insert replacement cost
								(taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, printingnumber, acceptgenerationind, lastuserid, lastmaintdate)
								VALUES
								(@v_formatyearkey, @v_bucket_internal, @v_bucket_calccost, @v_bucket_cost, @v_printing, @v_acceptgenind, 'QSIADMIN', getdate())
								
								INSERT INTO taqversioncostmessages 
								(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser)
								VALUES
								(@v_formatyearkey, 'Costs for P&L Spec item have been added to this charge code w/o unitcost (no quantity available)', 4, @v_bucket_internal, @v_bucket_cost,
								getdate(), 'QSIADMIN')
							END
							
						END
						ELSE BEGIN
							--write error to taqversioncostmessages
							INSERT INTO taqversioncostmessages 
							(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser)
							VALUES
							(@v_formatyearkey, 'Allow Gen? is not selected for this printing. Costs will not be added to the charge code.', 3, @v_bucket_internal, @v_bucket_cost,
							getdate(), 'QSIADMIN')
						END
					END
					ELSE BEGIN   
						--if there is a quantity, recalculate unit cost and update it
						IF (@v_quantity IS NOT NULL AND @v_quantity <> 0)
						BEGIN
							SET @v_unitcost = @v_bucket_cost / @v_quantity --unit cost calculation
							
							INSERT INTO taqversioncosts --insert new cost
							(taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, unitcost, printingnumber, acceptgenerationind, lastuserid, lastmaintdate)
							VALUES
							(@v_formatyearkey, @v_bucket_internal, @v_bucket_calccost, @v_bucket_cost, @v_unitcost, @v_printing, 1, 'QSIADMIN', getdate())
						
							INSERT INTO taqversioncostmessages 
							(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser)
							VALUES
							(@v_formatyearkey, 'New costs for P&L Spec item have been added to this charge code', 4, @v_bucket_internal, @v_bucket_cost,
							getdate(), 'QSIADMIN')
						END
						ELSE BEGIN
							INSERT INTO taqversioncosts --insert new cost
							(taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, printingnumber, acceptgenerationind, lastuserid, lastmaintdate)
							VALUES
							(@v_formatyearkey, @v_bucket_internal, @v_bucket_calccost, @v_bucket_cost, @v_printing, 1, 'QSIADMIN', getdate())
						
							INSERT INTO taqversioncostmessages 
							(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser)
							VALUES
							(@v_formatyearkey, 'New costs for P&L Spec item have been added to this charge code w/o unitcost (no quantity available)', 4, @v_bucket_internal, @v_bucket_cost,
							getdate(), 'QSIADMIN')
						END
					END
        END
				FETCH bucketcosts_cursor
			INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
			
			END
			CLOSE bucketcosts_cursor
			DEALLOCATE bucketcosts_cursor
			
			FETCH printings_cursor
			INTO @v_formatyearkey, @v_printing, @v_yearcode, @v_quantity
		END
		CLOSE printings_cursor
		DEALLOCATE printings_cursor
		
		FETCH formats_cursor
		INTO @v_formatkey
	END
	CLOSE formats_cursor
	DEALLOCATE formats_cursor
  
END
GO

GRANT EXEC ON qpl_generate_perpage_costs TO PUBLIC
GO
