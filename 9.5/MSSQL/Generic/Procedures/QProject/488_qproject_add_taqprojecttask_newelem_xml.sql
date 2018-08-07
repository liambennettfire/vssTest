if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojecttask_newelem_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_add_taqprojecttask_newelem_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_add_taqprojecttask_newelem_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojecttask_newelem_xml
**  Desc: This stored procedure adds all tasks associated with the newly added
**        element. If the new element is Manuscript, a row is also added
**        to taqprojectreaderiteration table for each active Reader.
**
**    Auth: Kate
**    Date: 10/21/04
*******************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_TaqElementKey  INT,
  @v_TaqElementKeyAsString  VARCHAR(50),
  @v_ElementTypeCode  INT,
  @v_UserID   VARCHAR(30),
  @v_TaskViewKey  INT,
  @v_BookKey  INT,
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
      @v_TaqElementKeyAsString = TaqElementKeyAsString,
      @v_ElementTypeCode = ElementTypeCode,
      @v_UserID = UserID,
      @v_TaskViewKey = TaskViewKey,
      @v_BookKey = BookKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
      TaqElementKeyAsString varchar(50) 'TaqElementKeyAsString',
      ElementTypeCode int 'ElementTypeCode',
      UserID varchar(30) 'UserID',
      TaskViewKey int 'TaskViewKey',
      BookKey int 'BookKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_add_taqprojecttask_newelem_xml.'
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
  --PRINT 'elementtypecode=' + CAST(@v_ElementTypeCode AS VARCHAR)
  --PRINT 'userid=' + @v_UserID
  
  
  /** Call procedure that will populate TAQPROJECTTASK table **/
  /** (and TAQPROJECTREADERITERATION table when necessary) **/
  EXEC qproject_add_taqprojecttask_newelem @v_TaskViewKey,@v_ProjectKey, @v_TaqElementKey,
    @v_ElementTypeCode, @v_BookKey, @v_UserID, @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qproject_add_taqprojecttask_newelem_xml TO PUBLIC
GO
