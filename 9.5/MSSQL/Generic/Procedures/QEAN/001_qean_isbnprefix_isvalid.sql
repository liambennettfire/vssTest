IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_isbnprefix_isvalid')
BEGIN
  DROP PROCEDURE qean_isbnprefix_isvalid
END
GO

CREATE PROCEDURE qean_isbnprefix_isvalid (
  @i_passed_string    VARCHAR(120),
  @i_eanprefix        VARCHAR(40),
  @o_pubprefix_length INT OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)
AS

/**********************************************************************************
**  Name: qean_isbnprefix_isvalid
**  Desc: Procedure validates passed ISBN Prefix (for given EAN Prefix).
**
**  @o_error_code 0   valid ISBN Prefix (no error or warning)
**  @o_error_code -1  ERROR
**  @o_error_code 1   WARNING
**
**  Auth: Kate J. Wiewiora
**  Date: 7 November 2006
***********************************************************************************/

BEGIN
  DECLARE
    @v_error              INT,
    @v_group_desc         VARCHAR(50),
    @v_group_desc_detail  VARCHAR(255),
    @v_group_element      VARCHAR(5),    
    @v_group_int          INT,
    @v_group_length       INT,
    @v_hyphen_pos         INT,
    @v_passed_string      VARCHAR(120),
    @v_pos                INT,    
    @v_pubprefix          VARCHAR(7),
    @v_pubprefix_length   INT,
    @v_rowcount           INT,
    @v_string_length      INT,
    @v_tempint            INT,
    @v_tempstring         VARCHAR(120),
    @v_isbn10_generation_required INT,
    @v_count INT    
    
  -- Default return values
  SET @o_pubprefix_length = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_passed_string = LTRIM(RTRIM(@i_passed_string))
  
  -- ISBN Prefix may not be blank
  IF @v_passed_string IS NULL OR @v_passed_string = ''
  BEGIN
    SET @o_error_desc = 'ISBN Prefix may not be blank.'
    GOTO RETURN_ERROR
  END
  
  -- Check if leading or trailing spaces are found
  IF @i_passed_string <> @v_passed_string
    BEGIN
      SET @o_error_desc = 'ISBN Prefix may not contain spaces.'
      GOTO RETURN_ERROR
    END
  ELSE
    BEGIN
      -- Check if any spaces are found within the passed string (trimmed above)
      SET @v_pos = CHARINDEX(' ', @v_passed_string)
      IF @v_pos > 0
      BEGIN
        SET @o_error_desc = 'ISBN Prefix may not contain spaces.'
        GOTO RETURN_ERROR
      END
    END
        
  -- Check the length of passed string - cannot exceed 9 characters
  SET @v_string_length = LEN(@v_passed_string)
  IF @v_string_length > 9
  BEGIN
    SET @o_error_desc = 'Invalid length - ISBN Prefix cannot exceed 9 characters.'
    GOTO RETURN_ERROR
  END

  -- Make sure that a hyphen is found within passed string
  SET @v_hyphen_pos = CHARINDEX('-', @v_passed_string)
  IF @v_hyphen_pos = 0
  BEGIN
    SET @o_error_desc = 'ISBN Prefix must contain a hyphen.'
    GOTO RETURN_ERROR
  END
  
  -- Make sure that only one hyphen is found within passed string
  IF @v_hyphen_pos < @v_string_length
  BEGIN
    SET @v_pos = CHARINDEX('-', @v_passed_string, @v_hyphen_pos + 1)
    IF @v_pos > 0
    BEGIN
      SET @o_error_desc = 'ISBN Prefix may contain only one hyphen.'
      GOTO RETURN_ERROR
    END
  END
    
  -- Make sure that ISBN Prefix consists of digits and a hyphen only.
  SET @v_tempstring = REPLACE(@v_passed_string, '-', '')
  IF ISNUMERIC(@v_tempstring) = 0
  BEGIN
    SET @o_error_desc = 'ISBN Prefix must consist of digits and a hyphen only.'
    GOTO RETURN_ERROR
  END  

  -- get optionvalue for cleintoption optionid 109 (ISBN-10 Generation Required)
  SELECT @v_count = COUNT(*)
    FROM clientoptions
   WHERE optionid = 109

   IF @v_count = 0 BEGIN
     SET @v_isbn10_generation_required = 0
   END

   IF @v_count = 1 BEGIN
    SELECT @v_isbn10_generation_required = optionvalue
      FROM clientoptions
     WHERE optionid = 109
   END

  -- Although '979' EAN Prefix is valid for books, it is not yet supported
  IF @v_isbn10_generation_required = 1 BEGIN
    IF LTRIM(RTRIM(@i_eanprefix)) = '979'
    BEGIN
      SET @o_error_desc = '979 ISBN Prefixes are not yet supported and cannot be validated.'
      GOTO RETURN_WARNING
    END
  END
    
  -- EAN Prefix other than '978' and '979' doesn't make sense for books
  -- NOTE: This should never happen since EAN Prefix should have been validated
  IF @v_isbn10_generation_required = 1 BEGIN
    IF LTRIM(RTRIM(@i_eanprefix)) <> '978'
    BEGIN
      SET @o_error_desc = 'Only 978 and 979 ISBN Prefixes are valid for books.'
      GOTO RETURN_WARNING
    END
  END
  ELSE
  BEGIN
    IF (LTRIM(RTRIM(@i_eanprefix)) <> '978') AND (LTRIM(RTRIM(@i_eanprefix)) <> '979')
    BEGIN
      SET @o_error_desc = 'Only 978 and 979 ISBN Prefixes are valid for books.'
      GOTO RETURN_WARNING
    END
  END
  
  
  -- *** Validate Language/Country Group portion of ISBN Prefix (before hyphen) ***    
  -- *** NOTE: At this point, only 978 ISBN Prefixes are being validated below. ***
    
  -- Make sure that Language/Country Group does not exceed 5 characters
  SET @v_group_element = LEFT(@v_passed_string, @v_hyphen_pos -1)
  SET @v_tempstring = @v_group_element
  SET @v_string_length = LEN(@v_tempstring)
  IF @v_string_length > 5
  BEGIN
    SET @o_error_desc = 'Language/Country Group (before hyphen) cannot exceed 5 digits.'
    GOTO RETURN_ERROR
  END
  
  -- Strip out any dashes from passed string
  SET @v_tempstring = REPLACE(@v_passed_string, '-', '')
  -- Check the first 5 characters
  SET @v_tempstring = LEFT(@v_tempstring, 5)
  
  -- Pad the string with zeros on the right to form a 5-character string of digits
  SET @v_string_length = LEN(@v_tempstring)
  IF @v_string_length < 5
  BEGIN
    SET @v_tempstring = @v_tempstring + SPACE(5 - @v_string_length)
    SET @v_tempstring = REPLACE(@v_tempstring, ' ', '0')
  END  
  
  -- Convert the Language/Country Group portion of ISBN Prefix to 5-digit number
  SET @v_tempint = CONVERT(INT, @v_tempstring)
  
  -- Determine Group element length based on the 5-digit group number above
  SET @v_group_length = 
  CASE
    WHEN @v_tempint < 60000 THEN 1
    WHEN @v_tempint < 70000 THEN 3
    WHEN @v_tempint < 80000 THEN 1
    WHEN @v_tempint < 95000 THEN 2
    WHEN @v_tempint < 99000 THEN 3
    WHEN @v_tempint < 99900 THEN 4
    ELSE 5
  END  

  -- No Group element entered
  IF LEN(@v_group_element) = 0
  BEGIN
    SET @o_error_desc = 'Language/Country Group (before hyphen) must be entered.'
    GOTO RETURN_ERROR
  END

  -- Invalid Language/Country Group length
  IF LEN(@v_group_element) <> @v_group_length
  BEGIN  
    IF @v_tempint < 60000
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be a single digit if ISBN Prefix begins with digits 0-5.'
    ELSE IF @v_tempint < 70000
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be 3 digits if ISBN Prefix begins with digit 6.'
    ELSE IF @v_tempint < 80000
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be a single digit 7 if ISBN Prefix begins with digit 7.'
    ELSE IF @v_tempint < 95000
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be 2 digits if ISBN Prefix begins with numbers 80-94.'
    ELSE IF @v_tempint < 99000
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be 3 digits if ISBN Prefix begins with numbers 950-989.'
    ELSE IF @v_tempint < 99900
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be 4 digits if ISBN Prefix begins with numbers 9900-9989.'
    ELSE
      SET @o_error_desc = 'Language/Country Group (before hyphen) must be 5 digits if ISBN Prefix begins with digits 999.'
      
    GOTO RETURN_ERROR
  END
  
  -- NOTE: At this point, the Language/Country Group element (before hyphen) is valid.
  -- Convert the Language/Country Group to an integer.
  SET @v_group_int = CONVERT(INT, @v_group_element)
  
  -- Get group description from isbngroup table for this group
  EXEC qean_get_group_desc @v_group_element, @v_group_desc OUTPUT, @v_group_desc_detail OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  -- Exit if error was returned from stored procedure
  IF @o_error_code = -1
    GOTO RETURN_ERROR
  
  
  -- *** Validate Publisher Prefix portion of ISBN Prefix (after hyphen) ***
    
  -- Make sure that Publisher Prefix does not exceed 7 characters
  SET @v_pubprefix = SUBSTRING(@v_passed_string, @v_hyphen_pos + 1, 120)
  SET @v_tempstring = @v_pubprefix
  SET @v_string_length = LEN(@v_tempstring)
  IF @v_string_length > 7
  BEGIN
    SET @o_error_desc = 'Publisher Prefix (after hyphen) cannot exceed 7 digits.'
    GOTO RETURN_ERROR
  END
  
  -- No Publisher Prefix element entered
  IF @v_string_length = 0
  BEGIN
    SET @o_error_desc = 'Publisher Prefix (after hyphen) must be entered.'
    GOTO RETURN_ERROR
  END

  -- Pad the string with zeros on the right to form a 7-character string of digits
  IF @v_string_length < 7
  BEGIN
    SET @v_tempstring = @v_tempstring + SPACE(7 - @v_string_length)
    SET @v_tempstring = REPLACE(@v_tempstring, ' ', '0')
  END
  
  -- Convert the Publisher Prefix portion of ISBN Prefix to integer
  SET @v_tempint = CONVERT(INT, @v_tempstring)
  
	-- Check if ranges are defined for this Language/Country Group 
	-- on isbnprefixrange table
	SELECT @v_rowcount = COUNT(*)
  FROM isbnprefixrange
  WHERE isbngroup = @v_group_int
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_desc = 'Could not access isbngroup table (isbngroup=' + @v_group_element + ').'
    GOTO RETURN_ERROR
  END
  
  -- Invalid Language/Country Group - no ranges are defined
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_desc = 'No prefix ranges are defined for Language/Country Group ' + @v_group_element + ' - ' + @v_group_desc + '.'
    GOTO RETURN_ERROR
  END
  
  -- Determine length of Publisher Prefix based on valid prefix ranges for this group
  -- on isbnprefixrange table
  SELECT @v_rowcount = COUNT(*)
  FROM isbnprefixrange
  WHERE isbngroup = @v_group_int AND
        @v_tempint >= CONVERT(INT, beginrange) AND
        @v_tempint <= CONVERT(INT, endrange)
        
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_desc = 'Could not access isbnprefixrange table (isbngroup=' + @v_group_element + ').'
    GOTO RETURN_ERROR
  END        
  
  IF @v_rowcount > 0
  BEGIN
    SELECT @v_pubprefix_length = prefixlength
    FROM isbnprefixrange
    WHERE isbngroup = @v_group_int AND
          @v_tempint >= CONVERT(INT, beginrange) AND
          @v_tempint <= CONVERT(INT, endrange)
          
    -- Set return value
    SET @o_pubprefix_length = @v_pubprefix_length
  
    -- Invalid Language/Country Group length
    IF LEN(@v_pubprefix) <> @v_pubprefix_length
    BEGIN
      SET @o_error_desc = 'Language/Country Group ' + @v_group_element + ' - ' + @v_group_desc + 
        '<newline>Publisher Prefix (after hyphen) should consist of ' + 
        CONVERT(VARCHAR, @v_pubprefix_length) + ' digits if value begins with digits ' + 
        @v_pubprefix + '.'
        
      GOTO RETURN_ERROR
    END
  END --IF @v_rowcount > 0
  
  RETURN
  
    
RETURN_ERROR:
  SET @o_error_code = -1
  RETURN
  
RETURN_WARNING:
  SET @o_error_code = 1
  RETURN
  
END
GO

GRANT EXEC ON dbo.qean_isbnprefix_isvalid TO PUBLIC
GO
