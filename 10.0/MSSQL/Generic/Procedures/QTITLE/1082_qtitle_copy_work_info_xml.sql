if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_work_info_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_work_info_xml 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_work_info_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_copy_work_info_xml
**  Desc: This stored procedure will copy work information from one 
**        title to another title (propagate).
**
**    Auth: Alan Katzen
**    Date: 30 July 2009
*******************************************************************************/

  DECLARE 
	  @IsOpen			BIT,
	  @DocNum			INT

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
--print @xmlParameters
--print @KeyNamePairs     

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END
  
  SET @IsOpen = 1
  
  DECLARE @bookkey_from            int,
          @bookkey_to              int,
          @bookkey_to_string       varchar(120),
          @tablename               varchar(100),
          @columnname              varchar(100),
          @userid                  varchar(30)
   
  SELECT @bookkey_from = BookKeyFrom, @bookkey_to_string = BookKeyTo,
    @tablename = TableName, @columnname = ColumnName, @userid = UserId
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (BookKeyFrom int 'bookkeyfrom', BookKeyTo varchar(120) 'bookkeyto',
    TableName int 'tablename', ColumnName int 'columnname',
    Userid varchar(30) 'userid')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Title Information from xml parameters.'
    GOTO ExitHandler
  END

--  print 'Bookkey From: ' + cast(@bookkey_from AS VARCHAR)
--  print 'Bookkey To String: ' + @bookkey_to_string
--  print 'Table Name: ' + @tablename
--  print 'Column Name: ' + @columnname
--  print 'Userid: ' + @userid

  /* bookkey_to may have been generated (new title) */
  if (@bookkey_to_string is not null and LEN(@bookkey_to_string) > 0 and SUBSTRING(@bookkey_to_string, 1, 1) = '?')
  BEGIN
    DECLARE @TempKey int
    DECLARE @TempKeyName varchar(256)
    SET @TempKey = 0
    SET @TempKeyName = ''

    IF (LEN(@bookkey_to_string) > 1)
    BEGIN
      SET @TempKeyName = SUBSTRING(@bookkey_to_string, 2, LEN(@bookkey_to_string) -1)
      SET @TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @TempKeyName)
    END
    --SET @KeyName = SUBSTRING(@KeyValue 
    IF (@TempKey = 0)
    BEGIN
      exec next_generic_key @UserID, @TempKey output, @o_error_code output, @o_error_desc
      SET @bookkey_to_string = CONVERT(varchar(120), @TempKey)
      IF (LEN(@TempKeyName) > 0)
      BEGIN
        SET @KeyNamePairs = @KeyNamePairs + @TempKeyName + ',' + @bookkey_to_string + ','
        IF @newkeys is null BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @TempKeyName + ',' + @bookkey_to_string + ','
      END
    END
    ELSE BEGIN
      SET @bookkey_to_string = CONVERT(varchar(120), @TempKey)
    END
  END

  SET @bookkey_to = CONVERT(int, @bookkey_to_string)
  --print 'Bookkey To: ' + cast(@bookkeyto AS VARCHAR)

  EXECUTE copy_work_info @bookkey_from,@bookkey_to,@tablename,@columnname

  ExitHandler:

  if @IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
  END

GO

GRANT EXEC ON qtitle_copy_work_info_xml TO PUBLIC
GO
