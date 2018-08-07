if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_assoctitles_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_create_assoctitles_xml
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_create_assoctitles_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_create_assoctitles_xml
**  Desc: Interface to make call to qtitle_create_assoctitles
**
**    Auth: Alan Katzen
**    Date: 3/2/06
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    03/29/2016   UK             Case 37241
*******************************************************************************/

DECLARE 
  @v_IsOpen                            BIT,
  @v_DocNum                            INT,
  @v_BookKeyAsString                   VARCHAR(255),
  @v_BookKey                           INT,
  @v_PrintingKeyAsString               VARCHAR(255),
  @v_PrintingKey                       INT,
  @v_AssocTypeCodeAsString             VARCHAR(255),
  @v_AssocTypeCode                     INT,
  @v_AssocTypeSubCodeAsString          VARCHAR(255),
  @v_AssocTypeSubCode                  INT,
  @v_ReverseAssocTypeCodeAsString      VARCHAR(255),
  @v_ReverseAssocTypeCode              INT,
  @v_ReverseAssocTypeSubCodeAsString   VARCHAR(255),
  @v_ReverseAssocTypeSubCode           INT,
  @v_ProductNumber                     VARCHAR(19),
  @v_ProductIdTypeAsString             VARCHAR(255),
  @v_ProductIdType                     INT,
  @v_AssocTitleBookKeyAsString         VARCHAR(255),
  @v_AssocTitleBookKeyName             VARCHAR(255),
  @v_AssocTitleBookKey                 INT,
  @v_UserID                            VARCHAR(30),
  @v_StopOnWarningAsString             VARCHAR(255),
  @v_StopOnWarning                     INT,
  @v_TempKey                           INT,
  @v_TempKeyName                       VARCHAR(255),
  @KeyNameIndex                        int,
  @ENDKeyIndex                         int,
  @v_SortOrderAsString                 VARCHAR(255),
  @v_SortOrder                         int,
  @v_ReleaseToEloquenceIndAsString     VARCHAR(255),  
  @v_ReleaseToEloquenceInd             int

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''

 --PRINT '---------- BEGIN CREATE ASSOCTITLES ---------------------------------'

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_BookKeyAsString = BookKeyAsString,
    @v_PrintingKeyAsString = PrintingKeyAsString,
    @v_AssocTypeCodeAsString = AssociationTypeCodeAsString,
    @v_AssocTypeSubCodeAsString = AssociationTypeSubCodeAsString,
    @v_ProductNumber = ProductNumber,
    @v_ProductIdTypeAsString = ProductIdTypeAsString,
    @v_AssocTitleBookKeyAsString = AssociateTitleBookKeyAsString,
    @v_UserID = UserID,
    @v_StopOnWarningAsString = StopOnWarningAsString,
    @v_ReverseAssocTypeCodeAsString = ReverseAssocTypeCodeAsString,
    @v_ReverseAssocTypeSubCodeAsString = ReverseAssocTypeSubCodeAsString,
    @v_SortOrderAsString = SortOrderAsString,
    @v_ReleaseToEloquenceIndAsString = ReleaseToEloquenceIndAsString    
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKeyAsString VARCHAR(255) 'BookKey', 
    PrintingKeyAsString VARCHAR(255) 'PrintingKey',
    AssociationTypeCodeAsString VARCHAR(255) 'AssociationTypeCode',
    AssociationTypeSubCodeAsString VARCHAR(255) 'AssociationTypeSubCode',
    ProductNumber VARCHAR(19) 'ProductNumber',
    ProductIdTypeAsString VARCHAR(255) 'ProductIdType',
    AssociateTitleBookKeyAsString VARCHAR(255) 'AssociateTitleBookKey',
    UserID VARCHAR(30) 'UserID',
    StopOnWarningAsString VARCHAR(255) 'StopOnWarning',
    ReverseAssocTypeCodeAsString VARCHAR(255) 'ReverseAssocTypeCode',
    ReverseAssocTypeSubCodeAsString VARCHAR(255) 'ReverseAssocTypeSubCode',
    SortOrderAsString VARCHAR(255) 'SortOrder',
    ReleaseToEloquenceIndAsString VARCHAR(255) 'ReleaseToEloquenceInd')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qtitle_create_assoctitles_xml.'
    GOTO ExitHandler
  END

  SET @v_PrintingKey = CONVERT(INT,@v_PrintingKeyAsString)
  SET @v_AssocTypeCode = CONVERT(INT,@v_AssocTypeCodeAsString)
  SET @v_AssocTypeSubCode = CONVERT(INT,@v_AssocTypeSubCodeAsString)
  SET @v_ProductIdType = CONVERT(INT,@v_ProductIdTypeAsString)
  SET @v_StopOnWarning = CONVERT(INT,@v_StopOnWarningAsString)
  SET @v_ReverseAssocTypeCode = CONVERT(INT,@v_ReverseAssocTypeCodeAsString)
  SET @v_ReverseAssocTypeSubCode = CONVERT(INT,@v_ReverseAssocTypeSubCodeAsString)
  SET @v_AssocTitleBookKey = CONVERT(INT, @v_AssocTitleBookKeyAsString)
  SET @v_SortOrder = CONVERT(INT,@v_SortOrderAsString)
  SET @v_ReleaseToEloquenceInd = CONVERT(INT,@v_ReleaseToEloquenceIndAsString)

  IF (@v_BookKeyAsString IS NOT NULL AND LEN(@v_BookKeyAsString) > 0 AND SUBSTRING(@v_BookKeyAsString,1,1) = '?') BEGIN
    IF (LEN(@v_BookKeyAsString) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_BookKeyAsString, 2, LEN(@v_BookKeyAsString) - 1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR(2000))
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR(2000))

    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_BookKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0) BEGIN
       SET @keys = @keys + @v_TempKeyName + ',' + @v_BookKeyAsString + ','
        IF @NewKeys IS NULL BEGIN
          SET @NewKeys = ''
        END
        SET @NewKeys = @NewKeys + @v_TempKeyName + ',' + @v_BookKeyAsString + ','
      END
    END
    ELSE BEGIN
      SET @v_BookKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_BookKey = CONVERT(INT, @v_BookKeyAsString)

