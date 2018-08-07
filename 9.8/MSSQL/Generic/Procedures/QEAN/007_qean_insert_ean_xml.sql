if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_insert_ean_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  print 'Dropping dbo.qean_insert_ean_xml'
  drop procedure dbo.qean_insert_ean_xml
END
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

print 'Creating dbo.qean_insert_ean_xml'
GO

CREATE PROCEDURE dbo.qean_insert_ean_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qean_insert_ean_xml
**  Desc: This stored procedure calls the qean_reuse_ean stored procedure
**        as part of a generalized transaction.
**
**        @bookkey		 int,		
**        @isbnkey		 int,
**        @isbn_prefix_code  int,
**        @ean_prefix_code 	 int, 
**        @isbn_with_dashes  varchar(50),
**        @ean_with_dashes   varchar(50),
**        @gtin_with_dashes  varchar(50),
**        @itemnumber	VARCHAR(50),
**        @itemnumbergen TINYINT
**
**    Auth: James Weber
**    Date: 08 Sep 2004
**    
*******************************************************************************/

DECLARE 
  @IsOpen   BIT,
  @DocNum   INT,
  @bookkey    INT,
  @bookkeystring  VARCHAR(50),
  @isbnkey    INT,
  @isbnkeystring  VARCHAR(50),
  @isbn_prefix_code   INT,
  @ean_prefix_code    INT,
  @isbn_with_dashes   VARCHAR(50),
  @ean_with_dashes    VARCHAR(50),
  @gtin_with_dashes   VARCHAR(50),
  @itemnumber	VARCHAR(50),
  @itemnumbergen	TINYINT,
  @TempKey    INT,
  @TempKeyName  VARCHAR(255),
  @KeyValue   VARCHAR(50),
  @v_UserID   VARCHAR(30)

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @newkeys = ''
 
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END
  
  SET @IsOpen = 1
  
  SELECT @bookkeystring = BookKey, 
    @isbnkeystring = IsbnKey, 
    @ean_prefix_code = EanPrefixCode, 
    @isbn_prefix_code = IsbnPrefixCode, 
    @ean_with_dashes = EanWithDashes, 
    @isbn_with_dashes = IsbnWithDashes, 
    @gtin_with_dashes = GtinWithDashes,
    @itemnumber = ItemNumber,
    @itemnumbergen = ItemNumberGen,
    @v_UserID = UserID
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (BookKey varchar(50) 'BookKey', 
    IsbnKey varchar(50) 'IsbnKey', 
    EanPrefixCode int 'EanPrefixCode', 
    IsbnPrefixCode int 'IsbnPrefixCode', 
    EanWithDashes varchar(50) 'EanWithDashes', 
    IsbnWithDashes varchar(50) 'IsbnWithDashes', 
    GtinWithDashes varchar(50) 'GtinWithDashes',
    ItemNumber VARCHAR(50) 'ItemNumber',
    ItemNumberGen TINYINT 'ItemNumberGen',
    UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting ean insert information from xml parameters.'
    GOTO ExitHandler
  END
  
  if (@bookkeystring is not null and LEN(@bookkeystring) > 0 and SUBSTRING(@bookkeystring, 1, 1) = '?')
    BEGIN
      SET @TempKey = 0
      SET @TempKeyName = ''
      SET @KeyValue = ''

      IF (LEN(@bookkeystring) > 1)
      BEGIN
        SET @TempKeyName = SUBSTRING(@bookkeystring, 2, LEN(@bookkeystring) -1)
        SET @TempKey = dbo.key_from_key_list_string(@keys, @TempKeyName)
      END

      IF (@TempKey = 0)
      BEGIN
        exec next_generic_key 'EAN Insert', @TempKey output, @o_error_code output, @o_error_desc
        SET @KeyValue = CONVERT(varchar(120), @TempKey)
        IF (LEN(@TempKeyName) > 0)
        BEGIN
          SET @newkeys = @newkeys + @TempKeyName + ',' + @KeyValue + ','
        END
      END

      SET @bookkey = @TempKey 
    END
  ELSE
    BEGIN
      SET @bookkey = convert(int, @bookkeystring);  
    END
  
  if (@isbnkeystring is not null and LEN(@isbnkeystring) > 0 and SUBSTRING(@isbnkeystring, 1, 1) = '?')
    BEGIN
      SET @TempKey = 0
      SET @TempKeyName = ''
      SET @KeyValue = ''

      IF (LEN(@bookkeystring) > 1)
      BEGIN
        SET @TempKeyName = SUBSTRING(@isbnkeystring, 2, LEN(@isbnkeystring) -1)
        SET @TempKey = dbo.key_from_key_list_string(@keys, @TempKeyName)
      END
      
      IF (@TempKey = 0)
      BEGIN
        SET @TempKey = dbo.key_from_key_list_string(@newkeys, @TempKeyName)
      END
      
      IF (@TempKey = 0)
      BEGIN
        exec next_generic_key 'EAN Insert', @TempKey output, @o_error_code output, @o_error_desc
        SET @KeyValue = CONVERT(varchar(120), @TempKey)
        IF (LEN(@TempKeyName) > 0)
        BEGIN
          SET @newkeys = @newkeys + @TempKeyName + ',' + @KeyValue + ','
        END
      END
              
      SET @isbnkey = @TempKey 
    END
  ELSE
    BEGIN
      SET @isbnkey = convert(int, @isbnkeystring);  
    END
  
  --print @bookkeystring
  --print @bookkey
  --print @isbnkeystring  
  --print @isbnkey
  --print @isbn_prefix_code
  --print @ean_prefix_code
  --print @isbn_with_dashes
  --print @ean_with_dashes
  --print @gtin_with_dashes
  --print @keys
  --print @newkeys

  EXEC dbo.qean_insert_ean @bookkey, @isbnkey, @isbn_prefix_code, @ean_prefix_code, 
    @isbn_with_dashes, @ean_with_dashes, @gtin_with_dashes, @itemnumber, @itemnumbergen, @v_UserID,
    @o_error_code output, @o_error_desc output

ExitHandler:
  if @IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
  END

GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_insert_ean_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  GRANT EXEC ON dbo.qean_insert_ean_xml TO PUBLIC
END
GO
