if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_pl_items_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_pl_items_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_recalc_pl_items_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_recalc_pl_items_xml
**  Desc: This stored procedure recalculates all p&l summary items for the given level.
**
**  Auth: Kate
**  Date: October 4 2012
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_PLStageCode  INT,
  @v_VersionKey INT,
  @v_YearCode INT,
  @v_UserID VARCHAR(30),
  @v_TempKey  INT,
  @v_TempKeyName  VARCHAR(255),
  @v_KeyValue VARCHAR(50)  
  
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
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey VARCHAR(120) 'ProjectKey', 
      PLStage int 'PLStage',
      PLVersion int 'PLVersion',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_recalc_pl_items_xml.'
    GOTO ExitHandler
  END 

  /** Call actual procedure **/
  EXEC qpl_recalc_pl_items @v_ProjectKey, @v_PLStageCode,
    @v_VersionKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qpl_recalc_pl_items_xml TO PUBLIC
GO
