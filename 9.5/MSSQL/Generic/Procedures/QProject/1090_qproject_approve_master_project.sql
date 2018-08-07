IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_approve_master_project]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [dbo].[qproject_approve_master_project]
END
GO

CREATE PROCEDURE [dbo].[qproject_approve_master_project]
		(@i_master_projectkey     integer,
		 @i_userid				  varchar(30),
		 @o_error_code			  integer output,
		 @o_error_desc		      varchar(2000) output)
AS
/******************************************************************************
**  Name: qproject_approve_master_project
**  Desc: This stored procedure approves a master project and creates an associated
**		  Master Work. Note, it does not handle the approving of all subordinate title acq projects.
**		  Acquisition Project approval happens via addtochangerequest.
**    Auth: Dustin Miller
**    Date: June 13, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  -----     ------    -------------------------------------------
**  08/04/16  Dustin	Changed the procedure to only approve the Master Acq if it isn't already approved.
**						If it is already approved, just return the associated Master Work key that was created previously.
*******************************************************************************/
BEGIN
	DECLARE @v_work_projectkey		INT,
			@v_projecttitle			VARCHAR(255),
			@v_projectstatuscode		INT,
			@v_masterprojrelcode	INT,
			@v_masterworkrelcode	INT,
			@v_projapprovedstatus	INT,
			@v_masterworkitemtype	INT,
			@v_masterworkusageclass	INT

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SET @v_projapprovedstatus = NULL
	SELECT @v_projapprovedstatus = datacode
	FROM gentables
	WHERE tableid = 522
	  AND qsicode = 1

	IF COALESCE(@v_projapprovedstatus, 0) <= 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to determine Acquisition Approved Status Code'
		RETURN
	END

	SET @v_masterprojrelcode = NULL
	SELECT @v_masterprojrelcode = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 14

	SET @v_masterworkrelcode = NULL
	SELECT @v_masterworkrelcode = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 15

	IF COALESCE(@v_masterprojrelcode, 0) <= 0 OR COALESCE(@v_masterworkrelcode, 0) <= 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to determine Master Acquisition/Master Work relationship codes'
		RETURN
	END

	SELECT @v_projectstatuscode = taqprojectstatuscode
	FROM taqproject
	WHERE taqprojectkey = @i_master_projectkey

	SET @v_work_projectkey = 0
	IF @v_projectstatuscode <> @v_projapprovedstatus --If Master Acq not already approved
	BEGIN
		SELECT @v_projecttitle = taqprojecttitle
		FROM taqproject
		WHERE taqprojectkey = @i_master_projectkey

		EXEC qproject_create_work @i_master_projectkey, 0, @i_userid, 0, @v_projecttitle, @v_work_projectkey output,@o_error_code output,@o_error_desc output

		IF @o_error_code < 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project (error creating work): ' + @o_error_desc + '.'
			RETURN
		END

		SELECT @v_masterworkitemtype = datacode
		FROM gentables
		WHERE tableid = 550
		  AND qsicode = 9

		SELECT @v_masterworkusageclass = datasubcode
		FROM subgentables
		WHERE tableid = 550
		  AND datacode = @v_masterworkitemtype
		  AND qsicode = 53

		UPDATE taqproject
		SET searchitemcode = @v_masterworkitemtype,
			usageclasscode = @v_masterworkusageclass
		WHERE taqprojectkey = @v_work_projectkey

		EXEC qproject_copy_project_insert_relationship @i_master_projectkey, @v_work_projectkey, @v_masterworkrelcode, 
		@v_masterprojrelcode, @i_userid, @o_error_code output, @o_error_desc output

		IF @o_error_code <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to create relationship between Master Acquisition and Master work.'
			RETURN
		END

		UPDATE taqproject
		SET taqprojectstatuscode = @v_projapprovedstatus
		WHERE taqprojectkey = @i_master_projectkey
	END
	ELSE BEGIN --Master Acq already approved
		--Retrieve @v_work_projectkey (master work key) value from existing Master work Associated with @i_master_projectkey
		SELECT TOP 1 @v_work_projectkey = taqprojectkey2
		FROM taqprojectrelationship
		WHERE taqprojectkey1 = @i_master_projectkey
		  AND relationshipcode1 = @v_masterprojrelcode
		  AND relationshipcode2 = @v_masterworkrelcode
		ORDER BY lastmaintdate DESC

		IF COALESCE(@v_work_projectkey, 0) = 0
		BEGIN
			SELECT TOP 1 @v_work_projectkey = taqprojectkey1
			FROM taqprojectrelationship
			WHERE taqprojectkey2 = @i_master_projectkey
			  AND relationshipcode1 = @v_masterworkrelcode
			  AND relationshipcode2 = @v_masterprojrelcode
			ORDER BY lastmaintdate DESC
		END
	END

	SELECT @v_work_projectkey AS workprojectkey
END
GO

GRANT EXEC ON qproject_approve_master_project TO PUBLIC
GO