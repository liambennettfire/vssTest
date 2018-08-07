if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_set_primary_format_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_set_primary_format_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_set_primary_format_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qproject_set_primary_format_xml
**  Desc: This stored procedure sets the specified project format to primary 
**	Note: If FormatKey = 0, we set the First format as the selected format.
**
**  Auth: Uday A. Khisty
**  Date: Feb 16 2016
*******************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_ProjectKey INT,
  @v_FormatKey INT,
  @v_count INT
  
  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document.'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_ProjectKey = ProjectKey,
         @v_FormatKey = FormatKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKey int 'ProjectKey', 
        FormatKey int 'FormatKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qproject_set_primary_format_xml.'
    GOTO ExitHandler
  END 

  IF @v_FormatKey <=0 BEGIN
	IF EXISTS(SELECT * FROM taqprojecttitle WHERE taqprojectkey = @v_ProjectKey AND titlerolecode IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)) BEGIN
		SELECT @v_count = count(*)
		FROM taqprojecttitle 
		WHERE taqprojectkey = @v_ProjectKey
                  AND primaryformatind = 1 AND titlerolecode IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
                  
        IF @v_count > 0 BEGIN
			GOTO ExitHandler
        END
        ELSE BEGIN
			SELECT TOP(1) @v_FormatKey = taqprojectformatkey  
			FROM taqprojecttitle tpt
			WHERE tpt.taqprojectkey = @v_ProjectKey and titlerolecode = 2
			ORDER BY tpt.primaryformatind DESC, tpt.mediatypecode, tpt.taqprojectformatdesc
        END
	END
  END
  
  IF @v_ProjectKey > 0 AND @v_FormatKey > 0 BEGIN
	/** Call actual procedure **/
	EXEC qproject_set_primary_format @v_ProjectKey, @v_FormatKey, @o_error_code OUTPUT, @o_error_desc OUTPUT
  END


ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qproject_set_primary_format_xml TO PUBLIC
GO
