
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_verify_or_add_author_related_role_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_verify_or_add_author_related_role_xml
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_verify_or_add_author_role_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_verify_or_add_author_role_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_verify_or_add_author_role_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_verify_or_add_author_role_xml
**  Desc: This stored procedure verifies that 
**        the role associated with the author type is present on the contact
**        and if it is not, it is added to the contact. It's interface is the
**        standard XML parameter interface that can be called via the 
**        pre-defined interface mechanism.
**
**    Auth: James Weber
**    Date: 21 June 2004
**    
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
  
  DECLARE @contactkey int
  DECLARE @author_role_type int
  
    SELECT @contactkey = ContactKey, @author_role_type = AuthorRoleType
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (ContactKey int 'ContactKey', AuthorRoleType int 'AuthorRoleType')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Contact Roll and author type from xml parameters.'
    GOTO ExitHandler
  END

  print @contactkey
  print @author_role_type


exec qcontact_verify_or_add_author_role @contactkey, @author_role_type, @o_error_code output, @o_error_desc output

ExitHandler:

if @IsOpen = 1
BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
    

END


GO
GRANT EXEC ON qcontact_verify_or_add_author_role_xml TO PUBLIC
GO


