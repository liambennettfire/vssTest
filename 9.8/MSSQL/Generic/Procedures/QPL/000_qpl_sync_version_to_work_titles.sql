if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_sync_version_to_work_titles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_sync_version_to_work_titles
GO

CREATE PROCEDURE qpl_sync_version_to_work_titles
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_plversionkey   integer,
  @i_userkey        integer,
  @i_copy_select_data_from_pl_to_work_titles	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_sync_version_to_work_titles
**  Desc: This stored procedure will Sync P&L Version to Titles for Work 
**        For all formats, price, quantity, pagecount,production specs will be synced
**        Selected comments and selected categories will be synced. 
**        
**
**  Auth: Kusum
**  Date: November 11, 2011
**
**  
*****************************************************************************************************/

DECLARE
	@v_isopentrans TINYINT,
	@v_userid VARCHAR(30),
	@v_taqprojectformatkey	INT,
	@v_activeprice  FLOAT,
	@v_mediatypecode	INT,
	@v_mediatypesubcode	INT,
  @v_count	INT,
	@v_count1	INT,
	@v_count2	INT,
	@v_count3	INT,
  @v_count4 INT,
  @v_count5 INT,
  @v_sub_quantity INT,
  @v_sub2_quantity INT,
	@v_quantity	INT,
	@v_taqprojectformatdesc VARCHAR(120),
	@v_version_commentkey INT,
  @v_project_commentkey	INT,
	@v_new_version_commentkey	INT,
	@v_commenttext	varchar(max),
	@v_commenthtml	varchar(max),
	@v_commenthtmllite	varchar(max),
	@v_invalidhtmlind	INT,
	@v_releasetoeloquenceind	TINYINT,
	@v_sortorder INT,	
	@v_clientdefaultvalue	INT,
	@v_cur_marketkey	INT, 
	@v_marketcode	INT, 
	@v_marketsubcode	INT, 
	@v_marketsub2code	INT, 
	@v_marketgrowthrate	INT, 
  @v_subjectkey	INT,
  @v_error	INT,
	@v_rowcount	INT,
	@v_commenttype	INT,
	@v_commentsubtype	INT,
  @v_titlerolecode INT,
	@v_bookkey	INT,
  @v_new_pricekey	INT,
	@v_price FLOAT,
	@v_budgetprice	FLOAT, 
	@v_finalprice	FLOAT,
  @v_historyorder INT,
  @v_currencytypecode	INT,
	@v_pricetypecode	INT,
  @v_plstage_sortorder INT,
  @v_last_non_actual_stage INT,
	@v_plstatus_approved_version INT,
  @v_plstatuscode_sel_version	INT,
	@v_currencytypedesc VARCHAR(40),
	@v_currentstringvalue VARCHAR(120),
  @v_pricetypedesc VARCHAR(40),
	@v_tmm_page_count	INT,
	@v_firstprintingqty	INT,
	@v_announcedfirstprint	INT,
	@v_pagecount	INT,
	@v_tmmpagecount	INT,
	@v_bookpages	INT,
	@v_misckey INT,
	@v_misctype INT,
	@v_longvalue INT,
	@v_floatvalue FLOAT,
	@v_textvalue	VARCHAR(255),
	@v_specitemcategory	INT,
  @v_specitem	INT,
  @v_taqversionspecategorykey INT,
  @v_itemcategorycode	INT,
	@v_itemcode	INT,
	@v_itemdetailcode	INT,
	@v_description VARCHAR(250),
	@v_datacode	INT,
	@v_datasubcode	INT,
	@v_miscname VARCHAR(40),
	@v_categorydesc	VARCHAR(40),
	@v_subcategorydesc	VARCHAR(40),
	@v_subcategory2desc	VARCHAR(40),
	@v_fielddesc	VARCHAR(40),
	@v_commentdesc	VARCHAR(40),
  @v_commentsubdesc	VARCHAR(40)

	

