if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_sync_version_to_acq_project_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_sync_version_to_acq_project_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_sync_version_to_acq_project_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_sync_version_to_acq_project_xml
**  Desc: This stored procedure syncs selected P&L Version to Acquisiton Project
**        Formats, selected comments and selected categories will be synced.  
**
**  Auth: Uday A. Khisty
**  Date: May 08 2014
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_PLStageCode  INT,
  @v_VersionKey INT,
  @v_UserKey INT,
  @v_Copy_Select_Data_From_Pl_To_Acq_Project INT    
  
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
      @v_PLStageCode = PLStage,
      @v_VersionKey = PLVersion,
      @v_UserKey = UserKey,
      @v_Copy_Select_Data_From_Pl_To_Acq_Project = CopySelectData
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
      PLStage int 'PLStage',
      PLVersion int 'PLVersion',
      UserKey int 'UserKey',
	  CopySelectData int 'CopySelectData' )

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_sync_version_to_acq_project_xml.'
    GOTO ExitHandler
  END 

  /** Call actual procedure **/
  EXEC qpl_sync_version_to_acq_project @v_ProjectKey, @v_PLStageCode,
    @v_VersionKey, @v_UserKey, @v_Copy_Select_Data_From_Pl_To_Acq_Project, @o_error_code OUTPUT, @o_error_desc OUTPUT


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_sync_version_to_acq_project_xml TO PUBLIC
GO
