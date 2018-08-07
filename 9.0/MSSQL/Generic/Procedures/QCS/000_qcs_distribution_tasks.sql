IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_distribution_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_distribution_tasks
GO

CREATE PROCEDURE [dbo].qcs_distribution_tasks(
	@transactionKey int,
	@bookKey int,
	@assetKey int,
	@tag varchar(25),
	@partnerKey int,
	@sendDate datetime,
	@updatedBy varchar(40),
	@updatedAt datetime)
AS
BEGIN
	DECLARE @statusCode int
	DECLARE @dateTypeCode int
	DECLARE @taskKey int
	DECLARE @roleCode int

	SELECT @statusCode=datacode FROM gentables WHERE tableid=576 AND qsicode=1
	SELECT @dateTypeCode=datetypecode FROM datetype WHERE qsicode=11
	SELECT @roleCode=datacode FROM gentables WHERE tableid=285 AND qsicode=12
	
	IF @statusCode IS NULL BEGIN
		RAISERROR('Cannot find the Requested Distribution Status in the gentables', 16, 1)
		RETURN
	END

	IF @dateTypeCode IS NULL BEGIN
		RAISERROR('Cannot find valid Distribute Asset datetype', 16, 1)
		RETURN
	END

	IF @roleCode IS NULL BEGIN
		RAISERROR('Cannot find valid Trading Partner Role Code', 16, 1)
		RETURN
	END
	
	EXEC get_next_key @updatedBy, @taskKey OUTPUT
			
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
		transactionkey)
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
		@transactionKey)
END
GO

GRANT EXEC ON qcs_distribution_tasks TO PUBLIC
GO
