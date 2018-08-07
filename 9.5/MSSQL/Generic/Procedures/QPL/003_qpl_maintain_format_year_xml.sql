if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_maintain_format_year_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_maintain_format_year_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_maintain_format_year_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_maintain_format_year_xml
**  Desc: This stored procedure maintais all tables dependent on changes to version formats
**        (taqversionformat) and Include Up To Year value (taqversion.maxyearcode).
**
**  Auth: Kate
**  Date: November 9 2007
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_ProjectKey_string varchar(120),
  @v_PLStageCode  INT,
  @v_VersionKey INT,
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
  SELECT @v_ProjectKey_string = ProjectKey,
      @v_PLStageCode = PLStage,
      @v_VersionKey = PLVersion,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey VARCHAR(120) 'ProjectKey', 
      PLStage int 'PLStage',
      PLVersion int 'PLVersion',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_maintain_format_year_xml.'
    GOTO ExitHandler
  END

  --DEBUG
  --PRINT 'projectkey_string=' + @v_ProjectKey_string
  --PRINT 'plstagecode=' + CAST(@v_PLStageCode AS VARCHAR)
  --PRINT 'taqversionkey=' + CAST(@v_VersionKey AS VARCHAR)
  --PRINT 'userid=' + @v_UserID  
  
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''

  IF (@v_ProjectKey_string IS NOT NULL AND LEN(@v_ProjectKey_string) > 0 AND SUBSTRING(@v_ProjectKey_string, 1, 1) = '?') BEGIN
    IF (LEN(@v_ProjectKey_string) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_ProjectKey_string, 2, LEN(@v_ProjectKey_string) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END
      
    --DEBUG
    --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
    --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Project Version', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @v_ProjectKey = @v_TempKey 
  END
  ELSE BEGIN
    SET @v_ProjectKey = convert(int, @v_ProjectKey_string);
  END  
  --DEBUG
  --print 'projectkey: ' + cast(@v_ProjectKey AS VARCHAR)

  /** Call actual procedure **/
  EXEC qpl_maintain_format_year @v_ProjectKey, @v_PLStageCode,
    @v_VersionKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_maintain_format_year_xml TO PUBLIC
GO
