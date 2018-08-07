if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_copy_format_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_copy_format_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_copy_format_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_copy_format_xml
**  Desc: This stored procedure copies information for the given format.
**
**  Auth: Kate
**  Date: November 8 2011
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_PLStageCode  INT,
  @v_VersionKey INT,
  @v_FormatKey INT,
  @v_FormatKey_string VARCHAR(120),
  @v_FromFormatKey  INT,
  @v_FormatPrice  FLOAT,
  @v_CopyValues   TINYINT,
  @v_BookKey  INT,
  @v_UserID VARCHAR(30),
  @v_TempKey  INT,
  @v_TempKeyName  VARCHAR(255),
  @v_KeyValue VARCHAR(50)  
  
  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document.'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_ProjectKey = ProjectKey,
      @v_PLStageCode = PLStage,
      @v_VersionKey = PLVersion,
      @v_FormatKey_string = FormatKey,
      @v_FromFormatKey = FromFormatKey,
      @v_FormatPrice = FormatPrice,
      @v_CopyValues = CopyValues,
      @v_BookKey = BookKey,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey INT 'ProjectKey', 
      PLStage INT 'PLStage',
      PLVersion INT 'PLVersion',
      FormatKey VARCHAR(120) 'FormatKey',
      FromFormatKey INT 'FromFormatKey',
      FormatPrice FLOAT 'FormatPrice',
      CopyValues TINYINT 'CopyValues',
      BookKey INT 'BookKey',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_copy_format_xml.'
    GOTO ExitHandler
  END

  --DEBUG
  PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
  PRINT 'plstagecode=' + CAST(@v_PLStageCode AS VARCHAR)
  PRINT 'taqversionkey=' + CAST(@v_VersionKey AS VARCHAR)
  PRINT 'formatkey_string=' + @v_FormatKey_string
  PRINT 'FROM formatkey=' + CAST(@v_FromFormatKey AS VARCHAR)
  PRINT 'format price=' + CAST(@v_FormatPrice AS VARCHAR)
  PRINT 'copyvalues=' + CAST(@v_CopyValues AS VARCHAR)
  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
  PRINT 'userid=' + @v_UserID  
  
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''

  IF (@v_FormatKey_string IS NOT NULL AND LEN(@v_FormatKey_string) > 0 AND SUBSTRING(@v_FormatKey_string, 1, 1) = '?') BEGIN
    IF (LEN(@v_FormatKey_string) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_FormatKey_string, 2, LEN(@v_FormatKey_string) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END
      
    --DEBUG
    PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
    PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Format', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @v_FormatKey = @v_TempKey 
  END
  ELSE BEGIN
    SET @v_FormatKey = convert(int, @v_FormatKey_string);
  END  
  
  --DEBUG
  PRINT 'formatkey: ' + cast(@v_FormatKey AS VARCHAR)

  /** Call actual procedure **/
  EXEC qpl_copy_format @v_ProjectKey, @v_PLStageCode, @v_VersionKey, @v_FormatKey, 
    @v_FromFormatKey, @v_FormatPrice, @v_CopyValues, @v_BookKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_copy_format_xml TO PUBLIC
GO
