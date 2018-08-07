IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_update_task_owners_xml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_update_task_owners_xml]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_update_task_owners_xml]
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output, 
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************
**  Name: qproject_update_task_owners_xml
**  Desc: This stored procedure updates the globalcontactkeys on the tasks
**          contained in the string sent in.
**
**  Auth: Lisa
**  Date: 18 October 2008
**************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_TaskList varchar(8000)

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
  SELECT @v_TaskList = TaskList
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (TaskList VARCHAR(max) 'TaskList')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_update_task_owners_xml.'
    GOTO ExitHandler
  END

  -- Call the procedure  
  EXEC qproject_update_task_owners @v_TaskList, @o_error_code output, @o_error_desc output
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
GO

GRANT EXEC on qproject_update_task_owners_xml TO PUBLIC
GO