if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_set_default_template_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_set_default_template_xml 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_set_default_template_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_set_default_template_xml
**  Desc: This sets the default Template indicator for a title.
**
**    Auth: Alan Katzen
**    Date: 18 September 2009
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
  
  DECLARE @new_template_bookkey           int,
          @new_template_bookkey_string    varchar(120),
          @old_template_bookkey           int,
          @userid                         varchar(30)
   
  SELECT @new_template_bookkey_string = NewTemplateBookkey, 
         @old_template_bookkey = OldTemplateBookkey, @userid = UserId
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (NewTemplateBookkey varchar(120) 'new_template_bookkey', 
        OldTemplateBookkey int 'old_template_bookkey', Userid varchar(30) 'userid')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Title Information from xml parameters.'
    GOTO ExitHandler
  END

--  print 'New Template Bookkey String: ' + @new_template_bookkey_string
--  print 'Old Template Bookkey: ' + cast(@old_template_bookkey AS VARCHAR)
--  print 'Userid: ' + @userid

  /* bookkey_to may have been generated (new title) */
  if (@new_template_bookkey_string is not null and LEN(@new_template_bookkey_string) > 0 and SUBSTRING(@new_template_bookkey_string, 1, 1) = '?')
  BEGIN
    DECLARE @TempKey int
    DECLARE @TempKeyName varchar(256)
    SET @TempKey = 0
    SET @TempKeyName = ''

    IF (LEN(@new_template_bookkey_string) > 1)
    BEGIN
      SET @TempKeyName = SUBSTRING(@new_template_bookkey_string, 2, LEN(@new_template_bookkey_string) -1)
      SET @TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @TempKeyName)
    END
    --SET @KeyName = SUBSTRING(@KeyValue 
    IF (@TempKey = 0)
    BEGIN
      exec next_generic_key @UserID, @TempKey output, @o_error_code output, @o_error_desc
      SET @new_template_bookkey_string = CONVERT(varchar(120), @TempKey)
      IF (LEN(@TempKeyName) > 0)
      BEGIN
        SET @KeyNamePairs = @KeyNamePairs + @TempKeyName + ',' + @new_template_bookkey_string + ','
        IF @newkeys is null BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @TempKeyName + ',' + @new_template_bookkey_string + ','
      END
    END
    ELSE BEGIN
      SET @new_template_bookkey_string = CONVERT(varchar(120), @TempKey)
    END
  END

  SET @new_template_bookkey = CONVERT(int, @new_template_bookkey_string)
  --print 'New Template Bookkey: ' + cast(@new_template_bookkey AS VARCHAR)

  EXECUTE qtitle_set_default_template @new_template_bookkey,@old_template_bookkey,@userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  if @IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
  END

GO

GRANT EXEC ON qtitle_set_default_template_xml TO PUBLIC
GO
