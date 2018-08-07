if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_version_royalties_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_version_royalties_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_delete_version_royalties_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: qpl_delete_version_royalties_xml
**  Desc: Deletes all royalty rows for all formats of a PL Version for a particular roletypecode/globalcontactkey
**  Case: 42178
**
**  Auth: Colman
**  Date: January 13 2017
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date      Author      Description
**	--------  ----------  -----------------------
***********************************************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_PLStage  INT,
  @v_PLVersion INT,
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
  SELECT  @v_ProjectKey = ProjectKey,
          @v_PLStage = PLStage,
          @v_PLVersion = PLVersion,
          @v_RoleCode = RoleCode,
          @v_ContactKey = ContactKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey INT 'ProjectKey', 
      PLStage INT 'PLStage',
      PLVersion INT 'PLVersion',
      RoleCode INT 'RoleCode',
      ContactKey INT 'ContactKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_delete_version_royalties_xml.'
    GOTO ExitHandler
  END

  /** Call actual procedure **/
  EXEC qpl_delete_version_royalties @v_ProjectKey, @v_PLStage, @v_PLVersion, @v_RoleCode, @v_ContactKey, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_delete_version_royalties_xml TO PUBLIC
GO
