if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_work_rights_unaccounted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_work_rights_unaccounted 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_work_rights_unaccounted
 (@i_workprojectkey				integer,
	@i_rightstype						integer,
	@i_mediacode						integer,
	@i_formatcode						integer,
	@i_languagecode					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*****************************************************************************************************************************************
**  Name: qcontract_get_work_rights_unaccounted
**  Desc: This procedure returns countries not present in any of the work rights tables
**        It only returns data if the input parameters match one or more countries
**
**	Auth: Colman
**	Date: Jan 25, 2017
******************************************************************************************************************************************
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

BEGIN  
  SELECT g.datacode AS countryCode
  INTO #tmpCountries
  FROM CoreWorkRightsAvailableInternal r
    JOIN gentables g ON g.tableid=114 AND (r.countryCode = 0 OR g.datacode = r.countryCode) AND g.deletestatus='N'
  WHERE r.workprojectkey = @i_workprojectkey
  AND r.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR r.formatcode IN (0, @i_formatcode))
  AND r.languagecode IN (0, @i_languagecode)
  AND r.rightstype = @i_rightstype
  UNION
  SELECT g.datacode AS countryCode
  FROM CoreWorkRightsNotAvailableInternal n
    JOIN gentables g ON g.tableid=114 AND (n.countryCode = 0 OR g.datacode = n.countryCode) AND g.deletestatus='N'
  WHERE n.workprojectkey = @i_workprojectkey
  AND n.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR n.formatcode IN (0, @i_formatcode))
  AND n.languagecode IN (0, @i_languagecode)
  AND n.rightstype = @i_rightstype
  UNION
  SELECT g.datacode AS countryCode
  FROM CoreWorkRightsAvailableSubrights a
    JOIN gentables g ON g.tableid=114 AND (a.countryCode = 0 OR g.datacode = a.countryCode) AND g.deletestatus='N'
  WHERE a.workprojectkey = @i_workprojectkey
  AND a.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR a.formatcode IN (0, @i_formatcode))
  AND a.languagecode IN (0, @i_languagecode)
  AND a.rightstype = @i_rightstype
  UNION
  SELECT g.datacode AS countryCode
  FROM CoreWorkRightsSoldSubrights s
    JOIN gentables g ON g.tableid=114 AND (s.countryCode = 0 OR g.datacode = s.countryCode) AND g.deletestatus='N'
  WHERE s.workprojectkey = @i_workprojectkey
  AND s.mediacode = @i_mediacode
  AND (@i_formatcode = 0 OR s.formatcode IN (0, @i_formatcode))
  AND s.languagecode IN (0, @i_languagecode)
  AND s.rightstype = @i_rightstype

  IF ISNULL(@@ROWCOUNT,0) > 0
  BEGIN
    SELECT DISTINCT g.datacode AS countryCode, g.datadesc AS countryDesc
    FROM gentables g 
    WHERE NOT EXISTS(SELECT 1 FROM #tmpCountries ct
              WHERE g.datacode = ct.countryCode)
    AND g.tableid=114
    AND g.deletestatus = 'N'
    ORDER BY countryDesc
  END
END

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error returning rights (projectkey=' + cast(@i_workprojectkey as varchar) + ')'
  RETURN  
END  
GO

GRANT EXEC ON qcontract_get_work_rights_unaccounted TO PUBLIC
GO