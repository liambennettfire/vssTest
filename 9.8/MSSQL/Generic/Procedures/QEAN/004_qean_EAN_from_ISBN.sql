SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_EAN_from_ISBN')
  BEGIN
    DROP PROCEDURE qean_EAN_from_ISBN
  END
GO

CREATE PROCEDURE dbo.qean_EAN_from_ISBN
  @i_isbn          VARCHAR(25),
  @o_ean         VARCHAR(25) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_EAN_from_ISBN
**  Desc: For the passed ISBN-103 (10-digit ISBN) regardless of format
**        (with or without dashes), generate valid EAN/ISBN-13 value (13-digit ISBN).
**        The generated ISBN-13 value is validated - the required length, the correct
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
  @v_validated_isbn VARCHAR(25),
  @v_coreisbn       VARCHAR(25)
  
BEGIN
  
  -- Initialize output
  SET @o_ean = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Strip out any hyphens and spaces from the passed ISBN-10 string
  SET @v_isbn_string = REPLACE(@i_isbn, '-', '')
  SET @v_isbn_string = REPLACE(@v_isbn_string, ' ', '')
  SET @v_isbn_string = UPPER(@v_isbn_string)
  
  -- Validate passed string, without checking if this ISBN-10 already exists
  SET @v_check_if_exists = 0
  SET @v_product_type = 0   --ISBN-10
  EXEC qean_validate_product @v_isbn_string, @v_product_type, @v_check_if_exists, 0,
    @v_validated_isbn OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if passed EAN/ISBN-13 is invalid (errorcode -1 or -2 returned)
  IF @o_error_code < 0 
    RETURN
  
  -- Extract the check digit from the validated ISBN-10 string
  SET @v_coreisbn = SUBSTRING(@v_validated_isbn, 1, 11)
  SET @v_coreisbn = REPLACE(@v_coreisbn, '-', '')
  
  -- Generate the check digit for this EAN/ISBN-13
  SET @v_ean_string = '978' + @v_coreisbn
  EXEC qean_generate_check_digit @v_ean_string, @v_checkdigit OUTPUT, 1
  
  -- This is the EAN/ISBN-13 string without dashes
  SET @v_ean_string = '978-' + @v_coreisbn + @v_checkdigit
  
  -- Now validate the generated EAN/SBN-13 string to get back hyphenated string
  SET @v_check_if_exists = 0
  SET @v_product_type = 1   --EAN/ISBN-13
  EXEC qean_validate_product @v_ean_string, @v_product_type, @v_check_if_exists, 0,
    @o_ean OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  --DEBUG
  --PRINT @o_ean
        
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.qean_EAN_from_ISBN TO PUBLIC
GO
