if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qse_check_private_status_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qse_check_private_status_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qse_check_private_status_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output, 
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************
**  Name: qse_check_private_status_xml
**  Desc: This stored procedure checks the private status of a given list.
**        If the list is private, it removes it from any existing lists of lists
**        for users other than the list owner and any people on his/her private team.
**
**  Auth: Kate
**  Date: 18 October 2006
**************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ListKey  INT,
  @v_PrivateInd TINYINT

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_ListKey = ListKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ListKey INT 'ListKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qse_check_private_status_xml.'
    GOTO ExitHandler
  END

  -- Call the procedure  
  EXEC qse_check_private_status @v_ListKey, @v_PrivateInd output,
    @o_error_code output, @o_error_desc output
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qse_check_private_status_xml TO PUBLIC
GO
