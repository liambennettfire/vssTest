if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_reuse_ean_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
print 'Dropping dbo.qean_reuse_ean_xml'
drop procedure dbo.qean_reuse_ean_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qean_reuse_ean_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qean_reuse_ean_xml
**  Desc: This stored procedure calls the qean_reuse_ean stored procedure
**        as part of a generalized transaction.
**
**        @ean_prefix_code   int, 
**        @isbn_prefix_code  int,
**        @ean_with_dashes   varchar(50),
**
**    Auth: James Weber
**    Date: 08 Sep 2004
**    
*******************************************************************************/

  DECLARE 
	@IsOpen			BIT,
	@DocNum			INT

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END
  
  
  SET @IsOpen = 1
  
  DECLARE @ean_prefix_code   int
  DECLARE @isbn_prefix_code  int
  DECLARE @ean_with_dashes   varchar(50)
  
    SELECT @ean_prefix_code = EanPrefixCode, @isbn_prefix_code = IsbnPrefixCode, @ean_with_dashes = EanWithDashes 
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (EanPrefixCode int 'EanPrefixCode', IsbnPrefixCode int 'IsbnPrefixCode', EanWithDashes varchar(50) 'EanWithDashes')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting reuse information from xml parameters.'
    GOTO ExitHandler
  END

  --print @ean_prefix_code
  --print @isbn_prefix_code
  --print @ean_with_dashes


  exec dbo.qean_reuse_ean @ean_prefix_code, @isbn_prefix_code, @ean_with_dashes, @o_error_code output, @o_error_desc output

ExitHandler:

if @IsOpen = 1
BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
END


GO
GRANT EXEC ON qean_reuse_ean_xml TO PUBLIC
GO


