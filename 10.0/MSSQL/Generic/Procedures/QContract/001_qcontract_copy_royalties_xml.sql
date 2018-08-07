if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_copy_royalties_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_copy_royalties_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_copy_royalties_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qcontract_copy_royalties_xml
**  Desc: Copies all royalty rows for all formats for a particular roletypecode/globalcontactkey
**
**  Auth: Colman
**  Date: January 13 2017
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_FromRoleCode INT,
  @v_FromContactKey INT,
  @v_RoleCode INT,
  @v_ContactKey INT,
  @v_UserID VARCHAR(30)
  
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
      @v_FromRoleCode = FromRoleCode,
      @v_FromContactKey = FromContactKey,
      @v_RoleCode = RoleCode,
      @v_ContactKey = ContactKey,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey INT 'ProjectKey', 
      FromRoleCode INT 'FromRoleCode',
      FromContactKey INT 'FromContactKey',
      RoleCode INT 'RoleCode',
      ContactKey INT 'ContactKey',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qcontract_copy_royalties_xml.'
    GOTO ExitHandler
  END

  /** Call actual procedure **/
  EXEC qcontract_copy_royalties @v_ProjectKey, @v_FromRoleCode, @v_FromContactKey, @v_RoleCode, @v_ContactKey, 
          @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qcontract_copy_royalties_xml TO PUBLIC
GO
