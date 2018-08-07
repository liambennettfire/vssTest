IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_conversion_tasks')
-- Remove Obsolete Proc
DROP PROCEDURE  qcs_update_conversion_tasks
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_conversion_task')
DROP PROCEDURE  qcs_update_conversion_task
GO

CREATE PROCEDURE qcs_update_conversion_task (
    @transactionTag VARCHAR(25),
    @statusTag VARCHAR(25),
    @taqTaskNote VARCHAR(2000),
    @csEventId UNIQUEIDENTIFIER,
    @updatedBy VARCHAR(40),
    @sendDate DATETIME)
AS
/***********************************************************************************
**    Change History
************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
*************************************************************************************/
BEGIN
    DECLARE @taskKey INT
    DECLARE @bookKey INT
    DECLARE @assetKey INT
    DECLARE @partnerKey INT
    DECLARE @roleCode INT
    DECLARE @dateTypeCode INT
    DECLARE @transactionKey INT

    SELECT @roleCode = datacode FROM gentables WHERE tableid=285 AND qsicode=13
    SELECT @dateTypeCode = datetypecode FROM csconversionstatus WHERE cloudstatustag=@statusTag
    
    SELECT 
        @transactionKey = transactionkey,
        @assetKey = targetassetkey,
        @partnerKey = converter
    FROM csconversion 
    WHERE transactiontag = @transactionTag

    SELECT @bookKey = bookkey FROM taqprojectelement WHERE taqelementkey = @assetKey

    IF @transactionKey IS NULL BEGIN
        RAISERROR('Could not find transactionkey for taqprojecttask.', 16, 1)
        RETURN
    END

    IF @dateTypeCode IS NULL BEGIN
        RAISERROR('Could not find datetypecode for taqprojecttask.', 16, 1)
        RETURN
    END

    IF @roleCode IS NULL BEGIN
        RAISERROR('Could not find rolecode for taqprojecttask.', 16, 1)
        RETURN
    END

    IF @bookKey IS NULL BEGIN
        RAISERROR('Could not find bookkey for taqprojecttask.', 16, 1)
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
            @partnerKey,
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

GRANT EXEC ON qcs_update_conversion_task TO PUBLIC
GO
