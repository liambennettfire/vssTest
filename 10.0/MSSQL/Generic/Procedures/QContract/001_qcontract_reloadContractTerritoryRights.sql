IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontract_reloadContractTerritoryRights')
  DROP PROCEDURE qcontract_reloadContractTerritoryRights
GO

CREATE PROCEDURE qcontract_reloadContractTerritoryRights 
(
	@i_contractprojectkey INT,
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qcontract_reloadContractTerritoryRights
**  Desc: This stored procedure will reload all territory rights
**
**  Parameters:
**		@o_error_code output param, not used but required
**		@o_error_desc output param, not used but required
**		@i_contractprojectkey input param
**
**  Auth: Colman
**  Date: 27 January 2017
*****************************************************************************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

BEGIN

DECLARE 
	@v_workprojectkey INT
	
  DECLARE works_cur CURSOR FOR
    SELECT relatedprojectkey 
    FROM projectrelationshipview 
    WHERE taqprojectkey = @i_contractprojectkey 
      AND relationshipcode = 28

  OPEN works_cur
  FETCH NEXT FROM works_cur INTO @v_workprojectkey
  
  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    exec qcontract_incrementalTerritoryRights @v_workprojectkey, 'WORK', @o_error_code OUTPUT, @o_error_desc OUTPUT
    FETCH NEXT FROM works_cur INTO @v_workprojectkey
  END
  
  CLOSE works_cur
  DEALLOCATE works_cur
END
GO

GRANT EXEC ON qcontract_reloadContractTerritoryRights TO PUBLIC
GO