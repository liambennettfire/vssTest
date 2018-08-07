SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_insert_ean')
BEGIN
  DROP PROCEDURE  qean_insert_ean
END
GO

CREATE PROCEDURE dbo.qean_insert_ean
  @i_bookkey          INT,
  @i_isbnkey          INT,
  @i_isbn_prefix_code INT,
  @i_ean_prefix_code  INT,
  @i_isbn_with_dashes VARCHAR(50),
  @i_ean_with_dashes  VARCHAR(50),
  @i_gtin_with_dashes VARCHAR(50),
  @i_itemnumber       VARCHAR(50),
  @i_itemnumbergen    TINYINT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

/**************************************************************************************************
**  Name: qean_insert_ean
**  Desc: Inserts/Updates to isbn table with the passed standard Product ID values (EAN,ISBN,GTIN)
**        as well as all newly auto-generated non-standard Product IDs (currently itemnumber only).
**
**  AH 08/02/04 Innitial development
**  
**  8/21/2015 - KW - Added itemnumber input parameter - see case 33163
**
**  11/9/2015 - KB - Brooks does not generate itemnumber but derives it from EAN value (35107)
**************************************************************************************************/

DECLARE	
  @isbn varchar(50),
  @ean varchar(50),
  @gtin varchar(50),
  @error  varchar(2000),
  @v_count  INT,
  @v_fielddesc  VARCHAR(80),
  @v_stringvalue  VARCHAR(255),
  @v_new_itemnumber VARCHAR(20)

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  --SET @v_new_itemnumber = @i_itemnumber
  
  -- get @isbn, @ean, @gtin removing dashes
  select @isbn = replace(@i_isbn_with_dashes, '-', '')
  select @ean = replace(@i_ean_with_dashes, '-', '')
  select @gtin = replace(@i_gtin_with_dashes, '-', '')

  -- Delete isbn from reuseisbns
  exec qean_remove_from_isbn_reuse @i_ean_with_dashes, @o_error_code output, @o_error_desc output
  
  IF @isbn IS NOT NULL  --at least ISBN has been passed in - generate new itemnumber    
  BEGIN    
     Select @v_new_itemnumber=right(@ean,5)  
  END 

  --print 'isbnkey'
  --print @i_isbnkey

  --update or insert row
  select @v_count = COUNT(bookkey)
  from isbn
  where isbnkey = @i_isbnkey

  if @v_count > 0
  begin
      
    IF @i_isbn_prefix_code > 0 
      UPDATE isbn
      SET isbn = @i_isbn_with_dashes, 
        isbn10 = @isbn,
        ean13 = @ean,
        ean = @i_ean_with_dashes,
        gtin = @i_gtin_with_dashes,
        gtin14 = @gtin,
        isbnprefixcode = @i_isbn_prefix_code,
        eanprefixcode = @i_ean_prefix_code,
        itemnumber = @v_new_itemnumber,
        lastuserid = @i_userid,
        lastmaintdate = getdate()
      WHERE isbnkey = @i_isbnkey
    ELSE
     UPDATE isbn
      SET itemnumber = @v_new_itemnumber,
        lastuserid = @i_userid,
        lastmaintdate = getdate()
      WHERE isbnkey = @i_isbnkey

    select @error = @@error
    if @error <> 0 begin
      select @o_error_code = @error
      select @o_error_desc = 'Could not update isbn table (isbnkey=' + CONVERT(VARCHAR, @i_isbnkey) + ').'
      return
    end
      
	  IF EXISTS (SELECT * FROM book WHERE bookkey = @i_bookkey AND workkey = @i_bookkey)
	  AND NOT EXISTS (SELECT * FROM titlehistory WHERE columnkey = 45 AND bookkey = @i_bookkey) BEGIN
		  IF EXISTS(SELECT * FROM titlehistory WHERE bookkey = @i_bookkey AND columnkey = 268 AND LTRIM(RTRIM(currentstringvalue)) IN (CONVERT(VARCHAR, @i_bookkey), '(Not Present)'))
		  BEGIN
			UPDATE titlehistory SET currentstringvalue = COALESCE(@i_ean_with_dashes, '(Not Present)') WHERE bookkey = @i_bookkey AND columnkey = 268
		  END     
	  END       
    end
    
  else 
    begin
      IF @i_isbnkey is null or @i_isbnkey = 0
      BEGIN
        SET @i_isbnkey = @i_bookkey
      END

      --insert new row in isbn table
      IF @i_isbn_prefix_code > 0 
        insert into isbn
          (isbn, 
          bookkey, 
          isbnkey, 
          isbnprefixcode, 
          isbn10,
          lastuserid,
          lastmaintdate,
          ean,
          ean13,	
          gtin,
          gtin14,
          itemnumber)
        values
          (@i_isbn_with_dashes,
          @i_bookkey,
          @i_isbnkey,
          @i_isbn_prefix_code,
          @isbn, 
          @i_userid,
          getdate(),
          @i_ean_with_dashes,
          @ean,
          @i_gtin_with_dashes,
          @gtin,
          @v_new_itemnumber)
      ELSE
        INSERT INTO isbn
          (bookkey, isbnkey, itemnumber, lastuserid, lastmaintdate)
        VALUES
          (@i_bookkey, @i_isbnkey, @v_new_itemnumber, @i_userid, getdate())
        
      select @error = @@error
      if @error <> 0 begin
        select @o_error_code = @error
        select @o_error_desc = 'Could not insert into isbn table.'
        return
      end
    end
  
  
  /***** Update titlehistory for ISBN-10 (columnkey=43) *****/
  IF @i_isbn_with_dashes IS NOT NULL
  BEGIN
    -- Get titlehistorycolumns description for isbn-10
    SELECT @v_count = COUNT(*)
    FROM titlehistorycolumns
    WHERE columnkey = 43
    
    IF @v_count > 0
      SELECT @v_fielddesc = columndescription
      FROM titlehistorycolumns
      WHERE columnkey = 43
    ELSE
      SET @v_fielddesc = 'ISBN-10'
    
    -- Get the last history row info for isbn-10
    SELECT @v_count = COUNT(*)
    FROM titlehistory
    WHERE bookkey = @i_bookkey AND columnkey = 43
    
    IF @v_count > 0
      SELECT @v_stringvalue = currentstringvalue
      FROM titlehistory 
      WHERE bookkey = @i_bookkey AND columnkey = 43
      ORDER BY lastmaintdate DESC
    ELSE
    SET @v_stringvalue = '(Not Present)'
    
    -- Insert new row into titlehistory for recent change to isnb-10
    INSERT INTO titlehistory
      (bookkey, printingkey, columnkey, fielddesc, stringvalue, currentstringvalue,
      lastuserid, lastmaintdate)
    VALUES
      (@i_bookkey, 1, 43, @v_fielddesc, @v_stringvalue, @i_isbn_with_dashes,
      @i_userid, getdate())
  END --IF @i_isbn_with_dashes IS NOT NULL
  
    
  /***** Update titlehistory for EAN/ISBN-13 (columnkey=45) *****/
  IF @i_ean_with_dashes IS NOT NULl
  BEGIN
    -- Get titlehistorycolumns description for ean/isbn-13
    SELECT @v_count = COUNT(*)
    FROM titlehistorycolumns
    WHERE columnkey = 45
    
    IF @v_count > 0
      SELECT @v_fielddesc = columndescription
      FROM titlehistorycolumns
      WHERE columnkey = 45
    ELSE
      SET @v_fielddesc = 'EAN/ISBN-13'
      
    -- Get the last history row info for ean/isbn-13
    SELECT @v_count = COUNT(*)
    FROM titlehistory
    WHERE bookkey = @i_bookkey AND columnkey = 45
    
    IF @v_count > 0
      SELECT @v_stringvalue = currentstringvalue
      FROM titlehistory 
      WHERE bookkey = @i_bookkey AND columnkey = 45
      ORDER BY lastmaintdate DESC
    ELSE
      SET @v_stringvalue = '(Not Present)'
      
    -- Insert new row into titlehistory for recent change to ean/isnb-13
    INSERT INTO titlehistory
      (bookkey, printingkey, columnkey, fielddesc, stringvalue, currentstringvalue,
      lastuserid, lastmaintdate)
    VALUES
      (@i_bookkey, 1, 45, @v_fielddesc, @v_stringvalue, @i_ean_with_dashes,
      @i_userid, getdate())
  END --IF @i_ean_with_dashes IS NOT NULL
      
      
  /***** Update titlehistory for GTIN (columnkey=228) *****/
  IF @i_gtin_with_dashes IS NOT NULL
  BEGIN
    -- Get titlehistorycolumns description for gtin
    SELECT @v_count = COUNT(*)
    FROM titlehistorycolumns
    WHERE columnkey = 228
    
    IF @v_count > 0
      SELECT @v_fielddesc = columndescription
      FROM titlehistorycolumns
      WHERE columnkey = 228
    ELSE
      SET @v_fielddesc = 'GTIN'
    
    -- Get the last history row info for gtin
    SELECT @v_count = COUNT(*)
    FROM titlehistory
    WHERE bookkey = @i_bookkey AND columnkey = 228
    
    IF @v_count > 0
      SELECT @v_stringvalue = currentstringvalue
      FROM titlehistory 
      WHERE bookkey = @i_bookkey AND columnkey = 228
      ORDER BY lastmaintdate DESC
    ELSE
      SET @v_stringvalue = '(Not Present)'
      
    -- Insert new row into titlehistory for recent change to gtin
    INSERT INTO titlehistory
      (bookkey, printingkey, columnkey, fielddesc, stringvalue, currentstringvalue,
      lastuserid, lastmaintdate)
    VALUES
      (@i_bookkey, 1, 228, @v_fielddesc, @v_stringvalue, @i_gtin_with_dashes,
      @i_userid, getdate())
  END --IF @i_gtin_with_dashes IS NOT NULL
      
      
  /***** Update titlehistory for Item # (columnkey=241) *****/
  IF @v_new_itemnumber IS NOT NULL
  BEGIN
    -- Get titlehistorycolumns description for itemnumber
    SELECT @v_count = COUNT(*)
    FROM titlehistorycolumns
    WHERE columnkey = 241
  
    IF @v_count > 0
      SELECT @v_fielddesc = columndescription
      FROM titlehistorycolumns
      WHERE columnkey = 241
    ELSE
      SET @v_fielddesc = 'Item #'
    
    -- Get the last history row info for itemnumber
    SELECT @v_count = COUNT(*)
    FROM titlehistory
    WHERE bookkey = @i_bookkey AND columnkey = 241
  
    IF @v_count > 0
      SELECT @v_stringvalue = currentstringvalue
      FROM titlehistory 
      WHERE bookkey = @i_bookkey AND columnkey = 241
      ORDER BY lastmaintdate DESC
    ELSE
      SET @v_stringvalue = '(Not Present)'
    
    -- Insert new row into titlehistory for recent change to isnb-10
    INSERT INTO titlehistory
      (bookkey, printingkey, columnkey, fielddesc, stringvalue, currentstringvalue,
      lastuserid, lastmaintdate)
    VALUES
      (@i_bookkey, 1, 241, @v_fielddesc, @v_stringvalue, @v_new_itemnumber,
      @i_userid, getdate())
  END --@v_new_itemnumber IS NOT NULL
    
  -- update bookedistatus
  EXECUTE qtitle_update_bookedistatus @i_bookkey, 1, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  IF @o_error_code < 0 BEGIN
    SET @o_error_code = -1
    RETURN
  END     
  
  -- If the new itemnumber was generated, call the cleanup stored procedure that will update itemnumber numeric and/or alpha sequence
  IF @v_new_itemnumber IS NOT NULL AND @i_itemnumbergen = 1
  BEGIN
    EXEC qean_after_itemnumber_update @v_new_itemnumber, @o_error_code OUTPUT, @o_error_desc OUTPUT
  END 
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qean_insert_ean  to public
go
