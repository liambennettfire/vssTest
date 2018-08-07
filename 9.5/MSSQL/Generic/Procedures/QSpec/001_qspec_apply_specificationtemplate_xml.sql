if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_apply_specificationtemplate_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_apply_specificationtemplate_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qspec_apply_specificationtemplate_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qspec_apply_specificationtemplate_xml
**  Desc: This stored procedure applies the P&L spec items for given version/format.
**       @@v_ActionValue = 1 - Overwrite Existing data
**				         = 2 - Leave Existing Data, Add New Values
**
**  Auth: Uday A. Khisty
**  Date: June 08 2014
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,   
  @v_SpecificationTemplateKey INT,  
  @v_TaqProjectFormatKey INT,
  @v_ItemType     INT,
  @v_UsageClass   INT,
  @v_UserID        VARCHAR(30),
  @v_ActionValue INT 
    
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
		 @v_SpecificationTemplateKey = SpecificationTemplateKey,  
		 @v_TaqProjectFormatKey = TaqProjectFormatKey,		 
		 @v_ItemType = ItemType,
		 @v_UsageClass = UsageClass,
		 @v_UserID = UserID,
		 @v_ActionValue = ActionValue		 		 		 
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
        SpecificationTemplateKey int 'SpecificationTemplateKey', 
        TaqProjectFormatKey int 'TaqProjectFormatKey',
        ItemType int 'ItemType',
        UsageClass int 'UsageClass',
        UserID varchar(30) 'UserID',        
        ActionValue int 'ActionValue')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qspec_apply_specificationtemplate_xml.'
    GOTO ExitHandler
  END 

  /** Call actual procedure **/
  EXEC qspec_apply_specificationtemplate @v_ProjectKey, @v_SpecificationTemplateKey
    ,@v_TaqProjectFormatKey, @v_ItemType, @v_UsageClass, @v_UserID,@v_ActionValue, @o_error_code OUTPUT, @o_error_desc OUTPUT


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qspec_apply_specificationtemplate_xml TO PUBLIC
GO
