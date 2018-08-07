SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_update_bookdetail_csmetadatastatuscode_xml')
  BEGIN
    PRINT 'Dropping Procedure qtitle_update_bookdetail_csmetadatastatuscode_xml'
    DROP  Procedure  qtitle_update_bookdetail_csmetadatastatuscode_xml
  END

GO

PRINT 'Creating Procedure qtitle_update_bookdetail_csmetadatastatuscode_xml'
GO

CREATE PROCEDURE qtitle_update_bookdetail_csmetadatastatuscode_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qtitle_update_bookdetail_csmetadatastatuscode_xml
**  Desc: This stored procedure resends title.
**        
**
**  Auth: Uday
**  Date: November 05 2013
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
  SELECT @v_BookKey = BookKey,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKey VARCHAR(120) 'BookKey', 
      UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'qtitle_update_bookdetail_csmetadatastatuscode_xml.'
    GOTO ExitHandler
  END


  EXEC qtitle_update_bookdetail_csmetadatastatuscode @v_BookKey, @v_UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT

  
  ExitHandler:

  IF @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

END
GO

GRANT EXEC ON qtitle_update_bookdetail_csmetadatastatuscode_xml TO PUBLIC
GO
