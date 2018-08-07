/* 1/5/05 - KB - CRM# 2242 - if primary title is being deleted */
/* reset workkey on all subordinate titles  */

-- Drop this procedure if it already exists
PRINT 'deletetitle_delete_book'
GO
IF object_id('deletetitle_delete_book ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_delete_book 
END 
GO

/********************************************************************************************/ 
/*This procedure deletes from book and book related tables based on bookkey                 */ 
/********************************************************************************************/ 

CREATE PROCEDURE deletetitle_delete_book @delete_title_bookkey INT, @delete_title_userid varchar(30)
AS

DECLARE
  @res INT,
  @err_msg varchar(70),
  @subtitle_bookkey INT,
  @v_set_bookkey          INT,
  @v_apply_discount       TINYINT,
  @v_pricetype            INT,
  @v_currency             INT,  
  @v_set_budgetprice      DECIMAL(9,2),
  @v_set_finalprice       DECIMAL(9,2),
  @v_orig_set_budgetprice DECIMAL(9,2),
  @v_orig_set_finalprice  DECIMAL(9,2),
  @v_quantity             INT,
  @v_title_pricetype      INT,
  @v_title_currency       INT,
  @v_title_budgetprice    DECIMAL(9,2),
  @v_title_finalprice     DECIMAL(9,2),  
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
  @v_error_code           INT,
  @v_error_desc           VARCHAR(2000)

/* find all titles linked to this title */
DECLARE	subordinate_titles_cur CURSOR FOR
  SELECT book.bookkey
  FROM book
  WHERE book.workkey=@delete_title_bookkey  

BEGIN

	OPEN subordinate_titles_cur 	
	FETCH NEXT FROM subordinate_titles_cur INTO @subtitle_bookkey 
	
	WHILE (@@FETCH_STATUS = 0)   /*FOR subordinate_titles_cur FOUND */
	BEGIN
	  UPDATE book
       SET workkey = @subtitle_bookkey,
       linklevelcode=10, 
       propagatefromprimarycode=0
	  WHERE bookkey = @subtitle_bookkey

	  FETCH NEXT FROM subordinate_titles_cur INTO @subtitle_bookkey
	END  /*LOOP subordinate_titles_cur */
	CLOSE subordinate_titles_cur 
	DEALLOCATE subordinate_titles_cur 


  -- ***** 5/3/07 - KW - Modified for Case 4712. *****/
  -- Check if client has 'Update Set Price' optionvalue to 0 - this is the default  
  SELECT @v_clientoption = optionvalue
  FROM clientoptions
  WHERE optionid = 38

  -- Retrieve all sets that the passed title is part of
  DECLARE bookfamily_cur INSENSITIVE CURSOR FOR 
    SELECT parentbookkey
    FROM bookfamily  
    WHERE bookfamily.childbookkey = @delete_title_bookkey AND relationcode = 20001
    ORDER BY parentbookkey ASC, childbookkey ASC
  FOR READ ONLY
  
	-- retrieve all sets that this title is a component of and delete the title from each of those sets from bookfamily
	OPEN  bookfamily_cur

	FETCH NEXT FROM bookfamily_cur INTO @v_set_bookkey
	
  WHILE (@@FETCH_STATUS = 0 )
  BEGIN
    
    -- Only if 'Update Set Prices' option is OFF (0), set prices need to be re-calculated 
    -- (as the sum of title prices within the set for same price type and currency)
    IF @v_clientoption = 0
    BEGIN
    
      -- Get the price discount % for this set
      SELECT @v_count = COUNT(*)
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
       SELECT p.pricetypecode, p.currencytypecode,p.history_order,
              SUM(budgetprice * quantity), SUM(finalprice * quantity)
        FROM bookprice p, bookfamily f
        WHERE p.bookkey = f.childbookkey AND  
              f.parentbookkey = @v_set_bookkey AND  
              f.relationcode = 20001 AND  
              p.activeind = 1 
        GROUP BY p.pricetypecode, p.currencytypecode,p.history_order

      OPEN set_prices_cur

      FETCH NEXT FROM set_prices_cur
      INTO @v_pricetype, @v_currency, @v_history_order, @v_set_budgetprice, @v_set_finalprice

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
        SELECT @v_count = COUNT(*)
        FROM bookfamily f, bookprice p
        WHERE f.childbookkey = p.bookkey AND  
              f.relationcode = 20001 AND  
              f.parentbookkey = @v_set_bookkey AND
              f.childbookkey = @delete_title_bookkey AND
              p.pricetypecode = @v_pricetype AND
              p.currencytypecode = @v_currency

        IF @v_count > 0
          BEGIN
            -- Get passed title's quantity and price for this price type and currency
            SELECT @v_title_budgetprice = p.budgetprice, 
                  @v_title_finalprice = p.finalprice, 
                  @v_quantity = f.quantity
            FROM bookfamily f, bookprice p
            WHERE f.childbookkey = p.bookkey AND  
                  f.relationcode = 20001 AND  
                  f.parentbookkey = @v_set_bookkey AND
                  f.childbookkey = @delete_title_bookkey AND
                  p.pricetypecode = @v_pricetype AND
                  p.currencytypecode = @v_currency
          
            IF @v_title_budgetprice IS NULL
              SET @v_title_budgetprice = 0.00
            IF @v_title_finalprice IS NULL
              SET @v_title_finalprice = 0.00

            SET @v_title_budgetprice = @v_title_budgetprice * @v_quantity
            SET @v_title_finalprice = @v_title_finalprice * @v_quantity
                        
            SET @v_set_budgetprice = @v_set_budgetprice - @v_title_budgetprice
            SET @v_set_finalprice = @v_set_finalprice - @v_title_finalprice
            
            -- Check if discount is applied to this pricetype/currency on current set
            SELECT @v_apply_discount = applysetdiscountind
            FROM bookprice
            WHERE bookkey = @v_set_bookkey AND
                  pricetypecode = @v_pricetype AND
                  currencytypecode = @v_currency
            
            -- Apply Set Discount when necessary            
            IF @v_apply_discount = 1
            BEGIN
              SET @v_set_budgetprice = @v_set_budgetprice * (100 - @v_discount) / 100
              SET @v_set_finalprice = @v_set_finalprice * (100 - @v_discount) / 100
            END            
          END
        ELSE
          BEGIN
            -- Passed title doesn't have a price of this type and currency, so it doesn't affect set price recalc
            -- CONTINUE to next row
            FETCH NEXT FROM set_prices_cur
            INTO @v_pricetype, @v_currency, @v_history_order, @v_set_budgetprice, @v_set_finalprice
            
            CONTINUE
          END


        IF @v_set_budgetprice = 0.00 AND @v_set_finalprice = 0.00
          BEGIN
            DELETE FROM bookprice
            WHERE bookkey = @v_set_bookkey AND
                pricetypecode = @v_pricetype AND 
                currencytypecode = @v_currency

          	EXEC gentables_shortdesc 306, @v_pricetype, @v_pricetypedesc_short OUTPUT

            EXECUTE qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_set_bookkey, 0, 0, ' ', 'delete', 
                                   @delete_title_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code, @v_error_desc 

            EXECUTE qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, ' ', 'delete', 
                                   @delete_title_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code, @v_error_desc
          END 
        ELSE  
          BEGIN       
            UPDATE bookprice
            SET budgetprice = @v_set_budgetprice, finalprice = @v_set_finalprice
            WHERE bookkey = @v_set_bookkey AND
                pricetypecode = @v_pricetype AND 
                currencytypecode = @v_currency

				/* write to titlehistory for the recalculated set prices */
				EXEC gentables_shortdesc 122, @v_currency, @v_currencydesc_short OUTPUT
            EXEC gentables_shortdesc 306, @v_pricetype, @v_pricetypedesc_short OUTPUT
            
            IF @v_orig_set_budgetprice <> @v_set_budgetprice
            BEGIN
               SET @v_currentstringvalue =  convert(char(10),@v_set_budgetprice) + ' ' + @v_currencydesc_short

					EXEC qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_set_bookkey, 0, 0, @v_currentstringvalue, 'update', 
                                   @delete_title_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code, @v_error_desc 
				END

				IF @v_orig_set_finalprice <> @v_set_finalprice
            BEGIN
               SET @v_currentstringvalue =  convert(char(10),@v_set_finalprice) + ' ' + @v_currencydesc_short

					EXEC qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, @v_currentstringvalue, 'update', 
                                  @delete_title_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code, @v_error_desc 
				END
          END

        FETCH NEXT FROM set_prices_cur
        INTO @v_pricetype, @v_currency, @v_history_order, @v_set_budgetprice, @v_set_finalprice
        
      END --set_prices_cur LOOP
      
      CLOSE set_prices_cur
      DEALLOCATE set_prices_cur
      
    END  --@v_clientoption = 0


    SELECT @v_title = title
    FROM book
    WHERE bookkey = @delete_title_bookkey		  
			
    SET @v_note_desc = 'Title ' + @v_title + ' deleted. '  

    UPDATE titlesethistory
    SET titleremoveddate = getdate(), titleremovedby = @delete_title_userid, note = @v_note_desc                                                            
    WHERE setbookkey = @v_set_bookkey AND
          titlebookkey = @delete_title_bookkey

    -- Get the title count and latest pubdate WITHOUT counting passed title
    SELECT @v_count = COUNT(*), @v_maxbestpubdate = MAX(c.bestpubdate)
    FROM bookfamily f, coretitleinfo c
    WHERE f.childbookkey = c.bookkey AND
          f.parentbookkey = @v_set_bookkey AND  
          f.childbookkey <> @delete_title_bookkey AND
          f.relationcode = 20001 AND  
          c.printingkey = 1

    UPDATE booksets
    SET numtitles = @v_count, availabledate = @v_maxbestpubdate
    WHERE bookkey = @v_set_bookkey AND
          printingkey = 1
    
								  
		FETCH NEXT FROM bookfamily_cur INTO @v_set_bookkey
	END --bookfamily_cur LOOP

  CLOSE bookfamily_cur
  DEALLOCATE bookfamily_cur
  

  -- Delete title from bookfamily
  DELETE FROM bookfamily
  WHERE bookfamily.childbookkey = @delete_title_bookkey

  DELETE FROM bookfamily
  WHERE bookfamily.parentbookkey = @delete_title_bookkey

  -- ***** END 5/3/07 - KW - Modified for Case 4712. *****/
  
	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookfamily for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 


	/* delete from book-level tables   */
	/* delete from book  */
	DELETE FROM book
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from book for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 
	
	/* delete from bookauthor */
	DELETE FROM bookauthor
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookauthor for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 
	
	/* delete from bookdetail  */
	DELETE FROM bookdetail
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookdetail for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 

	/* delete from bookaudience  */
	DELETE FROM bookaudience
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookaudience for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 

	
	/* delete from bookorgentry  */
	DELETE FROM bookorgentry
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookorgentry for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 
	
	/* delete from bookprice  */
	DELETE FROM bookprice
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookprice for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end
	
	/* delete from citation  */
	DELETE FROM citation
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from citation for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 
	
	/* delete from bookproductdetail  */
	DELETE FROM bookproductdetail
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookproductdetail for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 	
	
	/* delete from keyword  */
	DELETE FROM keyword
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from keyword for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 
	
	/* delete from isbn  */
	DELETE FROM isbn
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from isbn for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 

	/* delete from bookmisc  */
	DELETE FROM bookmisc
				WHERE bookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from bookmisc for bookkey' + convert(char(10),@delete_title_bookkey) 
		print @err_msg
		return 
	end

	/* delete from associatedtitles */
	DELETE FROM associatedtitles
				WHERE bookkey = @delete_title_bookkey OR 
				      associatetitlebookkey = @delete_title_bookkey;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from associatedtitles for bookkey' + convert(char(10),@delete_title_bookkey) 
      print @err_msg
		return 
	end 

	/* Delete any row of printingkey = 0 that might have been created during the delete process -  CRM# 5139 */
	SELECT @v_count = count(*)
	FROM coretitleinfo
	WHERE bookkey = @delete_title_bookkey
     AND printingkey = 0;

   IF @v_count > 0
   BEGIN
		/* Delete coretitleinfo row with 0 printingkey */
		DELETE FROM coretitleinfo
			WHERE bookkey = @delete_title_bookkey
				AND printingkey = 0 ;
		
			IF @@error != 0 
			BEGIN
				SELECT @err_msg = 'Error deleting from coretitleinfo for bookkey' + convert(char(10),@delete_title_bookkey) 
				  + ' and for printingkey 0' 
				PRINT @err_msg
				return
			END 
    END
 


	/*COMMIT;*/
	/* commit is done in the w_ua_delete_title_printing ue_delete event after all deletes are done  */


END