if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_new_version_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_new_version_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_create_new_version_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qpl_create_new_version_xml
**  Desc: This stored procedure copies information for the given version.
**
**  Auth: Kate
**  Date: November 11 2011
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**  02/16/2016   UK          Case 35197 - Backing out change for Task 001 / Case 36095
*****************************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_PLStage  INT,
  @v_PLVersion  INT,
  @v_NewProjectKey_string VARCHAR(120),  
  @v_NewProjectKey INT,
  @v_NewPLStage INT,
  @v_NewPLVersion INT,
  @v_PLType INT,
  @v_PLSubType  INT,
  @v_RelStrategy  INT,
  @v_VerDesc  VARCHAR(40),
  @v_CopyValues   TINYINT,
  @v_UserKey  INT,
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
      @v_PLStage = PLStage,
      @v_PLVersion = PLVersion,
      @v_NewProjectKey_string = NewProjectKey,
      @v_NewPLStage = NewPLStage,
      @v_NewPLVersion = NewPLVersion,
      @v_PLType = PLType,
      @v_PLSubType = PLSubType,
      @v_RelStrategy = ReleaseStrategy,
      @v_UserKey = UserKey,
      @v_VerDesc = VersionDesc,
      @v_CopyValues = CopyValues      
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey INT 'ProjectKey', 
      PLStage INT 'PLStage',
      PLVersion INT 'PLVersion',
      NewProjectKey VARCHAR(120) 'NewProjectKey',
      NewPLStage INT 'NewPLStage',
      NewPLVersion INT 'NewPLVersion',
      PLType INT 'PLType',
      PLSubType INT 'PLSubType',
      ReleaseStrategy INT 'ReleaseStrategy',
      UserKey INT 'UserKey',
      VersionDesc VARCHAR(40) 'VersionDesc',
      CopyValues TINYINT 'CopyValues')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_create_new_version_xml.'
    GOTO ExitHandler
  END

  --DEBUG
  PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
  PRINT 'plstage=' + CAST(@v_PLStage AS VARCHAR)
  PRINT 'plversion=' + CAST(@v_PLVersion AS VARCHAR)
  PRINT 'newprojectkey_string=' + @v_NewProjectKey_string
  PRINT 'newplstage=' + CAST(@v_NewPLStage AS VARCHAR)
  PRINT 'newplversion=' + CAST(@v_NewPLVersion AS VARCHAR)
  PRINT 'pltype=' + CAST(@v_PLType AS VARCHAR)
  PRINT 'plsubtype=' + CAST(@v_PLSubType AS VARCHAR)
  PRINT 'relstrategy=' + CAST(@v_RelStrategy AS VARCHAR)
  PRINT 'verdesc=' + @v_VerDesc
  PRINT 'userkey=' + CAST(@v_UserKey AS VARCHAR)
  PRINT 'copyvalues=' + CAST(@v_CopyValues AS VARCHAR)
  
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''

  IF (@v_NewProjectKey_string IS NOT NULL AND LEN(@v_NewProjectKey_string) > 0 AND SUBSTRING(@v_NewProjectKey_string, 1, 1) = '?') BEGIN
    IF (LEN(@v_NewProjectKey_string) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_NewProjectKey_string, 2, LEN(@v_NewProjectKey_string) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END
      
    --DEBUG
    PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
    --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Version', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @v_NewProjectKey = @v_TempKey 
  END
  ELSE BEGIN
    SET @v_NewProjectKey = convert(int, @v_NewProjectKey_string);
  END  
  
  --DEBUG
  print 'NEW projectkey: ' + cast(@v_NewProjectKey AS VARCHAR)

  /** Call actual procedure **/
  EXEC qpl_create_new_version @v_ProjectKey, @v_PLStage, @v_PLVersion, @v_NewProjectKey, @v_NewPLStage, @v_NewPLVersion,
    @v_PLType, @v_PLSubType, @v_RelStrategy, @v_UserKey, @v_VerDesc, @v_CopyValues, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_create_new_version_xml TO PUBLIC
GO
