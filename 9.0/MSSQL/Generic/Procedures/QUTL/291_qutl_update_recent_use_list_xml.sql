if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_update_recent_use_list_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_update_recent_use_list_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_update_recent_use_list_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output, 
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************
**  Name: qutl_update_recent_use_list_xml
**  Desc: This stored procedure updates the "recent" list
**
**  Auth: Kate
**  Date: 19 September 2006
**********************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_UserKey  INT,
  @v_SearchType    INT,
  @v_ListType INT,
  @v_Key1     INT,
  @v_Key2     INT,
  @v_Key1AsString  VARCHAR(50),
  @v_ActionType TINYINT,
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
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_UserKey = UserKey, @v_SearchType = SearchType, @v_ListType = ListType,
       @v_Key1AsString = Key1AsString, @v_Key2 = Key2, @v_ActionType = ActionType
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (UserKey INT 'UserKey', 
      SearchType INT 'SearchType',
      ListType INT 'ListType',
      Key1AsString VARCHAR(50) 'Key1AsString',
      Key2 INT 'Key2',
      ActionType TINYINT 'ActionType')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qutl_update_recent_use_list_xml.'
    GOTO ExitHandler
  END
  
  -- DEBUG
  PRINT 'userkey=' + CAST(@v_UserKey AS VARCHAR)
  PRINT 'searchtypecode=' + CAST(@v_SearchType AS VARCHAR)
  PRINT 'listtypecode=' + CAST(@v_ListType AS VARCHAR)
  PRINT 'key1=' + @v_Key1AsString
  PRINT 'key2=' + CAST(@v_Key2 AS VARCHAR)
  PRINT 'actiontype=' + CAST(@v_ActionType AS VARCHAR)
  
  IF (@v_Key1AsString IS NOT NULL AND LEN(@v_Key1AsString) > 0 AND SUBSTRING(@v_Key1AsString, 1, 1) = '?')
    BEGIN
        
      IF (LEN(@v_Key1AsString) > 1)
      BEGIN
        SET @v_TempKeyName = SUBSTRING(@v_Key1AsString, 2, LEN(@v_Key1AsString) -1)
        SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
      END
      
      --DEBUG
      PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
      PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
      IF (@v_TempKey = 0)
      BEGIN
        EXEC next_generic_key 'NewList', @v_TempKey output, @o_error_code output, @o_error_desc
        SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
        IF (LEN(@v_TempKeyName) > 0)
        BEGIN
          SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
        END
      END
              
      SET @v_Key1 = @v_TempKey 
    END
  ELSE
    BEGIN
      SET @v_Key1 = CONVERT(INT, @v_Key1AsString);
    END  
      
  /** Call procedure that will update the "recent" list **/
  EXEC qutl_update_recent_use_list @v_UserKey, @v_SearchType, @v_ListType, 
    @v_Key1, @v_Key2, @v_ActionType, @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qutl_update_recent_use_list_xml TO PUBLIC
GO
