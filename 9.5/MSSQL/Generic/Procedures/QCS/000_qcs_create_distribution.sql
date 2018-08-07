IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_create_csdistribution')
-- Remove obsolete proc
DROP PROCEDURE  qcs_create_csdistribution
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_create_distribution')
DROP PROCEDURE  qcs_create_distribution
GO

CREATE PROCEDURE qcs_create_distribution (
    @transactionKey INT,
    @transactionTag VARCHAR(25),
    @bookKey INT,
    @assetKey INT,
    @partnerKey INT,
    @sendDate DATETIME,
    @jobKey INT,
    @updatedBy VARCHAR(40),
    @updatedAt DATETIME
)
AS

BEGIN
    DECLARE @statusCode INT
	DECLARE @dateTypeCode INT
	DECLARE @roleCode INT
	DECLARE @taskKey INT
	DECLARE @globalContactKey INT
    DECLARE @msg VARCHAR(255)

	IF EXISTS (SELECT 1 FROM csdistribution WHERE transactionkey=@transactionKey)
		RETURN

	SELECT @statusCode=datacode FROM gentables WHERE tableid=576 AND qsicode=1
	SELECT @dateTypeCode=datetypecode FROM datetype WHERE qsicode = 11
	SELECT @roleCode=datacode FROM gentables WHERE tableid=285 AND qsicode=12

	IF @statusCode IS NULL BEGIN
		RAISERROR('Could not find statuscode for Distribute Asset', 16, 1)
		RETURN
	END

	IF @dateTypeCode IS NULL BEGIN
		RAISERROR ('Cannot find valid Distribute Asset datetype', 16, 1)
		RETURN
	END

	IF @roleCode IS NULL BEGIN
		RAISERROR ('Cannot find valid Trading Partner Role Code', 16, 1)
		RETURN
	END

	INSERT INTO csdistribution (
		transactionkey,
		bookkey,
		assetkey,
		partnercontactkey,
		transactiontag,
		statuscode,
		qsijobkey,
		lastuserid,
		lastmaintdate)
	VALUES (
		@transactionKey,
		@bookKey,
		@assetKey,
		@partnerKey,
		@transactionTag,
		@statusCode,
		@jobKey,
		@updatedBy,
		@updatedAt)

	IF @@ERROR != 0
		RETURN
	
	EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT

	-- Insert Distribute Asset datetype
	INSERT INTO taqprojecttask (
		taqtaskkey,
		datetypecode,
		taqelementkey,
		globalcontactkey,
		rolecode,
		bookkey,
		activedate,
		originaldate,
		actualind,
		lastmaintdate,
		lastuserid,
		printingkey,
		transactionkey,
		qsijobkey)
	VALUES (
		@taskKey,
		@dateTypeCode,
		@assetKey,
		@partnerKey,
		@roleCode,
		@bookKey,
		@sendDate,
		@sendDate,
		0,
		@updatedAt,
		@updatedBy,
		1,
		@transactionKey,
		@jobKey)

    SELECT * FROM taqprojectelementpartner WHERE assetkey = @assetKey AND bookkey = @bookKey AND partnercontactkey = @partnerKey 
    IF @@ROWCOUNT = 0
    BEGIN
		INSERT INTO taqprojectelementpartner (
			assetkey,
			bookkey,
			partnercontactkey,
			resendind,
			lastuserid,
			lastmaintdate)
		VALUES (
			@assetKey,
			@bookKey,
			@partnerKey,
			1,
			@updatedBy,
			@updatedAt
		)
    END
END
GO

GRANT EXEC ON qcs_create_distribution TO PUBLIC
GO