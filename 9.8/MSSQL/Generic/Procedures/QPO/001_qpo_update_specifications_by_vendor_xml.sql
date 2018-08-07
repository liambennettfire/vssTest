if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_update_specifications_by_vendor_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpo_update_specifications_by_vendor_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_update_specifications_by_vendor_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_update_specifications_by_vendor_xml
**
**  Desc: This stored procedure processes the XML string into parameters
**        and calls qcontact_add_project_participant_by_role to add Record 
**        for a Participant by Role Section.
**
**
**    Auth: Uday A. Khisty
**    Date: 10/04/14
**
*******************************************************************************/

DECLARE 
  @v_IsOpen							BIT,
  @v_DocNum							INT,
  @v_ProjectKeyAsString				VARCHAR(255),  
  @v_ProjectKey						INT,
  @v_GlobalContactKeyOriginal		INT,
  @v_GlobalContactKeyCurrent		INT,  
  @v_RoleCode						INT,    
  @v_UserID							VARCHAR(30),
  @v_TempKey						INT,
  @v_TempKeyName					VARCHAR(255),
  @v_KeyValue						VARCHAR(50),
  @v_ProjectContactKeyAsString		VARCHAR(50)

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
  SELECT @v_ProjectKeyAsString = ProjectKeyAsString,
      @v_GlobalContactKeyOriginal = GlobalContactKeyOriginal,    
      @v_GlobalContactKeyCurrent = GlobalContactKeyCurrent,              
      @v_RoleCode = RoleCode,    
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKeyAsString VARCHAR(255) 'ProjectKey',
      GlobalContactKeyOriginal int 'GlobalContactKeyOriginal', 
      GlobalContactKeyCurrent int 'GlobalContactKeyCurrent',       
      RoleCode int 'RoleCode',        
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpo_update_specifications_by_vendor_xml.'
    GOTO ExitHandler
  END
  
  
----DEBUG
--  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
--  PRINT 'printingkey=' + CAST(@v_PrintingKey AS VARCHAR)
--  PRINT 'bookcontactkey=' + CAST(@v_BookContactKey AS VARCHAR)
--  PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
--  PRINT 'projectcontactkey=' + CAST(@v_ProjectContactKey AS VARCHAR)  
--  PRINT 'userid=' + @v_UserID 

  IF (@v_ProjectKeyAsString IS NOT NULL AND LEN(@v_ProjectKeyAsString) > 0 AND SUBSTRING(@v_ProjectKeyAsString,1,1) = '?')
  BEGIN
      
    IF (LEN(@v_ProjectKeyAsString) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_ProjectKeyAsString, 2, LEN(@v_ProjectKeyAsString) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)

    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @keys = @keys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
        IF @newkeys IS NULL BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
      END
    END
    ELSE 
    BEGIN
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_ProjectKey = CONVERT(INT, @v_ProjectKeyAsString)

  /** Call procedure that will delete Element and Task records **/
  EXEC qpo_update_specifications_by_vendor @v_ProjectKey, @v_GlobalContactKeyOriginal, @v_GlobalContactKeyCurrent, @v_RoleCode,  @v_UserID, @o_error_code output, @o_error_desc output
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpo_update_specifications_by_vendor_xml TO PUBLIC
GO
