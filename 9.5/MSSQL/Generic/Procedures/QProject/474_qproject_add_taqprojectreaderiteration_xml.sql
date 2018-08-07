if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojectreaderiteration_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_add_taqprojectreaderiteration_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_add_taqprojectreaderiteration_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojectreaderiteration_xml
**  Desc: This stored procedure adds a new row to taqprojectreaderiteration table.
**        If no contactrolekey is passed, it adds a new taqprojectreaderiteration
**        row for each active Reader.
**
**    Auth: Kate
**    Date: 9/10/10
*******************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_ContactRoleKey INT,
  @v_TaqElementKey  INT,
  @v_TaqElementKeyAsString  VARCHAR(50),
  @v_UserID   VARCHAR(30),
  @v_TempKey  INT,
  @v_TempKeyName  VARCHAR(255),
  @v_KeyValue VARCHAR(50)  

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''
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
  SELECT @v_ProjectKey = ProjectKey,
      @v_ContactRoleKey = ContactRoleKey,
      @v_TaqElementKeyAsString = TaqElementKeyAsString,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
      ContactRoleKey int 'ContactRoleKey',
      TaqElementKeyAsString varchar(50) 'TaqElementKeyAsString',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_add_taqprojectreaderiteration_xml.'
    GOTO ExitHandler
  END
  
  IF (@v_TaqElementKeyAsString IS NOT NULL AND LEN(@v_TaqElementKeyAsString) > 0 AND SUBSTRING(@v_TaqElementKeyAsString, 1, 1) = '?')
    BEGIN
        
      IF (LEN(@v_TaqElementKeyAsString) > 1)
      BEGIN
        SET @v_TempKeyName = SUBSTRING(@v_TaqElementKeyAsString, 2, LEN(@v_TaqElementKeyAsString) -1)
        SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
      END
      
      --DEBUG
      --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
      --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
      IF (@v_TempKey = 0)
      BEGIN
        EXEC next_generic_key 'New Project Element', @v_TempKey output, @o_error_code output, @o_error_desc
        SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
        IF (LEN(@v_TempKeyName) > 0)
        BEGIN
          SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
        END
      END
              
      SET @v_TaqElementKey = @v_TempKey 
    END
  ELSE
    BEGIN
      SET @v_TaqElementKey = convert(int, @v_TaqElementKeyAsString);
    END  
  
  --PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
  --PRINT 'taqelementkey=' + CAST(@v_TaqElementKey AS VARCHAR)
  --PRINT 'contactrolekey=' + CAST(@v_ContactRoleKey AS VARCHAR)
  --PRINT 'userid=' + @v_UserID
  
  
  /** Call procedure that will populate TAQPROJECTREADERITERATION table **/
  EXEC qproject_add_taqprojectreaderiteration @v_ProjectKey, @v_ContactRoleKey, 
    @v_TaqElementKey, @v_UserID, @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qproject_add_taqprojectreaderiteration_xml TO PUBLIC
GO
