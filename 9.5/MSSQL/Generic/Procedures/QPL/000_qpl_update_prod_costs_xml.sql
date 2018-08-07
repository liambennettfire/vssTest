if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_prod_costs_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_prod_costs_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_update_prod_costs_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qpl_update_prod_costs
**  Desc: This stored procedure maintains production costs for the associated P&L Version/Format/Year
**        based on new production quantity or percentage.
**
**  Auth: Kate
**  Date: March 21 2008
**********************************************************************************************************/

BEGIN

  DECLARE 
    @v_IsOpen   BIT,
    @v_DocNum   INT,
    @v_FormatYearKey  INT,
    @v_NewPercent FLOAT,    
    @v_NewQuantity  INT,
    @v_PrintingNumber INT,
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
  SELECT @v_FormatYearKey = FormatYearKey,
      @v_NewQuantity = NewQuantity,
      @v_NewPercent = NewPercent,
      @v_PrintingNumber = PrintingNumber,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (FormatYearKey VARCHAR(120) 'FormatYearKey', 
      NewQuantity INT 'NewQuantity',
      NewPercent FLOAT 'NewPercent',
      PrintingNumber INT 'PrintingNumber',
      UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpl_update_prod_costs_xml.'
    GOTO ExitHandler
  END


  EXEC qpl_update_prod_costs @v_FormatYearKey, @v_NewQuantity, @v_NewPercent, @v_PrintingNumber,
    @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qpl_update_prod_costs_xml TO PUBLIC
GO
