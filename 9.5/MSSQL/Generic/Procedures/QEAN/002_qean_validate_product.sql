SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_validate_product')
  BEGIN
    DROP PROCEDURE qean_validate_product
  END
GO

CREATE PROCEDURE dbo.qean_validate_product
  @i_passed_string    VARCHAR(25),
  @i_type             TINYINT,
  @i_check_if_exists  TINYINT,
  @i_bookkey          INT,
  @o_new_string       VARCHAR(25) OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_validate_product
**  Desc: For the passed product string (@i_passed_string) of given type (@i_type), 
**        validate the required length, the check digit, and the structure of
**        the product string itself (Country/Language Group and Publisher Prefix), 
**        and generate the corresponding product string with dashes(@o_new_string).
**
**  Auth: Kate J. Wiewiora
**  Date: 20 June 2006
**
**  @o_error_code -1 will be returned generally when error occurred that prevented validation
**  @o_error_code -2 will be returned to indicate INVALID PRODUCT (-3 invalid check digit)
**  @o_error_code > 0 will indicate a specific warning
**
**  @i_type = 0  - ISBN-10      (this is the 10-digit/13-character pre-2007 ISBN)
**  @i_type = 1  - ISBN-13/EAN  (this is the NEW 13-digit/17-character ISBN)
**  @i_type = 2  - GTIN         (14-digit global trade item number)
**
**  Examples: 
**      GTIN        0-978-1-86233-193-8 (EAN/ISBN-13 preceded with a 0)
**      EAN/ISBN-13   978-1-86233-193-8
**      ISBN-10           1-86233-193-6 (NOTE the different check digit)
**    
**  Structure of the above EAN/ISBN-13 pieces (978-1-86233-193-8):    
**      EAN Prefix (978)
**      Country/Language Group (1)
**      Publisher Prefix  (86233)
**      Publication (193)
**      Check digit (8)
**
******************************************************************************************/

DECLARE
  @v_check_digit    CHAR(1),
  @v_ean_prefix     CHAR(3),
  @v_group_element  VARCHAR(5),
  @v_group_length   SMALLINT,
  @v_gtin_prefix    CHAR(1),
  @v_last_digit     CHAR(1),
  @v_prodcolumn     VARCHAR(25),
  @v_proddesc       VARCHAR(15),
  @v_prodstring_no_check_digit VARCHAR(25),
  @v_publication_element  VARCHAR(7),
  @v_pubprefix_element   VARCHAR(7),
  @v_pubprefix_length    SMALLINT,
  @v_required_length  SMALLINT,
  @v_rowcount     INT,
  @v_startpos     SMALLINT,
  @v_string_length  SMALLINT,
  @v_work_string  VARCHAR(25),
  @v_SQLString    NVARCHAR(4000),
  @v_isbn10_generation_required INT,
  @v_count INT,
  @v_datacode     INT,
  @v_datasubcode  INT   

