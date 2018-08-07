if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_resend_contact_titles_to_elo_from_row_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_resend_contact_titles_to_elo_from_row_xml
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_resend_contact_titles_to_elo_from_row_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_resend_contact_titles_to_elo_from_row_xml
**  Desc: Interface to make calls to qcontact_resend_titles_to_eloquence
**       
**
**    Auth: Kusum Basra
**    Date: 1/18/2012
*******************************************************************************/

DECLARE 
  @v_IsOpen                            BIT,
  @v_DocNum                            INT,
  @v_Key1AsString                      VARCHAR(255),
  @v_Key1                              INT,
  @v_UpdateTableName                   VARCHAR(100),
  @v_UserID                            VARCHAR(30),
  @v_TempKey                           INT,
  @v_TempKeyName                       VARCHAR(255),
  @KeyNameIndex                        int,
  @ENDKeyIndex                         int,
  @v_ReleaseToEloquenceInd	   int,
  @v_ReleaseToEloquenceIndAsString	VARCHAR(255),
  @v_ExportToEloquenceInd	   int,
  @v_ExportToEloquenceIndAsString	VARCHAR(255)

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
	          @v_UpdateTableName = UpdateTableName,
         	 @v_UserID = UserID,
         	 @v_ReleaseToEloquenceIndAsString = ReleaseToEloquenceIndAsString,
        		 @v_ExportToEloquenceIndAsString = ExportToEloquenceIndAsString
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (Key1AsString VARCHAR(255) 'Key1', 
	UpdateTableName VARCHAR(100) 'UpdateTableName',
    UserID VARCHAR(30) 'UserID',
    ReleaseToEloquenceIndAsString VARCHAR(255) 'ReleaseToEloquenceInd',
    ExportToEloquenceIndAsString VARCHAR(255) 'ExportToEloquenceInd'
      )

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qutl_resend_globalcontact_related_titles_to_elo_from_row_xml.'
    GOTO ExitHandler
  END
  

  SET @v_ReleaseToEloquenceInd = CONVERT(INT,@v_ReleaseToEloquenceIndAsString)
  SET @v_ExportToEloquenceInd	 = CONVERT(INT,@v_ExportToEloquenceIndAsString)

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

  -- resend all titles related to contact to eloquence
  IF @v_UpdateTableName = 'QSICOMMENTS' AND @v_ReleaseToEloquenceInd = 1 AND @v_ExportToEloquenceInd = 1
  BEGIN
  	EXECUTE qcontact_resend_titles_to_eloquence @v_Key1,@v_UserID, @o_error_code output,@o_error_desc output
  END

  IF @v_UpdateTableName = 'GLOBALCONTACTMISC' AND @v_ReleaseToEloquenceInd = 1 AND @v_ExportToEloquenceInd = 1
  BEGIN
  	EXECUTE qcontact_resend_titles_to_eloquence @v_Key1,@v_UserID, @o_error_code output,@o_error_desc output
  END
 

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

GRANT EXEC ON qutl_resend_contact_titles_to_elo_from_row_xml TO PUBLIC
GO
