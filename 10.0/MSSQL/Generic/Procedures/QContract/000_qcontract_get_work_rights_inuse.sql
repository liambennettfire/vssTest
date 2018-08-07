IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontract_get_work_rights_inuse')
  DROP PROCEDURE qcontract_get_work_rights_inuse
GO

CREATE PROCEDURE qcontract_get_work_rights_inuse 
(
	@i_contractprojectkey INT,
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qcontract_get_work_rights_inuse
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
**  Date        Who      Change
**  -------     ---      ---------------------------------------------------------------------------------------------------------------
**  05/17/2017  Uday     Case 45101
******************************************************************************************************************************************/
BEGIN

DECLARE 
	@v_workprojectkey INT,
  @v_count INT,
  @v_TurnOnRightsCalculus INT

 SET @v_TurnOnRightsCalculus = (SELECT COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 122)

  IF @v_TurnOnRightsCalculus = 0 BEGIN
	RETURN
  END

  -- First purge any orphan rows that are more than an hour old
  SELECT @v_count = COUNT(*)   
  FROM projectrelationshipview r
    JOIN CoreWorkRightsProcessLog l ON l.workProjectKey = r.relatedprojectkey 
  WHERE r.taqprojectkey = @i_contractprojectkey 
    AND r.relationshipcode = 28
    AND DATEDIFF(minute, l.lastmaintdate, getdate()) > 60

  IF @v_count > 0
    DELETE FROM CoreWorkRightsProcessLog
    WHERE workProjectKey IN (
      SELECT r.relatedprojectkey   
      FROM projectrelationshipview r
        JOIN CoreWorkRightsProcessLog l ON l.workProjectKey = r.relatedprojectkey 
      WHERE r.taqprojectkey = @i_contractprojectkey 
        AND r.relationshipcode = 28
        AND DATEDIFF(minute, l.lastmaintdate, getdate()) > 60 )

  SELECT p.taqprojectkey, p.taqprojecttitle
  FROM projectrelationshipview r
    JOIN taqproject p ON p.taqprojectkey = r.relatedprojectkey 
    JOIN CoreWorkRightsProcessLog l ON l.workProjectKey = r.relatedprojectkey 
  WHERE r.taqprojectkey = @i_contractprojectkey 
    AND r.relationshipcode = 28
    
END
GO

GRANT EXEC ON qcontract_get_work_rights_inuse TO PUBLIC
GO