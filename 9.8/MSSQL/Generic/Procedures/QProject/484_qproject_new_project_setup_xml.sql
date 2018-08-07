if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_new_project_setup_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_new_project_setup_xml
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_new_project_setup_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_new_project_setup_xml
**  Desc: This stored procedure initializes any necessary values
**        for a new project - project dates, initial iteration, etc.
**
**    Auth: Kate
**    Date: 3/23/05
*******************************************************************************/

DECLARE 
  @v_IsOpen		BIT,
  @v_DocNum		INT,
  @v_ProjectKeyAsString		VARCHAR(255),
  @v_ProjectKey	INT,
  @v_ProjectTypeAsString	VARCHAR(255),
  @v_ProjectType	INT,
  @v_UserID		VARCHAR(30),
  @v_TempKey	INT,
  @v_TempKeyName	VARCHAR(255)  

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
  SELECT @v_ProjectKeyAsString = ProjectKeyAsString,
	@v_ProjectTypeAsString = ProjectTypeAsString,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKeyAsString VARCHAR(255) 'ProjectKey', 
	ProjectTypeAsString VARCHAR(255) 'ProjectType',
      UserID VARCHAR(30) 'UserID')

  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_new_project_setup_xml.'
    GOTO ExitHandler
  END


  SET @v_ProjectType =  CONVERT(INT, @v_ProjectTypeAsString)


  IF (@v_ProjectKeyAsString IS NOT NULL AND LEN(@v_ProjectKeyAsString) > 0 AND SUBSTRING(@v_ProjectKeyAsString,1,1) = '?')
  BEGIN
      
    IF (LEN(@v_ProjectKeyAsString) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_ProjectKeyAsString, 2, LEN(@v_ProjectKeyAsString) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)

    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @keys = @keys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
        IF @newkeys IS NULL BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
      END
    END
    ELSE 
    BEGIN
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_ProjectKey = CONVERT(INT, @v_ProjectKeyAsString)
  
   
  /** Call procedure that will do the initialization on new project **/
  EXEC qproject_new_project_setup @v_ProjectKey, @v_ProjectType, @v_UserID, 
    @o_error_code output, @o_error_desc output

  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qproject_new_project_setup_xml TO PUBLIC
GO
