if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_prod_chargecode_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_prod_chargecode_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_delete_prod_chargecode_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qpl_delete_prod_chargecode_xml
**  Desc: This stored procedure deletes chargecode costs for ALL printings for given P&L Version/Format - 
**        the 2 visible printings on Production Costs by Printing page, and all other printings.
**
**  Auth: Kate
**  Date: March 21 2008
**************************************************************************************************/

BEGIN

  DECLARE 
    @v_IsOpen   BIT,
    @v_DocNum   INT,
    @v_ProjectKey INT,
    @v_PLStageCode  INT,
    @v_VersionKey INT,
    @v_FormatKey  INT,
    @v_ChargeCode INT
      
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
      @v_FormatKey = TaqProjectFormatKey,
      @v_ChargeCode = ChargeCode
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey VARCHAR(120) 'ProjectKey', 
      PLStage int 'PLStage',
      PLVersion int 'PLVersion',
      TaqProjectFormatKey int 'TaqProjectFormatKey',
      ChargeCode int 'ChargeCode')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_delete_prod_chargecode_xml.'
    GOTO ExitHandler
  END


  EXEC qpl_delete_prod_chargecode @v_ProjectKey, @v_PLStageCode, @v_VersionKey, @v_FormatKey, 
    @v_ChargeCode, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qpl_delete_prod_chargecode_xml TO PUBLIC
GO
