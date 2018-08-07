IF EXISTS (
		SELECT 1
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[qproject_update_master_taq_approval_relationships]')
			AND type IN (N'P', N'PC')
		)
BEGIN
	DROP PROCEDURE [dbo].[qproject_update_master_taq_approval_relationships]
END
GO

CREATE PROCEDURE [dbo].[qproject_update_master_taq_approval_relationships] (
	@i_masteracq_projectkey INTEGER
	,@i_userid VARCHAR(30)
	,@o_error_code INTEGER OUTPUT
	,@o_error_desc VARCHAR(2000) OUTPUT
	)
AS
/******************************************************************************
**  Name: qproject_update_master_taq_approval_relationships
**  Desc: 
**  Auth: Colman
**  Case: 49110
**  Date: 2/14/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  -----     ------    -------------------------------------------
*******************************************************************************/
BEGIN
	DECLARE @v_subacqprojectkey INT
		,@v_masterwork_projectkey INT
		,@v_masterworkrelcode INT
		,@v_subacqrelcode INT
		,@v_unapprovedrelcode_work INT
		,@v_unapprovedrelcode_acq INT
		,@v_newkey INT
		,@v_sortorder INT
		,@v_error INT

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_masterworkrelcode = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 15

	SELECT @v_masterwork_projectkey = relatedprojectkey
	FROM projectrelationshipview
	WHERE relationshipcode = @v_masterworkrelcode
		AND taqprojectkey = @i_masteracq_projectkey

  -- If this Master Acq hasn't been at least partially approved, there is nothing to do.
  IF ISNULL(@v_masterwork_projectkey, 0) = 0
    RETURN

	SELECT @v_subacqrelcode = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 33

	SELECT @v_unapprovedrelcode_work = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 44

	SELECT @v_unapprovedrelcode_acq = datacode
	FROM gentables
	WHERE tableid = 582
		AND qsicode = 45

	IF ISNULL(@v_unapprovedrelcode_work, 0) <= 0
		OR ISNULL(@v_unapprovedrelcode_acq, 0) <= 0
		OR ISNULL(@v_masterworkrelcode, 0) <= 0
		OR ISNULL(@v_subacqrelcode, 0) <= 0
	BEGIN
		SET @o_error_code = - 1
		SET @o_error_desc = 'Unable to determine Master Acquisition relationship codes'

		RETURN
	END

	-- If any subordinate acquisitions are approved, make sure they are not in the unapproved relationship
	DELETE
	FROM taqprojectrelationship
	WHERE relationshipcode1 = @v_unapprovedrelcode_work
		AND taqprojectkey1 = @v_masterwork_projectkey
		AND taqprojectkey2 IN (
			SELECT r.taqprojectkey1
			FROM taqprojectrelationship r
			JOIN taqproject p ON p.taqprojectkey = r.taqprojectkey1
				AND p.taqprojectstatuscode IN (
					SELECT datacode
					FROM gentables
					WHERE tableid = 522
						AND gen2ind = 1
					) -- Locked statuses
			)

	DELETE
	FROM taqprojectrelationship
	WHERE relationshipcode2 = @v_unapprovedrelcode_work
		AND taqprojectkey2 = @v_masterwork_projectkey
		AND taqprojectkey1 IN (
			SELECT r.taqprojectkey1
			FROM taqprojectrelationship r
			JOIN taqproject p ON p.taqprojectkey = r.taqprojectkey1
				AND p.taqprojectstatuscode IN (
					SELECT datacode
					FROM gentables
					WHERE tableid = 522
						AND gen2ind = 1
					) -- Locked statuses
			)

	-- If any subordinate acquisitions are not approved, make sure they are in the unapproved relationship
	DECLARE subacq_cur CURSOR
	FOR
	SELECT r.relatedprojectkey
	FROM projectrelationshipview r
	JOIN taqproject p ON p.taqprojectkey = r.relatedprojectkey
		AND p.taqprojectstatuscode NOT IN (
			SELECT datacode
			FROM gentables
			WHERE tableid = 522
				AND gen2ind = 1
			) -- Locked statuses
	WHERE relationshipcode = @v_subacqrelcode -- Master to Subordinate Acquisition
		AND r.taqprojectkey = @i_masteracq_projectkey
		AND r.relatedprojectkey NOT IN (
			SELECT relatedprojectkey
			FROM projectrelationshipview
			WHERE relationshipcode = @v_unapprovedrelcode_acq
				AND taqprojectkey = @v_masterwork_projectkey
			)

	OPEN subacq_cur

	FETCH subacq_cur
	INTO @v_subacqprojectkey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC get_next_key @i_userid
			,@v_newkey OUTPUT

		SELECT @v_sortorder = MAX(ISNULL(sortorder, 0)) + 1
		FROM projectrelationshipview
		WHERE taqprojectkey = @v_masterwork_projectkey
			AND relationshipcode = @v_unapprovedrelcode_work

		INSERT INTO taqprojectrelationship (
			taqprojectrelationshipkey
			,taqprojectkey1
			,taqprojectkey2
			,projectname2
			,relationshipcode1
			,relationshipcode2
			,project2status
			,project2participants
			,relationshipaddtldesc
			,keyind
			,sortorder
			,indicator1
			,indicator2
			,quantity1
			,quantity2
			,decimal1
			,decimal2
			,lastuserid
			,lastmaintdate
			)
		VALUES (
			@v_newkey
			,@v_masterwork_projectkey
			,@v_subacqprojectkey
			,NULL
			,@v_unapprovedrelcode_work
			,@v_unapprovedrelcode_acq
			,NULL
			,NULL
			,NULL
			,0
			,@v_sortorder
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,@i_userid
			,getdate()
			)

		SELECT @v_error = @@ERROR

		IF @@ERROR <> 0
		BEGIN
			SET @o_error_code = - 1
			SET @o_error_desc = 'insert into taqprojectrelationship failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey = ' + cast(@v_masterwork_projectkey AS VARCHAR) + '; related taqprojectkey = ' + cast(@v_subacqprojectkey AS VARCHAR)

			RETURN
		END

		FETCH subacq_cur
		INTO @v_subacqprojectkey
	END

	CLOSE subacq_cur

	DEALLOCATE subacq_cur
END
GO

GRANT EXEC
	ON qproject_update_master_taq_approval_relationships
	TO PUBLIC
GO


