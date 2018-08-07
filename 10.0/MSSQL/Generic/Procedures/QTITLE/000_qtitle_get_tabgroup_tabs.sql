if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_tabgroup_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_tabgroup_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_tabgroup_tabs
 (@i_configobjectkey integer,
  @i_windowviewkey integer,
  @i_itemtypecode   integer,
  @i_usageclasscode  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qtitle_get_tabgroup_tabs
**  Desc: This stored procedure returns all title relation tabs
**        for the given itemtype and usageclass for the tabgroup associated with the configobjectkey.
**
**  Auth: Dustin Miller
**  Date: 18 January 2017
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:   Author: Description:
**  ------  ------  ------------
**  
*****************************************************************************************************/

DECLARE @v_configdetailkey INT

BEGIN

	SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @configdetails TABLE
	(
		configdetailkey INT
	)

	INSERT INTO @configdetails
	SELECT DISTINCT cd.configdetailkey
	FROM qsiconfigdetail cd
	JOIN qsiconfigobjects co
	ON co.configobjectkey = cd.configobjectkey
	WHERE cd.qsiwindowviewkey = @i_windowviewkey
		AND (cd.usageclasscode = @i_usageclasscode OR cd.usageclasscode = 0)
		AND co.configobjectkey = @i_configobjectkey
		AND co.itemtypecode = @i_itemtypecode
		AND co.tabgroupsectionind = 1

	SELECT cdt.configdetailkey, g.datadesc, COALESCE(e.gentext1, g.datadesc) as windowtitle, REPLACE(g.datadesc, ' ', '') windowname, g.alternatedesc1, g.alternatedesc2, 
  g.datacode, g.qsicode, COALESCE(g.gen1ind, 0) gen1ind, 0 assotitlestabind, e.gentext2
	FROM gentables g
	JOIN qsiconfigdetailtabs cdt
	ON g.datacode = cdt.relationshiptabcode
	JOIN gentables_ext e
	ON g.tableid = e.tableid and g.datacode = e.datacode
	WHERE g.tableid = 440
		AND cdt.configdetailkey IN (SELECT configdetailkey FROM @configdetails)
		AND cdt.sortorder > 0
	ORDER BY cdt.configdetailkey, cdt.sortorder
  

END 

GO

GRANT EXEC ON qtitle_get_tabgroup_tabs TO PUBLIC
GO