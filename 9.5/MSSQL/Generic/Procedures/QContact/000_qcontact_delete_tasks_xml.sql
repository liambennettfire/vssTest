if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_delete_tasks_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_delete_tasks_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_delete_tasks_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_delete_tasks_xml
**
**  Desc: This stored procedure processes the XML string into parameters
**        and calls qcontact_delete_tasks to delete Elemets and
**        Tasks for a contact based on the delete options chosen.
**
**
**    Auth: Lisa
**    Date: 10/01/08
**
*******************************************************************************/

DECLARE 
  @v_IsOpen         BIT,
  @v_DocNum         INT,
  @v_BookKey        INT,
  @v_PrintingKey    INT,
  @v_ProjectKey     INT,
  @v_GlobalContactKey INT,
  @v_ProjectContactKey   INT,
  @v_RoleCode       INT,
  @v_DoDelete       INT,
  @v_UserID         VARCHAR(30),
  @v_TempKey        INT,
  @v_TempKeyName    VARCHAR(255),
  @v_KeyValue       VARCHAR(50),
  @v_BookContactKeyAsString varchar(50),
  @v_ProjectContactKeyAsString varchar(50)

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
      @v_ProjectKey = ProjectKey,
      @v_GlobalContactKey = GlobalContactKey,
      @v_ProjectContactKey = ProjectContactKey,
      @v_RoleCode = RoleCode,
      @v_DoDelete = DeleteOption,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKey int 'BookKey',
      PrintingKey int 'PrintingKey', 
      ProjectKey int 'ProjectKey',
      GlobalContactKey int 'GlobalContactKey',
      ProjectContactKey int 'ProjectContactKey',
      RoleCode int 'RoleCode',
      DeleteOption int 'DeleteOption',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qcontact_delete_tasks_xml.'
    GOTO ExitHandler
  END
  
--  print '**** DEBUG ***************************************'
--  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
--  PRINT 'printingkey=' + CAST(@v_PrintingKey AS VARCHAR)
--  PRINT 'globalcontactkey=' + CAST(@v_GlobalContactKey AS VARCHAR)
--  PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
--  PRINT 'projectcontactkey=' + CAST(@v_ProjectContactKey AS VARCHAR)  
--  PRINT 'rolecode=' + CAST(@v_RoleCode AS VARCHAR)
--  PRINT 'deleteoption=' + CAST(@v_DoDelete AS VARCHAR)
--  PRINT 'userid=' + @v_UserID
--  print '****************************************************'
  
  /** Call procedure that will delete Element and Task records **/
  EXEC qcontact_delete_tasks @v_BookKey, @v_PrintingKey, @v_GlobalContactKey,
                             @v_ProjectKey, @v_ProjectContactKey, @v_RoleCode, 
                             @v_UserID, @v_DoDelete, @o_error_code output, @o_error_desc output


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qcontact_delete_tasks_xml TO PUBLIC
GO
