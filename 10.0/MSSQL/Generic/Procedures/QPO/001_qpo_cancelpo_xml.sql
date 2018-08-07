IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_cancelpo_xml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_cancelpo_xml]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qpo_cancelpo_xml]
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output, 
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************
**  Name: qpo_cancelpo_xml
**  Desc: This stored procedure Auto generate 'Cancelled' date on PO summary
**         and changes status on every 'Pending' PO report to 'Cancelled'
**
**  Auth: Uday A. Khisty
**  Date: 21 November 2014
**************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey	INT,
  @v_UserID		VARCHAR(30)

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
  SELECT @v_ProjectKey = ProjectKey,
		 @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey INT 'ProjectKey', 
        UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qpo_cancelpo_xml.'
    GOTO ExitHandler
  END
  
  -- Call the procedure  
  EXEC qpo_cancelpo @v_ProjectKey, @v_UserID, @o_error_code output, @o_error_desc output
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
GO

GRANT EXEC on qpo_cancelpo_xml TO PUBLIC
GO