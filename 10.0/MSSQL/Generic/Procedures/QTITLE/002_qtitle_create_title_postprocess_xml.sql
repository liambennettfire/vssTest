if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_title_postprocess_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_title_postprocess_xml 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_create_title_postprocess_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_create_title_postprocess_xml
**  Desc: 
**  Case: 48528
**
**  Auth: Colman
**  Date: 12/1/2017
************************************************************************************************/


  DECLARE 
    @v_BookKey  INT,
    @v_DocNum   INT,
    @v_IsOpen   BIT

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
  SELECT @v_BookKey = BookKey
  FROM OPENXML(@v_DocNum, 'Parameters')
  WITH (BookKey int 'BookKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting book key from xml parameters.'
    GOTO ExitHandler
  END

  EXEC qtitle_create_title_postprocess @v_BookKey, @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  if @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

GO

GRANT EXEC ON qtitle_create_title_postprocess_xml TO PUBLIC
GO