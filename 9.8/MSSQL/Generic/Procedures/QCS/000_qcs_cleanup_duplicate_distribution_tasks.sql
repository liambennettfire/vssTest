IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_cleanup_duplicate_distribution_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_cleanup_duplicate_distribution_tasks]
GO

CREATE PROCEDURE [dbo].[qcs_cleanup_duplicate_distribution_tasks]
AS BEGIN
    DECLARE @transactionCode INT
    DECLARE @completedStatusCode INT
    DECLARE @completedDateTypeCode INT
    DECLARE @error VARCHAR(255)
    
    SELECT @transactionCode=datacode FROM gentables WHERE tableid=575 AND qsicode=2
    SELECT @completedStatusCode=datacode FROM gentables WHERE tableid=576 AND eloquencefieldtag='CLD_DS_Completed'
    SELECT @completedDateTypeCode=datetypecode FROM datetype WHERE cstransactioncode=@transactionCode AND csstatuscode=@completedStatusCode

    CREATE TABLE #duplicates (
        taskkey INT, 
        bookkey INT, 
        assetkey INT,
        partnercontactkey INT,
        datetypecode INT)

    INSERT INTO #duplicates
    SELECT
        t.taqtaskkey,
        d.bookkey,
        d.assetkey,
        d.partnercontactkey,
        t.datetypecode
    FROM 
        taqprojecttask t,
        csdistribution d
    WHERE
        t.transactionkey = d.transactionkey AND
        t.cseventid IS NULL AND NOT ( 
            t.datetypecode = @completedDateTypeCode AND
            t.actualind = 0)

    INSERT INTO csdistributiontaskcleanup(
        taskkey,
        bookkey,
        assetkey,
        partnercontactkey,
        datetypecode,
        duplicateremoved,
        lastmaintdate)
    SELECT
        taskkey,
        bookkey,
        assetkey,
        partnercontactkey,
        datetypecode, 
        1,
        GETDATE()
    FROM #duplicates

    DELETE FROM taqprojecttask WHERE taqtaskkey IN (SELECT taskkey FROM #duplicates)
    
    DROP TABLE #duplicates

    -- Update Distribute Asset tasks so that originaldate = requested date
    UPDATE t
    SET t.originaldate=r.activedate
    FROM 
	    taqprojecttask t, 
	    taqprojecttask r, 
	    csdistributionstatus rs, 
	    csdistributionstatus ts
    WHERE 
	    t.transactionkey=r.transactionkey AND 
	    r.datetypecode=rs.datetypecode AND 
	    ts.datetypecode=t.datetypecode AND 
	    ts.cloudstatustag='CLD_DS_Completed' AND
	    rs.cloudstatustag='CLD_DS_Requested' AND 
	    --t.originaldate > t.activedate AND 
	    t.transactionkey is not null

    -- Update Non- Distribute Asset tasks so that originaldate = activedate
    UPDATE t
    SET t.originaldate=t.activedate
    FROM taqprojecttask t, csdistributionstatus s
    WHERE 
	    t.datetypecode = s.datetypecode AND 
	    s.cloudstatustag != 'CLD_DS_Completed' AND
	    t.originaldate != t.activedate AND 
	    t.transactionkey is not null

END
GO

GRANT EXEC ON qcs_cleanup_duplicate_distribution_tasks TO PUBLIC
GO
