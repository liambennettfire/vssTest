
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'dbo.qproject_delete_projects_by_date_status') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_delete_projects_by_date_status
GO

CREATE PROCEDURE qproject_delete_projects_by_date_status
(
	@i_itemType INT,
	@i_class INT,
	@i_beginDate DATETIME,
	@i_endDate DATETIME,
	@o_error_code INT OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT,
	@i_statusCode INT = NULL,
	@i_deleteLastPrintingInd INT = NULL
)
AS

BEGIN

DECLARE 
	@v_projectKey INT,
	@v_userKey VARCHAR(50),
	@v_errorCode INT,
	@v_error_desc VARCHAR(MAX),
	@v_isprinting INT

SET @v_isprinting = 0

IF (@i_itemType IS NULL OR @i_class IS NULL)
BEGIN
	SET @o_error_code = -1
    SET @o_error_desc = 'One of the following fields needs to be populated at a minimum itemtype or class'
	RETURN
END


IF EXISTS(SELECT 1 FROM subgentables gen
			WHERE gen.tableId = 550
			AND gen.dataCode = @i_itemType
			AND gen.datasubcode = @i_class
			AND gen.qsicode = 40)
SET @v_isprinting = 1

SELECT
	tp.taqProjectKey
INTO
	#tmp_projectDeletes
FROM
	taqProject tp
INNER JOIN taqProjectTask tt
	ON tp.taqprojectkey = tt.taqprojectkey
WHERE
	tp.searchitemcode = @i_itemType
AND tp.usageclasscode = @i_class
AND tp.taqprojectstatuscode = IIF(@i_statusCode IS NULL,tp.taqprojectstatuscode,@i_statusCode)
AND tt.activedate BETWEEN @i_beginDate AND @i_endDate
AND @v_isprinting = 0
UNION
SELECT
	tp.taqProjectKey
FROM
	taqProject tp
INNER JOIN taqProjectTitle tpt
	ON tp.taqprojectkey = tpt.taqprojectkey
INNER JOIN taqProjectTask tt
	ON tpt.bookkey = tt.bookkey
	AND tpt.printingkey = tt.printingkey
WHERE
	tp.searchitemcode = @i_itemType
AND tp.usageclasscode = @i_class
AND tp.taqprojectstatuscode = IIF(@i_statusCode IS NULL,tp.taqprojectstatuscode,@i_statusCode)
AND tt.activedate BETWEEN @i_beginDate AND @i_endDate
AND @v_isprinting = 1 


--If @i_deleteLastPrintingInd is not set 1 don't delete it
IF (@v_isprinting = 1 AND ISNULL(@i_deleteLastPrintingInd,0) = 0)
BEGIN
	DELETE t
	FROM #tmp_projectDeletes t
	INNER JOIN taqProjectTitle tt
		ON t.taqprojectkey = tt.taqprojectkey
	WHERE NOT EXISTS(SELECT 1 FROM taqProjectTitle ch
					WHERE tt.bookkey = ch.bookkey
					AND tt.projectrolecode = ch.projectrolecode
					AND ch.printingkey > tt.printingkey)
	OR tt.printingkey = 1
END


DECLARE csr_projectsToDelete CURSOR FAST_FORWARD FOR
SELECT taqProjectKey FROM #tmp_projectDeletes

OPEN csr_projectsToDelete
FETCH NEXT FROM csr_projectsToDelete INTO @v_projectKey

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'ProjectKey= '+ CAST(@v_projectKey AS VARCHAR(50))
	EXEC dbo.qproject_delete_project_lessrestrictive @v_projectKey, @v_userKey, @v_errorCode OUT, @v_error_desc OUT
	
	FETCH NEXT FROM csr_projectsToDelete INTO @v_projectKey
END
CLOSE csr_projectsToDelete
DEALLOCATE csr_projectsToDelete

END
GO

GRANT EXEC ON qproject_delete_projects_by_date_status TO PUBLIC
GO


--DECLARE 
--	@i_itemType INT,
--	@i_class INT,
--	@i_beginDate DATETIME,
--	@i_endDate DATETIME,
--	@o_error_code INT,
--    @o_error_desc VARCHAR(2000),
--	@i_statusCode INT = NULL,
--	@i_deleteLastPrintingInd INT = 1
--SET @i_itemType = 14
--SET @i_class = 1
--SET @i_beginDate = '2017-04-28' 
--SET @i_endDate= '2017-04-29'
--
--EXEC qproject_delete_projects_by_date_status @i_itemType,@i_class,@i_beginDate,@i_endDate,@o_error_code OUT,@o_error_desc OUT,@i_statusCode,@i_deleteLastPrintingInd
