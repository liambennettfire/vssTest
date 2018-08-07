IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_cleanup_distribution_task]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_cleanup_distribution_task]
GO

CREATE PROCEDURE [dbo].[qcs_cleanup_distribution_task] (
	@transactionTag VARCHAR(25),
    @csEventId UNIQUEIDENTIFIER,
    @statusTag VARCHAR(25),
    @note VARCHAR(2000),
	@updatedAt DATETIME,
    @fix BIT)
AS 
/***********************************************************************************
**    Change History
************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
*************************************************************************************/
BEGIN
    IF @transactionTag IS NULL BEGIN
        RAISERROR('NULL transactionTag', 16, 1)
        RETURN
    END

    DECLARE @transactionCode INT
	DECLARE @statusCode INT
    DECLARE @requestedStatusCode INT
    DECLARE @completedStatusCode INT
    DECLARE @failedStatusCode INT
    DECLARE @canceledStatusCode INT
    DECLARE @distStatusCode INT
	DECLARE @dateTypeCode INT
    DECLARE @completedDateTypeCode INT
    DECLARE @transactionKey INT
    DECLARE @bookKey INT
    DECLARE @partnerContactKey INT
    DECLARE @assetKey INT
    DECLARE @taskKey INT
    DECLARE @daTaskKey INT
    DECLARE @actualInd INT
    DECLARE @activeDate DATETIME
    DECLARE @originalDate DATETIME
    DECLARE @roleCode INT
    DECLARE @fixActualInd BIT
    DECLARE @fixActiveDate BIT
    DECLARE @fixNotFound BIT
    DECLARE @fixDaActualInd BIT
    DECLARE @fixDaActiveDate BIT
    DECLARE @fixDaNotFound BIT
    DECLARE @error VARCHAR(255)

    SET @fixActualInd = 0
    SET @fixActiveDate = 0
    SET @fixNotFound = 0
    SET @fixDaActualInd = 0
    SET @fixDaActiveDate = 0
    SET @fixDaNotFound = 0

    CREATE TABLE #log (msg VARCHAR(255) NOT NULL);

    SELECT 
        @transactionKey = transactionkey,
        @bookKey = bookkey,
        @partnerContactKey = partnercontactkey,
        @assetKey = assetkey, 
        @distStatusCode = statuscode 
    FROM csdistribution 
    WHERE transactiontag = @transactionTag
    
    SELECT @roleCode = datacode FROM gentables WHERE tableid=285 AND qsicode=12
    SELECT @transactionCode=datacode FROM gentables WHERE tableid=575 AND qsicode=2
    SELECT @statusCode=datacode FROM gentables WHERE tableid=576 AND eloquencefieldtag=@statusTag
    SELECT @completedStatusCode=datacode FROM gentables WHERE tableid=576 AND eloquencefieldtag='CLD_DS_Completed'
    SELECT @requestedStatusCode=datacode FROM gentables WHERE tableid=576 AND eloquencefieldtag='CLD_DS_Requested'
    SELECT @dateTypeCode=datetypecode FROM datetype WHERE cstransactioncode=@transactionCode AND csstatuscode=@statusCode
    SELECT @completedDateTypeCode=datetypecode FROM datetype WHERE cstransactioncode=@transactionCode AND csstatuscode=@completedStatusCode
    
    IF @transactionKey IS NULL BEGIN
        SET @error = 'Distribution NOT FOUND'
        GOTO Finish
    END

    IF @distStatusCode IS NULL BEGIN
        SET @error = 'Cannot find Distribution Status Code'
        GOTO Finish
    END

    IF @roleCode IS NULL BEGIN
        SET @error = 'Cannot find Role Code'
        GOTO Finish
    END

    IF @transactionCode IS NULL BEGIN
        SET @error = 'Cannot find Transaction Code'
        GOTO Finish
    END

    IF @statusCode IS NULL BEGIN
        SET @error = 'Cannot find valid Status Code'
        GOTO Finish
    END

    IF @completedStatusCode IS NULL BEGIN
        SET @error = 'Cannot find valid Status Code for CLD_DS_Completed'
        GOTO Finish
    END
    	
    IF @requestedStatusCode IS NULL BEGIN
        SET @error = 'Cannot find valid Status Code for CLD_DS_Requested'
        GOTO Finish
    END

    IF @dateTypeCode IS NULL BEGIN
        SET @error = 'Cannot find valid Date Type Code'
        GOTO Finish
    END

    IF @completedDateTypeCode IS NULL BEGIN
        SET @error = 'Cannot find valid Date Type Code for CLD_DS_Completed'
        GOTO Finish
    END

    SELECT 
        @taskKey = taqtaskkey,
        @actualInd=actualind,
        @activeDate=activedate
    FROM taqprojecttask
    WHERE cseventid = @csEventId

    IF @taskKey IS NULL BEGIN
        SELECT TOP 1 
            @taskKey = taqtaskkey,
            @actualInd=actualind,
            @activeDate=activedate
        FROM taqprojecttask
        WHERE
            transactionkey = @transactionKey AND
            datetypecode = @dateTypeCode AND
            cseventid IS NULL
        ORDER BY activedate
    END

    IF @taskKey IS NOT NULL BEGIN
        IF DATEDIFF(minute, @activeDate, @updatedAt) != 0 BEGIN
            INSERT INTO #log VALUES('activedate')
            SET @fixActiveDate = 1
        END

        IF @actualInd != 1 BEGIN
            INSERT INTO #log VALUES('actualind')
            SET @fixActualInd = 1
        END

        IF @fix = 1 AND (@fixActiveDate = 1 OR @fixActualInd = 1) BEGIN
            -- Fix Normal Task
            PRINT 'Fix Task taqtaskkey=' + CAST(@taskKey AS VARCHAR(20))
            UPDATE taqprojecttask
            SET activedate = @updatedAt,
                actualind = 1,
                cseventid = @csEventId,
                lastmaintdate = GETDATE(),
                lastuserid = 'CLEANUP'
            WHERE taqtaskkey = @taskKey

            IF @@ERROR <> 0
                GOTO Finish
        END
    END
    ELSE BEGIN
        INSERT INTO #log VALUES('NOT FOUND')
        SET @fixNotFound = 1

        IF @fix = 1 BEGIN
            EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT
           
            
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
                taqtasknote,
                transactionkey,
                cseventid)
            VALUES (
                @taskKey,
                @dateTypeCode,
                @assetKey,
                @partnerContactKey,
                @roleCode,
                @bookKey,
                @updatedAt,
                @updatedAt,
                1,
                getdate(),
                'CLEANUP',
                1,
                @note,
                @transactionKey,
                @csEventId)    
            
        END
    END


    IF @statusTag = 'CLD_DS_Requested' AND @distStatusCode != @completedStatusCode BEGIN
        SET @actualInd = NULL
        SET @activeDate = NULL

        SELECT TOP 1 
            @daTaskKey = taqtaskkey,
            @actualInd = actualind,
            @activeDate = activedate
        FROM taqprojecttask
        WHERE
            transactionkey = @transactionKey AND
            datetypecode = @completedDateTypeCode AND
            cseventid IS NULL
        ORDER BY activedate

        IF @daTaskKey IS NOT NULL BEGIN
            IF DATEDIFF(minute, @activeDate, @updatedAt) != 0 BEGIN
                INSERT INTO #log VALUES('DA activedate')
                SET @fixDaActiveDate = 1
            END

            IF @actualInd != 0 BEGIN
                INSERT INTO #log VALUES('DA actualind')
                SET @fixDaActualInd = 1
            END

            IF @fix = 1 AND (@fixDaActiveDate = 1 OR @fixDaActualInd = 1) BEGIN
                -- Fix Normal Task
                PRINT 'Fix Task taqtaskkey=' + CAST(@taskKey AS VARCHAR(20))
                UPDATE taqprojecttask
                SET activedate = @updatedAt,
                    actualind = 0,
                    lastmaintdate = GETDATE(),
                    lastuserid = 'CLEANUP'
                WHERE taqtaskkey = @daTaskKey

                IF @@ERROR <> 0
                    GOTO Finish
            END
        END
        ELSE BEGIN
            INSERT INTO #log VALUES('DA NOT FOUND')
            SET @fixDaNotFound = 1

            IF @fix = 1 BEGIN
                EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT
           
            
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
                    taqtasknote,
                    transactionkey)
                VALUES (
                    @daTaskKey,
                    @completedDateTypeCode,
                    @assetKey,
                    @partnerContactKey,
                    @roleCode,
                    @bookKey,
                    @updatedAt,
                    @updatedAt,
                    1,
                    getdate(),
                    'CLEANUP',
                    1,
                    @note,
                    @transactionKey)
            END
        END
    END

