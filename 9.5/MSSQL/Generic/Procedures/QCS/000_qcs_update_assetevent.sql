IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_update_assetevent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_update_assetevent]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[qcs_update_assetevent](
    @assetId uniqueidentifier, 
    @statusTag varchar(25), 
    @updatedBy varchar(50),
    @updatedAt datetime, 
    @metadata bit = 0,
    @csEventId uniqueidentifier,
    @jobKey int = 0)
AS
BEGIN
    DECLARE @taskKey int
    DECLARE @elementKey int
    DECLARE @dateTypeCode int
    DECLARE @bookKey int
    DECLARE @assetIdStr varchar(50)
    DECLARE @elementKeyStr varchar(25)

    SET @assetIdStr = CAST(@assetId AS varchar(50))
    
    SELECT TOP 1 @elementKey = tpn.elementKey FROM taqproductnumbers tpn WHERE tpn.productnumber = CAST(@assetId AS varchar(50))
		AND EXISTS (SELECT tpe.bookkey FROM taqprojectelement tpe WHERE tpe.taqelementkey = tpn.elementKey)
    IF @elementKey IS NULL BEGIN
        RAISERROR('Cannot find element for Asset Id %s', 16, 1, @assetIdStr)
        RETURN
    END

    SELECT @bookKey = bookkey FROM taqprojectelement WHERE taqelementkey = @elementKey
    IF @bookKey IS NULL BEGIN
        SET @elementKeyStr = CAST(@elementKey AS varchar(25))
        RAISERROR('Cannot find book for Element Key %s based on Asset Id %s', 16, 1, @elementKeyStr, @assetIdStr)
        RETURN
    END
    
    SELECT 
        @dateTypeCode = datetypecode
    FROM
        datetype d,
        gentables t,
        gentables s
    WHERE
        d.cstransactioncode = t.datacode AND
        d.csstatuscode = s.datacode AND
        t.tableid = 575 /* TaskTrackingType */ AND
        t.qsicode = 1 AND
        t.deletestatus = 'N' AND
        s.tableid = 593 /* ElementStatus */ AND
        s.eloquencefieldtag = @statusTag AND
        s.deletestatus = 'N'

    IF @dateTypeCode IS NULL BEGIN
        RAISERROR('There is no valid datetype for Asset Status Tag %s.', 16, 1, @statusTag)
        RETURN
    END
        
    IF @metadata = 1 BEGIN
        SELECT TOP 1 @taskKey=taqtaskkey
        FROM taqprojecttask 
        WHERE taqelementkey=@elementKey and datetypecode=@dateTypeCode
    END
    ELSE BEGIN
        SELECT TOP 1 @taskKey=taqtaskkey
        FROM taqprojecttask
        WHERE cseventid=@csEventid

        IF @taskKey IS NULL BEGIN
            SELECT TOP 1 @taskKey=taqtaskkey
            FROM taqprojecttask
            WHERE 
                taqelementkey=@elementKey AND
                datetypecode=@dateTypeCode AND
                (CASE WHEN DATEDIFF(day, activedate, GETDATE()) = 0
                    THEN ABS(DATEDIFF(ms, activedate, GETDATE())) END) < 3
        END
    END

     IF @taskKey IS NOT NULL BEGIN
        UPDATE taqprojecttask
        SET datetypecode = @dateTypeCode,
            activedate = @updatedAt,
            lastmaintdate = @updatedAt,
            lastuserid = @updatedBy,
            cseventid = @csEventId,
            qsijobkey = CASE WHEN @jobKey > 0 THEN @jobKey ELSE qsijobkey END
        WHERE taqtaskkey=@taskKey
    END
    ELSE BEGIN
        EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT
        INSERT INTO taqprojecttask (
            taqtaskkey, 
            datetypecode, 
            taqelementkey, 
            bookkey, 
            activedate, 
            originaldate, 
            actualind, 
            printingkey,
            lastmaintdate, 
            lastuserid,
            cseventid,
            qsijobkey)
        VALUES (
            @taskKey,
            @dateTypeCode,
            @elementKey,
            @bookKey,
            @updatedAt,
            @updatedAt,
            1,
            1,
            @updatedAt,
            @updatedBy,
            @csEventId,
            @jobKey)
    END
END
GO

GRANT EXEC ON qcs_update_assetevent TO PUBLIC
GO
