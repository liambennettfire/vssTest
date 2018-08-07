if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_bookcomment_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_bookcomment_xml 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_bookcomment_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_bookcomment_xml
**  Desc: This stored procedure will copy bookcomments record from one title to another.
**
**  Auth: Kate Wiewiora
**  Date: 3 August 2012
************************************************************************************************/


  DECLARE 
    @v_FromBookkey  INT,
    @v_NewBookkey   INT,
    @v_CommentType  INT,
    @v_CommentSubType INT,
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
  SELECT @v_NewBookkey = NewBookKey, @v_FromBookKey = FromBookKey, 
    @v_CommentType = CommentTypeCode, @v_CommentSubType = CommentTypeSubCode
  FROM OPENXML(@v_DocNum, 'Parameters')
  WITH (NewBookKey int 'NewBookKey', FromBookKey int 'FromBookKey', 
    CommentTypecode int 'CommentTypeCode', CommentTypeSubCode int 'CommentTypeSubCode')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Comment keys from xml parameters.'
    GOTO ExitHandler
  END

  EXEC qtitle_copy_bookcomment @v_NewBookkey, @v_FromBookkey, @v_CommentType, @v_CommentSubType,
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  if @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

GO

GRANT EXEC ON qtitle_copy_bookcomment_xml TO PUBLIC
GO