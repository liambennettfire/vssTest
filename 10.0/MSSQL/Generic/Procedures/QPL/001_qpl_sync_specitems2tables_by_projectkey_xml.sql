if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_sync_specitems2tables_by_projectkey_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_sync_specitems2tables_by_projectkey_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_sync_specitems2tables_by_projectkey_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_sync_specitems2tables_by_projectkey_xml
**  Desc: This stored procedure syncs the specifications section
**
**  Auth: Uday A. Khisty
**  Date: January 06 2015
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_VersionKey INT,
  @v_UserID VARCHAR(255)
  
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
      @v_VersionKey = PLVersion,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
      PLVersion int 'PLVersion',
      UserID VARCHAR(255) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_sync_specitems2tables_by_projectkey_xml.'
    GOTO ExitHandler
  END 

  /** Call actual procedure **/
  EXEC qpl_sync_specitems2tables_by_projectkey @v_ProjectKey, @v_VersionKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_sync_specitems2tables_by_projectkey_xml TO PUBLIC
GO
