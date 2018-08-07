SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_validate_other_product')
  BEGIN
    DROP PROCEDURE qean_validate_other_product
  END
GO

CREATE PROCEDURE dbo.qean_validate_other_product
  @i_type             VARCHAR(25),
  @i_value            VARCHAR(50),
  @o_new_string       VARCHAR(50) OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_validate_other_product
**  Desc: For the passed product colum name (@i_type) of given value (@i_value), 
**        validate if the product number already exists.
**
**  Auth: Uday Khisty
**  Date: 23 January 2012
**
**  @o_error_code -1 will be returned generally when error occurred that prevented validation
**  @o_error_code > 0 will indicate a specific warning
**
**  @i_type = itemnumber  - itemnumber    (this is the Product Number)
**  @i_type = upc         - upc            (this is the Product Number
**  @i_type = lccn        - lccn           (this is the Product Number)
**  @i_type = dsmarc      - dsmarc         (this is the Product Number)
**
******************************************************************************************/

DECLARE
  @v_prodcolumn			   VARCHAR(25),
  @v_proddesc              VARCHAR(15),
  @v_rowcount			   INT,
  @v_SQLString             NVARCHAR(4000),
  @v_ProjectOrTitleName    VARCHAR(50)

BEGIN

  -- Initialize variables
  SET @o_new_string = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_ProjectOrTitleName = ''

  IF @i_type = 'itemnumber'
    BEGIN
      SET @v_prodcolumn = 'itemnumber'
    END
  ELSE IF @i_type = 'upc'
    BEGIN
      SET @v_prodcolumn = 'upc'
    END
  ELSE IF @i_type = 'lccn'
    BEGIN
      SET @v_prodcolumn = 'lccn'
    END
  ELSE IF @i_type = 'dsmarc'
    BEGIN
      SET @v_prodcolumn = 'dsmarc'
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

 IF @i_value <> ''
    SET @o_new_string = @i_value

  IF @v_prodcolumn = 'itemnumber'
  BEGIN
    SET @v_SQLString = N'SELECT @p_rowcount = COUNT(*) FROM isbn 
      WHERE  LTRIM(RTRIM(UPPER(' + @v_prodcolumn + '))) like LTRIM(RTRIM(UPPER(''' + @i_value + ''')))'

    EXECUTE sp_executesql @v_SQLString, 
      N'@p_rowcount INT OUTPUT, @p_product VARCHAR(50)', 
      @v_rowcount OUTPUT, @o_new_string

    IF @v_rowcount > 0
    BEGIN
	  SELECT top 1 @v_ProjectOrTitleName = b.title FROM isbn AS i INNER JOIN book AS b ON i.bookkey = b.bookkey WHERE LTRIM(RTRIM(UPPER(i.itemnumber))) LIKE LTRIM(RTRIM(UPPER( @i_value)))
      SET @o_error_code = 1 --NOTE: check for this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned on Title ''' + @v_ProjectOrTitleName + '''.'
      RETURN
    END    

    -- check project formats on taqprojecttitle 
    SET @v_SQLString = N'SELECT @p_rowcount = COUNT(*) FROM taqprojecttitle 
     WHERE  LTRIM(RTRIM(UPPER(' + @v_prodcolumn + '))) like LTRIM(RTRIM(UPPER(''' + @i_value + ''')))'

    EXECUTE sp_executesql @v_SQLString, 
      N'@p_rowcount INT OUTPUT, @p_product VARCHAR(50)', 
      @v_rowcount OUTPUT, @o_new_string

    IF @v_rowcount > 0
    BEGIN
	  SELECT top 1 @v_ProjectOrTitleName = q.taqprojecttitle FROM taqprojecttitle AS p INNER JOIN taqproject AS q  ON p.taqprojectkey = q.taqprojectkey WHERE  LTRIM(RTRIM(UPPER(p.itemnumber))) LIKE LTRIM(RTRIM(UPPER( @i_value)))
      SET @o_error_code = 1 --NOTE: check for this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned (Formats) on Project ''' + @v_ProjectOrTitleName + '''.'
      RETURN
    END    
  END
--  ELSE IF @v_prodcolumn = 'upc'
--    BEGIN
--    END
--  ELSE IF @v_prodcolumn = 'lccn'
--    BEGIN
--    END
--  ELSE IF @v_prodcolumn = 'dsmarc'
--    BEGIN
--    END
  ELSE
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unknown product type ' + CONVERT(VARCHAR, @v_prodcolumn) + '.'
      RETURN
    END
      
END
GO

GRANT EXEC ON dbo.qean_validate_other_product TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