--PRINT 'keys=' + CAST(@keys AS VARCHAR(2000))
--PRINT 'newkeys=' + CAST(COALESCE(@NewKeys,'') AS VARCHAR(2000))
--PRINT 'Bookkey=' + CAST(@v_BookKeyAsString AS VARCHAR(2000))
--PRINT 'ReverseAssocTypeCode=' + CAST(COALESCE(@v_ReverseAssocTypeCode,0) AS VARCHAR(2000))
--PRINT 'ReverseAssocTypeSubCode=' + CAST(COALESCE(@v_ReverseAssocTypeSubCode,0) AS VARCHAR(2000))
--PRINT '@v_ProductNumber=' + CAST(@v_ProductNumber AS VARCHAR(2000))

  -- Call procedure that will do the removal of the title relationship
  EXECUTE qtitle_create_assoctitles @v_BookKey,@v_PrintingKey,@v_AssocTypeCode,@v_AssocTypeSubCode,@v_ProductNumber,
                                    @v_ProductIdType,@v_UserID,@v_StopOnWarning,@v_ReverseAssocTypeCode,
                                    @v_ReverseAssocTypeSubCode,@v_SortOrder, @v_ReleaseToEloquenceInd, @v_AssocTitleBookKey output, 
                                    @o_error_code output,@o_error_desc output
  
--PRINT 'AssocTitleBookKey=' + CAST(@v_AssocTitleBookKey AS VARCHAR(2000))
--PRINT 'Error Desc=' + CAST(@o_error_desc AS VARCHAR(2000))
--PRINT 'keys=' + CAST(@keys AS VARCHAR(2000))
--PRINT 'newkeys=' + CAST(COALESCE(@NewKeys,'') AS VARCHAR(2000))
--PRINT '---------- END CREATE ASSOCTITLES ---------------------------------'
  
ExitHandler:

IF @v_IsOpen = 1 BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qtitle_create_assoctitles_xml TO PUBLIC
GO
