if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_sync_deleted_specitem2table_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_sync_deleted_specitem2table_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_sync_deleted_specitem2table_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_sync_deleted_specitem2table_xml
**  Desc: This stored procedure syncs the specifications section for any deleted spec items
**
**  Auth: Kusum Basra
**  Date: October 01 2015
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_SpecItemCategoryKey INT,
  @v_SpecItemKey	INT,
  @v_Key1			INT,
  @v_Key2			INT,
  @v_ProjectKey		INT,
  @v_UsageClass		INT,
  @v_ItemType		INT,
  @v_VersionKey     INT,
  @v_UserID         VARCHAR(255)
  
  SET NOCOUNT ON
  --print '3'
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
  SELECT @v_SpecItemCategoryKey = SpecItemCategoryKey,
	  @v_SpecItemKey = SpecItemKey,
	  @v_Key1 = Key1,
      @v_Key2 = Key2,
      @v_ProjectKey = ProjectKey,
      @v_UsageClass = UsageClass,
      @v_ItemType = ItemType,
      @v_VersionKey = VersionKey,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (SpecItemCategoryKey int 'SpecItemCategoryKey',
      SpecItemKey int 'SpecItemKey',
      Key1 int 'Key1',
      Key2 int 'Key2',
	  ProjectKey int 'ProjectKey', 
	  UsageClass int 'UsageClass',
	  ItemType int 'ItemType',
      VersionKey int 'VersionKey',
      UserID VARCHAR(255) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_sync_specitems2tables_by_projectkey_xml.'
    GOTO ExitHandler
  END 

  --print '2'
  /** Call actual procedure **/
  EXEC qpl_sync_deleted_specitem2table @v_SpecItemCategoryKey, @v_SpecItemKey, @v_Key1, @v_Key2, @v_ProjectKey, @v_UsageClass, @v_ItemType, @v_VersionKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT

ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_sync_deleted_specitem2table_xml TO PUBLIC
GO
