if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_work_rights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_work_rights 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_work_rights
 (@i_workprojectkey				integer,
	@i_rightstype						integer,
	@i_mediacode						integer,
	@i_formatcode						integer,
	@i_languagecode					integer,
  @i_availableind         tinyint,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/****************************************************************************************************************************************
**  Name: qcontract_get_work_rights
**  Desc: This procedure returns data from the CoreWorkRightsAvailableInternal 
**        or CoreWorkRightsNotAvailableInternal table
**
**	Auth: Colman
**	Date: Jan 25, 2017
*****************************************************************************************************************************************
*****************************************************************************************************************************************
**  Date        Who      Change
**  -------     ---      ---------------------------------------------------------------------------------------------------------------
**  05/17/2017  Uday     Case 45101
******************************************************************************************************************************************/

DECLARE @v_error			INT,
	    @v_TurnOnRightsCalculus INT

SET @o_error_code = 0
SET @o_error_desc = ''
SET @v_TurnOnRightsCalculus = (SELECT COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 122)

IF @v_TurnOnRightsCalculus = 0 BEGIN
	RETURN
END

IF @i_availableind = 1
BEGIN
--  SELECT DISTINCT workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, exclusiveInd, activeContractKeys, effectiveDate, expirationDate
  SELECT DISTINCT g.datacode AS countryCode, exclusiveInd, g.datadesc AS countryDesc
  FROM CoreWorkRightsAvailableInternal r
    JOIN gentables g ON g.tableid=114 AND (r.countryCode = 0 OR g.datacode = r.countryCode) AND g.deletestatus='N'
  WHERE r.workprojectkey = @i_workprojectkey
    AND r.mediacode = @i_mediacode
    AND (@i_formatcode = 0 OR r.formatcode IN (0, @i_formatcode))
    AND r.languagecode IN (0, @i_languagecode)
    AND r.rightstype = @i_rightstype
  ORDER BY countryDesc
END
ELSE
BEGIN
--  SELECT DISTINCT workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, activeContractKeys, effectiveDate, expirationDate
  SELECT DISTINCT g.datacode AS countryCode, g.datadesc AS countryDesc
  FROM CoreWorkRightsNotAvailableInternal r
    JOIN gentables g ON g.tableid=114 AND (r.countryCode = 0 OR g.datacode = r.countryCode) AND g.deletestatus='N'
  WHERE r.workprojectkey = @i_workprojectkey
    AND r.mediacode = @i_mediacode
    AND (@i_formatcode = 0 OR r.formatcode IN (0, @i_formatcode))
    AND r.languagecode IN (0, @i_languagecode)
    AND r.rightstype = @i_rightstype
  ORDER BY countryDesc
END

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error returning rights (projectkey=' + cast(@i_workprojectkey as varchar) + ')'
  RETURN  
END   

GO

GRANT EXEC ON qcontract_get_work_rights TO PUBLIC
GO