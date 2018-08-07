IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'update_sets_bisacstatus_changed')
BEGIN
  PRINT 'Dropping Procedure update_sets_bisacstatus_changed'
  DROP  Procedure  update_sets_bisacstatus_changed
END
GO

PRINT 'Creating Procedure update_sets_bisacstatus_changed'
GO

CREATE Procedure update_sets_bisacstatus_changed
(
  @i_bookkey          INT,
  @i_origstatuscode   INT,
  @i_newstatuscode    INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

/***
5/10/07 - KW - Recreated for case 4712 - looping through sets, then titles on set, then prices on titles
to come up with set price totals is replaced with SUM select statement for each processed set.
Price recalculation takes into account title quantity, set discount percentage and applysetdiscount indicator
on price, and occurs only if the client option 'Update Set Prices' is OFF (default).

NOTE: This stored procedure is called when BISAC Status changes on a title to a status w/Exclude from Sets flag
set to Yes (gentables.gen1ind=1 for tableid 314).
***/

DECLARE
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
  @v_orig_bisacdesc       VARCHAR(40),
  @v_new_bisacdesc        VARCHAR(40),
  @v_maxbestpubdate       DATETIME,
  @v_clientoption         TINYINT,
  @v_note_desc            VARCHAR(400),
  @v_history_order        INT,
  @v_pricetypedesc_short  VARCHAR(20),
  @v_currencydesc_short   VARCHAR(20),
  @v_currentstringvalue   VARCHAR(255)

BEGIN
 
  -- Check if client has 'Update Set Price' optionvalue to 0 - this is the default  
  SELECT @v_clientoption = optionvalue
  FROM clientoptions
  WHERE optionid = 38

  -- Retrieve all sets that the passed title is part of
  DECLARE bookfamily_cur INSENSITIVE CURSOR FOR
    SELECT parentbookkey
    FROM bookfamily  
    WHERE bookfamily.childbookkey = @i_bookkey AND relationcode = 20001
    ORDER BY parentbookkey ASC, childbookkey ASC
  FOR READ ONLY
  
  OPEN bookfamily_cur

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

      WHILE (@@FETCH_STATUS = 0)
      BEGIN

        IF @v_set_budgetprice IS NULL
          SET @v_set_budgetprice = 0.00
        IF @v_set_finalprice IS NULL
          SET @v_set_finalprice = 0.00

	SET @v_orig_set_budgetprice = @v_set_budgetprice
        SET @v_orig_set_finalprice = @v_set_finalprice

        -- Check if passed title has a price row for this price type and currency
        SELECT @v_count = COUNT(*)
        FROM bookfamily f, bookprice p
        WHERE f.childbookkey = p.bookkey AND  
              f.relationcode = 20001 AND  
              f.parentbookkey = @v_set_bookkey AND
              f.childbookkey = @i_bookkey AND
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
                  f.childbookkey = @i_bookkey AND
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
                                   @i_userid, @v_history_order, @v_pricetypedesc_short, @o_error_code, @o_error_desc 
            EXECUTE qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, ' ', 'delete', 
                                   @i_userid, @v_history_order, @v_pricetypedesc_short, @o_error_code, @o_error_desc
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
                                   @i_userid, @v_history_order, @v_pricetypedesc_short, @o_error_code, @o_error_desc 
				END
				IF @v_orig_set_finalprice <> @v_set_finalprice
            BEGIN
               SET @v_currentstringvalue =  convert(char(10),@v_set_finalprice) + ' ' + @v_currencydesc_short
					EXEC qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, @v_currentstringvalue, 'update', 
                                   @i_userid, @v_history_order, @v_pricetypedesc_short, @o_error_code, @o_error_desc 
				END
          END

        FETCH NEXT FROM set_prices_cur
        INTO @v_pricetype, @v_currency, @v_history_order, @v_set_budgetprice, @v_set_finalprice
        
      END --set_prices_cur LOOP
      
      CLOSE set_prices_cur
      DEALLOCATE set_prices_cur
      
    END  --@v_clientoption = 0


    SET @v_orig_bisacdesc = ''
    SET @v_new_bisacdesc = ''
    SET @v_note_desc = ''

    IF @i_origstatuscode IS NULL
      SET @i_origstatuscode = 0
    IF @i_newstatuscode IS NULL
      SET @i_newstatuscode = 0

    IF @i_origstatuscode > 0 
      EXEC gentables_longdesc 314, @i_origstatuscode, @v_orig_bisacdesc OUTPUT

    IF @i_newstatuscode > 0 
      EXEC gentables_longdesc 314, @i_newstatuscode, @v_new_bisacdesc OUTPUT

    IF (@i_origstatuscode > 0 AND @i_newstatuscode > 0)
      SET @v_note_desc = 'Bisac Status changed on title from ' + @v_orig_bisacdesc + ' to ' + @v_new_bisacdesc + '.'

    IF (@i_origstatuscode = 0 AND @i_newstatuscode > 0)
      SET @v_note_desc = 'Bisac Status changed on title to ' + @v_new_bisacdesc + '.'


    UPDATE titlesethistory
    SET titleremoveddate = getdate(), titleremovedby = @i_userid, note = @v_note_desc                                                            
    WHERE setbookkey = @v_set_bookkey AND 
          titlebookkey = @i_bookkey

    -- Get the title count and latest pubdate WITHOUT counting passed title
    SELECT @v_count = COUNT(*), @v_maxbestpubdate = MAX(c.bestpubdate)
    FROM bookfamily f, coretitleinfo c
    WHERE f.childbookkey = c.bookkey AND
          f.parentbookkey = @v_set_bookkey AND  
          f.childbookkey <> @i_bookkey AND
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
  WHERE bookfamily.childbookkey = @i_bookkey 

  DELETE FROM bookfamily
  WHERE bookfamily.parentbookkey = @i_bookkey
  
END
GO

GRANT EXEC ON update_sets_bisacstatus_changed TO PUBLIC
GO
