SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_generate_ean')
BEGIN
  DROP  Procedure  qean_generate_ean
END
GO

CREATE PROCEDURE dbo.qean_generate_ean
  @isbn_prefix        VARCHAR(20),
  @ean_prefix         VARCHAR(20),
  @gtin_prefix        VARCHAR(20),
  @manually_typed	    VARCHAR(40),
  @productnumlockey   INT,
  @bookkey            INT,
  @o_isbn             VARCHAR(50) OUTPUT,
  @o_ean              VARCHAR(50) OUTPUT,
  @o_gtin             VARCHAR(50) OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

/**********************************************************************************************
**  Name: qean_generate_ean
**  Desc: This stored procedure will generate the ISBN-10, EAN/ISBN-13 and GTIN
**        for the passed isbn elements.
**
**  Auth: Kate J. Wiewiora
**  Date: 19 July 2006
**
**  @o_error_code -1 will be returned generally when error occurred that prevented generation
**  @o_error_code -2 will be returned to indicate INVALID INPUT - could not generate
**  @o_error_code > 0 will indicate a specific warning
**
**********************************************************************************************/
/* AH 08/02/04 - Innitial development */
/* KW 07/19/06 - Rewritten */

-- DOIT_AGAIN Label:
-- When warning is returned from the executed validation procedure, this procedure 
-- will get executed again to try generate new numbers. This happens only if user is
-- generating the numbers rather than manually typing a number.
DOIT_AGAIN:

DECLARE	
  @do_it_again  tinyint,
  @prefix_code int,
  @prefix_sub_code int,
  @last_isbn int,
  @next_isbn int,
  @prefixlen int,
  @requiredlen int,
  @isbnlen	int,
  @checkdigit_isbn char(1),
  @checkdigit_ean	char(1),
  @loop		int,	
  @cnt		int,
  @rowcount	int,	
  @error		int,
  @v_count  INT,
  @v_leadingzeros       VARCHAR(10),
  @v_coreisbn           VARCHAR(25),
  @v_coreean            VARCHAR(25),
  @v_prodcolumn         VARCHAR(50),
  @v_proddesc           VARCHAR(25),
  @v_check_count        INT,
  @v_check_if_exists    TINYINT,
  @v_product_type       TINYINT,
  @v_product            VARCHAR(25),
  @v_validated_product  VARCHAR(25),
  @v_save_error_code    INT,
  @v_save_error_desc    VARCHAR(2000),
  @v_isbn10_generation_required INT

