if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationship_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_relationship_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_relationship_tabs
 (@i_itemtypecode   integer,
  @i_usageclasscode  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qproject_get_relationship_tabs
**  Desc: This stored procedure returns all project relation tabs
**        for the given itemtype and usageclass. 
**
**  Auth: Alan Katzen
**  Date: 15 February 2008
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:     Author: Description:
**  ------    ------  ------------
**  1/2/13    KW      Added associated title tabs based on the item/usage class filter.
**  2/3/16    UK      Case 29745 - Task 003. Not using gentable sort order as default
**  10/19/16  UK      Case 41082
*****************************************************************************************************/

DECLARE @error_var  INT,
  @rowcount_var INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
   BEGIN
	  SELECT DISTINCT g.datacode, g.datadesc, g.qsicode, g.alternatedesc1, g.alternatedesc2, 0 assotitlestabind, CASE WHEN i.sortorder is not null THEN i.sortorder ELSE g.sortorder END sortorder 						
    FROM gentables g, gentablesitemtype i
     WHERE g.tableid = i.tableid and i.tableid = 583
       and (g.qsicode = 14 OR (g.datacode in (SELECT datacode FROM gentablesitemtype i 
                                           WHERE i.tableid = 583
                                             and i.itemtypecode = @i_itemtypecode
                                             and COALESCE(i.itemtypesubcode,0) in (0,@i_usageclasscode))))
	   and (deletestatus <> 'Y' or deletestatus <> 'y') and g.datacode = i.datacode and i.itemtypecode = @i_itemtypecode 
	   and (i.itemtypesubcode = @i_usageclasscode OR i.itemtypesubcode = 0)
	  UNION
	  SELECT g.datacode, g.datadesc + ' ' + 'Rel Tab' as datadesc, g.qsicode, COALESCE(gx.gentext1, g.datadesc), 
		'~/PageControls/ProjectRelationships/ProjectsComparativeTitles.ascx', 1 assotitlestabind, CASE WHEN i.sortorder is not null THEN i.sortorder ELSE g.sortorder END sortorder
	  FROM gentables g, gentablesitemtype i, gentables_ext gx
	  WHERE g.tableid = i.tableid AND
		g.datacode = i.datacode AND
		g.tableid = gx.tableid AND
		g.datacode = gx.datacode AND
		g.tableid = 440 AND
		i.itemtypecode = @i_itemtypecode AND 
		(i.itemtypesubcode = @i_usageclasscode OR i.itemtypesubcode = 0) AND
		(deletestatus <> 'Y' or deletestatus <> 'y')
	  ORDER BY sortorder ASC
	     
	  -- Save the @@ERROR and @@ROWCOUNT values in local 
	  -- variables before they are cleared.
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'error getting project relationship tab data: itemtypecode = ' + cast(@i_itemtypecode AS VARCHAR) +
							' and usageclass = ' + cast(COALESCE(@i_usageclasscode,0) AS VARCHAR)
		RETURN
	  END
	END
END 

GO

GRANT EXEC ON qproject_get_relationship_tabs TO PUBLIC
GO