Success:
    IF  @fix = 1 AND (
        @fixActualInd = 1 OR 
        @fixActiveDate = 1 OR
        @fixNotFound = 1 OR
        @fixDaActualInd = 1 OR
        @fixDaActiveDate = 1 OR
        @fixDaNotFound = 1) BEGIN

        BEGIN TRY
            INSERT INTO csdistributiontaskcleanup(
                taskkey,
                cseventid,
                transactiontag,
                transactionkey,
                statustag,
                updatedat,
                bookkey,
                assetkey,
                partnercontactkey, 
                datetypecode,
                actualindfixed, 
                activedatefixed,
                notfoundfixed,
                distributeasset_taskkey,
                distributeasset_actualindfixed,
                distributeasset_activedatefixed,
                distributeasset_notfoundfixed, 
                lastmaintdate)
            VALUES (
                @taskKey,
                @csEventId,
                @transactionTag,
                @transactionKey,
                @statusTag,
                @updatedAt,
                @bookKey,
                @assetKey,
                @partnerContactKey,
                @dateTypeCode,
                @fixActualInd,
                @fixActiveDate,
                @fixNotFound,
                @daTaskKey,
                @fixDaActualInd,
                @fixDaActiveDate,
                @fixDaNotFound,
                GETDATE())
        END TRY
        BEGIN CATCH
            SET @error = 'Failed to track cleanup for ' + CAST(@taskKey AS VARCHAR(25)) + ': ' + ERROR_MESSAGE()
            GOTO Finish
        END CATCH
    END

    SELECT msg FROM #log

Finish:
    IF @error IS NOT NULL BEGIN
        INSERT INTO csdistributiontaskcleanuperror(transactiontag, statustag, updatedat, errortext, lastmaintdate)
        VALUES(@transactionTag, @statusTag, @updatedAt, @error, GETDATE())
        RAISERROR(@error, 16, 1)
    END
    
    DROP TABLE #log
END
GO

GRANT EXEC ON qcs_cleanup_distribution_task TO PUBLIC
GO
