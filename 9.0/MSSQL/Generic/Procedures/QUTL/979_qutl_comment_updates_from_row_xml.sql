if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_comment_updates_from_row_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_comment_updates_from_row_xml
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_comment_updates_from_row_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_comment_updates_from_row_xml
**  Desc: Interface to make calls to html_to_lite_from_row and 
**        html_to_text_from_row
**
**    Auth: Alan Katzen
**    Date: 3/30/06
*******************************************************************************/

DECLARE 
  @v_IsOpen                            BIT,
  @v_DocNum                            INT,
  @v_Key1AsString                      VARCHAR(255),
  @v_Key1                              INT,
  @v_Key2AsString                      VARCHAR(255),
  @v_Key2                              INT,
  @v_CommentTypeCodeAsString           VARCHAR(255),
  @v_CommentTypeCode                   INT,
  @v_CommentTypeSubCodeAsString        VARCHAR(255),
  @v_CommentTypeSubCode                INT,
  @v_UpdateTableName                   VARCHAR(100),
  @v_UserID                            VARCHAR(30),
  @v_TempKey                           INT,
  @v_TempKeyName                       VARCHAR(255),
  @KeyNameIndex                        int,
  @ENDKeyIndex                         int

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''

 --PRINT '---------- BEGIN ---------------------------------'

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_Key1AsString = Key1AsString,
	 @v_Key2AsString = Key2AsString,
	 @v_CommentTypeCodeAsString = CommentTypeCodeAsString,
	 @v_CommentTypeSubCodeAsString = CommentTypeSubCodeAsString,
         @v_UpdateTableName = UpdateTableName,
         @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (Key1AsString VARCHAR(255) 'Key1', 
	Key2AsString VARCHAR(255) 'Key2',
	CommentTypeCodeAsString VARCHAR(255) 'CommentTypeCode',
	CommentTypeSubCodeAsString VARCHAR(255) 'CommentTypeSubCode',
        UpdateTableName VARCHAR(100) 'UpdateTableName',
        UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qutl_comment_updates_from_row_xml.'
    GOTO ExitHandler
  END

  SET @v_Key2 = CONVERT(INT,@v_Key2AsString)
  SET @v_CommentTypeCode = CONVERT(INT,@v_CommentTypeCodeAsString)
  SET @v_CommentTypeSubCode = CONVERT(INT,@v_CommentTypeSubCodeAsString)

  IF (@v_Key1AsString IS NOT NULL AND LEN(@v_Key1AsString) > 0 AND SUBSTRING(@v_Key1AsString,1,1) = '?') BEGIN
    IF (LEN(@v_Key1AsString) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_Key1AsString, 2, LEN(@v_Key1AsString) - 1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR(2000))
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR(2000))

    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_Key1AsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0) BEGIN
       SET @keys = @keys + @v_TempKeyName + ',' + @v_Key1AsString + ','
        IF @NewKeys IS NULL BEGIN
          SET @NewKeys = ''
        END
        SET @NewKeys = @NewKeys + @v_TempKeyName + ',' + @v_Key1AsString + ','
      END
    END
    ELSE BEGIN
      SET @v_Key1AsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_Key1 = CONVERT(INT, @v_Key1AsString)

--PRINT 'keys=' + CAST(@keys AS VARCHAR(2000))
--PRINT 'newkeys=' + CAST(COALESCE(@NewKeys,'') AS VARCHAR(2000))
--PRINT 'Key1=' + CAST(@v_Key1AsString AS VARCHAR(2000))
--PRINT 'CommentTypeCode=' + CAST(COALESCE(@v_CommentTypeCode,0) AS VARCHAR(2000))
--PRINT 'CommentTypeSubCode=' + CAST(COALESCE(@v_CommentTypeSubCode,0) AS VARCHAR(2000))
--PRINT '@v_UpdateTableName=' + CAST(@v_UpdateTableName AS VARCHAR(2000))

  -- update htmllite column
  EXECUTE html_to_lite_from_row_new @v_Key1,@v_Key2,@v_CommentTypeCode,@v_CommentTypeSubCode,@v_UpdateTableName,0,
                                    @o_error_code output,@o_error_desc output
  -- update text column
  EXECUTE html_to_text_from_row_new @v_Key1,@v_Key2,@v_CommentTypeCode,@v_CommentTypeSubCode,@v_UpdateTableName,
                                    @o_error_code output,@o_error_desc output

--PRINT 'Error Desc=' + CAST(@o_error_desc AS VARCHAR(2000))
--PRINT 'keys=' + CAST(@keys AS VARCHAR(2000))
--PRINT 'newkeys=' + CAST(COALESCE(@NewKeys,'') AS VARCHAR(2000))
--PRINT '---------- END ---------------------------------'
  
ExitHandler:

IF @v_IsOpen = 1 BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qutl_comment_updates_from_row_xml TO PUBLIC
GO
