SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_ISBN_from_EAN')
  BEGIN
    DROP PROCEDURE qean_ISBN_from_EAN
  END
GO

CREATE PROCEDURE dbo.qean_ISBN_from_EAN
  @i_ean          VARCHAR(25),
  @o_isbn         VARCHAR(25) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_ISBN_from_EAN
**  Desc: For the passed EAN/ISBN-13 (13-digit ISBN) regardless of format
**        (with or without dashes), generate valid ISBN-10 value (10-digit ISBN).
**        The generated ISBN-10 value is validated - the required length, the correct
**        check digit, and proper placement of hyphens is part of this validation.
**
**  Auth: Kate J. Wiewiora
**  Date: 21 July 2006
******************************************************************************************/

DECLARE
  @v_checkdigit       CHAR(1),
  @v_check_if_exists  TINYINT,
  @v_product_type     TINYINT,
  @v_ean_string     VARCHAR(25),
  @v_isbn_string    VARCHAR(25),
  @v_validated_ean  VARCHAR(25),
  @v_coreisbn       VARCHAR(25),
  @v_count  INT,
  @v_isbn10_generation_required INT
  
BEGIN
  
  -- Initialize output
  SET @o_isbn = ''
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

  IF @v_isbn10_generation_required = 0 BEGIN
     SET @o_isbn = ''
     RETURN
  END
  
  -- Strip out any hyphens and spaces from the passed EAN/ISBN-13 string
  SET @v_ean_string = REPLACE(@i_ean, '-', '')
  SET @v_ean_string = REPLACE(@v_ean_string, ' ', '')
  SET @v_ean_string = UPPER(@v_ean_string)
  
  -- Validate passed string, without the checking if this EAN/ISBN-13 already exists
  SET @v_check_if_exists = 0
  SET @v_product_type = 1   --EAN/ISBN-13
  EXEC qean_validate_product @v_ean_string, @v_product_type, @v_check_if_exists, 0,
    @v_validated_ean OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if passed EAN/ISBN-13 is invalid (errorcode -1 or -2 returned)
  IF @o_error_code < 0 
    RETURN
  
  -- Extract EAN Prefix from the validated EAN/ISBN-13 (the first 4 characters)
  -- and extract the check digit (last 2 characters - check digit and last dash)
  SET @v_coreisbn = SUBSTRING(@v_validated_ean, 5, 11)
  SET @v_coreisbn = REPLACE(@v_coreisbn, '-', '')
  
  -- Generate the check digit for this ISBN-10
  EXEC qean_generate_check_digit @v_coreisbn, @v_checkdigit OUTPUT, 0
  
  -- This is the ISBN-10 string without dashes
  SET @v_isbn_string = @v_coreisbn + @v_checkdigit
  
  -- Now validate the generated ISBN-10 string to get back hyphenated ISBN-10 string
  SET @v_check_if_exists = 0
  SET @v_product_type = 0   --ISBN-10
  EXEC qean_validate_product @v_isbn_string, @v_product_type, @v_check_if_exists, 0,
    @o_isbn OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  --DEGUB
  --PRINT @o_isbn
        
END
GO

GRANT EXEC ON dbo.qean_ISBN_from_EAN TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
