if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qse_copy_list_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qse_copy_list_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qse_copy_list_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output, 
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************
**  Name: qse_copy_list_xml
**  Desc: This stored procedure copies all results from one list to another.
**
**  Auth: Kate
**  Date: 8 August 2006
**********************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_FromListKey  INT,
  @v_ToListKey    INT,
  @v_ToListKeyAsString  VARCHAR(50),  
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
  SELECT @v_FromListKey = FromListKey, 
      @v_ToListKeyAsString = ToListKeyAsString
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (FromListKey INT 'FromListKey', 
      ToListKeyAsString VARCHAR(50) 'ToListKeyAsString')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qse_copy_list_xml.'
    GOTO ExitHandler
  END
  
  -- DEBUG
  PRINT 'from_listkey=' + CAST(@v_FromListKey AS VARCHAR)
  PRINT 'to_listkey=' + @v_ToListKeyAsString
  
  IF (@v_ToListKeyAsString IS NOT NULL AND LEN(@v_ToListKeyAsString) > 0 AND SUBSTRING(@v_ToListKeyAsString, 1, 1) = '?')
    BEGIN
        
      IF (LEN(@v_ToListKeyAsString) > 1)
      BEGIN
        SET @v_TempKeyName = SUBSTRING(@v_ToListKeyAsString, 2, LEN(@v_ToListKeyAsString) -1)
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
              
      SET @v_ToListKey = @v_TempKey 
    END
  ELSE
    BEGIN
      SET @v_ToListKey = convert(int, @v_ToListKeyAsString);
    END  
  
  --DEBUG
  PRINT '@v_ToListKey=' + CAST(@v_ToListKey AS VARCHAR)
  
  /** Call procedure that will populate TAQPROJECTTASK table **/
  /** (and TAQPROJECTREADERITERATION table when necessary) **/
  EXEC qse_copy_list @v_FromListKey, @v_ToListKey,
    @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qse_copy_list_xml TO PUBLIC
GO
