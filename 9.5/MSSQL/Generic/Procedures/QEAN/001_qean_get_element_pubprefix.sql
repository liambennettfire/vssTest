IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_get_element_pubprefix')
  BEGIN
    DROP PROCEDURE qean_get_element_pubprefix
  END
GO

CREATE PROCEDURE dbo.qean_get_element_pubprefix
  (@i_product_string    VARCHAR(25),
  @i_group_length       SMALLINT,
  @o_pubprefix_element  VARCHAR(7) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT)
AS

/**********************************************************************************
**  Name: qean_get_element_pubprefix
**  Desc: Extract and return Publisher Prefix element from passed product string.
**
**  NOTE: i_product_string must be stripped of GTIN and EAN Prefixes before passed in.
**
**  Auth: Kate J. Wiewiora
**  Date: 10 July 2006
***********************************************************************************/

DECLARE
  @v_group_element      VARCHAR(5),
  @v_group_desc         VARCHAR(50),
  @v_group_desc_detail  VARCHAR(255),
  @v_group_int          INT,
  @v_pubprefix_length   SMALLINT,    
  @v_rowcount           INT,
  @v_tempint            INT,
  @v_tempstring         VARCHAR(10),    
  @v_work_string        VARCHAR(25)    

BEGIN
    
  -- Default return values
  SET @o_pubprefix_element = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Strip out any dashes from passed product string
  SET @v_work_string = REPLACE(@i_product_string, '-', '')  
  
  -- First, determine the Group Element
  IF @i_group_length > 0
    BEGIN
      -- When group length is passed in, extract Group Element from passed product string
      SET @v_group_element = LEFT(@v_work_string, @i_group_length)      
    END
  ELSE
    BEGIN
      -- When group length is unknown, run the stored procedure to get the Group Element
      EXEC qean_get_element_group @v_work_string, @v_group_element OUTPUT, 
        @o_error_code OUTPUT, @o_error_desc OUTPUT

      -- Exit if error was returned from stored procedure
      IF @o_error_code < 0
        RETURN
      
      -- Set Group Element length
      SET @i_group_length = LEN(@v_group_element)
    END

  -- Get group description
  EXEC qean_get_group_desc @v_group_element, @v_group_desc OUTPUT, @v_group_desc_detail OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0
    RETURN
  
  -- Store all digits after the determined Group element into work string
  SET @v_work_string = SUBSTRING(@v_work_string, @i_group_length + 1, 25)  

  -- Get the first 7 characters of current work string (after extracted Group Element)
  SET @v_tempstring = LEFT(@v_work_string, 7)
  
  -- Pad the string with zeros on the right to form a 7-character string
  IF LEN(@v_tempstring) < 7
  BEGIN
    SET @v_tempstring = @v_tempstring + SPACE(7 - LEN(@v_tempstring))
    SET @v_tempstring = REPLACE(@v_tempstring, ' ', '0')
  END
  
  -- Convert the 7-character string to an integer for prefix range comparison
  SET @v_tempint = CONVERT(INT, @v_tempstring)

  -----------------------------------------------------------------------
  -- Determine Publisher Prefix length for the given Group element
  -----------------------------------------------------------------------  
   
  -- NOTE: All ranges in the isbnprefixrange table are taken from International ISBN Agency website
  -- http://www.isbn-international.org/en/identifiers/List-of-Ranges.pdf
  -- as of October 16, 2008. This list may get updated in the future, so the table will need to be updated.
  -- ISBN-10 to ISBN-13 converter to validate ISBNs:
  -- http://www.isbn-international.org/converter/converter.html
  
	SET @v_pubprefix_length = 0
  SET @v_group_int = CONVERT(INT, @v_group_element)
	
	-- Check if ranges are defined for this Language/Country Group on isbnprefixrange table
  SELECT @v_rowcount = COUNT(*)
  FROM isbnprefixrange
  WHERE isbngroup = @v_group_int
    
  -- Invalid Language/Country Group - no ranges are defined
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -2
    SET @o_error_desc = 'No prefix ranges are defined for Language/Country Group ' + @v_group_element + ' - ' + @v_group_desc + '.'
    RETURN
  END

  -- Determine length of Publisher Prefix based on valid prefix ranges for this group  on isbnprefixrange table
  SELECT @v_rowcount = COUNT(*)
  FROM isbnprefixrange
  WHERE isbngroup = @v_group_int AND
        @v_tempint >= CONVERT(INT, beginrange) AND
        @v_tempint <= CONVERT(INT, endrange)
  
  IF @v_rowcount > 0
    SELECT @v_pubprefix_length = prefixlength
    FROM isbnprefixrange
    WHERE isbngroup = @v_group_int AND
          @v_tempint >= CONVERT(INT, beginrange) AND
          @v_tempint <= CONVERT(INT, endrange)
    
  IF @v_pubprefix_length = 0
  BEGIN
    SET @o_error_code = -2
    SET @o_error_desc = 'Publisher Prefix is invalid for Language/Country Group ' + @v_group_element + ' - ' + @v_group_desc + '.'
    RETURN
  END
    
  -- Extract Publisher Prefix
  SET @o_pubprefix_element = LEFT(@v_work_string, @v_pubprefix_length)

END
GO

GRANT EXEC ON dbo.qean_get_element_pubprefix TO PUBLIC
GO
