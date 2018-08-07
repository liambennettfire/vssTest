IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_get_element_publication')
  BEGIN
    DROP PROCEDURE qean_get_element_publication
  END
GO

CREATE PROCEDURE dbo.qean_get_element_publication
 (@i_eanprefix            VARCHAR(3),
  @i_product_string       VARCHAR(25),
  @o_publication_element  VARCHAR(7) OUTPUT,
  @o_error_code           INT OUTPUT,
  @o_error_desc           VARCHAR(2000) OUTPUT)
AS

/**********************************************************************************
**  Name: qean_get_element_publication
**  Desc: Extract and return Publication element from passed product string.
**
**  NOTE: i_product_string must be stripped of GTIN and EAN Prefixes before passed in.
**
**  Auth: Kate J. Wiewiora
**  Date: 10 July 2006
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    -------------------------------------------
**  11/04/2016   Colman      40804 - Support for 979 EAN prefix
***********************************************************************************/

DECLARE
  @v_group_element      VARCHAR(5),
  @v_group_length       SMALLINT,
  @v_pubprefix_element  VARCHAR(7),
  @v_pubprefix_length   SMALLINT,    
  @v_startpos           SMALLINT,
  @v_string_length      SMALLINT,
  @v_work_string        VARCHAR(25)    

BEGIN
    
  -- Default return values
  SET @o_publication_element = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Strip out any dashes from passed product string
  SET @v_work_string = REPLACE(@i_product_string, '-', '')  
  
  -- Get the Group Element
  EXEC qean_get_element_group @i_eanprefix, @v_work_string, @v_group_element OUTPUT, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0
    RETURN
      
  -- Set Group Element length
  SET @v_group_length = LEN(@v_group_element)

  -- Get the Publisher Prefix element
  EXEC qean_get_element_pubprefix @i_eanprefix, @v_work_string, @v_group_length, @v_pubprefix_element OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
    
  -- Exit if error was retured from stored procedure
  IF @o_error_code < 0
    RETURN
  
  -- Get the length of Publisher Prefix element string
  SET @v_pubprefix_length = LEN(@v_pubprefix_element)

  -- The remaining portion of the work string is the Publication element
  SET @v_startpos = @v_group_length + @v_pubprefix_length + 1
  SET @v_string_length = 10 - @v_startpos --(10-digit string - Group - Pub Prefix - Check Digit)
  SET @o_publication_element = SUBSTRING(@v_work_string, @v_startpos, @v_string_length)  

END
GO

GRANT EXEC ON dbo.qean_get_element_publication TO PUBLIC
GO