BEGIN

  --initialize variables 
  SET @do_it_again = 0
  SET @v_save_error_code = 0
  SET @o_isbn = ''
  SET @o_ean = ''
  SET @o_gtin = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''


  -- get optionvalue for cleintoption optionid 109 (ISBN-10 Generation Required)
  SELECT @v_count = COUNT(*)
    FROM clientoptions
   WHERE optionid = 109

  IF @v_count = 0 BEGIN
     SET @v_isbn10_generation_required = 1
  END

  IF @v_count = 1 BEGIN
    SELECT @v_isbn10_generation_required = optionvalue
      FROM clientoptions
     WHERE optionid = 109
  END

  IF @ean_prefix IS NULL
    SET @ean_prefix = '978'
  IF @gtin_prefix IS NULL
    SET @gtin_prefix = '0'

  IF @ean_prefix <> '978' BEGIN
     IF @v_isbn10_generation_required = 1 BEGIN
       SET @o_error_code = -1
       SET @o_error_desc = 'You have chosen a prefix other than 978. This is not allowed ' +
          'because according to your client options you are required to have an ISBN-10. ' +
          'An ISBN-10 cannot be generated with this prefix. Please see your system adminstrator if you have questions.'
       RETURN
     END
  END
  

  -- Call procedure that will check if there are some old ISBNs sitting in reuseisbns table
  -- that should be unlocked based on number of days passed
  EXEC qean_release_ean_locks @o_error_code OUTPUT, @o_error_desc OUTPUT

  select @error = @@error
  if @error <> 0 begin
    return
  end

 
  -- get prefix_code from gentables for passed tableid and datadesc
  SELECT @prefix_code = datacode
  FROM gentables
  WHERE tableid = 138 AND datadesc = @ean_prefix

  --raise error if prefix not found
  select @rowcount = @@rowcount
  if @rowcount = 0
  begin
    select @o_error_code = -1
    select @o_error_desc = 'Could not select Prefix code from gentables table.' 
    return
  end


   -- get prefix_code from  subgentables for passed tableid and datadesc
  SELECT @prefix_sub_code = datasubcode
  FROM subgentables
  WHERE tableid = 138 AND datacode = @prefix_code AND datadesc = @isbn_prefix

  --raise error if prefix not found
  select @rowcount = @@rowcount
  if @rowcount = 0 begin
    select @o_error_code = -1 
    select @o_error_desc = 'Could not select Prefix code from subgentables table.' 
    return
  end  

  -- Get client's productnumlocation configuration
  SELECT @v_prodcolumn = LOWER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = @productnumlockey

  --raise error if option value not found
  select @rowcount = @@rowcount
  if @rowcount = 0 begin
    select @o_error_code = -1
    select @o_error_desc = 'Could not select columnname from productnumlocation table (productnumlockey=' + CONVERT(VARCHAR, @productnumlockey) + '.' 
    return
  end

  IF @v_prodcolumn = 'isbn10'
    SET @v_prodcolumn = 'isbn'
  IF @v_prodcolumn = 'ean13'
    SET @v_prodcolumn = 'ean'
  IF @v_prodcolumn = 'gtin14'
    SET @v_prodcolumn = 'gtin'

  -- Get ISBN generation type based on client's product configuration
  -- Default to 1 (EAN/ISBN-13)
  SET @v_product_type = 
  CASE
    WHEN @v_prodcolumn = 'isbn' THEN 0
    WHEN @v_prodcolumn = 'ean' THEN 1
    WHEN @v_prodcolumn = 'gtin' THEN 2
    ELSE 1
  END

  IF @manually_typed IS NULL  --generating numbers
    BEGIN
      -- Check if there is already a number posted on reuseisbns table for these prefixes
      SELECT TOP 1 @o_isbn = isbn, @o_ean = ean, @o_gtin = gtin	
      FROM reuseisbns
      WHERE isbnprefixcode = @prefix_code AND
            isbnsubprefixcode = @prefix_sub_code AND
            locked = 'N'
      ORDER BY isbn ASC
      
      SELECT @rowcount = @@rowcount    
