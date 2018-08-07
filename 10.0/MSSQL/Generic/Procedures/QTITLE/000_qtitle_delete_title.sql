SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qtitle_delete_title]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[qtitle_delete_title]
GO

/************************************************************************************************************************
**  Name: qtitle_delete_title
**  Desc: This stored procedure deletes a title from the book table and related tables.
**        Based on deletetitle_delete_book which is called from the desktop application and should no longer be used
**
**  Notes:
**        @i_optionflags is a bit mask. current options are:
**          0x01 - Verify only
**          0x02 - Force delete
**
**  Auth: Colman
**  Date: 08/18/2017
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   ------------------------------------------------------------------------------------------------
**************************************************************************************************************************/

CREATE PROCEDURE qtitle_delete_title 
  @i_bookkey     INT, 
  @i_userid      VARCHAR(30),
  @i_optionflags INT,
  @o_error_code  INT OUTPUT,
  @o_error_desc  VARCHAR(2000) OUTPUT
AS
BEGIN
  DECLARE
    @v_error_code           INT,
    @v_error_desc           VARCHAR(255),
    @v_subtitle_bookkey     INT,
    @v_set_bookkey          INT,
    @v_work_projectkey      INT,
    @v_taqprojectkey        INT,
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
    @v_exists               TINYINT,
    @v_discount             FLOAT,
    @v_maxbestpubdate       DATETIME,
    @v_clientoption         TINYINT,
    @v_note_desc            VARCHAR(400),
    @v_title                VARCHAR(255),
    @v_history_order        INT,
    @v_pricetypedesc_short  VARCHAR(20),
    @v_currencydesc_short   VARCHAR(20),
    @v_currentstringvalue   VARCHAR(255),
    @v_questioncommentkey   INT, 
    @v_answercommentkey     INT,
    @v_transaction          TINYINT,
    @v_isprimary            TINYINT,
    @v_flag_verifyonly      INT,
    @v_flag_forcedelete     INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_transaction = 0
  SET @v_isprimary = 0
  SET @v_work_projectkey = 0
  SET @v_taqprojectkey = 0
  
  -- Option flag values
  SET @v_flag_verifyonly    = 0x01
  SET @v_flag_forcedelete   = 0x80

  -- Check for locked title
  IF EXISTS 
    (SELECT 1
     FROM booklock
     WHERE bookkey = @i_bookkey
       AND printingkey IN (0, 1)
       AND LOWER(userid) <> LOWER(@i_userid))
  BEGIN
    SELECT @v_error_desc = 'This Title can not be deleted because it is locked by another user.'  
    GOTO ERROR_OUT
  END

  -- Check force deletion flag  
  IF (@i_optionflags & @v_flag_forcedelete) > 0
    GOTO BEGIN_DELETE
    
  --------------------- BEGIN VALIDATION ---------------------------
  
  -- Check whether this is the primary title/format
  SELECT @v_isprimary = 1 FROM book WHERE bookkey = @i_bookkey AND workkey = bookkey
  SELECT @v_work_projectkey = ISNULL(taqprojectkey, 0) FROM taqprojecttitle where bookkey = @i_bookkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 1)
  SELECT @v_taqprojectkey = ISNULL(taqprojectkey, 0) FROM taqprojecttitle where bookkey = @i_bookkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2)

  SELECT @v_count = COUNT(*)
  FROM printing
  WHERE bookkey = @i_bookkey

  -- Check for multiple printings
  IF @v_count > 1 BEGIN
    SELECT @v_error_desc = 'This Title can not be deleted because it contains multiple Printings.'
    GOTO ERROR_OUT 
  END 

  -- Check for subordinate titles
  IF EXISTS (SELECT 1 FROM taqproject WHERE workkey = @i_bookkey)
  BEGIN
    IF EXISTS (SELECT 1 FROM book WHERE workkey = @i_bookkey AND bookkey <> @i_bookkey)
    BEGIN
      SELECT @v_error_desc = 'This Title can not be deleted because it has subordinate titles on the related Work.'
      GOTO ERROR_OUT
    END 
  END

  -- Check for related contracts
  IF EXISTS 
    (SELECT 1 FROM projectrelationshipview 
      WHERE relationshipcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 16) -- Work (for Contract)
        AND relatedprojectkey = @v_work_projectkey)
  BEGIN 
    SELECT @v_error_desc = 'This Title can not be deleted because it is associated with a contract.'
    GOTO ERROR_OUT
  END

  -- Verify that the Printing can be deleted
  EXEC qtitle_delete_printing @i_bookkey, 1, @i_userid, @v_flag_verifyonly, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code <> 0 BEGIN
    GOTO ERROR_OUT 
  END 
  
  IF (@i_optionflags & @v_flag_verifyonly) > 0
    RETURN
  
  --------------------- BEGIN DELETION ---------------------------

