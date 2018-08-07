SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_relate_specs_and_costs_xml')
  BEGIN
    PRINT 'Dropping Procedure qpl_relate_specs_and_costs_xml'
    DROP  Procedure  qpl_relate_specs_and_costs_xml
  END

GO

PRINT 'Creating Procedure qpl_relate_specs_and_costs_xml'
GO

CREATE PROCEDURE qpl_relate_specs_and_costs_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qpl_relate_specs_and_costs_xml
**  Desc: This stored procedure will relate the specs and costs from one project to another.
**        
**
**  Auth: Kusum
**  Date: March 26 2013
**********************************************************************************************************/

BEGIN

  DECLARE 
    @v_IsOpen   BIT,
    @v_DocNum   INT,
    @v_current_projkey  INT,
    @v_related_projkey INT,
    @v_vendorkey INT
  
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
  SELECT @v_current_projkey = current_projkey,
      @v_related_projkey = related_projkey,
      @v_vendorkey = vendorkey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (current_projkey VARCHAR(120) 'current_projkey', 
      related_projkey VARCHAR(120) 'related_projkey',
      vendorkey VARCHAR(120) 'vendorkey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'qpl_relate_specs_and_costs_xml.'
    GOTO ExitHandler
  END
  
  EXEC qpl_relate_specs_and_costs @v_current_projkey, @v_related_projkey, @v_vendorkey, @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qpl_relate_specs_and_costs_xml TO PUBLIC
GO