--      IF @v_isbn10_generation_required = 0 BEGIN
--         SET @rowcount = 0
--      END

      IF @rowcount > 0
      BEGIN
      
        -- Make sure that the product selected from reuseisbns table is valid
        SET @v_product = 
        CASE
          WHEN @v_product_type = 0 THEN @o_isbn
          WHEN @v_product_type = 2 THEN @o_gtin
          ELSE @o_ean
        END
        
        SET @v_check_if_exists = 1
        EXEC qean_validate_product @v_product, @v_product_type, @v_check_if_exists,
          @bookkey, @v_validated_product OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
        
        IF @o_error_code < 0
        BEGIN
          -- Get product label from isbnlabels
          SELECT @v_check_count = COUNT(*)
          FROM isbnlabels WHERE columnname = @v_prodcolumn
          
          IF @v_check_count > 0
            SELECT @v_proddesc = label
            FROM isbnlabels WHERE columnname = @v_prodcolumn
          ELSE
            SET @v_proddesc = 
            CASE
              WHEN @v_product_type = 0 THEN 'ISBN-10'
              WHEN @v_product_type = 2 THEN 'GTIN'
              ELSE 'EAN/ISBN-13'
            END        
        
          SET @o_error_code = -1
          SET @o_error_desc = @v_proddesc + ' ''' + @v_product + ''' is invalid on reuseisbns table - ' + @o_error_desc
          RETURN
        END

        -- If the values found on reuseisbn are valid,
        -- use values on that row - lock it and return
        UPDATE reuseisbns 
        SET locked = 'Y', lastuserid = suser_sname(), lastmaintdate = getdate()
        WHERE isbnprefixcode = @prefix_code AND
              isbnsubprefixcode = @prefix_sub_code AND
              isbn = @o_isbn
              
        RETURN
      END 

      -- Get last and next number from isbnnumbers only if not mannualy typed by user
      --IF @v_isbn10_generation_required = 1 BEGIN
        SELECT @last_isbn = lastisbn, @next_isbn = nextisbn 
        FROM isbnnumbers  
        WHERE isbnprefixcode = @prefix_sub_code AND 
              eanprefixcode = @prefix_code 

        select @rowcount = @@rowcount		
        if @rowcount = 0 or @next_isbn is null or @last_isbn is Null begin
          select @o_error_code = -1
          select @o_error_desc = 'Could not generate ISBN - ISBN Number Generation Range has not been defined.' 
          return 
        end 

        if @last_isbn < @next_isbn begin
          select @o_error_code = -1
          select @o_error_desc = 'No more entries are available in isbnnumbers table for this ISBN Prefix.'
          return 
        end
     

        --raise warning msg but continue processing
        if @next_isbn + 50 > @last_isbn begin
          SET @v_save_error_code = 4  --WARNING (NOTE: other warning codes inside qean_validate_product)
          SET @v_save_error_desc = 'Almost out of numbers for this ISBN Prefix.'
        end
     --END` 

        -- ISBN Prefix length is the length of passed prefix + 1 dash that follows
        SET @prefixlen = len(@isbn_prefix) + 1
        -- Required entry length, excluding last hyphen and check digit
        SET @requiredlen = 11 - @prefixlen
        -- Next ISBN value length
        SET @isbnlen = len(@next_isbn)

        -- Loop to pad the Next ISBN value with the required number of leading 0's
        SET @cnt = 0
        SET @v_leadingzeros = ''
        SET @loop = @requiredlen - @isbnlen		
        IF @isbnlen < @requiredlen
        BEGIN
          WHILE 1=1
          BEGIN
            SET @v_leadingzeros = '0' +  @v_leadingzeros
            SET @cnt = @cnt + 1 
            IF @cnt = @loop BREAK
          END
        END

        -- Get ISBN-10 value without the check digit
        SET @v_coreisbn = @v_leadingzeros + CONVERT(VARCHAR(25), @next_isbn)
        SET @v_coreisbn = @isbn_prefix + '-' + @v_coreisbn
        -- Get EAN/ISBN-13 value without the check digit
        SET @v_coreean = @ean_prefix + '-' + @v_coreisbn
    	  
        -- Generate the check digit for ISBN-10
        EXEC qean_generate_check_digit @v_coreisbn, @checkdigit_isbn OUTPUT, 0 
--      END   

      -- Generate the check digit for EAN/ISBN-13
      EXEC qean_generate_check_digit @v_coreean, @checkdigit_ean OUTPUT, 1
            
      SET @o_isbn = @v_coreisbn + '-' + @checkdigit_isbn
      SET @o_ean = @v_coreean + '-' + @checkdigit_ean
    END
    
  ELSE --manually entered 
    BEGIN
      IF @v_product_type = 0  --ISBN-10
        BEGIN
          -- The manually typed product has the ISBN-10 check digit - build ISBN-10 value
          SET @o_isbn = @isbn_prefix + '-' + @manually_typed          
          -- Must come up with EAN/ISBN-13 value
          SET @v_coreisbn = REPLACE(@o_isbn, '-', '')
          SET @v_coreisbn = LEFT(@v_coreisbn, 9)
          SET @v_coreean = @ean_prefix + '-' + @v_coreisbn
          -- Generate the check digit for EAN/ISBN-13
          EXEC qean_generate_check_digit @v_coreean, @checkdigit_ean OUTPUT, 1
          -- Build EAN/ISBN-13 with the generated check digit, since it is different
          -- from the manually entered check digit for main product ISBN-10
          SET @o_ean = @v_coreean + '-' + @checkdigit_ean
        END
      ELSE  --EAN/ISBN-13 or GTIN
        BEGIN
          -- The manually typed product has the EAN/ISBN-13 check digit - build EAN/ISBN-13
          SET @o_ean = @ean_prefix + '-' + @isbn_prefix + '-' + @manually_typed
          -- Must come up with ISBN-10
          SET @v_coreisbn = REPLACE(@isbn_prefix + @manually_typed, '-', '')
          SET @v_coreisbn = LEFT(@v_coreisbn, 9)
          -- Generate the check digit for ISBN-10
          EXEC qean_generate_check_digit @v_coreisbn, @checkdigit_isbn OUTPUT, 0
          -- Build ISBN-10 with the generated check digit, since it is different
          -- from the manually entered check digit for main product EAN/ISBN-13 or GTIN
          SET @o_isbn = @v_coreisbn + '-' + @checkdigit_isbn
        END
    END

  -- GTIN is EAN/ISBN-13 preceded by GTIN Prefix
  SET @o_gtin = @gtin_prefix + '-' + @o_ean

  --print '@o_isbn : ' + COALESCE(@o_isbn,'') 
  --print '@o_ean : ' + COALESCE(@o_ean,'') 
  --print '@o_gtin : ' + COALESCE(@o_gtin,'') 

  SET @v_product = 
  CASE
    WHEN @v_product_type = 0 THEN @o_isbn
    WHEN @v_product_type = 2 THEN @o_gtin
    ELSE @o_ean
  END

  -- Validate product, including the check if this product already exists
  SET @v_check_if_exists = 1
  EXEC qean_validate_product @v_product, @v_product_type, @v_check_if_exists,
    @bookkey, @v_validated_product OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if error was returned from the validation stored procedure
  IF @o_error_code < 0 
    RETURN

  -- If warning was returned from the validation stored procedure,
  -- loop again to try generate another number
  IF @manually_typed IS NULL
  BEGIN
    -- Errorcode 1 - WARNING: product has already been assigned (qean_validate_product)
    -- Errorcode 2 - WARNING: GTIN should begin with a leading zero (qean_validate_product)
    -- Errorcode 3 - WARNING: product is listed in donotuseisbn table (qean_validate_product)
    -- Errorcode 4 - WARNING: almost out of numbers (qean_generate_ean)
    IF @o_error_code = 1 OR @o_error_code = 3
      SET @do_it_again = 1
    ELSE IF @o_error_code <> 0 --treat any other warning as an error - return
      BEGIN
        -- Check if LOCKED row exists on reuseisbns table for this isbn
        SELECT @v_count = COUNT(*)
        FROM reuseisbns
        WHERE isbnprefixcode = @prefix_code AND
            isbnsubprefixcode = @prefix_sub_code AND
            isbn = @o_isbn AND
            locked = 'Y'

        IF @v_count > 0
          SET @do_it_again = 1
        ELSE      
          GOTO PROCESS_FINISHED
      END
      
    -- Update isbnnumbers to set Next value - only if validation passed
    -- NOTE: this table will be updated only if no error, or for warnings 1 and 2
    UPDATE isbnnumbers 
    SET nextisbn = @next_isbn + 1
    WHERE isbnprefixcode = @prefix_sub_code AND
          eanprefixcode = @prefix_code 
    
    SELECT @error = @@error
    IF @error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not update nextisbn on isbnnumbers table (@@error=' + CONVERT(VARCHAR, @error) + ').'
    END
    
    IF @do_it_again = 1
      GOTO DOIT_AGAIN    
  END
  
  PROCESS_FINISHED:
  
  -- Update return values with validated values
  IF @v_product_type = 0  --ISBN-10
  BEGIN
    SET @o_isbn = @v_validated_product
    SET @o_ean = @ean_prefix + '-' + LEFT(@o_isbn, 12) + @checkdigit_ean
    SET @o_gtin = @gtin_prefix + '-' + @o_ean    
  END
  IF @v_product_type = 1  --EAN/ISBN-13
  BEGIN
    SET @o_isbn = SUBSTRING(@v_validated_product, 5, 12) + @checkdigit_isbn
    SET @o_ean = @v_validated_product
    SET @o_gtin = @gtin_prefix + '-' + @o_ean
  END
  IF @v_product_type = 2  --GTIN
  BEGIN
    SET @o_isbn = SUBSTRING(@v_validated_product, 7, 12) + @checkdigit_isbn
    SET @o_ean = RIGHT(@v_validated_product, 17)
    SET @o_gtin = @v_validated_product
  END
  
  -- If warning was generated but process continued, set return error values
  IF @v_save_error_code > 0
  BEGIN
    SET @o_error_code = @v_save_error_code
    SET @o_error_desc = @v_save_error_desc
  END 

  IF @v_isbn10_generation_required = 0 BEGIN
     SET @o_isbn = ''
  END
    
  --Insert isbn to reuseisbns and set flag that isbn is used by user if
  --not manually typed.
  IF @v_isbn10_generation_required = 1 BEGIN
    IF @manually_typed IS NULL
    BEGIN
      INSERT INTO reuseisbns
        (isbnprefixcode,
        isbnsubprefixcode,
        isbn,
        ean,
        gtin,
        locked,
        lastuserid,
        lastmaintdate)
      VALUES 
        (@prefix_code, 
        @prefix_sub_code, 
        @o_isbn, 
        @o_ean, 
        @o_gtin,
        'Y',
        suser_sname(), 
        getdate())
        
      select @error = @@error
      if @error <> 0
      begin
        select @o_error_code = -1
        select @o_error_desc = 'Could not insert into reuseisbns table (@@error=' + CONVERT(VARCHAR, @error) + ').'
      end
    END
   END  		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qean_generate_ean  to public
go

