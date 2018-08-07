IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_csdistribution')
-- Remove obsolete proc
DROP PROCEDURE  qcs_update_csdistribution
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_distribution')
DROP PROCEDURE  qcs_update_distribution
GO

CREATE PROCEDURE [dbo].[qcs_update_distribution] (
    @transactionKey INT,
    @transactionTag VARCHAR(25),
    @statusTag VARCHAR(25),
    @notes VARCHAR(2000),
    @assetId UNIQUEIDENTIFIER,
    @partnerKey INT,
    @jobKey INT,
    @sendDate DATETIME,
    @updatedBy VARCHAR(40),
    @updatedAt DATETIME)
AS
/***********************************************************************************
**    Change History
************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
*************************************************************************************/
BEGIN
    DECLARE @statusCode INT
    DECLARE @assetKey INT
    DECLARE @bookKey INT
    DECLARE @distributeDateTypeCode INT
    DECLARE @roleCode INT
    DECLARE @taskKey INT
    DECLARE @globalContactKey INT
    DECLARE @msg VARCHAR(255)

    SELECT @statusCode = csstatuscode FROM csdistributionstatus WHERE cloudstatustag = @statusTag

    IF @statusCode IS NULL BEGIN
        SET @msg = 'Could not find csstatuscode for ' + @statusTag
        RAISERROR(@msg, 16, 1)
        RETURN
    END
		
		SELECT TOP 1
        @assetKey=A.taqelementkey,
        @bookKey=A.bookkey
    FROM taqprojectelement A
    JOIN taqproductnumbers N ON A.taqelementkey=N.elementkey
    WHERE
        N.productidcode=8 AND
        N.productnumber=CAST(@assetId AS VARCHAR(50))
		
    IF EXISTS (SELECT 1 FROM csdistribution WHERE transactionkey=@transactionKey) BEGIN
        UPDATE csdistribution
        SET lastuserid = @updatedBy, 
            lastmaintdate = @updatedAt,
            notes = @notes, 
            statuscode = @statusCode
        WHERE transactionkey = @transactionKey  
    END
    ELSE BEGIN
        IF @assetKey IS NULL BEGIN
            SET @msg = 'Could not find taqprojectelement for ' + CAST(@assetId AS VARCHAR(50))
            RAISERROR(@msg, 16, 1)
            RETURN
        END

        SELECT @globalContactKey=globalcontactkey	FROM globalcontact WHERE partnerkey=@partnerKey
        SELECT @distributeDateTypeCode=datetypecode FROM datetype WHERE qsicode=11
        SELECT @roleCode=datacode FROM gentables WHERE tableid=285 AND qsicode=12


        IF @globalContactKey IS NULL BEGIN
            SET @msg = 'Could not find globalcontact for ' + CAST(@partnerKey AS VARCHAR(50))
            RAISERROR(@msg, 16, 1)
            RETURN
        END

        IF @distributeDateTypeCode IS NULL BEGIN
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
            @globalContactKey,
            @transactionTag,
            @statusCode,
            @jobKey,
            @updatedBy,
            @updatedAt)

        
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
            @distributeDateTypeCode,
            @assetKey,
            @globalContactKey,
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
    END

    SELECT * FROM csdistribution WHERE transactionkey=@transactionKey
    SELECT * FROM taqprojecttask WHERE transactionkey=@transactionKey
    SELECT @bookKey
END
GO

GRANT EXEC ON [dbo].[qcs_update_distribution] TO PUBLIC
GO
