if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_verify_or_add_globalcontact_role_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_verify_or_add_globalcontact_role_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_verify_or_add_globalcontact_role_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_verify_or_add_globalcontact_role_xml
**  Desc: This stored procedure verifies that 
**        the role is present on the contact
**        and if not, adds it to the contact.
**
**  Auth: Colman
**  Date: 11/21/2016
*******************************************************************************/

  DECLARE 
	@IsOpen			BIT,
	@DocNum			INT

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END
  
  
  SET @IsOpen = 1
  
  DECLARE @v_globalcontactkey int
  DECLARE @v_rolecode int
  DECLARE @v_userid varchar(30)
  
  SELECT @v_globalcontactkey = GlobalContactKey, @v_rolecode = RoleCode, @v_userid = UserID 
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (GlobalContactKey int 'GlobalContactKey', RoleCode int 'RoleCode', UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Contact Role from xml parameters.'
    GOTO ExitHandler
  END

  exec qcontact_verify_or_add_globalcontact_role @v_globalcontactkey, @v_rolecode, @v_userid, @o_error_code output, @o_error_desc output

ExitHandler:

if @IsOpen = 1
BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
END

GO
GRANT EXEC ON qcontact_verify_or_add_globalcontact_role_xml TO PUBLIC
GO


