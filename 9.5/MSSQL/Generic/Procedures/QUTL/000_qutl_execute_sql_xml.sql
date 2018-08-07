if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_execute_sql_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_execute_sql_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_execute_sql_xml
 (@xmlParameters     varchar(max),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_execute_sql_xml
**  Desc: This stored procedure executes dynamic SQL string.
**
**  Auth: Kate Wiewiora
**  Date: 8/1/08
*******************************************************************************/

DECLARE 
  @v_IsOpen       BIT,
  @v_DocNum       INT,
  @v_SQLString    VARCHAR(max)

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_SQLString = SQLString
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (SQLString VARCHAR(max) 'SQLString')

  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qutl_execute_sql_xml.'
    GOTO ExitHandler
  END 
   
  EXEC qutl_execute_sql @v_SQLString, @o_error_code OUTPUT, @o_error_desc OUTPUT

ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qutl_execute_sql_xml TO PUBLIC
GO
