if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_other_printings_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_other_printings_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_update_other_printings_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qpl_update_other_printings_xml
**  Desc: This stored procedure maintains the printings other than the 2 visible printings on 
**        the Production Costs by Printing page - this stored procedure must be called separately 
**        but as part of the same transaction when the values for the 2 visible printing columns are updated.
**
**  Auth: Kate
**  Date: March 19 2008
**************************************************************************************************/

BEGIN

  DECLARE 
    @v_IsOpen   BIT,
    @v_DocNum   INT,
    @v_ProjectKey INT,
    @v_PLStageCode  INT,
    @v_VersionKey INT,
    @v_FormatKey  INT,
    @v_ChargeCode INT,
    @v_FromPrinting INT,
    @v_NewCalcTypeValue INT,
    @v_NewNote VARCHAR(2000),
    @v_UserID VARCHAR(30),
    @v_plcalccostsubcode INT,
    @v_taqversionspeccategorykey INT
  
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
      @v_ChargeCode = ChargeCode,
      @v_FromPrinting = FromPrinting,
      @v_NewCalcTypeValue = NewCalcTypeValue,
      @v_NewNote = NewNote,
      @v_UserID = UserID,
      @v_plcalccostsubcode = plcalccostsubcode,
      @v_taqversionspeccategorykey = taqversionspeccategorykey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey VARCHAR(120) 'ProjectKey', 
      PLStage int 'PLStage',
      PLVersion int 'PLVersion',
      TaqProjectFormatKey int 'TaqProjectFormatKey',
      ChargeCode int 'ChargeCode',
      FromPrinting int 'FromPrinting',
      NewCalcTypeValue int 'NewCalcTypeValue',
      NewNote varchar(2000) 'NewNote',
      UserID varchar(30) 'UserID',
      plcalccostsubcode int 'plcalccostsubcode',
      taqversionspeccategorykey int 'taqversionspeccategorykey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_update_other_printings_xml.'
    GOTO ExitHandler
  END


  EXEC qpl_update_other_printings @v_ProjectKey, @v_PLStageCode, @v_VersionKey, @v_FormatKey, @v_ChargeCode,
    @v_FromPrinting, @v_NewCalcTypeValue, @v_NewNote, @v_UserID, @v_plcalccostsubcode, @v_taqversionspeccategorykey,
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  
  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qpl_update_other_printings_xml TO PUBLIC
GO
