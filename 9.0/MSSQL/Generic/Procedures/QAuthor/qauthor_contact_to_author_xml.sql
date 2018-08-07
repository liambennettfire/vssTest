
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qauthor_contact_to_author_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qauthor_contact_to_author_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qauthor_contact_to_author_xml
 (@xmlParameters     varchar(8000),
  @KeyNamePairs      varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qauthor_contact_to_author_xml
**  Desc: This allows the stored procedure qauthor_contact_to_author to
**        to be called from the update script.
**
**    Auth: James Weber
**    Date: 21 June 2004
**  
**    Updated: Kusum Basra 
**    Date: 21 January 2015
**    Case: 30591
**  
*******************************************************************************/

  DECLARE 
	@IsOpen			BIT,
	@DocNum			INT,
	@ContactKey INT,
	@ContactKeyAsString   VARCHAR(120),
	@v_TempKey  INT,
	@v_TempKeyName  VARCHAR(255),
	@v_KeyValue VARCHAR(50),
	@v_userid VARCHAR(30)  

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
  
  --DECLARE @contactkey int
  --DECLARE @userid varchar(30)
  
    SELECT @ContactKeyAsString = ContactKey_String, @v_userid = UserID
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (ContactKey_String varchar(120) 'ContactKey',UserID varchar(30) 'UserID')
     

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Contact Roll and author type from xml parameters.'
    GOTO ExitHandler
  END

  --print @ContactKey_String
  --print @v_userid

IF (@ContactKeyAsString IS NOT NULL AND LEN(@ContactKeyAsString) > 0 AND SUBSTRING(@ContactKeyAsString, 1, 1) = '?') BEGIN
    IF (LEN(@ContactKeyAsString) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@ContactKeyAsString, 2, LEN(@ContactKeyAsString) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
    END
                
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Author', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @ContactKey = @v_TempKey 
  END
  ELSE BEGIN
    SET @ContactKey = convert(int, @ContactKeyAsString);
  END
  /***** START THE TRANSACTION *****/

exec qauthor_contact_to_author @ContactKey, @v_userid, @o_error_code output, @o_error_desc output

ExitHandler:

if @IsOpen = 1
BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL    

END


GO
GRANT EXEC ON qauthor_contact_to_author_xml TO PUBLIC
GO


 