BEGIN_DELETE:
  BEGIN TRANSACTION
  
  SET @v_transaction = 1
    
  -- Delete Printing #1
  EXEC qtitle_delete_printing @i_bookkey, 1, @i_userid, @v_flag_forcedelete, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code <> 0 BEGIN
    GOTO ERROR_OUT 
  END 
  
  -- Check whether client has 'Update Set Price' optionvalue to 0 - this is the default  
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
  
  -- Retrieve all sets that this title is a component of and delete the title from each of those sets from bookfamily
  OPEN  bookfamily_cur

  FETCH NEXT FROM bookfamily_cur INTO @v_set_bookkey
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
    -- Only if 'Update Set Prices' option is OFF (0), prices for the set need to be re-calculated 
    -- (as the sum of title prices within the set for same price type and currency)
    IF @v_clientoption = 0 
    BEGIN
      -- Get the price discount % FOR this SET
      IF EXISTS (SELECT 1 FROM booksets WHERE bookkey = @v_set_bookkey)
        SELECT @v_discount = discountpercent
        FROM booksets
        WHERE bookkey = @v_set_bookkey
      ELSE
        SET @v_discount = 0
      
      IF @v_discount IS NULL
        SET @v_discount = 0

      -- Retrieve all price totals as the sum of all title prices on the SET,
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
        SET @v_exists = 0
        SELECT @v_exists = 1
        FROM bookfamily f, bookprice p
        WHERE f.childbookkey = p.bookkey AND  
              f.relationcode = 20001 AND  
              f.parentbookkey = @v_set_bookkey AND
              f.childbookkey = @i_bookkey AND
              p.pricetypecode = @v_pricetype AND
              p.currencytypecode = @v_currency

        IF @v_exists = 1 
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
          -- continue to next row
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

          EXEC qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_set_bookkey, 0, 0, ' ', 'DELETE', 
                                 @i_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code OUTPUT, @v_error_desc OUTPUT 

          EXEC qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, ' ', 'DELETE', 
                                 @i_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code OUTPUT, @v_error_desc OUTPUT
        END 
        ELSE 
        BEGIN       
          UPDATE bookprice
          SET budgetprice = @v_set_budgetprice, finalprice = @v_set_finalprice
          WHERE bookkey = @v_set_bookkey AND
              pricetypecode = @v_pricetype AND 
              currencytypecode = @v_currency

          -- Write to titlehistory for the recalculated set prices 
          EXEC gentables_shortdesc 122, @v_currency, @v_currencydesc_short OUTPUT
          EXEC gentables_shortdesc 306, @v_pricetype, @v_pricetypedesc_short OUTPUT
            
          IF @v_orig_set_budgetprice <> @v_set_budgetprice 
          BEGIN
            SET @v_currentstringvalue =  CONVERT(CHAR(10),@v_set_budgetprice) + ' ' + @v_currencydesc_short

            EXEC qtitle_update_titlehistory 'bookprice', 'budgetprice', @v_set_bookkey, 0, 0, @v_currentstringvalue, 'UPDATE', 
                                   @i_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code OUTPUT, @v_error_desc OUTPUT 
          END

          IF @v_orig_set_finalprice <> @v_set_finalprice 
          BEGIN
            SET @v_currentstringvalue =  CONVERT(CHAR(10),@v_set_finalprice) + ' ' + @v_currencydesc_short

            EXEC qtitle_update_titlehistory 'bookprice', 'finalprice', @v_set_bookkey, 0, 0, @v_currentstringvalue, 'UPDATE', 
                                  @i_userid, @v_history_order, @v_pricetypedesc_short, @v_error_code OUTPUT, @v_error_desc OUTPUT 
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
    WHERE bookkey = @i_bookkey      
      
    SET @v_note_desc = 'Title ' + @v_title + ' deleted. '  

    UPDATE titlesethistory
    SET titleremoveddate = getdate(), titleremovedby = @i_userid, note = @v_note_desc                                                            
    WHERE setbookkey = @v_set_bookkey AND
          titlebookkey = @i_bookkey

    -- Get the title count and latest pubdate without counting passed title
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
  DELETE FROM bookfamily WHERE bookfamily.childbookkey = @i_bookkey
  DELETE FROM bookfamily WHERE bookfamily.parentbookkey = @i_bookkey

  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookfamily. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- Delete from book-level tables   
  -- Delete from book  
  DELETE FROM book WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM book. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT
  END 
  
  -- DELETE FROM bookauthor 
  DELETE FROM bookauthor WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookauthor. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT
  END 
  
  -- DELETE FROM bookdetail  
  DELETE FROM bookdetail WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookdetail. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM bookaudience  
  DELETE FROM bookaudience WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookaudience. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 
  
  -- DELETE FROM bookorgentry  
  DELETE FROM bookorgentry WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookorgentry. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT
  END 
  
  -- DELETE FROM bookprice  
  DELETE FROM bookprice WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookprice. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END
  
  
  DELETE FROM citation WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM citation. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT
  END

  -- DELETE FROM bookproductdetail  
  DELETE FROM bookproductdetail WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookproductdetail. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 
  
  -- DELETE FROM keyword  
  DELETE FROM keyword WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM keyword. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM bookkeywords 
  DELETE FROM bookkeywords WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookkeywords. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 
  
  -- DELETE FROM isbn  
  DELETE FROM isbn WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM isbn. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM bookmisc  
  DELETE FROM bookmisc WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookmisc. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END

  -- DELETE FROM associatedtitles 
  DELETE FROM associatedtitles WHERE bookkey = @i_bookkey OR associatetitlebookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM associatedtitles. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM rankings  
  DELETE FROM rankings WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM rankings. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM discoveryquestions  
  -- DELETE FROM qsicomments  
  DECLARE discoveryquestions_cur INSENSITIVE CURSOR FOR 
    SELECT questioncommentkey, answercommentkey
    FROM discoveryquestions  
    WHERE bookkey = @i_bookkey 
    FOR READ ONLY

  OPEN discoveryquestions_cur   
  FETCH NEXT FROM discoveryquestions_cur INTO @v_questioncommentkey, @v_answercommentkey 
  
  WHILE (@@FETCH_STATUS = 0)   --FOR discoveryquestions_cur FOUND 
  BEGIN
    DELETE FROM qsicomments
    WHERE commentkey IN (@v_questioncommentkey,@v_answercommentkey)

    FETCH NEXT FROM discoveryquestions_cur INTO @v_questioncommentkey, @v_answercommentkey  
  END  --LOOP discoveryquestions_cur 
  CLOSE discoveryquestions_cur 
  DEALLOCATE discoveryquestions_cur 

  DELETE FROM discoveryquestions WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM discoveryquestions. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM bookcustom  
  DELETE FROM bookcustom WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookcustom. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- DELETE FROM booksubjectcategory  
  DELETE FROM booksubjectcategory WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM booksubjectcategory. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END

  -- DELETE FROM bookverificationmessage  
  DELETE FROM bookverificationmessage WHERE bookkey = @i_bookkey;
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM bookverificationmessage. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
    GOTO ERROR_OUT 
  END 

  -- Delete any row of printingkey = 0 that might have been created during the DELETE process -  CRM# 5139 
  IF EXISTS (SELECT 1 FROM coretitleinfo WHERE bookkey = @i_bookkey AND printingkey = 0)
  BEGIN
    -- Delete coretitleinfo row with 0 printingkey 
    DELETE FROM coretitleinfo
    WHERE bookkey = @i_bookkey AND printingkey = 0
    
    IF @@ERROR != 0 BEGIN
      SELECT @v_error_desc = 'Error deleting FROM coretitleinfo. bookkey=' + CONVERT(CHAR(10),@i_bookkey) 
        + ' AND FOR printingkey 0' 
      GOTO ERROR_OUT
    END 
  END
  
  -- If this title belongs to a Work
  IF @v_work_projectkey > 0
  BEGIN
    IF @v_isprimary = 1
    BEGIN
      DECLARE @v_userkey INT
      SELECT @v_userkey = userkey FROM qsiusers WHERE userid = @i_userid
      
      -- If it is the Primary format, delete the work. 
      EXEC qproject_delete_project @v_work_projectkey, @v_userkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
      IF @v_error_code != 0
        GOTO ERROR_OUT
    END
    ELSE
    BEGIN
      -- Otherwise, delete the relationship with the work    
      DELETE FROM taqprojecttitle where bookkey = @i_bookkey AND taqprojectkey = @v_work_projectkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 1)
      IF @@ERROR != 0 BEGIN
        SELECT @v_error_desc = 'Error deleting FROM taqprojecttitle. bookkey=' + CONVERT(CHAR(10),@i_bookkey)
        GOTO ERROR_OUT
      END 
    END
  END
  
  -- If this title has a related TAQ project
  IF @v_taqprojectkey > 0
  BEGIN
    -- Delete the relationship with the TAQ
    DELETE FROM taqprojecttitle where bookkey = @i_bookkey AND taqprojectkey = @v_taqprojectkey AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2)
    IF @@ERROR != 0 BEGIN
      SELECT @v_error_desc = 'Error deleting FROM taqprojecttitle. bookkey=' + CONVERT(CHAR(10),@i_bookkey)
      GOTO ERROR_OUT
    END 
    
    IF @v_isprimary = 1
    BEGIN
      -- If deleting the primary title, update the TAQ project status from Approved to Active
      UPDATE taqproject SET taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 3)
      WHERE taqprojectkey = @v_taqprojectkey
      
      IF @@ERROR != 0 BEGIN
        SELECT @v_error_desc = 'Error updating taqproject.  @v_taqprojectkey=' + CONVERT(CHAR(10),@v_taqprojectkey)
        GOTO ERROR_OUT
      END 
    END
  END
  
  
  SUCCESS:
    IF @v_transaction = 1
      COMMIT
    RETURN
    
  ERROR_OUT:
    SET @o_error_code = -1
    SET @o_error_desc = @v_error_desc
    PRINT @v_error_desc
    IF @v_transaction = 1
      ROLLBACK
END
GO

GRANT EXEC ON qtitle_delete_title TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO