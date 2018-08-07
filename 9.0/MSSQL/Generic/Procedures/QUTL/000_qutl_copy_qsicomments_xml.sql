if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_copy_qsicomments_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_copy_qsicomments_xml 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_copy_qsicomments_xml
 (@xmlParameters    varchar(8000),
  @KeyNamePairs     varchar(8000), 
  @newkeys          varchar(2000) output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_copy_qsicomments_xml
**  Desc: This stored procedure will copy qsicomments record from one commentkey to another.
**        NOTE: The new commentkey must be generated prior to calling this procedure, 
**        and should exist on qsicomments table already as a dummy row (blank comments).
**
**  Auth: Kate Wiewiora
**  Date: 23 July 2012
*******************************************************************************/

  DECLARE 
    @v_FromCommentkey    INT,
    @v_NewCommentkey  INT,
    @v_NewCommentkey_String   VARCHAR(120),
    @v_DocNum   INT,
    @v_IsOpen   BIT,
    @v_TempKey INT,
    @v_TempKeyName VARCHAR(255),
    @v_UserID VARCHAR(30)	  

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
  SELECT @v_NewCommentkey_String = NewCommentKey, @v_FromCommentKey = FromCommentKey, @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (NewCommentKey varchar(120) 'NewCommentKey', FromCommentKey int 'FromCommentKey', UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting Comment keys from xml parameters.'
    GOTO ExitHandler
  END

  PRINT '@v_NewCommentkey_String=' + @v_NewCommentkey_String
  
  /* New Commentkey may have been generated */
  if (@v_NewCommentkey_String is not null and LEN(@v_NewCommentkey_String) > 0 and SUBSTRING(@v_NewCommentkey_String, 1, 1) = '?')
  BEGIN
    IF (LEN(@v_NewCommentkey_String) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_NewCommentkey_String, 2, LEN(@v_NewCommentkey_String) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
    END
    
  PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)
    
    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_NewCommentkey_String = CONVERT(VARCHAR(120), @v_TempKey)
      
      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @KeyNamePairs = @KeyNamePairs + @v_TempKeyName + ',' + @v_NewCommentkey_String + ','
        IF @newkeys is null BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_NewCommentkey_String + ','
      END
    END
    ELSE BEGIN
      SET @v_NewCommentkey_String = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_NewCommentkey = CONVERT(INT, @v_NewCommentkey_String)

  /** Call procedure that will copy the specific qsicomments row **/
  EXEC qutl_copy_qsicomments @v_NewCommentkey, @v_FromCommentkey, @v_UserID,
    @o_error_code OUTPUT, @o_error_desc OUTPUT

  ExitHandler:

  if @v_IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @v_DocNum
    SET @v_DocNum = NULL
  END

GO

GRANT EXEC ON qutl_copy_qsicomments_xml TO PUBLIC
GO
