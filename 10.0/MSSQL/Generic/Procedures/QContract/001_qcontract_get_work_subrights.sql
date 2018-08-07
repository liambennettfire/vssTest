if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_work_subrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_work_subrights 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_work_subrights
 (@i_workprojectkey   integer,
	@i_rightstype       integer,
	@i_mediacode        integer,
	@i_formatcode       integer,
	@i_languagecode     integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*****************************************************************************************************************************************
**  Name: qcontract_get_work_subrights
**  Desc: This procedure returns data from the CoreWorkRightsAvailableSubrights
**        and CoreWorkRightsSoldSubrights table
**
**	Auth: Colman
**	Date: Jan 25, 2017
******************************************************************************************************************************************
**  Date        Who      Change
**  -------     ---      ---------------------------------------------------------------------------------------------------------------
**  05/17/2017  Uday     Case 45101
**  11/02/2017  Colman   Case 47675 - Rights dashboard is not displaying Pending rights correctly
******************************************************************************************************************************************/

DECLARE @v_error			INT,
		@v_TurnOnRightsCalculus INT

SET @o_error_code = 0
SET @o_error_desc = ''
SET @v_TurnOnRightsCalculus = (SELECT COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 122)

IF @v_TurnOnRightsCalculus = 0 BEGIN
   RETURN
END

SELECT DISTINCT 1 AS availableind, a.workProjectKey, a.rightsType, a.mediaCode, a.formatCode, a.languageCode, g.datacode AS countryCode, g.datadesc AS countryDesc, nonExclusiveSoldInd, 
  activeContractKeys, pendingContractKeys, 
  effectiveDate, expirationDate, dbo.qcontract_rights_expiring_soon(expirationDate) AS expiringsoonind
FROM CoreWorkRightsAvailableSubrights a
  JOIN gentables g 
    ON g.tableid=114 
      AND (a.countryCode = 0 OR g.datacode = a.countryCode) 
      AND g.deletestatus='N'
WHERE a.workprojectkey = @i_workprojectkey
  AND a.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR a.formatcode IN (0, @i_formatcode))
  AND a.languagecode IN (0, @i_languagecode)
  AND a.rightstype = @i_rightstype
UNION
SELECT DISTINCT 0 AS availableind, s.workProjectKey, s.rightsType, s.mediaCode, s.formatCode, s.languageCode, g.datacode AS countryCode, g.datadesc AS countryDesc, 0 AS nonExclusiveSoldInd, 
  activeContractKeys, pendingContractKeys, 
  effectiveDate, expirationDate, dbo.qcontract_rights_expiring_soon(expirationDate) AS expiringsoonind
FROM CoreWorkRightsSoldSubrights s
  JOIN gentables g 
    ON g.tableid=114 
      AND (s.countryCode = 0 OR g.datacode = s.countryCode) 
      AND g.deletestatus='N'
WHERE s.workprojectkey = @i_workprojectkey
  AND s.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR s.formatcode IN (0, @i_formatcode))
  AND s.languagecode IN (0, @i_languagecode)
  AND s.rightstype = @i_rightstype
ORDER BY countryDesc

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error returning subrights (projectkey=' + cast(@i_workprojectkey as varchar) + ')'
  RETURN  
END   

GO

GRANT EXEC ON qcontract_get_work_subrights TO PUBLIC
GO
