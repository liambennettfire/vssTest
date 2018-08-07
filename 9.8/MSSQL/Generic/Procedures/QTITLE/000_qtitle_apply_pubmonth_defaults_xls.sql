if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_apply_pubmonth_defaults_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_apply_pubmonth_defaults_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_apply_pubmonth_defaults_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_apply_pubmonth_defaults_xml
**  Desc: Interface to make call to qtitle_apply_pubmonth_defaults
**
**  Auth: Kate Wiewiora
**  Date: 3 August 2010
*******************************************************************************/

DECLARE 
  @v_IsOpen           BIT,
  @v_DocNum           INT,
  @v_BookKeyAsString  VARCHAR(255),
  @v_BookKey          INT,
  @v_PrintingKey      INT,
  @v_PubMonth         INT,
  @v_PubYear          INT,       
  @v_UserID           VARCHAR(30),
  @v_TempKey          INT,
  @v_TempKeyName      VARCHAR(255)

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_BookKeyAsString = BookKeyAsString,
    @v_PrintingKey = PrintingKey,
    @v_PubMonth = PubMonth,
    @v_PubYear = PubYear,
    @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKeyAsString VARCHAR(255) 'BookKey', 
    PrintingKey INT 'PrintingKey',
    PubMonth INT 'PubMonth',
    PubYear INT 'PubYear',
    UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qtitle_apply_pubmonth_defaults_xml.'
    GOTO ExitHandler
  END

  IF (@v_BookKeyAsString IS NOT NULL AND LEN(@v_BookKeyAsString) > 0 AND SUBSTRING(@v_BookKeyAsString,1,1) = '?') BEGIN
    IF (LEN(@v_BookKeyAsString) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_BookKeyAsString, 2, LEN(@v_BookKeyAsString) - 1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR(2000))
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR(2000))

    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_BookKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0) BEGIN
       SET @keys = @keys + @v_TempKeyName + ',' + @v_BookKeyAsString + ','
        IF @NewKeys IS NULL BEGIN
          SET @NewKeys = ''
        END
        SET @NewKeys = @NewKeys + @v_TempKeyName + ',' + @v_BookKeyAsString + ','
      END
    END
    ELSE BEGIN
      SET @v_BookKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_BookKey = CONVERT(INT, @v_BookKeyAsString)

  -- Call procedure that will apply the pubmonth defaults
  EXECUTE qtitle_apply_pubmonth_defaults @v_BookKey, @v_PrintingKey, @v_PubMonth, @v_PubYear, @v_UserID, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT
   
ExitHandler:

IF @v_IsOpen = 1 BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qtitle_apply_pubmonth_defaults_xml TO PUBLIC
GO
