IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_cleanup_distribution]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_cleanup_distribution]
GO

CREATE PROCEDURE [dbo].[qcs_cleanup_distribution] (
	@transactionKey INT,
	@bookKey INT,
	@assetKey INT,
	@transactionTag VARCHAR(25),
    @statusTag VARCHAR(25),
	@partnerKey INT,
	@updatedAt DATETIME,
    @fix BIT)
AS BEGIN
    DECLARE @transactionCode INT
	DECLARE @statusCode INT
	DECLARE @dateTypeCode INT
	DECLARE @taskKey INT
	DECLARE @roleCode INT
    DECLARE @partnerContactKey INT
    DECLARE @existingTransactionKey INT
    DECLARE @existingBookKey INT
    DECLARE @existingTransactionTag VARCHAR(25)
    DECLARE @existingAssetKey INT
    DECLARE @existingStatusCode INT
    DECLARE @existingPartnerKey INT
    DECLARE @needsFixing BIT

    CREATE TABLE #log (msg VARCHAR(255) NOT NULL);

    SELECT @partnerContactKey=globalcontactkey FROM globalcontact WHERE partnerkey=@partnerKey
    SELECT @transactionCode=datacode FROM gentables WHERE tableid=575 AND qsicode=2
    SELECT @statusCode=datacode FROM gentables WHERE tableid=576 AND eloquencefieldtag=@statusTag
    SELECT @dateTypeCode=datetypecode FROM datetype WHERE cstransactioncode=@transactionCode AND csstatuscode=@statusCode
	SELECT @roleCode=datacode FROM gentables WHERE tableid=285 AND qsicode=12
	
    IF @partnerContactKey IS NULL BEGIN
        RAISERROR('Cannot find the Partner Contact Key', 16, 1)
        GOTO Finish
    END

	IF @statusCode IS NULL BEGIN
		RAISERROR('Cannot find the Distribution Status in the gentables', 16, 1)
		GOTO Finish
	END

	IF @dateTypeCode IS NULL BEGIN
		RAISERROR('Cannot find valid Distribute Asset datetype', 16, 1)
		GOTO Finish
	END

	IF @roleCode IS NULL BEGIN
		RAISERROR('Cannot find valid Trading Partner Role Code', 16, 1)
		GOTO Finish
	END

    SET @needsFixing = 0
 
    IF NOT EXISTS (SELECT * FROM csdistribution WHERE transactiontag=@transactionTag) BEGIN
        INSERT INTO #log VALUES('NOT FOUND')
        SET @needsFixing = 1
    END

    IF @fix = 1 AND @needsFixing = 1 BEGIN
	    INSERT INTO csdistribution(
		    transactionkey,
		    bookkey,
		    assetkey,
		    partnercontactkey,
		    transactiontag,
		    statuscode,
		    lastuserid,
		    lastmaintdate)
	    VALUES (
		    @transactionKey,
		    @bookKey,
		    @assetKey,
		    @partnerContactKey,
		    @transactionTag,
		    @statusCode,
		    'CLEANUP',
		    @updatedAt)

        IF @@ERROR <> 0
            GOTO Finish

        GOTO Success
    END

    SELECT 
        @existingTransactionKey=transactionkey,
        @existingBookKey=bookkey,
        @existingAssetKey=assetkey,
        @existingPartnerKey=partnercontactkey,
        @existingStatusCode=statuscode
    FROM csdistribution
    WHERE
        transactiontag=@transactionTag

    SET @needsFixing = 0
    IF @existingBookKey != @bookKey BEGIN
        INSERT INTO #log VALUES('bookkey')
        SET @needsFixing = 1
    END
    
    IF @existingAssetKey != @assetKey BEGIN
        INSERT INTO #log VALUES('assetkey')
        SET @needsFixing = 1
    END
    
    IF @existingPartnerKey != @partnerContactKey BEGIN
        INSERT INTO #log VALUES('partnercontactkey')
        SET @needsFixing = 1
    END

    IF @existingStatusCode != @statusCode BEGIN
        INSERT INTO #log VALUES('statuscode')
        SET @needsFixing = 1
    END

    IF @fix = 1 AND @needsFixing = 1 BEGIN
        UPDATE csdistribution
        SET bookkey=@bookKey,
            assetkey=@assetKey,
            partnercontactkey=@partnerContactKey,
            statuscode=@statusCode,
            lastuserid='CLEANUP',
            lastmaintdate=@updatedAt
        WHERE
            transactiontag=@transactionTag
    END
 
Success:
    SELECT msg FROM #log

Finish:
    DROP TABLE #log
END
GO

GRANT EXEC ON qcs_cleanup_distribution TO PUBLIC
GO
