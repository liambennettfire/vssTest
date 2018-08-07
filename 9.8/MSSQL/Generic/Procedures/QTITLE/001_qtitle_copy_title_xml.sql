if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_title_addtl_info_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_title_addtl_info_xml 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_title_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_title_xml 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_title_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_title_xml 
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_title_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_copy_title_xml
**  Desc: This stored procedure will copy information from a template 
**        to a new title during the creation process.
**
**  Auth: Kate Wiewiora
**  Date: 26 May 2009
*******************************************************************************/

  DECLARE 
    @v_Bookkey  INT,
    @v_Bookkey_String   VARCHAR(120),
    @v_CopyDataGroupsList   VARCHAR(255),
    @v_ClearDataGroupsList   VARCHAR(255),
    @v_DocNum   INT,
    @v_IsOpen   BIT,
    @v_Printingkey  INT,
    @v_TempKey INT,
    @v_TempKeyName VARCHAR(255),
    @v_TemplateBookkey    INT,
    @v_TemplatePrintingkey  INT,
    @v_Titleprefix  VARCHAR(15),
    @v_Userid   VARCHAR(30)
	  

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
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
  SELECT @v_Bookkey_String = BookKey, @v_Printingkey = PrintingKey,
    @v_TemplateBookkey = TemplateBookKey, @v_TemplatePrintingkey = TemplatePrintingKey,
    @v_CopyDataGroupsList = CopyDataGroupsList, @v_ClearDataGroupsList = ClearDataGroupsList,
    @v_Userid = UserId, @v_Titleprefix = TitlePrefix
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKey varchar(120) 'bookkey', PrintingKey int 'printingkey',
    TemplateBookKey int 'templatebookkey', TemplatePrintingKey int 'templateprintingkey',
    CopyDataGroupsList VARCHAR(2000) 'CopyDataGroupsList', ClearDataGroupsList VARCHAR(2000) 'ClearDataGroupsList',    
    Userid varchar(30) 'userid', TitlePrefix varchar(15) 'titleprefix')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Title Information from xml parameters.'
    GOTO ExitHandler
  END


  /* bookkey may have been generated (new title) */
  if (@v_Bookkey_String is not null and LEN(@v_Bookkey_String) > 0 and SUBSTRING(@v_Bookkey_String, 1, 1) = '?')
  BEGIN
    IF (LEN(@v_Bookkey_String) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_Bookkey_String, 2, LEN(@v_Bookkey_String) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
    END
    
  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)
    
    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_Bookkey_String = CONVERT(VARCHAR(120), @v_TempKey)
      
      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @KeyNamePairs = @KeyNamePairs + @v_TempKeyName + ',' + @v_Bookkey_String + ','
        IF @newkeys is null BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_Bookkey_String + ','
      END
    END
    ELSE BEGIN
      SET @v_Bookkey_String = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_Bookkey = CONVERT(INT, @v_Bookkey_String)

  /** Call procedure that will do the copy title **/
  EXEC qtitle_copy_title @v_Bookkey, @v_Printingkey, @v_TemplateBookkey, @v_TemplatePrintingkey, 
          @v_CopyDataGroupsList, @v_ClearDataGroupsList, @v_Userid, @v_Titleprefix, @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  if @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

GO

GRANT EXEC ON qtitle_copy_title_xml TO PUBLIC
GO
