if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_reciprocal_relationship_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_reciprocal_relationship_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_reciprocal_relationship_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @NewKeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_reciprocal_relationship_xml
**  Desc: Interface to make call to qtitle_reciprocal_relationship
**
**  Auth: Kate Wiewiora
**  Date: 9/21/09
*******************************************************************************/

DECLARE 
  @v_IsOpen                            BIT,
  @v_DocNum                            INT,
  @v_Action                            VARCHAR(1),
  @v_AuthorKeyAsString                 VARCHAR(255),
  @v_AuthorKey                         INT,
  @v_BookKeyAsString                   VARCHAR(255),
  @v_BookKey                           INT,
  @v_AssocTypeCodeAsString             VARCHAR(255),
  @v_AssocTypeCode                     INT,
  @v_AssocTypeSubCodeAsString          VARCHAR(255),
  @v_AssocTypeSubCode                  INT,
  @v_ProductIdTypeAsString             VARCHAR(255),
  @v_ProductIdType                     INT,
  @v_AssocTitleBookKeyAsString         VARCHAR(255),
  @v_AssocTitleBookKey                 INT,
  @v_UserID                            VARCHAR(30),
  @v_TempKey                           INT,
  @v_TempKeyName                       VARCHAR(255),
  @KeyNameIndex                        int,
  @ENDKeyIndex                         int,
  @v_lastuserid						   varchar(30)

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
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
  SELECT @v_BookKeyAsString = BookKeyAsString,
    @v_AssocTitleBookKeyAsString = AssociateTitleBookKeyAsString,
    @v_AssocTypeCodeAsString = AssociationTypeCodeAsString,
    @v_AssocTypeSubCodeAsString = AssociationTypeSubCodeAsString,
    @v_ProductIdTypeAsString = ProductIdTypeAsString,
    @v_Action = Action,
    @v_AuthorKeyAsString = AuthorKeyAsString,
    @v_lastuserid = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (BookKeyAsString VARCHAR(255) 'BookKey', 
    AssociateTitleBookKeyAsString VARCHAR(255) 'AssociateTitleBookKey',
    AssociationTypeCodeAsString VARCHAR(255) 'AssociationTypeCode',
    AssociationTypeSubCodeAsString VARCHAR(255) 'AssociationTypeSubCode',
    ProductIdTypeAsString VARCHAR(255) 'ProductIdType',
    Action VARCHAR(1) 'Action',
    AuthorKeyAsString VARCHAR(255) 'AuthorKey',
    UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qtitle_reciprocal_relationship_xml.'
    GOTO ExitHandler
  END

  SET @v_AssocTitleBookKey = CONVERT(INT, @v_AssocTitleBookKeyAsString)
  SET @v_AssocTypeCode = CONVERT(INT,@v_AssocTypeCodeAsString)
  SET @v_AssocTypeSubCode = CONVERT(INT,@v_AssocTypeSubCodeAsString)
  SET @v_ProductIdType = CONVERT(INT,@v_ProductIdTypeAsString)
  SET @v_AuthorKey = CONVERT(INT,@v_AuthorKeyAsString)

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

  -- Call procedure that will do the removal of the title relationship
  EXECUTE qtitle_reciprocal_relationship @v_BookKey, @v_AssocTitleBookKey, @v_AssocTypeCode, @v_AssocTypeSubCode,
      @v_ProductIdType, @v_Action, @v_AuthorKey, @v_lastuserid ,@o_error_code OUTPUT,@o_error_desc OUTPUT
   
ExitHandler:

IF @v_IsOpen = 1 BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qtitle_reciprocal_relationship_xml TO PUBLIC
GO
