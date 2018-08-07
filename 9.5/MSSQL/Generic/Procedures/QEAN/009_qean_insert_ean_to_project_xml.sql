if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_insert_ean_to_project_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
print 'Dropping dbo.qean_insert_ean_to_project_xml'
drop procedure dbo.qean_insert_ean_to_project_xml
END
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

print 'Creating dbo.qean_insert_ean_to_project_xml'
GO

CREATE PROCEDURE dbo.qean_insert_ean_to_project_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qean_insert_ean_to_project_xml
**  Desc: This stored procedure calls the qean_reuse_ean stored procedure
**        as part of a generalized transaction.
**
**        @taqprojectkey	 int,		
**        @taqprojectformatkey   int,
**        @isbn_prefix_code      int,
**        @ean_prefix_code 	 int, 
**        @isbn_with_dashes  varchar(50),
**        @ean_with_dashes   varchar(50),
**        @gtin_with_dashes  varchar(50),
**        @itemnumber VARCHAR(50),
**        @itemnumbergen TINYINT
**
**    Auth: Alan Katzen
**    Date: 10 May 2005
**    
*******************************************************************************/

  DECLARE 
	@IsOpen			BIT,
	@DocNum			INT

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
    
  DECLARE @taqprojectkey	     int	
  DECLARE @taqprojectkeystring       varchar(50)
  DECLARE @taqprojectformatkey	     int
  DECLARE @taqprojectformatkeystring varchar(50)
  DECLARE @isbn_prefix_code          int
  DECLARE @ean_prefix_code 	     int
  DECLARE @isbn_with_dashes          varchar(50)
  DECLARE @ean_with_dashes           varchar(50)
  DECLARE @gtin_with_dashes          varchar(50)
  DECLARE @itemnumber	VARCHAR(50)
  DECLARE @itemnumbergen	TINYINT
  DECLARE @TempKey                   int
  DECLARE @TempKeyName               varchar(256)
  DECLARE @KeyValue                  varchar(50)
  
  SELECT @taqprojectkeystring = TaqProjectKey, @taqprojectformatkeystring = TaqProjectFormatKey, 
         @ean_prefix_code = EanPrefixCode, @isbn_prefix_code = IsbnPrefixCode, @ean_with_dashes = EanWithDashes , 
         @isbn_with_dashes = IsbnWithDashes, @gtin_with_dashes = GtinWithDashes, 
         @itemnumber = ItemNumber, @itemnumbergen = ItemNumberGen
    FROM OPENXML(@DocNum,  '//Parameters')
    WITH (TaqProjectKey varchar(50) 'TaqProjectKey', TaqProjectFormatKey varchar(50) 'TaqProjectFormatKey', 
          EanPrefixCode int 'EanPrefixCode', IsbnPrefixCode int 'IsbnPrefixCode', EanWithDashes varchar(50) 'EanWithDashes', 
          IsbnWithDashes varchar(50) 'IsbnWithDashes', GtinWithDashes varchar(50) 'GtinWithDashes',
          ItemNumber VARCHAR(50) 'ItemNumber', ItemNumberGen TINYINT 'ItemNumberGen')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting ean insert information from xml parameters.'
    GOTO ExitHandler
  END
  
  if (@taqprojectkeystring is not null and LEN(@taqprojectkeystring) > 0 and SUBSTRING(@taqprojectkeystring, 1, 1) = '?') BEGIN
    SET @TempKey = 0
    SET @TempKeyName = ''
    SET @KeyValue = ''

    IF (LEN(@taqprojectkeystring) > 1) BEGIN
      SET @TempKeyName = SUBSTRING(@taqprojectkeystring, 2, LEN(@taqprojectkeystring) -1)
      SET @TempKey = dbo.key_from_key_list_string(@keys, @TempKeyName)
    END
        
    IF (@TempKey = 0) BEGIN
      exec next_generic_key 'EAN Insert', @TempKey output, @o_error_code output, @o_error_desc
      SET @KeyValue = CONVERT(varchar(120), @TempKey)
      IF (LEN(@TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @TempKeyName + ',' + @KeyValue + ','
      END
    END
                
    SET @taqprojectkey = @TempKey 
  END
  ELSE BEGIN
    SET @taqprojectkey = convert(int, @taqprojectkeystring);  
  END
  
  if (@taqprojectformatkeystring is not null and LEN(@taqprojectformatkeystring) > 0 and SUBSTRING(@taqprojectformatkeystring, 1, 1) = '?') BEGIN
    SET @TempKey = 0
    SET @TempKeyName = ''
    SET @KeyValue = ''

    IF (LEN(@taqprojectformatkeystring) > 1) BEGIN
      SET @TempKeyName = SUBSTRING(@taqprojectformatkeystring, 2, LEN(@taqprojectformatkeystring) -1)
      SET @TempKey = dbo.key_from_key_list_string(@keys, @TempKeyName)
    END
        
    IF (@TempKey = 0) BEGIN
      SET @TempKey = dbo.key_from_key_list_string(@newkeys, @TempKeyName)
    END
        
    IF (@TempKey = 0) BEGIN
      exec next_generic_key 'EAN Insert', @TempKey output, @o_error_code output, @o_error_desc
      SET @KeyValue = CONVERT(varchar(120), @TempKey)
      IF (LEN(@TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @TempKeyName + ',' + @KeyValue + ','
      END
    END
                
    SET @taqprojectformatkey = @TempKey 
  END
  ELSE BEGIN
    SET @taqprojectformatkey = convert(int, @taqprojectformatkeystring);  
  END
  
  --print @taqprojectkeystring
  --print @taqprojectkey
  --print @taqprojectformatkeystring  
  --print @taqprojectformatkey
  --print @isbn_prefix_code
  --print @ean_prefix_code
  --print @isbn_with_dashes
  --print @ean_with_dashes
  --print @gtin_with_dashes
  --print @keys
  --print @newkeys


  EXEC dbo.qean_insert_ean_to_project @taqprojectkey, @taqprojectformatkey, @isbn_prefix_code, @ean_prefix_code, 
    @isbn_with_dashes, @ean_with_dashes, @gtin_with_dashes, @itemnumber, @itemnumbergen, @o_error_code output, @o_error_desc output

ExitHandler:

if @IsOpen = 1
BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
END

GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_insert_ean_to_project_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
print 'Granting exec on dbo.qean_insert_ean_to_project_xml TO PUBLIC'
GRANT EXEC ON dbo.qean_insert_ean_to_project_xml TO PUBLIC
END
GO



