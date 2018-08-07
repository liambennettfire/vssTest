if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_add_taqprojecttask_newrole_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_add_taqprojecttask_newrole_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_add_taqprojecttask_newrole_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_add_taqprojecttask_newrole_xml
**  Desc: This stored procedure adds all tasks associated with the newly added
**        role. 
**
**    Auth: Lisa
**    Date: 10/01/08
*******************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_BookKey INT,
  @v_PrintingKey INT,
  @v_BookContactKey  INT,
  @v_BookContactKeyAsString  VARCHAR(50),
  @v_RoleCode  INT,
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
  SELECT @v_BookKey = BookKey,
      @v_PrintingKey = PrintingKey,
      @v_BookContactKey = BookContactKey,
      @v_BookContactKeyAsString = BookContactKeyAsString,
      @v_RoleCode = RoleCode,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKey int 'BookKey',
      PrintingKey int 'PrintingKey', 
      BookContactKey int 'BookContactKey',
      BookContactKeyAsString varchar(50) 'BookContactKeyAsString',
      RoleCode int 'RoleCode',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qtitle_add_taqprojecttask_newrole_xml.'
    GOTO ExitHandler
  END
  
--  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
--  PRINT 'printingkey=' + CAST(@v_PrintingKey AS VARCHAR)
--  PRINT 'bookcontactkey=' + cast(@v_BookContactKey as VARCHAR)
--  PRINT 'bookcontactkeyasstring=' + CAST(@v_BookContactKeyAsString AS VARCHAR)
--  PRINT 'rolecode=' + CAST(@v_RoleCode AS VARCHAR)
--  PRINT 'userid=' + @v_UserID
  
  IF ( isNull(@v_BookContactKey,0) <= 0 )
  BEGIN
      IF (@v_BookContactKeyAsString IS NOT NULL AND LEN(@v_BookContactKeyAsString) > 0 AND SUBSTRING(@v_BookContactKeyAsString, 1, 1) = '?')
        BEGIN
            
          IF (LEN(@v_BookContactKeyAsString) > 1)
          BEGIN
            SET @v_TempKeyName = SUBSTRING(@v_BookContactKeyAsString, 2, LEN(@v_BookContactKeyAsString) -1)
            SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
          END
          
          --DEBUG
          PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
          PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
                
          IF (@v_TempKey = 0)
          BEGIN
            EXEC next_generic_key 'New Book Role', @v_TempKey output, @o_error_code output, @o_error_desc
            SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
            IF (LEN(@v_TempKeyName) > 0)
            BEGIN
              SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
            END
          END
                  
          SET @v_BookContactKey = @v_TempKey 
        END
      ELSE
        BEGIN
          SET @v_BookContactKey = convert(int, @v_BookContactKeyAsString);
        END  
  END
  
  --DEBUG
--  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
--  PRINT 'printingkey=' + CAST(@v_PrintingKey AS VARCHAR)
--  PRINT 'bookcontactkey=' + CAST(@v_BookContactKey AS VARCHAR)
--  PRINT 'rolecode=' + CAST(@v_RoleCode AS VARCHAR)
--  PRINT 'userid=' + @v_UserID
  
  
  /** Call procedure that will populate TAQPROJECTTASK table **/
  /** (and TAQPROJECTREADERITERATION table when necessary) **/
  EXEC qtitle_add_taqprojecttask_newrole @v_BookKey, @v_PrintingKey, @v_BookContactKey,
    @v_RoleCode, @v_UserID, @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qtitle_add_taqprojecttask_newrole_xml TO PUBLIC
GO