BEGIN

  -- Strip out any hyphens and spaces from the passed string
  SET @v_work_string = REPLACE(@i_passed_string, '-', '')
  SET @v_work_string = REPLACE(@v_work_string, ' ', '')
  SET @v_work_string = UPPER(@v_work_string)
    
  -- Get the string length
  SET @v_string_length = LEN(@v_work_string)
    
  -- Initialize variables
  SET @o_new_string = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_gtin_prefix = ''
  SET @v_ean_prefix = ''
  IF @i_type = 0
    BEGIN
      SET @v_prodcolumn = 'isbn'
      SET @v_required_length = 10
    END
  ELSE IF @i_type = 1
    BEGIN
      SET @v_prodcolumn = 'ean'
      SET @v_required_length = 13
    END
  ELSE IF @i_type = 2
    BEGIN
      SET @v_prodcolumn = 'gtin'
      SET @v_required_length = 14
    END
  ELSE
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unknown product type ' + CONVERT(VARCHAR, @i_type) + '.'
      RETURN
    END
    
  -- Get product description from isbnlabels  
  SELECT @v_proddesc = label
  FROM isbnlabels
  WHERE LTRIM(RTRIM(LOWER(columnname))) = @v_prodcolumn
  
  SELECT @v_rowcount = @@ROWCOUNT
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Label is not populated on isbnlabels table for columnname=' + @v_prodcolumn + '.' 
    RETURN
  END
    
  -- Validate required number of digits
  IF @v_string_length <> @v_required_length
  BEGIN
    SET @o_error_code = -2
    SET @o_error_desc = @v_proddesc + ' must consist of ' + CONVERT(VARCHAR, @v_required_length) + ' digits.'
    RETURN
  END
  
  -- Extract the last digit for comparison with generated check digit at the end
  SET @v_last_digit = RIGHT(@v_work_string, 1)
  
  -- Store all digits before the check digit into @v_work_string
  SET @v_work_string = SUBSTRING(@v_work_string, 1, @v_string_length - 1)
  SET @v_prodstring_no_check_digit = @v_work_string
  
  -- Make sure the passed product string (excluding the check digit) is a number - 
  -- product string minus the check digit must consist of digits only
  IF ISNUMERIC(@v_work_string) = 0
  BEGIN
    SET @o_error_code = -2
    SET @o_error_desc = @v_proddesc + ' contains invalid characters.<newline>All characters before the check digit must be digits or hyphens.'
    RETURN
  END
    
  -- Separate string pieces into known elements
  IF @i_type = 1  --EAN/ISBN-13
    BEGIN
      SET @v_ean_prefix = LEFT(@v_work_string, 3)
      SET @v_work_string = SUBSTRING(@v_work_string, 4, 25)
    END  
  ELSE IF @i_type = 2  --GTIN
    BEGIN
      SET @v_gtin_prefix = LEFT(@v_work_string, 1)
      SET @v_ean_prefix = SUBSTRING(@v_work_string, 2, 3)
      SET @v_work_string = SUBSTRING(@v_work_string, 5, 25)    
    END

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

  -- For now, treat it as an error if EAN Prefix is not '978' - ranges are currently 
  -- defined for 978 Prefix only - ONLY if clientoption for optionid 109 has optionvalue = 1 
  IF @v_isbn10_generation_required = 1 BEGIN
    IF @v_ean_prefix <> ''
      IF @v_ean_prefix <> '978'
      BEGIN
        SET @o_error_code = -2
        IF @v_gtin_prefix <> '' --GTIN
          SET @o_error_desc = @v_proddesc + ' identifying a book should begin with digits 0978.'
        ELSE  --EAN/ISBN-13
