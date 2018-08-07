IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_create_related_work_xml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_create_related_work_xml]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qtitle_create_related_work_xml]
	(@xmlParameters    varchar(8000),
	 @KeyNamePairs     varchar(8000), 
	 @newkeys          varchar(2000) output,
	 @o_error_code     integer output,
	 @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_create_related_work_xml
**  Desc: This stored procedure creates a new work based off a title
**        via the AddToChangeRequest.
**
**    Auth: Dustin Miller
**    Date: 5 April 2016
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  05/25/2016  Colman    Case 37912 - Don't append to @newkeys
**  07/15/2016  Uday      Case 39219   Error generated adding advanced title
*******************************************************************************/

	DECLARE 
	@v_Taqprojectkey  INT,
	@v_Taqprojectkey_String   VARCHAR(120),
	@v_Workkey	INT,
	@v_Workkey_String	VARCHAR(120),
	@v_Templatekey	INT,
	@v_Taqprojectownerkey	INT,
	@v_Taqprojecttype	INT,
	@v_Usageclasscode	INT,
	@v_Taqprojectstatuscode	INT,
	@v_Taqprojecttitle	VARCHAR(255),
	@v_Taqprojecttitleprefix	VARCHAR(255),
	@v_Taqprojectsubtitle	VARCHAR(255),
	@v_DocNum   INT,
	@v_IsOpen   BIT,
	@v_TempKey INT,
	@v_TempKeyName VARCHAR(255),
	@v_Workitemtype INT,
	@v_title_title_role INT,
	@v_work_project_role INT,
	@new_taqprojectformatkey INT,
	@v_UserID VARCHAR(30)
	  

	SET NOCOUNT ON

	SET @v_IsOpen = 0
	SET @v_TempKey = 0
	SET @v_TempKeyName = ''
	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_Workitemtype = datacode
	FROM gentables
    WHERE tableid = 550
	  and qsicode = 9

	SELECT @v_work_project_role = datacode
    FROM gentables
    WHERE tableid = 604
     and qsicode = 1

	IF @@ERROR <> 0 BEGIN
		SET @o_error_code = @@ERROR
		SET @o_error_desc = 'Error getting project role.'
		RETURN
	END

	SELECT @v_title_title_role = datacode
    FROM gentables
    WHERE tableid = 605
     and qsicode = 1

	IF @@ERROR <> 0 BEGIN
		SET @o_error_code = @@ERROR
		SET @o_error_desc = 'Error getting title title role.'
		RETURN
	END 

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
	SELECT @v_Taqprojectkey_String = taqprojectkey, @v_Workkey_String = bookkey,
	@v_Templatekey = templatekey, @v_Taqprojectownerkey = taqprojectownerkey,
	@v_Taqprojecttype = taqprojecttype, @v_Usageclasscode = usageclasscode,
	@v_Taqprojectstatuscode = taqprojectstatuscode, @v_Taqprojecttitle = taqprojecttitle,
	@v_Taqprojecttitleprefix = taqprojecttitleprefix, @v_Taqprojectsubtitle = taqprojectsubtitle,
	@v_UserID = UserID
	FROM OPENXML(@v_DocNum,  '//Parameters')
	WITH (taqprojectkey varchar(120) 'taqprojectkey', bookkey varchar(120) 'bookkey',
	templatekey int 'templatekey', taqprojectownerkey int 'taqprojectownerkey',
	taqprojecttype int 'taqprojecttype', usageclasscode int 'usageclasscode',    
	taqprojectstatuscode int 'taqprojectstatuscode', taqprojecttitle varchar(255) 'taqprojecttitle',
	taqprojecttitleprefix varchar(255) 'taqprojecttitleprefix', taqprojectsubtitle varchar(255) 'taqprojectsubtitle',
	UserID VARCHAR(30) 'UserID')

	IF @@ERROR <> 0 BEGIN
		SET @o_error_code = @@ERROR
		SET @o_error_desc = 'Error extracting Work Information from xml parameters.'
		GOTO ExitHandler
	END
	
    IF @v_UserID IS NULL
	    SET @v_UserID = 'qsiadmin'	


	/* projectkey may have been generated (new work) */
	if (@v_Taqprojectkey_String is not null and LEN(@v_Taqprojectkey_String) > 0 and SUBSTRING(@v_Taqprojectkey_String, 1, 1) = '?')
	BEGIN
	IF (LEN(@v_Taqprojectkey_String) > 1)
	BEGIN
		SET @v_TempKeyName = SUBSTRING(@v_Taqprojectkey_String, 2, LEN(@v_Taqprojectkey_String) -1)
		SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
	END
    
	IF (@v_TempKey = 0)
	BEGIN
		EXEC next_generic_key @v_Taqprojectownerkey, @v_TempKey output, @o_error_code output, @o_error_desc
		SET @v_Taqprojectkey_String = CONVERT(VARCHAR(120), @v_TempKey)
      
		IF (LEN(@v_TempKeyName) > 0)
		BEGIN
		SET @KeyNamePairs = @KeyNamePairs + @v_TempKeyName + ',' + @v_Taqprojectkey_String + ','
		SET @newkeys = @v_TempKeyName + ',' + @v_Taqprojectkey_String + ','
		END
	END
	ELSE BEGIN
		SET @v_Taqprojectkey_String = CONVERT(VARCHAR(120), @v_TempKey)
	END
	END

	SET @v_Taqprojectkey = CONVERT(INT, @v_Taqprojectkey_String)

	/* bookkey may have been generated */
	SET @v_TempKey = 0
	SET @v_TempKeyName = ''

	if (@v_Workkey_String is not null and LEN(@v_Workkey_String) > 0 and SUBSTRING(@v_Workkey_String, 1, 1) = '?')
	BEGIN
	IF (LEN(@v_Workkey_String) > 1)
	BEGIN
		SET @v_TempKeyName = SUBSTRING(@v_Workkey_String, 2, LEN(@v_Workkey_String) -1)
		SET @v_TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @v_TempKeyName)
	END
    
	IF (@v_TempKey = 0)
	BEGIN
		EXEC next_generic_key @v_Taqprojectownerkey, @v_TempKey output, @o_error_code output, @o_error_desc
		SET @v_Workkey_String = CONVERT(VARCHAR(120), @v_TempKey)
      
		IF (LEN(@v_TempKeyName) > 0)
		BEGIN
		SET @KeyNamePairs = @KeyNamePairs + @v_TempKeyName + ',' + @v_Workkey_String + ','
		SET @newkeys = @v_TempKeyName + ',' + @v_Workkey_String + ','
		END
	END
	ELSE BEGIN
		SET @v_Workkey_String = CONVERT(VARCHAR(120), @v_TempKey)
	END
	END

	SET @v_Workkey = CONVERT(INT, @v_Workkey_String)

	--Perform work insert
	IF @v_Taqprojecttitle IS NULL OR LEN(@v_Taqprojecttitle) = 0
	BEGIN
		SELECT TOP 1 @v_Taqprojecttitle = title
		FROM book
		WHERE bookkey = @v_Workkey
	END

	INSERT INTO taqproject
	(taqprojectkey,taqprojectownerkey,taqprojecttitle,taqprojectsubtitle,taqprojecttype,
	taqprojectstatuscode,templateind,lockorigdateind,lastuserid,lastmaintdate,
	taqprojecttitleprefix,workkey,
	subsidyind,usageclasscode,searchitemcode,defaulttemplateind,autogeneratenameind) 
	VALUES
	(@v_Taqprojectkey, @v_Taqprojectownerkey, @v_Taqprojecttitle, @v_Taqprojectsubtitle, @v_Taqprojecttype,
	@v_Taqprojectstatuscode, 0, 0, @v_UserID, GETDATE(),
	@v_Taqprojecttitleprefix, @v_Workkey,
	0, @v_Usageclasscode, @v_Workitemtype, 0, 0)

	IF @@ERROR <> 0 BEGIN
		SET @o_error_code = @@ERROR
		SET @o_error_desc = 'Error inserting Work data to taqproject.'
		GOTO ExitHandler
	END

	exec get_next_key 'QSIDBA', @new_taqprojectformatkey output

	INSERT INTO taqprojecttitle
	(taqprojectformatkey, taqprojectkey, primaryformatind, bookkey, printingkey, projectrolecode, titlerolecode, lastuserid, lastmaintdate)
	VALUES
	(@new_taqprojectformatkey, @v_Taqprojectkey, 0, @v_Workkey, 1, @v_work_project_role, @v_title_title_role, @v_UserID, GETDATE())

	IF @@ERROR <> 0 BEGIN
		SET @o_error_code = @@ERROR
		SET @o_error_desc = 'Error inserting Work data to taqprojecttitle.'
		GOTO ExitHandler
	END

	IF COALESCE(@v_Templatekey, 0) > 0
	BEGIN
		--Copy from template if one was provided
		EXEC qproject_create_work @v_Templatekey, @v_Taqprojectkey, @v_UserID, 0, @v_Taqprojecttitle, null, @o_error_code output, @o_error_desc output

		IF @o_error_code <> 0
		BEGIN
			GOTO ExitHandler
		END
	END
	ELSE BEGIN
		--Copy all org levels from title
		INSERT INTO taqprojectorgentry
		(taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
		SELECT @v_Taqprojectkey, orgentrykey, orglevelkey, @v_UserID, GETDATE()
		FROM bookorgentry
		WHERE bookkey = @v_Workkey

		IF @@ERROR <> 0 BEGIN
			SET @o_error_code = @@ERROR
			SET @o_error_desc = 'Error inserting Work data to taqprojectorgentry.'
		GOTO ExitHandler
	END
	END

	ExitHandler:

	if @v_IsOpen = 1
	BEGIN
		EXEC sp_xml_removedocument @v_DocNum
		SET @v_DocNum = NULL
	END

RETURN
GO
set nocount off
GO
GRANT EXEC ON qtitle_create_related_work_xml TO PUBLIC
GO