
IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_send_catalogs]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_send_catalogs]
GO

CREATE PROCEDURE [dbo].[qcs_send_catalogs]
(
    @i_projectkey INTEGER,
    @o_error_code INTEGER OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS
	BEGIN
		DECLARE @SiteId VARCHAR(256)
		DECLARE @v_siteName VARCHAR(2000)
		DECLARE @v_description VARCHAR(2000)
		DECLARE @d_archiveDate DATETIME
		DECLARE @d_publishDate DATETIME
		DECLARE @ErrorVar INT
		DECLARE @RowcountVar INT
		DECLARE @d_cataloglastmaintdate DATETIME

		SET @o_error_code = 0
		SET @o_error_desc = ''

		-- Hardcoded as custom SQL for Perseus_pgw - Rick Steves' site...
		SET @SiteId = '74290fc5-1744-48c2-a2fd-a156010dac84'

		--Here we fill a cursor with the cswebcatalogupdatetracker rows that are of type pending and delete them, 
		-- these comprise rows that have not been synced. We're about to add another one which will take precedent.
		DECLARE @csTrackerID uniqueidentifier
		DECLARE @getUnusedCsTrackerIDs CURSOR
		SET @getUnusedCsTrackerIDs = CURSOR FOR
		
		SELECT  id
		FROM    cswebcatalogupdatetracker
		where active = 0
		
		OPEN @getUnusedCsTrackerIDs
			FETCH NEXT
			FROM @getUnusedCsTrackerIDs INTO @csTrackerID
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Delete all non-submitted cswebcatalogupdatetracker rows
				delete from cswebcatalogupdatetracker where id = @csTrackerID
								
				FETCH NEXT
				FROM @getUnusedCsTrackerIDs INTO @csTrackerID
			END
		CLOSE @getUnusedCsTrackerIDs
		DEALLOCATE @getUnusedCsTrackerIDs

		-- Site name
		SELECT @v_siteName = taqprojecttitle
			FROM taqproject t
			WHERE taqprojectkey = @i_projectkey

		-- Description
		SELECT @v_description = taqprojecttitle
			FROM taqproject t
			WHERE taqprojectkey = @i_projectkey

		-- Archive Date
		SELECT @d_archiveDate = activedate
			FROM taqprojecttask t
			WHERE taqprojectkey = @i_projectkey
				AND datetypecode IN (SELECT datetypecode
										 FROM datetype
										 WHERE qsicode = 18)
		-- Publish Date
		SELECT @d_publishDate = activedate
			FROM taqprojecttask t
			WHERE taqprojectkey = @i_projectkey
				AND datetypecode IN (SELECT datetypecode
										 FROM datetype
										 WHERE qsicode = 19)

		-- Catalog Last Maint Date
		SELECT @d_cataloglastmaintdate = lastmaintdate
			FROM taqproject t
			WHERE taqprojectkey = @i_projectkey

		INSERT
			INTO cswebcatalogupdatetracker
				(
				id,
				projectKey,
				webcatalogupdated,
				lastmaintdate,
				publishdate,
				archivedate,
				lastuserid,
				active,
				siteid,
				name,
				[description]
				)
			VALUES
				(
				newid() -- id
				,
				@i_projectkey -- projectKey
				,
				@d_cataloglastmaintdate -- webcatalogupdated
				,
				getdate() -- lastmaintdate
				,
				@d_publishDate -- publishdate
				,
				@d_archiveDate -- archivedate
				,
				'TMM_Upload' -- lastuserid
				,
				1 -- active ( 0 = Cloud.PublishStatus enum "Pending" )
				,
				@SiteId
				,
				'Rick Steves Digital ecommerce site' -- name
				,
				'Rick Steves Digital ecommerce site' -- description
				)

		SELECT @ErrorVar = @@ERROR,
			   @RowcountVar = @@ROWCOUNT
		IF @ErrorVar <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Could not insert cswebcatalogupdatetracker'
			END

	END

GO

grant execute on dbo.qcs_send_catalogs  to public
go