--        SET @o_error_desc = @v_proddesc + ' should begin with digits 978.'
--        IF @v_ean_prefix = '979'
          SET @o_error_desc = @o_error_desc + '<newline>You have chosen a prefix other than 978. This is not allowed ' +
            'because according to your client options you are required to have an ISBN-10. ' +
            'An ISBN-10 cannot be generated with this prefix. Please see your system adminstrator if you have questions.'
        RETURN
      END
   END
    
  -- Extract Group Element from work string
  EXEC qean_get_element_group @v_work_string, @v_group_element OUTPUT, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0 
    RETURN
    
  -- Get the length of Group element string
  SET @v_group_length = LEN(@v_group_element)
  
  -- Extract Publisher Prefix from the work string
  EXEC qean_get_element_pubprefix @v_work_string, @v_group_length, @v_pubprefix_element OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0
    RETURN
    
  -- Get the length of Publisher Prefix element string
  SET @v_pubprefix_length = LEN(@v_pubprefix_element)

  -- The remaining portion of the work string is the Publication element
  SET @v_startpos = @v_group_length + @v_pubprefix_length + 1
  SET @v_publication_element = SUBSTRING(@v_work_string, @v_startpos, 25)
      
  -- Separate each piece by hyphens and concatenate all pieces together 
  -- to form the new product string  
  IF @v_gtin_prefix <> ''
    SET @o_new_string = @v_gtin_prefix + '-'
  IF @v_ean_prefix <> ''
    SET @o_new_string = @o_new_string + @v_ean_prefix + '-'
  
  SET @o_new_string = @o_new_string + @v_group_element + '-' + 
    @v_pubprefix_element + '-' + @v_publication_element + '-' + @v_last_digit 
  
  -- Generate the check digit for the passed string of the given type
  EXEC qean_generate_check_digit @v_prodstring_no_check_digit, 
    @v_check_digit OUTPUT, @i_type
  
  -- Validate the check digit - compare with actual last digit entered
  IF @v_last_digit <> @v_check_digit
  BEGIN
    SET @o_error_code = -3
    SET @o_error_desc = 'The check digit for this ' + @v_proddesc + ' must be ' + @v_check_digit + '.'
    RETURN
  END
   
  -- ********* WARNINGS (not errors) ********* 
  -- IMPORTANT NOTE: this procedure is also called from qean_generate_ean, which also
  -- may issue warnings. The errorcodes for all warnings must be unique.
  
  -- Check if this ISBN exists in donotuseisbn table
  -- NOTE: DONOTUSEISBN warning must be checked first (need for Replaces/Replaced By)
  -- Because donotuseisbn table stores ISBN-10 values without dashes, and the 
  -- check digit is different for ISBN-10 and other values, we must compare 
  -- the first 9 digits (minus the check digit) with the work string
  SET @v_work_string = @v_group_element + @v_pubprefix_element + @v_publication_element
      
  SELECT @v_rowcount = COUNT(isbn10)
  FROM donotuseisbn
  WHERE LEFT(isbn10, 9) = @v_work_string
  
  IF @v_rowcount > 0
  BEGIN
	  SET @o_error_code = 3 --NOTE: check for this ErrorCode to customize warning msg
	  SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  is listed in DONOTUSEISBN table.'
	  RETURN	
  END
  
  -- Check if this product already exists on the database (don't count this bookkey)
  IF @i_check_if_exists = 1
  BEGIN
    SET @v_SQLString = N'SELECT @p_rowcount = COUNT(*) FROM isbn 
      WHERE bookkey <> ' + CONVERT(VARCHAR, @i_bookkey) + ' AND LTRIM(RTRIM(UPPER(' + @v_prodcolumn + '))) = UPPER(@p_product)'

    EXECUTE sp_executesql @v_SQLString, 
      N'@p_rowcount INT OUTPUT, @p_product VARCHAR(25)', 
      @v_rowcount OUTPUT, @o_new_string

    IF @v_rowcount > 0
    BEGIN
      SET @o_error_code = 1 --NOTE: check for this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned (Title).'
      RETURN
    END    

	SELECT @v_datacode = datacode FROM gentables WHERE tableid = 550 AND qsicode = 3
	SELECT @v_datasubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1 AND datacode = @v_datacode
	
    -- check project formats on taqprojecttitle 
    SET @v_SQLString = N'SELECT @p_rowcount = COUNT(*) FROM taqprojecttitle 
      WHERE LTRIM(RTRIM(UPPER(' + @v_prodcolumn + '))) = UPPER(@p_product)
      AND taqprojectkey IN 
      (SELECT taqprojectkey from taqproject WHERE searchitemcode = ' +  CONVERT(VARCHAR, @v_datacode) + ' and usageclasscode = ' +  CONVERT(VARCHAR, @v_datasubcode) + ' and taqprojectstatuscode IN 
		(select datacode from gentables where tableid = 522 and COALESCE(qsicode, 0) <> 1)) and projectrolecode = (select datacode from gentables where tableid = 604 and qsicode = 2)'

    EXECUTE sp_executesql @v_SQLString, 
      N'@p_rowcount INT OUTPUT, @p_product VARCHAR(25)', 
      @v_rowcount OUTPUT, @o_new_string

    IF @v_rowcount > 0
    BEGIN
      SET @o_error_code = 1 --NOTE: check for this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned (Project Format).'
      RETURN
    END    
  END
  
  -- Issue a warning if GTIN Prefix > 0
  IF @v_gtin_prefix <> ''
    IF @v_gtin_prefix > 0
    BEGIN
      SET @o_error_code = 2 --NOTE: check for this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + ' identifying a book should begin with a leading zero.'
      RETURN
    END
    
  -- IMPORTANT NOTE: this procedure is also called from qean_generate_ean, which also
  -- may issue warnings. The errorcodes for all warnings must be unique.
      
END
GO

GRANT EXEC ON dbo.qean_validate_product TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
