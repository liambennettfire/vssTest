PRINT 'CREATING STORED PROCEDURE : dbo.SetPrices'
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.SetPrices') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP PROC dbo.SetPrices
  END
GO

CREATE PROC dbo.SetPrices AS
BEGIN

  DECLARE @v_bookkey		INT,
		@v_count		INT,
		@v_numtitles	INT,
		@v_checkcount	INT,
		@v_maxdate		DATETIME,
		@v_checkdate	DATETIME,
		@v_sortorder	INT,
		@v_pricekey		INT,
		@v_pricetype	INT,
		@v_currency		INT,
		@v_budgetprice		FLOAT,
		@v_finalprice		FLOAT,
		@v_prev_pricetype		INT,
		@v_prev_currency		INT,
		@v_prev_budgetprice	INT,
		@v_prev_finalprice	INT,
		@v_sum_budgetprice	FLOAT,
		@v_sum_finalprice		FLOAT,
		@v_current_budgetprice	FLOAT,
		@v_current_finalprice	FLOAT,
		@v_processlastrow		TINYINT

  DECLARE sets_cur CURSOR FOR
	SELECT bookkey
	FROM book
	WHERE linklevelcode = 30

  OPEN sets_cur

  FETCH NEXT FROM sets_cur INTO @v_bookkey

  /* <<sets_cursor>> */
  WHILE (@@FETCH_STATUS = 0)
    BEGIN
		/* Get the count of titles in this set */
		SELECT @v_numtitles = count(*)
		FROM bookfamily
		WHERE bookfamily.parentbookkey = @v_bookkey AND bookfamily.relationcode = 20001

		IF @v_numtitles = 0
			SET @v_maxdate = NULL
		ELSE
			/* Get the latest Pub Date on all titles in the set */
			SELECT @v_maxdate = MAX(bestdate)
			FROM bookdates, bookfamily
			WHERE bookdates.printingkey = 1 AND
				bookdates.datetypecode = 8 AND
				bookdates.bookkey = bookfamily.childbookkey  AND
				bookfamily.parentbookkey = @v_bookkey AND bookfamily.relationcode = 20001  /* Set Component */
			GROUP BY parentbookkey

		/* Get the number of titles and available date as currently exists on booksets table for this set */
		SELECT @v_checkcount = numtitles, @v_checkdate = availabledate
		FROM booksets
		WHERE bookkey = @v_bookkey AND printingkey = 1

		/*** Update numtitles and availabledate on the booksets table ***/
		IF (@v_numtitles IS NULL AND @v_checkcount IS NOT NULL) OR 
				(@v_numtitles IS NOT NULL AND @v_checkcount IS NULL) OR
				(@v_maxdate IS NULL AND @v_checkdate IS NOT NULL) OR 
				(@v_maxdate IS NOT NULL AND @v_checkdate IS NULL) OR
				(@v_numtitles <> @v_checkcount) OR (@v_maxdate <> @v_checkdate)
			UPDATE booksets
			SET numtitles = @v_numtitles, availabledate = @v_maxdate,
				lastuserid = 'QSIDBA', lastmaintdate = getdate()
			WHERE bookkey = @v_bookkey AND printingkey = 1

		
		/* Initialize variables */
		SET @v_sortorder = 0
		SET @v_processlastrow = 0

		DECLARE titleprices_cur CURSOR FOR
		  SELECT pricetypecode, currencytypecode, budgetprice, finalprice 
		  FROM bookprice
		  WHERE activeind = 1 AND 
				bookkey IN (SELECT childbookkey 
				FROM bookfamily 
				WHERE parentbookkey = @v_bookkey AND relationcode = 20001)	/* Set Component */
		  ORDER BY pricetypecode, currencytypecode

		OPEN titleprices_cur

		FETCH NEXT FROM titleprices_cur 
		INTO @v_pricetype, @v_currency, @v_budgetprice, @v_finalprice

		SET @v_prev_pricetype = @v_pricetype
		SET @v_prev_currency = @v_currency
		SET @v_prev_budgetprice = @v_budgetprice
		SET @v_prev_finalprice = @v_finalprice

		/* <<titleprices_cursor>> */
		WHILE (@@FETCH_STATUS = 0)
		  BEGIN

			/* If the pricetype and currency differs from previous row, process previous row's prices */
			IF @v_pricetype <> @v_prev_pricetype OR @v_currency <> @v_prev_currency
			  BEGIN

				/* Accumulate sortorder */
				SET @v_sortorder = @v_sortorder + 1

				/* Check if this price already exists on this Set */
				SELECT @v_count = count(*)
				FROM bookprice
				WHERE bookkey = @v_bookkey AND
						pricetypecode = @v_prev_pricetype AND
						currencytypecode = @v_prev_currency

				IF @v_count = 0	/* this price doesn't exist on the Set - insert */
				  BEGIN

					/* Get next pricekey */
					UPDATE keys 
					SET generickey = generickey + 1,
						lastuserid = 'QSIDBA', 
						lastmaintdate = getdate()
					
					SELECT @v_pricekey = generickey
					FROM keys

					/* Insert new price for this Set */
					INSERT INTO bookprice
						(pricekey,
						bookkey,
						pricetypecode,
						currencytypecode,
						activeind,
						budgetprice,
						finalprice,
						sortorder,
						lastuserid,
						lastmaintdate)
					VALUES
						(@v_pricekey,
						@v_bookkey,
						@v_prev_pricetype,
						@v_prev_currency,
						1,
						@v_sum_budgetprice,
						@v_sum_finalprice,
						@v_sortorder,
						'QSIDBA',
						getdate())
				  END

				ELSE	/* this price already exists on the Set - update */
				  BEGIN
					/* Get existing prices */
					SELECT @v_current_budgetprice = budgetprice, @v_current_finalprice = finalprice
					FROM bookprice
					WHERE bookkey = @v_bookkey AND
							pricetypecode = @v_prev_pricetype AND
							currencytypecode = @v_prev_currency

					IF @v_current_budgetprice IS NULL
						SET @v_current_budgetprice = 0
					IF @v_current_finalprice IS NULL
						SET @v_current_finalprice = 0

					/* Only update when necessary */
					IF @v_current_budgetprice <> @v_sum_budgetprice OR @v_current_finalprice <> @v_sum_finalprice
						UPDATE bookprice
						SET budgetprice = @v_sum_budgetprice, finalprice = @v_sum_finalprice,
							sortorder = @v_sortorder, lastuserid = 'QSIDBA', lastmaintdate = getdate()
						WHERE bookkey = @v_bookkey AND
								pricetypecode = @v_prev_pricetype AND
								currencytypecode = @v_prev_currency

				  END
				
				/* Reset sum prices */
				SET @v_sum_budgetprice = 0
				SET @v_sum_finalprice = 0

			  END

			/* Accumulate prices for current pricetype and currency */
			IF @v_sum_budgetprice IS NULL
				SET @v_sum_budgetprice = 0
			IF @v_sum_finalprice IS NULL
				SET @v_sum_finalprice = 0
			IF @v_budgetprice IS NULL
				SET @v_budgetprice = 0
			IF @v_finalprice IS NULL
				SET @v_finalprice = 0
			SET @v_sum_budgetprice = @v_sum_budgetprice + @v_budgetprice
			SET @v_sum_finalprice = @v_sum_finalprice + @v_finalprice

			/* Set previous row's values for comparison */
			SET @v_prev_pricetype = @v_pricetype
			SET @v_prev_currency = @v_currency
			SET @v_prev_budgetprice = @v_budgetprice
			SET @v_prev_finalprice = @v_finalprice

			FETCH NEXT FROM titleprices_cur 
			INTO @v_pricetype, @v_currency, @v_budgetprice, @v_finalprice	

			/* Set indicator to force processing of last row after at least one row was processed for this set */
			SET @v_processlastrow = 1
		
		  END	/* LOOP <<titleprices_cursor>> */

		CLOSE titleprices_cur
		DEALLOCATE titleprices_cur

		IF @v_processlastrow = 1
		  BEGIN
			/* Accumulate sortorder */
			SET @v_sortorder = @v_sortorder + 1
	
			/* Check if the last row's price already exists on this Set */
			SELECT @v_count = count(*)
			FROM bookprice
			WHERE bookkey = @v_bookkey AND
					pricetypecode = @v_prev_pricetype AND
					currencytypecode = @v_prev_currency
	
			IF @v_count = 0	/* this price doesn't exist on the Set - insert */
			  BEGIN
	
				/* Get next pricekey */
				UPDATE keys 
				SET generickey = generickey + 1,
					lastuserid = 'QSIDBA', 
					lastmaintdate = getdate()
				
				SELECT @v_pricekey = generickey
				FROM keys
	
				/* Insert new price for this Set */
				INSERT INTO bookprice
					(pricekey,
					bookkey,
					pricetypecode,
					currencytypecode,
					activeind,
					budgetprice,
					finalprice,
					sortorder,
					lastuserid,
					lastmaintdate)
				VALUES
					(@v_pricekey,
					@v_bookkey,
					@v_prev_pricetype,
					@v_prev_currency,
					1,
					@v_sum_budgetprice,
					@v_sum_finalprice,
					@v_sortorder,
					'QSIDBA',
					getdate())
			  END
	
			ELSE	/* this price already exists on the Set - update */
			  BEGIN
					/* Get existing prices */
					SELECT @v_current_budgetprice = budgetprice, @v_current_finalprice = finalprice
					FROM bookprice
					WHERE bookkey = @v_bookkey AND
							pricetypecode = @v_prev_pricetype AND
							currencytypecode = @v_prev_currency
	
					IF @v_current_budgetprice IS NULL
						SET @v_current_budgetprice = 0
					IF @v_current_finalprice IS NULL
						SET @v_current_finalprice = 0
	
					/* Only update when necessary */
					IF @v_current_budgetprice <> @v_sum_budgetprice OR @v_current_finalprice <> @v_sum_finalprice
						UPDATE bookprice
						SET budgetprice = @v_sum_budgetprice, finalprice = @v_sum_finalprice,
							sortorder = @v_sortorder, lastuserid = 'QSIDBA', lastmaintdate = getdate()
						WHERE bookkey = @v_bookkey AND
								pricetypecode = @v_prev_pricetype AND
								currencytypecode = @v_prev_currency
	
			  END
		  END

		/* Reset sum prices */
		SET @v_sum_budgetprice = 0
		SET @v_sum_finalprice = 0

		/* Fetch the next Set bookkey */
		FETCH NEXT FROM sets_cur INTO @v_bookkey

    END  /* LOOP <<sets_cursor>> */

  CLOSE sets_cur
  DEALLOCATE sets_cur

END
GO

PRINT 'EXECUTING STORED PROCEDURE : dbo.SetPrices'
GO
PRINT 'NOTE: Updated/inserted bookprice and booksets rows will be timestamped w/lastuserid=QSIDBA'
GO

EXECUTE SetPrices
GO

PRINT 'DROPPING STORED PROCEDURE : dbo.SetPrices'
GO

DROP PROC dbo.SetPrices
GO

PRINT 'Batch completed'
GO