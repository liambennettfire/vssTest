
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qproject_delete_marketing_projects')
  DROP PROCEDURE qproject_delete_marketing_projects
GO
CREATE PROCEDURE qproject_delete_marketing_projects
(
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qproject_delete_marketing_projects
**  Desc:
**
**  Summary: 
**  Create SQL to delete all Marketing Projects (qsicode = 3) with a Project Status of 'Delete' (Use qproject_delete_project)
**
**  CASE: 42510
**
**  Paramaters:
**		@o_error_code output param, not used but required
**		@o_error_desc output param, not used but required
**
**  Auth: Joshua Granville
**  Date: 18 January 2017
*****************************************************************************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

BEGIN

DECLARE
	@v_projectKey INT,
	@v_userKey INT,
	@v_errorCode INT,
	@v_errorDesc VARCHAR(MAX),
	@v_deleteStatus INT,
	@v_dataCode INT,
	@v_dataSubCode INT

SET @v_userKey = 0

SELECT @v_deleteStatus = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 522 AND gen.qsiCode = 22)

SELECT 
	@v_dataCode = sub.dataCode, 
	@v_dataSubCode = sub.dataSubCode 
FROM gentables gen
INNER JOIN subgentables sub
	ON gen.tableid = sub.tableID 
	AND gen.dataCode = sub.dataCode 
WHERE 
	gen.tableID = 550 
AND gen.qsiCode = 3 --qsicode for projects
AND sub.qsiCode = 3	--qsicode for marketing projects

--Make sure we have a delete project status in gentables
IF @v_deleteStatus IS NULL
BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to find datacode for project status delete.'
    RETURN
END 

DECLARE csr_deleteProjects CURSOR FOR 
SELECT taqProjectKey 
FROM taqproject 
WHERE taqprojectstatuscode = @v_deleteStatus
AND searchitemcode = @v_dataCode
AND usageClassCode = @v_dataSubCode

OPEN csr_deleteProjects
FETCH NEXT FROM csr_deleteProjects INTO @v_projectKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC qproject_delete_project @v_projectKey, @v_userKey, @v_errorCode OUTPUT, @v_errorDesc OUTPUT
		FETCH NEXT FROM csr_deleteProjects INTO @v_projectKey
	END
CLOSE csr_deleteProjects
DEALLOCATE csr_deleteProjects

END
GO

GRANT EXEC ON qproject_delete_marketing_projects TO PUBLIC
GO
