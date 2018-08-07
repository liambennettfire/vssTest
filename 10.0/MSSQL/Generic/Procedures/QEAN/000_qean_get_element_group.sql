IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_get_element_group')
  BEGIN
    DROP PROCEDURE qean_get_element_group
  END
GO

CREATE PROCEDURE dbo.qean_get_element_group
 (@i_prefix           VARCHAR(3),
  @i_product_string   VARCHAR(25),
  @o_group_element    VARCHAR(5) OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)
AS

/************************************************************************************
**  Name: qean_get_element_group
**  Desc: Extract and return Country/Language Group element from passed product string.
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
*************************************************************************************/

DECLARE 
  @v_group_length       INT,
  @v_tempstring         VARCHAR(10),
  @v_tempint            INT

BEGIN

  -- Default return values
  SET @o_group_element = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Strip out any dashes from passed product string
  SET @i_product_string = REPLACE(@i_product_string, '-', '')

  -- Check the first 5 characters of the passed product string
  SET @v_tempstring = LEFT(@i_product_string, 5)
  SET @v_tempint = CONVERT(INT, @v_tempstring)
    
  -- Determine Group element length based on the first 5 characters above
  IF @i_prefix = '979'
  BEGIN
    IF LEFT(@i_product_string, 1) <> '1'
    BEGIN
      SET @o_error_code = -3
      SET @o_error_desc = @o_error_desc + '<newline>Registration group element for prefix 979 must begin with 1.'
      RETURN
    END
    ELSE
      SET @v_group_length = 2
  END
  ELSE
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
  
  -- Extract Group Element
  SET @o_group_element = LEFT(@i_product_string, @v_group_length)
  
END
GO

GRANT EXEC ON dbo.qean_get_element_group TO PUBLIC
GO
