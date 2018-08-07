IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_upload_project]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_upload_project]
GO

IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_send_catalogs]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_send_catalogs]
GO

CREATE PROCEDURE [dbo].[qcs_upload_project]
(
    @i_projectkey INTEGER,
	@i_userid     VARCHAR(30),
    @o_error_code INTEGER OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS
	BEGIN
		DECLARE @SiteId VARCHAR(256),
				@ErrorVar INT,
				@RowcountVar INT,
				@d_cataloglastmaintdate DATETIME,
				@v_jobqsicode INT,
				@v_itemtype INT,
				@v_usageclass INT,
				@v_jobdesc  VARCHAR(2000),
				@v_jobdescshort VARCHAR(255),
				@v_jobkey INT,
				@v_batchkey INT,
				@v_msgdesc  VARCHAR(255),
				@v_jobtypecode INT,
				@v_msgtype_started INT
		

		SET @o_error_code = 0
		SET @o_error_desc = ''

		SELECT @v_msgtype_started = datacode
		FROM gentables
		WHERE tableid = 539
		AND qsicode = 1

		SELECT @v_jobqsicode = sg.qsicode
		FROM taqproject tp
		JOIN subgentables sg
		ON (sg.datacode = tp.searchitemcode AND sg.datasubcode = tp.usageclasscode)
		WHERE tp.taqprojectkey = @i_projectkey
		AND sg.tableid = 550

		SET @v_jobtypecode = NULL
		IF @v_jobqsicode = 45 --Promo
		BEGIN
			SELECT @v_jobtypecode = datacode
			FROM gentables
			WHERE tableid = 543
			AND qsicode = 14
		END
		ELSE IF @v_jobqsicode = 32 --Web Catalog
		BEGIN
			SELECT @v_jobtypecode = datacode
			FROM gentables
			WHERE tableid = 543
			AND qsicode = 13
		END

		SET @v_jobdesc = 'Project Job'
		SET @v_jobdescshort = 'Project Job'
		SET @v_msgdesc = 'Job Pending'
		SET @v_jobkey = NULL
		SET @v_batchkey = NULL

		EXEC qutl_update_job @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, 0, @v_jobdesc, @v_jobdescshort, @i_userid, @i_projectkey, 0, 0,
		@v_msgtype_started, @v_msgdesc, 'Job Started', NULL, 7, @o_error_code OUTPUT, @o_error_desc OUTPUT

	END

GO

GRANT EXEC ON qcs_upload_project TO PUBLIC
GO