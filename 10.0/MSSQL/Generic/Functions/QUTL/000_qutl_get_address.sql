IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qutl_get_address')
      AND xtype IN (N'FN', N'IF', N'TF')
    )
  DROP FUNCTION dbo.qutl_get_address
GO

CREATE FUNCTION qutl_get_address (
  @i_address1 VARCHAR(MAX),
  @i_address2 VARCHAR(MAX),
  @i_address3 VARCHAR(MAX),
  @i_city VARCHAR(MAX),
  @i_statecode INT,
  @i_zip VARCHAR(MAX),
  @i_countrycode INT
)
RETURNS VARCHAR(MAX)

/******************************************************************************
**  Name: qutl_get_address
**  Desc: Assemble a full <br/> delimited address string from components
**
**  Auth: Colman
**  Date: 07/19/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:      Description:
**  --------  ----------   ----------------------------------------------------
**    
*******************************************************************************/
BEGIN
  DECLARE @v_address VARCHAR(MAX), @v_citystatezip VARCHAR(MAX), @v_state VARCHAR(MAX)


  SET @v_address = ''
  SET @v_citystatezip = ''

  SET @i_address1 = LTRIM(RTRIM(ISNULL(@i_address1, '')))
  SET @i_address2 = LTRIM(RTRIM(ISNULL(@i_address2, '')))
  SET @i_address3 = LTRIM(RTRIM(ISNULL(@i_address3, '')))
  SET @i_city = LTRIM(RTRIM(ISNULL(@i_city, '')))
  SET @i_zip = LTRIM(RTRIM(ISNULL(@i_zip, '')))

  IF @i_address1 <> ''
    SET @v_address = @v_address + @i_address1  

  IF @i_address2 <> ''
  BEGIN
    IF @v_address <> ''
      SET @v_address = @v_address + '<br/>'
    SET @v_address = @v_address + @i_address2  
  END

  IF @i_address3 <> ''
  BEGIN
    IF @v_address <> ''
      SET @v_address = @v_address + '<br/>'
    SET @v_address = @v_address + @i_address3
  END

  IF @i_city <> ''
  BEGIN
    SET @v_citystatezip = @i_city
  END

  IF ISNULL(@i_statecode, 0) > 0
  BEGIN
    SELECT @v_state = ISNULL(datadesc, '') FROM gentables WHERE tableid = 160 AND datacode = @i_statecode
    IF @v_citystatezip <> ''
      SET @v_citystatezip = @v_citystatezip + ', '
    SET @v_citystatezip = @v_citystatezip + @v_state
  END

  IF @i_zip <> ''
  BEGIN
    IF @v_citystatezip <> ''
      SET @v_citystatezip = @v_citystatezip + ' '
    SET @v_citystatezip = @v_citystatezip + @i_zip
  END

  IF @v_citystatezip <> ''
  BEGIN
    IF @v_address <> ''
      SET @v_address = @v_address + '<br/>'
    SET @v_address = @v_address + @v_citystatezip
  END

  RETURN @v_address
END
GO

GRANT EXEC ON dbo.qutl_get_address TO PUBLIC
GO


