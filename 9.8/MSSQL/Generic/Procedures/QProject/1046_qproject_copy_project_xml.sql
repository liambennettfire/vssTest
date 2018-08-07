if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_copy_project_xml
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_copy_project_xml
 (@xmlParameters     varchar(max),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_copy_project_xml
**  Desc: This stored procedure initializes any necessary values
**        for a new project - project dates, initial iteration, etc.
**
**    Auth: Alan Katzen
**    Date: 7/3/08
*******************************************************************************/

DECLARE 
  @v_IsOpen		                 BIT,
  @v_DocNum		                 INT,
  @v_CopyProjectKeyAsString		 VARCHAR(255),
  @v_CopyProjectKey	           INT,
  @v_NewProjectKeyAsString		 VARCHAR(255),
  @v_NewProjectKey	           INT,
  @v_RelatedJournalKeyAsString VARCHAR(255),
  @v_RelatedJournalKey  	     INT,
  @v_RelatedVolumeKeyAsString	 VARCHAR(255),
  @v_RelatedVolumeKey	         INT,
  @v_RelatedIssueKeyAsString	 VARCHAR(255),
  @v_RelatedIssueKey	         INT,
  @v_CopyDataGroupsList		     VARCHAR(max),
  @v_ClearDataGroupsList		   VARCHAR(max),
  @v_UserID		                 VARCHAR(30),
  @v_TempKey	                 INT,
  @v_TempKeyName	             VARCHAR(255),  
  @v_GeneratedProjectKey       INT

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
  SELECT @v_CopyProjectKeyAsString = CopyProjectKeyAsString,
	       @v_NewProjectKeyAsString = NewProjectKeyAsString,
	       @v_RelatedJournalKeyAsString = RelatedJournalKeyAsString,
	       @v_RelatedVolumeKeyAsString = RelatedVolumeKeyAsString,
	       @v_RelatedIssueKeyAsString = RelatedIssueKeyAsString,
	       @v_CopyDataGroupsList = CopyDataGroupsList,
	       @v_ClearDataGroupsList = ClearDataGroupsList,
         @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (CopyProjectKeyAsString VARCHAR(255) 'CopyProjectKey', 
	      NewProjectKeyAsString VARCHAR(255) 'NewProjectKey',
	      RelatedJournalKeyAsString VARCHAR(255) 'RelatedJournalKey',
	      RelatedVolumeKeyAsString VARCHAR(255) 'RelatedVolumeKey',
	      RelatedIssueKeyAsString VARCHAR(255) 'RelatedIssueKey',
	      CopyDataGroupsList VARCHAR(max) 'CopyDataGroupsList',
	      ClearDataGroupsList VARCHAR(max) 'ClearDataGroupsList',
        UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_copy_project_xml.'
    GOTO ExitHandler
  END

  SET @v_CopyProjectKey = CONVERT(INT, @v_CopyProjectKeyAsString)
  SET @v_RelatedJournalKey = CONVERT(INT, @v_RelatedJournalKeyAsString)
  SET @v_RelatedVolumeKey = CONVERT(INT, @v_RelatedVolumeKeyAsString)
  SET @v_RelatedIssueKey = CONVERT(INT, @v_RelatedIssueKeyAsString)

  IF (@v_NewProjectKeyAsString IS NOT NULL AND LEN(@v_NewProjectKeyAsString) > 0 AND SUBSTRING(@v_NewProjectKeyAsString,1,1) = '?')
  BEGIN   
    IF (LEN(@v_NewProjectKeyAsString) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_NewProjectKeyAsString, 2, LEN(@v_NewProjectKeyAsString) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)

    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_NewProjectKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @keys = @keys + @v_TempKeyName + ',' + @v_NewProjectKeyAsString + ','
        IF @newkeys IS NULL BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_NewProjectKeyAsString + ','
      END
    END
    ELSE 
    BEGIN
      SET @v_NewProjectKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_NewProjectKey = CONVERT(INT, @v_NewProjectKeyAsString)
  
   
  /** Call procedure that will do the copy project **/
  EXEC qproject_copy_project @v_NewProjectKey,@v_CopyProjectKey,@v_CopyDataGroupsList,@v_ClearDataGroupsList,
    @v_RelatedJournalKey,@v_RelatedVolumeKey,@v_RelatedIssueKey,@v_UserID,@v_GeneratedProjectKey output, 
    @o_error_code output,@o_error_desc output

ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qproject_copy_project_xml TO PUBLIC
GO
