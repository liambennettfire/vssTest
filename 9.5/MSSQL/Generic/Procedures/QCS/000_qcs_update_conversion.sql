IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_csconversion')
-- Remove obsolete proc
DROP PROCEDURE  qcs_update_csconversion
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_conversion')
DROP PROCEDURE  qcs_update_conversion
GO

CREATE PROCEDURE qcs_update_conversion (
    @transactionTag VARCHAR(25),
    @statusTag VARCHAR(25),
    @notes VARCHAR(2000),
    @errorText VARCHAR(2000),
    @updatedBy VARCHAR(40),
    @updatedAt DATETIME)
AS

BEGIN
    DECLARE @statusCode INT
    DECLARE @transactionKey INT
    DECLARE @msg VARCHAR(255)

    SELECT @statusCode = csstatuscode FROM csconversionstatus WHERE cloudstatustag = @statusTag
    SELECT @transactionKey = transactionkey FROM csconversion WHERE transactiontag = @transactionTag

    IF @transactionKey IS NULL BEGIN
        SET @msg = 'Could not find csconversion for ' + @transactionTag
        RAISERROR(@msg, 16, 1)
        RETURN
    END

    IF @statusCode IS NULL BEGIN
        SET @msg = 'Cound not find csstatuscode for ' + @statusTag
        RAISERROR(@msg, 16, 1)
        RETURN
    END

    UPDATE csconversion
    SET lastuserid = 'Cloud', 
        lastmaintdate = @updatedAt,
        notes = @notes, 
        errormessage = @errorText,
        statuscode = @statusCode
    WHERE transactionkey = @transactionKey

END
GO

GRANT EXEC ON qcs_update_conversion TO PUBLIC
GO
