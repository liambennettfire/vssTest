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
**        validate IF the product number already EXISTS.
**
**  Auth: Uday Khisty
**  Date: 23 January 2012
**
**  @o_error_code -1 will be returned generally WHEN error occurred that prevented validation
**  @o_error_code > 0 will indicate a specific warning
**
**  @i_type = itemnumber  - itemnumber    (this is the Product Number)
**  @i_type = upc         - upc            (this is the Product Number
**  @i_type = lccn        - lccn           (this is the Product Number)
**  @i_type = dsmarc      - dsmarc         (this is the Product Number)
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   ----------   --------    ------------------------------------------------------------------------
**  05/03/2017   Colman      44816 finish partial implementation
******************************************************************************************/

DECLARE
  @v_proddesc        VARCHAR(15),
  @v_duplicatename   VARCHAR(50),
  @v_comparevalue    VARCHAR(25)

BEGIN

  DECLARE @v_allowduplicates TINYINT,
          @v_datacode INT
  
  -- Initialize variables
  SET @o_new_string = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_duplicatename = ''
  
  SET @v_comparevalue = LTRIM(RTRIM(UPPER(@i_value)))
  
  SELECT @v_datacode = datacode FROM gentables_ext WHERE tableid = 551 AND gentext1 = @i_type
  
  -- If the product number type is not registered, skip the validation
  IF ISNULL(@v_datacode, 0) = 0
    RETURN
    
  SELECT @v_allowduplicates = gen2ind FROM gentables WHERE tableid = 551 AND datacode = @v_datacode
  
  IF ISNULL(@v_allowduplicates, 0) = 1
    RETURN
    
  -- Get product description FROM isbnlabels  
  SELECT @v_proddesc = label
  FROM isbnlabels
  WHERE columnname = @i_type

 IF ISNULL(@i_value, '') <> ''
    SET @o_new_string = @i_value

  IF @i_type = 'itemnumber'
  BEGIN
    IF EXISTS (SELECT 1 FROM isbn WHERE LTRIM(RTRIM(UPPER(itemnumber))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = b.title 
      FROM isbn i JOIN book b ON i.bookkey = b.bookkey 
      WHERE LTRIM(RTRIM(UPPER(i.itemnumber))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to Title ''' + @v_duplicatename + '''.'
      RETURN
    END    
    -- check project formats on taqprojecttitle 
    IF EXISTS (SELECT 1 FROM taqprojecttitle WHERE LTRIM(RTRIM(UPPER(itemnumber))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = q.taqprojecttitle 
      FROM taqprojecttitle p 
        JOIN taqproject AS q ON p.taqprojectkey = q.taqprojectkey
      WHERE LTRIM(RTRIM(UPPER(p.itemnumber))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to a Format on Project ''' + @v_duplicatename + '''.'
      RETURN
    END    
  END
  ELSE IF @i_type = 'upc'
  BEGIN
    IF EXISTS (SELECT 1 FROM isbn WHERE LTRIM(RTRIM(UPPER(upc))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = b.title 
      FROM isbn i JOIN book b ON i.bookkey = b.bookkey 
      WHERE LTRIM(RTRIM(UPPER(i.upc))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to Title ''' + @v_duplicatename + '''.'
      RETURN
    END    
    -- check project formats on taqprojecttitle 
    IF EXISTS (SELECT 1 FROM taqprojecttitle WHERE LTRIM(RTRIM(UPPER(upc))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = q.taqprojecttitle 
      FROM taqprojecttitle p 
        JOIN taqproject AS q ON p.taqprojectkey = q.taqprojectkey
      WHERE LTRIM(RTRIM(UPPER(p.upc))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to a Format on Project ''' + @v_duplicatename + '''.'
      RETURN
    END    
  END
  ELSE IF @i_type = 'lccn'
  BEGIN
    IF EXISTS (SELECT 1 FROM isbn WHERE LTRIM(RTRIM(UPPER(lccn))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = b.title 
      FROM isbn i JOIN book b ON i.bookkey = b.bookkey 
      WHERE LTRIM(RTRIM(UPPER(i.lccn))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to Title ''' + @v_duplicatename + '''.'
      RETURN
    END    
    -- check project formats on taqprojecttitle 
    IF EXISTS (SELECT 1 FROM taqprojecttitle WHERE LTRIM(RTRIM(UPPER(lccn))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = q.taqprojecttitle 
      FROM taqprojecttitle p 
        JOIN taqproject AS q ON p.taqprojectkey = q.taqprojectkey
      WHERE LTRIM(RTRIM(UPPER(p.lccn))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to a Format on Project ''' + @v_duplicatename + '''.'
      RETURN
    END    
  END
  ELSE IF @i_type = 'dsmarc'
  BEGIN
    IF EXISTS (SELECT 1 FROM isbn WHERE LTRIM(RTRIM(UPPER(dsmarc))) = @v_comparevalue)
    BEGIN
      SELECT TOP(1) @v_duplicatename = b.title 
      FROM isbn i JOIN book b ON i.bookkey = b.bookkey 
      WHERE LTRIM(RTRIM(UPPER(i.dsmarc))) = @v_comparevalue

      SET @o_error_code = 1 --NOTE: check FOR this ErrorCode to customize warning msg
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to Title ''' + @v_duplicatename + '''.'
      RETURN
    END    
    -- check project formats on taqprojecttitle 
    IF EXISTS ((SELECT 1 FROM taqprojecttitle WHERE LTRIM(RTRIM(UPPER(dsmarc))) = @v_comparevalue))
    BEGIN
      SELECT TOP(1) @v_duplicatename = q.taqprojecttitle 
      FROM taqprojecttitle p 
        JOIN taqproject AS q ON p.taqprojectkey = q.taqprojectkey
      WHERE LTRIM(RTRIM(UPPER(p.dsmarc))) = @v_comparevalue

      SET @o_error_code = 1
      SET @o_error_desc = @v_proddesc + '  ''' + @o_new_string + '''  has already been assigned to a Format on Project ''' + @v_duplicatename + '''.'
      RETURN
    END    
  END
  ELSE
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unknown product type ' + CONVERT(VARCHAR, @i_type) + '.'
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
