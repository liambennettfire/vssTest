USE [APH]
GO

IF EXISTS (SELECT *
			   FROM dbo.sysobjects
			   WHERE id = object_id(N'dbo.[qweb_deletetitle_APH]')
				   AND objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.qweb_deletetitle_APH
PRINT 'dropped dbo.[qweb_deletetitle_APH]'
PRINT 'created dbo.[qweb_deletetitle_APH]'

GO

/****** Object:  StoredProcedure [dbo].[qweb_deletetitle_APH]    Script Date: 10/04/2012 14:55:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************************/
/*  Name: [qweb_deletetitle_APH]															 */
/*  DESC: This stored PROCEDURE deletes all associated data FOR a given bookkey, IF the		 */
/*         passed bookkey IS a child OF a workkey, it will remove all titles under that		 */
/*		   workkey. Originally created in response to case #20521							 */
/*																							 */
/* Cursor Select Sample: SELECT bookkey														 	
	FROM book b									
	WHERE b.workkey IN (SELECT workkey
							FROM book
							WHERE book.bookkey = 1791911)									 */
/*																							 */
/*    Auth: Jonathan Hess																	 */
/*    Date: 10/9/2012																		 */
/*********************************************************************************************/


CREATE PROCEDURE [dbo].[qweb_deletetitle_APH]
    @delete_title_bookkey INT,
    @delete_title_userid VARCHAR(30),
    @i_error_desc_detail SMALLINT,
    @o_workkey INT OUTPUT,
    @o_associated_keys VARCHAR(2000) OUTPUT,
    @o_error_code INT OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
AS

	DECLARE
            @i_titlefetchstatus     INT,
            @res                    INT,
            @err_msg                VARCHAR(70),
            @subtitle_bookkey       INT,
            @v_set_bookkey          INT,
            @v_apply_discount       TINYINT,
            @v_pricetype            INT,
            @v_currency             INT,
            @v_set_budgetprice      DECIMAL(9, 2),
            @v_set_finalprice       DECIMAL(9, 2),
            @v_orig_set_budgetprice DECIMAL(9, 2),
            @v_orig_set_finalprice  DECIMAL(9, 2),
            @v_quantity             INT,
            @v_title_pricetype      INT,
            @v_title_currency       INT,
            @v_title_budgetprice    DECIMAL(9, 2),
            @v_title_finalprice     DECIMAL(9, 2),
            @v_count                INT,
            @v_discount             FLOAT,
            @v_maxbestpubdate       DATETIME,
            @v_clientoption         TINYINT,
            @v_note_desc            VARCHAR(400),
            @v_title                VARCHAR(255),
            @v_history_order        INT,
            @v_pricetypedesc_short  VARCHAR(20),
            @v_currencydesc_short   VARCHAR(20),
            @v_currentstringvalue   VARCHAR(255),
            @error_var              INT,
            @rowcount_var           INT,
            @cumulativeRowCount     INT,
            @OuterLoopCounter       INT,
            @associated_keys        VARCHAR(2000)

	--@v_error_code           INT,
	--@v_error_desc           VARCHAR(2000)

	SET @error_var = ''
	SET @cumulativeRowCount = 0
	SET @OuterLoopCounter = 0
	SET @o_error_code = 0
	SET @o_error_desc = ''

	/* find all titles linked to this title */
	DECLARE subordinate_titles_cur CURSOR FORWARD_ONLY FOR
	SELECT bookkey
		FROM book b
		WHERE b.workkey IN (SELECT workkey
								FROM book b
								WHERE b.bookkey = @delete_title_bookkey)
		ORDER BY b.bookkey DESC

	OPEN subordinate_titles_cur

	WHILE (1 = 1)
		BEGIN
			FETCH NEXT FROM subordinate_titles_cur INTO @subtitle_bookkey

			IF @@fetch_status <> 0
				BREAK;

			SET @OuterLoopCounter = @OuterLoopCounter + @OuterLoopCounter
			IF @OuterLoopCounter = 0
				BEGIN
					SELECT @o_workkey = workkey
						FROM book
						WHERE book.bookkey = @delete_title_bookkey

				END

			SET @associated_keys = @associated_keys + ', ' + @subtitle_bookkey

			SET @o_error_desc = @o_error_desc +
			char(13) + char(10) + '/****************************************************/'
			+ char(13) + char(10)


			-- Check if client has 'Update Set Price' optionvalue to 0 - this is the default  
			SELECT @v_clientoption = optionvalue
				FROM clientoptions
				WHERE optionid = 38

			-- Retrieve all sets that the passed title is part of
			DECLARE bookfamily_cur INSENSITIVE CURSOR FOR
			SELECT parentbookkey
				FROM bookfamily
				WHERE bookfamily.childbookkey = @subtitle_bookkey
					AND relationcode = 20001
				ORDER BY parentbookkey ASC,
						 childbookkey ASC
			FOR READ ONLY

			-- retrieve all sets that this title is a component of and delete the title from each of those sets from bookfamily
			OPEN bookfamily_cur

			FETCH NEXT FROM bookfamily_cur INTO @v_set_bookkey

			WHILE (@@FETCH_STATUS = 0)
				BEGIN
					-- Only if 'Update Set Prices' option is OFF (0), set prices need to be re-calculated 
					-- (as the sum of title prices within the set for same price type and currency)
					IF @v_clientoption = 0
						BEGIN

							-- Get the price discount % for this set
							SELECT @v_count = count(*)
								FROM booksets
								WHERE bookkey = @v_set_bookkey

							IF @v_count > 0
								SELECT @v_discount = discountpercent
									FROM booksets
									WHERE bookkey = @v_set_bookkey
							ELSE
								SET @v_discount = 0

							IF @v_discount IS NULL
								SET @v_discount = 0

							-- Retrieve all price totals as the sum of all title prices on the set,
							-- taking into account title quantity (but not price discount)
							DECLARE set_prices_cur CURSOR FOR
							SELECT p.pricetypecode,
								   p.currencytypecode,
								   p.history_order,
								   sum(budgetprice * quantity),
								   sum(finalprice * quantity)
								FROM bookprice p, bookfamily f
								WHERE p.bookkey = f.childbookkey
									AND
									f.parentbookkey = @v_set_bookkey
									AND
									f.relationcode = 20001
									AND
									p.activeind = 1
								GROUP BY p.pricetypecode,
										 p.currencytypecode,
										 p.history_order

							OPEN set_prices_cur

							FETCH NEXT FROM set_prices_cur
							INTO @v_pricetype, @v_currency, @v_history_order,
							@v_set_budgetprice, @v_set_finalprice

							IF @v_set_budgetprice IS NULL
								SET @v_set_budgetprice = 0.00
							IF @v_set_finalprice IS NULL
								SET @v_set_finalprice = 0.00

							SET @v_orig_set_budgetprice = @v_set_budgetprice
							SET @v_orig_set_finalprice = @v_set_finalprice

							WHILE (@@FETCH_STATUS = 0)
								BEGIN

									IF @v_set_budgetprice IS NULL
										SET @v_set_budgetprice = 0.00
									IF @v_set_finalprice IS NULL
										SET @v_set_finalprice = 0.00

									-- Check if passed title has a price row for this price type and currency
									SELECT @v_count = count(*)
										FROM bookfamily f, bookprice p
										WHERE f.childbookkey = p.bookkey
											AND
											f.relationcode = 20001
											AND
											f.parentbookkey = @v_set_bookkey
											AND
											f.childbookkey = @subtitle_bookkey
											AND
											p.pricetypecode = @v_pricetype
											AND
											p.currencytypecode = @v_currency

									IF @v_count > 0
										BEGIN
											-- Get passed title's quantity and price for this price type and currency
											SELECT @v_title_budgetprice = p.
												   budgetprice,
												   @v_title_finalprice = p.
												   finalprice,
												   @v_quantity = f.quantity
												FROM bookfamily f, bookprice p
												WHERE f.childbookkey = p.bookkey
													AND
													f.relationcode = 20001
													AND
													f.parentbookkey =
													@v_set_bookkey
													AND
													f.childbookkey =
													@subtitle_bookkey
													AND
													p.pricetypecode = @v_pricetype
													AND
													p.currencytypecode =
													@v_currency

											IF @v_title_budgetprice IS NULL
												SET @v_title_budgetprice = 0.00
											IF @v_title_finalprice IS NULL
												SET @v_title_finalprice = 0.00

											SET @v_title_budgetprice =
											@v_title_budgetprice *
											@v_quantity
											SET @v_title_finalprice =
											@v_title_finalprice *
											@v_quantity

											SET @v_set_budgetprice =
											@v_set_budgetprice -
											@v_title_budgetprice
											SET @v_set_finalprice =
											@v_set_finalprice
											-
											@v_title_finalprice

											-- Check if discount is applied to this pricetype/currency on current set
											SELECT @v_apply_discount =
												   applysetdiscountind
												FROM bookprice
												WHERE bookkey = @v_set_bookkey
													AND
													pricetypecode = @v_pricetype
													AND
													currencytypecode = @v_currency

											-- Apply Set Discount when necessary            
											IF @v_apply_discount = 1
												BEGIN
													SET @v_set_budgetprice =
													@v_set_budgetprice * (100 -
													@v_discount) / 100
													SET @v_set_finalprice =
													@v_set_finalprice
													* (100 - @v_discount) / 100
												END
										END
									ELSE
										BEGIN
											-- Passed title doesn't have a price of this type and currency, so it doesn't affect set price recalc
											-- CONTINUE to next row
											FETCH NEXT FROM set_prices_cur
											INTO @v_pricetype, @v_currency,
											@v_history_order,
											@v_set_budgetprice, @v_set_finalprice

											CONTINUE
										END


									IF @v_set_budgetprice = 0.00 AND
									@v_set_finalprice
									= 0.00
										BEGIN
											DELETE
												FROM bookprice
												WHERE bookkey = @v_set_bookkey AND
													pricetypecode = @v_pricetype
													AND
													currencytypecode = @v_currency

											EXEC gentables_shortdesc 306,
											@v_pricetype
											,
											@v_pricetypedesc_short OUTPUT

											EXECUTE qtitle_update_titlehistory
											'bookprice',
											'budgetprice', @v_set_bookkey, 0, 0,
											' ',
											'delete',
											@delete_title_userid, @v_history_order
											,
											@v_pricetypedesc_short, @o_error_code,
											@o_error_desc

											EXECUTE qtitle_update_titlehistory
											'bookprice',
											'finalprice', @v_set_bookkey, 0, 0,
											' ',
											'delete',
											@delete_title_userid, @v_history_order
											,
											@v_pricetypedesc_short, @o_error_code,
											@o_error_desc
										END
									ELSE
										BEGIN
											UPDATE bookprice
												SET budgetprice =
													@v_set_budgetprice,
													finalprice = @v_set_finalprice
												WHERE bookkey = @v_set_bookkey AND
													pricetypecode = @v_pricetype
													AND
													currencytypecode = @v_currency

											/* write to titlehistory for the recalculated set prices */
											EXEC gentables_shortdesc 122,
											@v_currency,
											@v_currencydesc_short OUTPUT
											EXEC gentables_shortdesc 306,
											@v_pricetype
											,
											@v_pricetypedesc_short OUTPUT

											IF @v_orig_set_budgetprice <>
											@v_set_budgetprice
												BEGIN
													SET @v_currentstringvalue =
													convert(CHAR(
													10), @v_set_budgetprice) + ' '
													+
													@v_currencydesc_short

													EXEC
													qtitle_update_titlehistory
													'bookprice', 'budgetprice',
													@v_set_bookkey, 0, 0,
													@v_currentstringvalue,
													'update',
													@delete_title_userid,
													@v_history_order,
													@v_pricetypedesc_short,
													@o_error_code,
													@o_error_desc
												END

											IF @v_orig_set_finalprice <>
											@v_set_finalprice
												BEGIN
													SET @v_currentstringvalue =
													convert(CHAR(
													10), @v_set_finalprice) + ' '
													+
													@v_currencydesc_short

													EXEC
													qtitle_update_titlehistory
													'bookprice', 'finalprice',
													@v_set_bookkey, 0, 0,
													@v_currentstringvalue,
													'update',
													@delete_title_userid,
													@v_history_order,
													@v_pricetypedesc_short,
													@o_error_code,
													@o_error_desc
												END
										END

									FETCH NEXT FROM set_prices_cur
									INTO @v_pricetype, @v_currency,
									@v_history_order,
									@v_set_budgetprice, @v_set_finalprice

								END --set_prices_cur LOOP

							CLOSE set_prices_cur
							DEALLOCATE set_prices_cur

						END --@v_clientoption = 0

					SELECT @v_title = title
						FROM book
						WHERE bookkey = @delete_title_bookkey

					SET @v_note_desc = 'Title ' + @v_title + ' deleted. '

					UPDATE titlesethistory
						SET titleremoveddate = getdate(),
							titleremovedby = @delete_title_userid,
							note = @v_note_desc
						WHERE setbookkey = @v_set_bookkey AND
							titlebookkey = @subtitle_bookkey

					-- Get the title count and latest pubdate WITHOUT counting passed title
					SELECT @v_count = count(*),
						   @v_maxbestpubdate = max(c.bestpubdate)
						FROM bookfamily f, coretitleinfo c
						WHERE f.childbookkey = c.bookkey
							AND
							f.parentbookkey = @v_set_bookkey
							AND
							f.childbookkey <> @subtitle_bookkey
							AND
							f.relationcode = 20001
							AND
							c.printingkey = 1

					UPDATE booksets
						SET numtitles = @v_count,
							availabledate = @v_maxbestpubdate
						WHERE bookkey = @v_set_bookkey AND
							printingkey = 1

					FETCH NEXT FROM bookfamily_cur INTO @v_set_bookkey
				END --bookfamily_cur LOOP

			CLOSE bookfamily_cur
			DEALLOCATE bookfamily_cur

			-- Delete title from bookfamily
			DELETE
				FROM bookfamily
				WHERE bookfamily.childbookkey = @subtitle_bookkey

			DELETE
				FROM bookfamily
				WHERE bookfamily.parentbookkey = @subtitle_bookkey

			-- Save the @@ERROR and @@ROWCOUNT values in local 
			-- variables before they are cleared.
			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookfamily ' + char(13) + char(10)
				END

			/* delete from book-level tables   */
			/* delete from book  */
			DELETE
				FROM book
				WHERE bookkey = @subtitle_bookkey;

			-- Save the @@ERROR and @@ROWCOUNT values in local 
			-- variables before they are cleared.
			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: book, bookkey: ' + cast(@subtitle_bookkey
					AS VARCHAR) + char(13) + char(10)
				END

			/* delete from bookauthor */
			DELETE
				FROM bookauthor
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookauthor ' + char(13) + char(10)
				END

			/* delete from bookdetail  */
			DELETE
				FROM bookdetail
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookdetail ' + char(13) + char(10)
				END

			/* delete from bookaudience  */
			DELETE
				FROM bookaudience
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookaudience ' + char(13) + char(10
					)
				END

			/* delete from bookorgentry  */
			DELETE
				FROM bookorgentry
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookorgentry ' + char(13) + char(10
					)
				END

			/* delete from bookprice  */
			DELETE
				FROM bookprice
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookprice ' + char(13) + char(10)
				END

			/* delete from citation  */
			DELETE
				FROM citation
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: citation ' + char(13) + char(10)
				END

			/* delete from keyword  */
			DELETE
				FROM keyword
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: keyword ' + char(13) + char(10)
				END

			/* delete from isbn  */
			DELETE
				FROM isbn
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: isbn ' + char(13) + char(10)
				END

			/* delete from bookmisc  */
			DELETE
				FROM bookmisc
				WHERE bookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: bookmisc ' + char(13) + char(10)
				END

			/* delete from associatedtitles */
			DELETE
				FROM associatedtitles
				WHERE bookkey = @subtitle_bookkey OR
					associatetitlebookkey = @subtitle_bookkey;

			SELECT @error_var = @@ERROR,
				   @rowcount_var = @@ROWCOUNT,
				   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
			IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
				BEGIN
					SET @o_error_code = @@ERROR
					SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
					AS
					VARCHAR)
					+ ' ) rows Deleted, table: associatedtitles' + char(13) + char
					(10)
				END

			/* Delete any row of printingkey = 0 that might have been created during the delete process -  CRM# 5139 */
			SELECT @v_count = count(*)
				FROM coretitleinfo
				WHERE bookkey = @subtitle_bookkey
					AND printingkey = 0;

			IF @v_count > 0
				BEGIN
					/* Delete coretitleinfo row with 0 printingkey */
					DELETE
						FROM coretitleinfo
						WHERE bookkey = @subtitle_bookkey
							AND
							printingkey = 0;

					SELECT @error_var = @@ERROR,
						   @rowcount_var = @@ROWCOUNT,
						   @cumulativeRowCount = @cumulativeRowCount + @@ROWCOUNT
					IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
						BEGIN
							SET @o_error_code = @@ERROR
							SET @o_error_desc = @o_error_desc + '-( ' + cast(
							@rowcount_var AS
							VARCHAR) + ' ) rows Deleted, table: coretitleinfo' +
							char(
							13)
							+ char(10)
						END
				END

		END

	CLOSE subordinate_titles_cur
	DEALLOCATE subordinate_titles_cur

	SET @o_error_desc = @o_error_desc +
	'/****************************************************/' + char(13) + char(10)

	SELECT @o_workkey,
		   @o_associated_keys,
		   @o_error_code,
		   @o_error_desc