BEGIN

	SET @v_isopentrans = 0
	SET @o_error_code = 0
	SET @o_error_desc = ''

	IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
		SET @o_error_desc = 'Invalid projectkey.'
		GOTO RETURN_ERROR
	END

	IF @i_plstagecode = 0 AND @i_plversionkey = 0 BEGIN
		SET @o_error_desc = 'Invalid versionkey.'
		GOTO RETURN_ERROR
	END

	-- Get the User ID for the passed userkey
	SET @v_userid = 'SyncPLVer'
	IF @i_userkey >= 0 BEGIN
		SELECT @v_userid = userid
		  FROM qsiusers
		 WHERE userkey = @i_userkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
		 SET @o_error_desc = 'Could not access qsiusers table to get User ID.'
		 GOTO RETURN_ERROR
		END
	END

	IF @i_copy_select_data_from_pl_to_work_titles = 0 BEGIN
		SET @o_error_desc = 'Client option value is not set to sync P&L version to Work Project/Titles.'
		GOTO RETURN_ERROR
	END

	-- ***** BEGIN TRANSACTION ****  
	 BEGIN TRANSACTION
	 SET @v_isopentrans = 1

	-- Determine if stage being processed is prior to last, non-actual stage or last non-actual stage
	SELECT @v_plstage_sortorder = sortorder FROM gentables WHERE tableid = 562 and qsicode = 1  -- Actual stage
	IF @v_plstage_sortorder > 1
		SELECT @v_last_non_actual_stage = @v_plstage_sortorder - 1
	ELSE
		SELECT @v_last_non_actual_stage = 0

	-- Check clientoptions for optionid = 4 (tmm page count) 
	SELECT @v_tmm_page_count = optionvalue
    FROM clientoptions
   WHERE optionid = 4

	-- Check clientdefaultvalue for clientdefault id = 61 (P&L Status For Selected Version) to determine whether selected version is approved or not
	SELECT @v_plstatus_approved_version = clientdefaultvalue
    FROM clientdefaults
   WHERE clientdefaultid = 61

	SELECT @v_plstatuscode_sel_version = plstatuscode 
    FROM taqversion 
   WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey

	-- FORMATS
	-- formats that exist on Work Titles and on the P&L Version
	DECLARE work_titles_format_cur CURSOR FOR
	 SELECT taqversionformat.taqprojectformatkey, taqprojecttitle.bookkey, taqversionformat.activeprice
	   FROM taqprojecttitle, taqversionformat
	  WHERE taqprojecttitle.taqprojectkey = taqversionformat.taqprojectkey  AND taqversionformat.plstagecode = @i_plstagecode 
      AND taqversionformat.taqversionkey = @i_plversionkey 
      AND taqprojecttitle.mediatypecode = taqversionformat.mediatypecode AND taqprojecttitle.mediatypesubcode = taqversionformat.mediatypesubcode
      AND taqprojecttitle.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 1) 
		  AND taqprojecttitle.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 1)
		  AND taqprojecttitle.taqprojectkey = @i_projectkey 
	   
	OPEN work_titles_format_cur
  
	FETCH work_titles_format_cur INTO @v_taqprojectformatkey, @v_bookkey, @v_price
	

	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SELECT @v_currencytypecode = currencytypecode, @v_pricetypecode = pricetypecode 
		  FROM filterpricetype 
		 WHERE filterkey = 7

		--Price
		SELECT @v_count = COUNT(*)
		  FROM bookprice
     WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode
		   AND pricetypecode = @v_pricetypecode AND activeind = 1
		
		IF @v_count = 0
        BEGIN
			-- generate new bookprice pricekey
			EXEC get_next_key @v_userid, @v_new_pricekey OUTPUT
			
			SELECT @v_sortorder = max(sortorder)
        FROM bookprice
       WHERE bookkey = @v_bookkey

      IF @v_sortorder is NULL OR @v_sortorder = 0
				SELECT @v_sortorder = 0
      ELSE
        SELECT @v_sortorder = @v_sortorder + 1

			EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @v_userid, 
				@v_historyorder OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT 
			
			INSERT INTO bookprice (pricekey, bookkey, pricetypecode, currencytypecode, activeind, budgetprice, lastuserid, lastmaintdate, sortorder, history_order)
				VALUES(@v_new_pricekey, @v_bookkey, @v_pricetypecode, @v_currencytypecode, 1,@v_price, @v_userid, getdate(), @v_sortorder, @v_historyorder)

			SELECT @v_error = @@ERROR
			IF @v_error <> 0 BEGIN
				SET @o_error_desc = 'Could not insert into bookprice table (Error ' + cast(@v_error AS VARCHAR) + ').'
				GOTO RETURN_ERROR
			END

			SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'short')
			SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_price) + ' ' + @v_currencytypedesc
            SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
			

			EXEC dbo.qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_bookkey, 1, 0, @v_currentstringvalue,
				'insert', @v_userid, @v_historyorder,@v_pricetypedesc, @o_error_code output, @o_error_desc output
		END  --- no row on bookprice for currencytypecode and pricetypecode
		ELSE IF @i_plstagecode = @v_last_non_actual_stage  -- row on bookprice and stage being processed is last non-actual stage
		BEGIN
			IF @v_plstatuscode_sel_version <> @v_plstatus_approved_version  -- selected version is not approved
			BEGIN
				UPDATE bookprice
				   SET budgetprice = @v_price,
					     lastuserid = @v_userid,
					     lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update bookprice table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_historyorder = history_order
				  FROM bookprice
				 WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode

				SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'short')
				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_price) + ' ' + @v_currencytypedesc
				SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
				

				EXEC dbo.qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, @v_historyorder,@v_pricetypedesc, @o_error_code output, @o_error_desc output

			END
			ELSE   -- row on bookprice and stage being processed is last non-actual stage and selected version is approved
			BEGIN
				UPDATE bookprice
				   SET finalprice = @v_price,
					     lastuserid = @v_userid,
					     lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update bookprice table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_historyorder = history_order
				  FROM bookprice
				 WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode

				SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'short')
				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_price) + ' ' + @v_currencytypedesc
				SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
				

				EXEC dbo.qtitle_update_titlehistory 'bookprice', 'finalprice', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, @v_historyorder,@v_pricetypedesc, @o_error_code output, @o_error_desc output
			END
		END
		ELSE -- row on bookprice and stage being processed is prior to last non-actual stage
		BEGIN
			UPDATE bookprice
         SET budgetprice = @v_price,
				     lastuserid = @v_userid,
				     lastmaintdate = getdate()
       WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode


			SELECT @v_error = @@ERROR
			IF @v_error <> 0 BEGIN
				SET @o_error_desc = 'Could not update bookprice table (Error ' + cast(@v_error AS VARCHAR) + ').'
				GOTO RETURN_ERROR
			END

			SELECT @v_historyorder = history_order
        FROM bookprice
			 WHERE bookkey = @v_bookkey AND currencytypecode = @v_currencytypecode AND pricetypecode = @v_pricetypecode


			SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'short')
			SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_price) + ' ' + @v_currencytypedesc
      SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
			

			EXEC dbo.qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_bookkey, 1, 0, @v_currentstringvalue,
				'update', @v_userid, @v_historyorder,@v_pricetypedesc, @o_error_code output, @o_error_desc output
		END
		
		-- Quantities, PageCount
		SELECT @v_firstprintingqty = firstprintingqty, @v_announcedfirstprint = announcedfirstprint,
			   @v_pagecount = pagecount, @v_tmmpagecount = tmmpagecount
      FROM printing
     WHERE bookkey = @v_bookkey
       AND printingkey = 1

		
		SELECT @v_quantity = quantity
      FROM taqversionformatyear
     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey 
       AND taqprojectformatkey = @v_taqprojectformatkey AND printingnumber = 1

    SELECT @v_datacode = datacode, @v_datasubcode = datasubcode 
      FROM subgentables 
     WHERE tableid = 616 and qsicode = 2

		SELECT @v_bookpages = quantity 
		FROM taqversionspecitems_view 
		WHERE itemcategorycode = @v_datacode
			AND taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey AND taqversionformatkey = @v_taqprojectformatkey
			AND itemcode = @v_datasubcode
		
		-- Quantities
		IF @v_firstprintingqty = 0 OR @v_firstprintingqty IS NULL
		BEGIN
			IF @v_quantity > 0
      BEGIN
				UPDATE printing
           SET tentativeqty = @v_quantity,
               lastuserid = @v_userid,
			  		   lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_quantity) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'tentativeqty', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output
			END
		END

		IF @v_announcedfirstprint = 0 OR @v_announcedfirstprint IS NULL
		BEGIN
			IF @v_quantity > 0
      BEGIN
				UPDATE printing
           SET estannouncedfirstprint = @v_quantity,
               lastuserid = @v_userid,
		  			   lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_quantity) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'estannouncedfirstprint', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output
			END
		END


		-- Page Count
		IF @v_tmm_page_count = 0
    BEGIN
			IF @v_pagecount = 0 OR @v_pagecount IS NULL
			BEGIN
				UPDATE printing
           SET tentativepagecount = @v_bookpages,
               lastuserid = @v_userid,
		  			   lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_bookpages) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'tentativepagecount', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output
			END
			ELSE
			BEGIN
			  UPDATE printing
           SET pagecount = @v_bookpages,
               lastuserid = @v_userid,
				  	   lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_bookpages) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'pagecount', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output

			END
		END
		ELSE   -- tmmpagecount = 1
		BEGIN
			IF @v_tmmpagecount = 0 OR @v_tmmpagecount IS NULL
			BEGIN
				UPDATE printing
           SET tentativepagecount = @v_bookpages,
               lastuserid = @v_userid,
			  		   lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_bookpages) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'tentativepagecount', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output
			END
			ELSE
			BEGIN
			  UPDATE printing
           SET tmmpagecount = @v_bookpages,
               lastuserid = @v_userid,
				       lastmaintdate = getdate()
				 WHERE bookkey = @v_bookkey AND printingkey = 1

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_desc = 'Could not update printing table (Error ' + cast(@v_error AS VARCHAR) + ').'
					GOTO RETURN_ERROR
				END

				SELECT @v_currentstringvalue = CONVERT(VARCHAR,@v_bookpages) 
				
				EXEC dbo.qtitle_update_titlehistory 'printing', 'tmmpagecount', @v_bookkey, 1, 0, @v_currentstringvalue,
					'update', @v_userid, NULL,NULL, @o_error_code output, @o_error_desc output
			END
		END


    -- Production Specs
    DECLARE misckey_cursor CURSOR FOR
      SELECT DISTINCT s.numericdesc2, i.miscname, i.misctype
      FROM subgentables s, bookmiscitems i
      WHERE s.numericdesc2 = i.misckey  AND tableid = 616 AND numericdesc2 > 0
      UNION
      SELECT DISTINCT s2.numericdesc2, i.miscname, i.misctype
      FROM sub2gentables  s2, bookmiscitems i
      WHERE s2.numericdesc2 = i.misckey  AND tableid = 616 AND numericdesc2 > 0

    OPEN misckey_cursor

    FETCH misckey_cursor INTO @v_misckey, @v_miscname, @v_misctype

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookmisc
      WHERE bookkey = @v_bookkey AND misckey = @v_misckey

      SELECT @v_count1 = COUNT(*)
      FROM subgentables
      WHERE tableid = 616 AND numericdesc2 = @v_misckey

      SELECT @v_count2 = COUNT(*)
      FROM sub2gentables
      WHERE tableid = 616 AND numericdesc2 = @v_misckey
      
      -- If the misc item is Numeric (1), update sum of quantities - it doesn't matter how many p&l spec items are mapped to this misckey
      IF @v_misctype = 1
      BEGIN
        SET @v_sub_quantity = 0
        SET @v_sub2_quantity = 0
        
        IF @v_count1 > 0
          SELECT @v_sub_quantity = COALESCE(SUM(i.quantity),0)
          FROM taqversionspeccategory c, taqversionspecitems i
          WHERE c.taqversionspecategorykey = i.taqversionspecategorykey AND
            c.taqprojectkey = @i_projectkey AND 
            c.plstagecode = @i_plstagecode AND
            c.taqversionkey = @i_plversionkey AND 
            c.taqversionformatkey = @v_taqprojectformatkey AND
            c.itemcategorycode IN (SELECT datacode FROM subgentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
            i.itemcode IN (SELECT datasubcode FROM subgentables WHERE tableid = 616 AND numericdesc2 = @v_misckey)	
        
        IF @v_count2 > 0
          SELECT @v_sub2_quantity = COALESCE(SUM(i.quantity),0)
          FROM taqversionspeccategory c, taqversionspecitems i
          WHERE c.taqversionspecategorykey  = i.taqversionspecategorykey AND
            c.taqprojectkey = @i_projectkey AND 
            c.plstagecode = @i_plstagecode AND
            c.taqversionkey = @i_plversionkey AND 
            c.taqversionformatkey = @v_taqprojectformatkey AND
            c.itemcategorycode IN (SELECT datacode FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
            i.itemcode IN (SELECT datasubcode FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
            i.itemdetailcode IN (SELECT datasub2code FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey)
            
        SET @v_quantity = @v_sub_quantity + @v_sub2_quantity
        
        IF @v_count = 0
          INSERT INTO bookmisc (bookkey, misckey, longvalue, lastuserid, lastmaintdate)
          VALUES (@v_bookkey, @v_misckey, @v_quantity, @v_userid, getdate())
        ELSE
          UPDATE bookmisc
          SET longvalue = @v_quantity, lastuserid = @v_userid, lastmaintdate = getdate()
          WHERE bookkey = @v_bookkey AND misckey = @v_misckey          

        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_desc = 'Could not insert into bookmisc table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END

        SELECT @v_currentstringvalue = CONVERT(VARCHAR, @v_quantity) 

        EXEC dbo.qtitle_update_titlehistory 'bookmisc', 'longvalue', @v_bookkey, 1, 0, @v_currentstringvalue,
          'insert', @v_userid, NULL, @v_miscname, @o_error_code OUTPUT, @o_error_desc OUTPUT
      END --IF @v_misctype = 1    	  

      IF @v_count1 = 1 AND @v_count2 = 0 AND (@v_misctype = 3 OR @v_misctype = 5) --misckey only on single subgentable row
      BEGIN
        SELECT @v_itemcode = itemcode, @v_itemdetailcode = itemdetailcode, @v_description = description
        FROM taqversionspeccategory c, taqversionspecitems i
        WHERE c.taqversionspecategorykey = i.taqversionspecategorykey AND
          c.taqprojectkey = @i_projectkey AND 
          c.plstagecode = @i_plstagecode AND
          c.taqversionkey = @i_plversionkey AND 
          c.taqversionformatkey = @v_taqprojectformatkey AND
          c.itemcategorycode = (SELECT datacode FROM subgentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
          i.itemcode = (SELECT datasubcode FROM subgentables WHERE tableid = 616 AND numericdesc2 = @v_misckey)
            		  
        IF @v_misctype = 3  --text
        BEGIN
          IF @v_count = 0
            INSERT INTO bookmisc (bookkey, misckey, textvalue, lastuserid, lastmaintdate)
            VALUES (@v_bookkey, @v_misckey, @v_description, @v_userid, getdate())
          ELSE
            UPDATE bookmisc
            SET textvalue = @v_description, lastuserid = @v_userid, lastmaintdate = getdate()
            WHERE bookkey = @v_bookkey AND misckey = @v_misckey 
                  
          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'Could not insert into bookmisc table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END

          EXEC dbo.qtitle_update_titlehistory 'bookmisc', 'textvalue', @v_bookkey, 1, 0, @v_description,
            'insert', @v_userid, NULL, @v_miscname, @o_error_code OUTPUT, @o_error_desc OUTPUT
        END
        /* 10/28/13 - KW - Gentable sync is wrong. Per Susan, we are not supporting it at this time.
        ELSE IF @v_misctype = 5 --gentable
        BEGIN          
          IF @v_count = 0
            INSERT INTO bookmisc (bookkey, misckey, longvalue, lastuserid, lastmaintdate)
            VALUES (@v_bookkey, @v_misckey, @v_itemdetailcode, @v_userid, getdate())
          ELSE
            UPDATE bookmisc
            SET longvalue = @v_itemdetailcode, lastuserid = @v_userid, lastmaintdate = getdate()
            WHERE bookkey = @v_bookkey AND misckey = @v_misckey 
        
          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'Could not insert into bookmisc table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END

          SELECT @v_currentstringvalue = datadesc
          FROM subgentables
          WHERE tableid = 525 AND datacode = @v_itemcategorycode AND datasubcode = @v_itemcode

          EXEC dbo.qtitle_update_titlehistory 'bookmisc', 'longvalue', @v_bookkey, 1, 0, @v_currentstringvalue,
           'insert', @v_userid, NULL,@v_miscname, @o_error_code output, @o_error_desc output          
        END
        */
      END  -- misckey only on single subgentable row

      IF @v_count1 = 0 AND @v_count2 = 1 AND @v_misctype = 3  --misckey only on single sub2gentable row
      BEGIN
        SELECT @v_description = description
        FROM taqversionspeccategory c, taqversionspecitems i
        WHERE c.taqversionspecategorykey = i.taqversionspecategorykey AND
          c.taqprojectkey = @i_projectkey AND 
          c.plstagecode = @i_plstagecode AND
          c.taqversionkey = @i_plversionkey AND 
          c.taqversionformatkey = @v_taqprojectformatkey AND
          c.itemcategorycode = (SELECT datacode FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
          i.itemcode = (SELECT datasubcode FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey) AND
          i.itemdetailcode IN (SELECT datasub2code FROM sub2gentables WHERE tableid = 616 AND numericdesc2 = @v_misckey)
          
        IF @v_count = 0
          INSERT INTO bookmisc (bookkey, misckey, textvalue, lastuserid, lastmaintdate)
          VALUES (@v_bookkey, @v_misckey, @v_description, @v_userid, getdate())
        ELSE
          UPDATE bookmisc
          SET textvalue = @v_description, lastuserid = @v_userid, lastmaintdate = getdate()
          WHERE bookkey = @v_bookkey AND misckey = @v_misckey 
                
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_desc = 'Could not insert into bookmisc table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END

        EXEC dbo.qtitle_update_titlehistory 'bookmisc', 'textvalue', @v_bookkey, 1, 0, @v_description,
          'insert', @v_userid, NULL, @v_miscname, @o_error_code OUTPUT, @o_error_desc OUTPUT          
      END -- misckey only on single subg2gentable row

      FETCH misckey_cursor INTO @v_misckey, @v_miscname, @v_misctype
    END  --misckey_cursor fetch

    CLOSE misckey_cursor
    DEALLOCATE misckey_cursor
   
	
	
		--COMMENTS
		DECLARE versioncomments_cur CURSOR FOR
			SELECT commentkey, commenttypecode, commenttypesubcode, sortorder
			 FROM taqversioncomments
			WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey
		    
		OPEN versioncomments_cur 
		  
		FETCH versioncomments_cur INTO @v_version_commentkey,@v_commenttype, @v_commentsubtype, @v_sortorder

		WHILE (@@FETCH_STATUS=0)
		BEGIN
			SELECT @v_count1 = 0
			SELECT @v_count2 = 0
			
			-- Item type filtering set for Projects/Title Acquisition
			SELECT @v_count1 = COUNT(*)
			  FROM gentablesitemtype 
			 WHERE tableid = 284
			   AND itemtypecode = (select datacode from gentables where tableid = 550 and qsicode = 1)
			   AND itemtypesubcode = (select datasubcode from subgentables where tableid = 550 and datacode = (select datacode from gentables where tableid = 550 and qsicode = 1)
							  and qsicode = 26) 
			   AND datacode = @v_commenttype 
			   AND datasubcode = @v_commentsubtype

			IF @v_count1 = 1 
			BEGIN
				-- Item type filtering set for User Admin/P&L Templat
				SELECT @v_count2 = COUNT(*)
				  FROM gentablesitemtype 
				 WHERE tableid = 284
				   AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 5)
				   AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 and datacode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 5)
										  AND qsicode = 29) 
				   AND datacode = @v_commenttype 
				   AND datasubcode = @v_commentsubtype

				IF @v_count2 = 1
				BEGIN
					SELECT @v_count3 = 0

					SELECT @v_count3 = COUNT(*)
					  FROM bookcomments
					 WHERE bookkey = @v_bookkey
					   AND commenttypecode = @v_commenttype
					   AND commenttypesubcode = @v_commentsubtype

					IF @v_count3 = 1 
					BEGIN

						SELECT @v_commenttext = commenttext, @v_commenthtml = commenthtml, @v_commenthtmllite = commenthtmllite,
								@v_invalidhtmlind = invalidhtmlind, @v_releasetoeloquenceind = releasetoeloquenceind
						  FROM qsicomments	
						 WHERE commentkey = @v_version_commentkey
						   AND commenttypecode = @v_commenttype
						   AND commenttypesubcode = @v_commentsubtype

						UPDATE bookcomments
						   SET commenttext = @v_commenttext, commenthtml = @v_commenthtml, commenthtmllite = @v_commenthtmllite,invalidhtmlind = @v_invalidhtmlind,
							   lastuserid = @v_userid, lastmaintdate = getdate()
						 WHERE bookkey = @v_bookkey
						   AND commenttypecode = @v_commenttype
						   AND commenttypesubcode = @v_commentsubtype

						SELECT @v_error = @@ERROR
						IF @v_error <> 0 BEGIN
							SET @o_error_desc = 'Could not update bookcomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
							GOTO RETURN_ERROR
						END

						SELECT @v_commentdesc = g.datadesc,@v_commentsubdesc = s.datadesc
						  FROM subgentables s JOIN gentables g
							ON s.tableid = g.tableid AND g.datacode = s.datacode
						 WHERE s.tableid = 284 AND s.deletestatus = 'N'
						   AND s.datacode = @v_commenttype AND s.datasubcode = @v_commentsubtype

						SELECT @v_fielddesc =  '(' + substring(@v_commentdesc,1,1) + ') ' + @v_commentsubdesc

						EXEC qtitle_update_titlehistory 'bookcomments', 'commentstring' , @v_bookkey, 1, 0, @v_commenttext, 'update', @v_userid, 
							NULL, @v_fielddesc, @o_error_code output, @o_error_desc output
					END
					ELSE
					BEGIN
						INSERT INTO bookcomments
						(bookkey,printingkey, commenttypecode, commenttypesubcode, commenttext, lastuserid, lastmaintdate,commenthtml,commenthtmllite,invalidhtmlind)
						SELECT
							@v_bookkey, 1, commenttypecode, commenttypesubcode,commenttext,@v_userid, getdate(),commenthtml,commenthtmllite,invalidhtmlind
						FROM qsicomments
						WHERE commentkey = @v_version_commentkey

						 
						SELECT @v_error = @@ERROR
						IF @v_error <> 0 BEGIN
							SET @o_error_desc = 'Could not insert into bookcomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
							GOTO RETURN_ERROR
						END

						SELECT @v_commentdesc = g.datadesc,@v_commentsubdesc = s.datadesc
						  FROM subgentables s JOIN gentables g
							ON s.tableid = g.tableid AND g.datacode = s.datacode
						 WHERE s.tableid = 284 AND s.deletestatus = 'N'
						   AND s.datacode = @v_commenttype AND s.datasubcode = @v_commentsubtype

						SELECT @v_fielddesc =  '(' + substring(@v_commentdesc,1,1) + ') ' + @v_commentsubdesc

						EXEC qtitle_update_titlehistory 'bookcomments', 'commentstring' , @v_bookkey, 1, 0, @v_commenttext, 'insert', @v_userid, 
							NULL, @v_fielddesc, @o_error_code output, @o_error_desc output
					END
				END
			END

			FETCH versioncomments_cur INTO @v_version_commentkey, @v_commenttype, @v_commentsubtype	, @v_sortorder
		END
		    
		CLOSE versioncomments_cur 
		DEALLOCATE versioncomments_cur 
		
		--CATEGORIES
		SELECT @v_count = 0

		SELECT @v_count = count(*)
		  FROM clientdefaults
		 WHERE clientdefaultid = 54  -- P&L Target Market Table ID

		IF @v_count = 1
		BEGIN
			SELECT @v_clientdefaultvalue = clientdefaultvalue
			  FROM clientdefaults
			 WHERE clientdefaultid = 54

			DECLARE markets_cur CURSOR FOR
				SELECT targetmarketkey, marketcode, marketsubcode, marketsub2code, marketgrowthpercent, sortorder
				FROM taqversionmarket
				WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey
	              
			    
			OPEN markets_cur
			  
			FETCH markets_cur
			  INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder

			WHILE (@@FETCH_STATUS=0)
			BEGIN
				SELECT @v_count2 = 0

				SELECT @v_count2 = COUNT(*)
				  FROM booksubjectcategory
				 WHERE bookkey = @v_bookkey AND categorytableid = @v_clientdefaultvalue 
				   AND categorycode = @v_marketcode AND categorysubcode = @v_marketsubcode
				   AND categorysub2code = @v_marketsub2code

				IF @v_count2 = 0
				BEGIN
					EXEC get_next_key @v_userid, @v_subjectkey OUTPUT

					INSERT INTO booksubjectcategory
						(bookkey, subjectkey, categorytableid, categorycode,categorysubcode, categorysub2code, sortorder, lastuserid, lastmaintdate)
					VALUES
						(@v_bookkey, @v_subjectkey, @v_clientdefaultvalue, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_sortorder,@v_userid, getdate()) 

					SELECT @v_error = @@ERROR
					IF @v_error <> 0 BEGIN
						SET @o_error_desc = 'Could not insert into bookcomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
						GOTO RETURN_ERROR
					END


					SELECT @v_categorydesc = dbo.rpt_get_gentables_desc(@v_clientdefaultvalue,@v_marketcode,'long')
					SELECT @v_subcategorydesc = dbo.rpt_get_subgentables_desc(@v_clientdefaultvalue,@v_marketcode,@v_marketsubcode,'long')
					SELECT @v_subcategory2desc = dbo.rpt_get_sub2gentables_desc(@v_clientdefaultvalue,@v_marketcode,@v_marketsubcode,@v_marketsub2code,'long')
					SELECT @v_fielddesc = 'Subject - ' + CONVERT(VARCHAR,@v_sortorder)
					SELECT @v_currentstringvalue = @v_categorydesc + ' - ' + @v_subcategorydesc + ' - ' + @v_subcategory2desc
						
					EXEC dbo.qtitle_update_titlehistory 'booksubjectcategory', 'categorycode', @v_bookkey, 1, 0, @v_currentstringvalue,
						'insert', @v_userid, NULL,@v_fielddesc, @o_error_code output, @o_error_desc output

					SELECT @v_fielddesc = 'Subject - ' + CONVERT(VARCHAR,@v_sortorder) + ' - ' + @v_categorydesc
					SELECT @v_currentstringvalue =  @v_subcategorydesc + ' - ' + @v_subcategory2desc
					EXEC dbo.qtitle_update_titlehistory 'booksubjectcategory', 'categorysubcode', @v_bookkey, 1, 0, @v_currentstringvalue,
						'insert', @v_userid, NULL,@v_fielddesc, @o_error_code output, @o_error_desc output

					SELECT @v_fielddesc = 'Subject - ' + CONVERT(VARCHAR,@v_sortorder) + ' - ' + @v_categorydesc + ' - '  + @v_subcategorydesc
					SELECT @v_currentstringvalue =  @v_subcategory2desc
					EXEC dbo.qtitle_update_titlehistory 'booksubjectcategory', 'categorysub2code', @v_bookkey, 1, 0, @v_currentstringvalue,
						'insert', @v_userid, NULL,@v_fielddesc, @o_error_code output, @o_error_desc output
				END

				FETCH markets_cur
					INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder
			END
		  
		  CLOSE markets_cur
		  DEALLOCATE markets_cur 
		END
		ELSE
		BEGIN
			SELECT @v_clientdefaultvalue = 0
		END

		FETCH work_titles_format_cur INTO @v_taqprojectformatkey, @v_bookkey, @v_price
	END
  
	CLOSE work_titles_format_cur
	DEALLOCATE work_titles_format_cur
	

	IF @v_isopentrans = 1
		COMMIT
    
	RETURN  

RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK
    
  SET @o_error_code = -1
  RETURN


END
GO

GRANT EXEC ON qpl_sync_version_to_work_titles TO PUBLIC
GO