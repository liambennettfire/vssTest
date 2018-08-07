
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_update_author_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_update_author_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_update_author_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000),
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_update_author_xml
**  Desc: Update author table with modified values from globalcontact tables.
**        It's interface is the standard XML parameter interface that can
**        be called via the pre-defined interface mechanism.
**
**    Auth: Alan Katzen
**    Date: 30 July 2004
**    
**  9/1/04 - KW - Added OwnerUserID parameter since we need the lastuserid
**  of the person who made a contact private - a trigger will then update
**  privateind and owneruserid columns on corecontactinfo table so that
**  no other user can access that contact but the person who owns it.
*******************************************************************************/

  DECLARE 
	@IsOpen			BIT,
	@DocNum			INT

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
print @xmlParameters
print @KeyNamePairs     

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END
  
  SET @IsOpen = 1
  
  DECLARE @masterkey          int,
          @masterkey_string   varchar(120),
          @detailkey          int,
          @detailkey_string   varchar(120),
          @owneruserid        varchar(30),   
          @tablename          varchar(100),
          @v_TempKey  INT,
          @v_TempKeyName  VARCHAR(255),
          @v_KeyValue VARCHAR(50)  

  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''

  SELECT @masterkey_string = MasterKey, @detailkey_string = DetailKey,
      @owneruserid = OwnerUserID, @tablename = TableName
  FROM OPENXML(@DocNum,  '//Parameters')
  WITH (MasterKey VARCHAR(120) 'masterkey', DetailKey VARCHAR(120) 'detailkey',
      OwnerUserID VARCHAR(30) 'owneruserid', TableName VARCHAR(100) 'tablename')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting global contact information from xml parameters.'
    GOTO ExitHandler
  END

  --print 'Masterkey String: ' + @masterkey_string
  --print 'Detailkey String: ' + @detailkey_string
  --print 'UserID: ' + cast(@owneruserid AS VARCHAR)
  --print 'Table Name: ' + @tablename

  IF (@masterkey_string IS NOT NULL AND LEN(@masterkey_string) > 0 AND SUBSTRING(@masterkey_string, 1, 1) = '?') BEGIN
    IF (LEN(@masterkey_string) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@masterkey_string, 2, LEN(@masterkey_string) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
    END
      
    --DEBUG
    --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
    --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Contact', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @masterkey = @v_TempKey 
  END
  ELSE BEGIN
    SET @masterkey = convert(int, @masterkey_string);
  END  
  --print 'Masterkey: ' + cast(@masterkey AS VARCHAR)

  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''

  IF (@detailkey_string IS NOT NULL AND LEN(@detailkey_string) > 0 AND SUBSTRING(@detailkey_string, 1, 1) = '?') BEGIN
    IF (LEN(@detailkey_string) > 1) BEGIN
      SET @v_TempKeyName = SUBSTRING(@detailkey_string, 2, LEN(@detailkey_string) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
    END
      
    --DEBUG
    --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
    --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)        
            
    IF (@v_TempKey = 0) BEGIN
      EXEC next_generic_key 'New Contact Address', @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_KeyValue = CONVERT(varchar(120), @v_TempKey)
      IF (LEN(@v_TempKeyName) > 0) BEGIN
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_KeyValue + ','
      END
    END
              
    SET @detailkey = @v_TempKey 
  END
  ELSE BEGIN
    SET @detailkey = convert(int, @detailkey_string);
  END  
  --print 'Detailkey: ' + cast(@detailkey AS VARCHAR)

  exec qcontact_update_author @masterkey, @detailkey, @owneruserid, @tablename, 
                              @o_error_code output, @o_error_desc output

  ExitHandler:

  if @IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
  END

GO

GRANT EXEC ON qcontact_update_author_xml TO PUBLIC
GO

