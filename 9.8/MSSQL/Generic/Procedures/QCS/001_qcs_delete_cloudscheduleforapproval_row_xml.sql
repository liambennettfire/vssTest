SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_delete_cloudscheduleforapproval_row_xml')
  BEGIN
    PRINT 'Dropping Procedure qcs_delete_cloudscheduleforapproval_row_xml'
    DROP  Procedure  qcs_delete_cloudscheduleforapproval_row_xml
  END

GO

PRINT 'Creating Procedure qcs_delete_cloudscheduleforapproval_row_xml'
GO

CREATE PROCEDURE qcs_delete_cloudscheduleforapproval_row_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qcs_delete_cloudscheduleforapproval_row_xml
**  Desc: This stored procedure deletes a row from the cloudscheduleforapproval table.
**        
**
**  Auth: Kusum
**  Date: April 09 2013
**********************************************************************************************************/

BEGIN

  DECLARE 
    @v_IsOpen   BIT,
    @v_DocNum   INT,
    @v_BookKey  INT,
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
  SELECT @v_BookKey = BookKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKey VARCHAR(120) 'BookKey') 
     

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'qcs_delete_cloudscheduleforapproval_row_xml.'
    GOTO ExitHandler
  END


  EXEC qcs_delete_cloudscheduleforapproval_row @v_BookKey, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qcs_delete_cloudscheduleforapproval_row_xml TO PUBLIC
GO
