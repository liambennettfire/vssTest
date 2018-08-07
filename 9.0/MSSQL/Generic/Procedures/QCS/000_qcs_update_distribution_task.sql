IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_distribution_tasks')
-- Remove Obsolete Proc
DROP PROCEDURE  qcs_update_distribution_tasks
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_distribution_task')
DROP PROCEDURE  qcs_update_distribution_task
GO

CREATE PROCEDURE qcs_update_distribution_task (
    @transactionTag VARCHAR(25),
    @statusTag VARCHAR(25),
    @taqTaskNote VARCHAR(2000),
    @csEventId UNIQUEIDENTIFIER,
    @updatedBy VARCHAR(40),
    @sendDate DATETIME)
AS

BEGIN
    DECLARE @taskKey INT
    DECLARE @bookKey INT
    DECLARE @assetKey INT
    DECLARE @partnerKey INT
    DECLARE @roleCode INT
    DECLARE @dateTypeCode INT
    DECLARE @transactionKey INT
    DECLARE @globalContactKey INT
    DECLARE @msg VARCHAR(255)

    SELECT @roleCode = datacode FROM gentables WHERE tableid=285 AND qsicode=12
    SELECT @dateTypeCode = datetypecode FROM csdistributionstatus WHERE cloudstatustag=@statusTag
    
    SELECT 
        @transactionKey = transactionkey,
        @bookKey = bookkey,
        @assetKey = assetkey,
        @partnerKey = partnercontactkey
    FROM csdistribution 
    WHERE transactiontag = @transactionTag

    IF @transactionKey IS NULL BEGIN
        SET @msg = 'Could not find transactionkey for taqprojecttask.  transactionTag=' + @transactionTag  
        RAISERROR(@msg, 16, 1)
        RETURN
    END

    IF @dateTypeCode IS NULL BEGIN
        SET @msg = 'Could not find datetypecode for taqprojecttask.  transactionTag=' + @transactionTag + '; statusTag='+ @statusTag 
        RAISERROR(@msg, 16, 1)
        RETURN
    END

    IF @roleCode IS NULL BEGIN
        RAISERROR('Could not find rolecode for taqprojecttask.', 16, 1)
        RETURN
    END

    SELECT @taskKey = taqtaskkey
    FROM taqprojecttask
    WHERE cseventid = @csEventId

    IF @taskKey IS NULL BEGIN
        SELECT @taskKey = taqtaskkey
        FROM taqprojecttask
        WHERE
            transactionkey = @transactionKey AND
            datetypecode = @dateTypeCode AND
            actualind = 0
    END
 
    IF @taskKey IS NOT NULL BEGIN           
        -- if it does then update as follows
        UPDATE taqprojecttask
        SET activedate = @sendDate, 
            actualind = 1,
            cseventid = @csEventId,
            lastuserid = 'Cloud', 
            lastmaintdate = getdate()
        WHERE
            taqtaskkey = @taskKey
    END
    ELSE BEGIN
        -- otherwise insert
        SELECT @globalContactKey=globalcontactkey	FROM globalcontact WHERE partnerkey=@partnerKey
         
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
            taqtasknote,
            transactionkey,
            cseventid)
        VALUES (
            @taskKey,
            @dateTypeCode,
            @assetKey,
            @globalContactKey,
            @roleCode,
            @bookKey,
            @sendDate,
            @sendDate,
            1,
            getdate(),
            'Cloud',
            1,
            @taqTaskNote,
            @transactionKey,
            @csEventId)    
    END
END
GO

GRANT EXEC ON qcs_update_distribution_task TO PUBLIC
GO
