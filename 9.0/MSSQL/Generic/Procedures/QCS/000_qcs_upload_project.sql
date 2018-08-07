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
    @o_error_code INTEGER OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS
	BEGIN
		DECLARE @SiteId VARCHAR(256),
				@ErrorVar INT,
				@RowcountVar INT,
				@d_cataloglastmaintdate DATETIME,
				@v_qsicode INT,
				@v_itemtype INT,
				@v_usageclass INT
		

		SET @o_error_code = 0
		SET @o_error_desc = ''

	 IF EXISTS (SELECT * FROM csprojectupdatetracker WHERE projectKey = @i_projectkey) BEGIN
		UPDATE csprojectupdatetracker SET updated = getdate(), lastmaintdate = getdate(), lastuserid = 'TMM_Upload' WHERE projectKey = @i_projectkey
	 END
	 ELSE BEGIN	
		INSERT
			INTO csprojectupdatetracker
				(
				id,
				projectKey,
				created,
				updated,
				lastmaintdate,
				lastuserid
				)
			VALUES
				(
				newid() -- id
				,
				@i_projectkey -- projectKey
				,
				getdate() -- created
				,
				getdate() -- updated
				,
				getdate() -- lastmaintdate
				,
				'TMM_Upload' -- lastuserid
				)

		SELECT @ErrorVar = @@ERROR,
			   @RowcountVar = @@ROWCOUNT
		IF @ErrorVar <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Could not insert csprojectupdatetracker'
			END
	 END
	END

GO

GRANT EXEC ON qcs_upload_project TO PUBLIC
GO