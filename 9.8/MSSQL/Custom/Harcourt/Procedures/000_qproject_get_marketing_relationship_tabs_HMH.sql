if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_marketing_relationship_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_marketing_relationship_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE [dbo].[qproject_get_marketing_relationship_tabs]
 (@i_itemtypecode    integer,
  @i_usageclasscode  integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qproject_get_marketing_relationship_tabs
**  Desc: This stored procedure returns all marketing type project relation tabs
**        for the given itemtype and usageclass. 
**
**  Auth: Joshua Robinson
**  Date: 21 April 2015
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:     Author: Description:
**  ------    ------  ------------
**  01/18/17    UK      Case 42737 
*****************************************************************************************************/

DECLARE @error_var  INT,
  @rowcount_var INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
   BEGIN
	  SELECT datacode, datadesc, qsicode, sortorder, alternatedesc1, alternatedesc2, 0 assotitlestabind
	  FROM gentables
	  WHERE tableid = 583
		and (datacode IN (SELECT datacode FROM gentablesitemtype i 
										  WHERE i.tableid = 583
										  and i.itemtypecode = @i_itemtypecode
										  and datacode <> 1
										  and COALESCE(i.itemtypesubcode,0) in (0,@i_usageclasscode)))
		and deletestatus <> 'Y'
	  UNION
	  SELECT g.datacode, g.datadesc, g.qsicode, g.sortorder, COALESCE(gx.gentext1, g.datadesc), 
		'~/PageControls/ProjectRelationships/ProjectsComparativeTitles.ascx', 1 assotitlestabind
	  FROM gentables g, gentablesitemtype i, gentables_ext gx
	  WHERE g.tableid = i.tableid AND
		g.datacode = i.datacode AND
		g.tableid = gx.tableid AND
		g.datacode = gx.datacode AND
		g.tableid = 440 AND
		i.itemtypecode = @i_itemtypecode AND 
		COALESCE(i.itemtypesubcode,0) IN (0,@i_usageclasscode) AND
		deletestatus <> 'Y'
	  ORDER BY sortorder
	  
	  SELECT DISTINCT s.datacode, s.datasubcode, s.datadesc, s.qsicode, i.itemtypecode, g.alternatedesc1, g.alternatedesc2, 
						0 assotitlestabind 
  FROM subgentables s, gentablesitemtype i, gentables g 
  WHERE s.tableid = 550 and i.tableid = 583 and s.qsicode in (3,9,10) and 
				i.itemtypesubcode in (14,15,16)
		
  SET @rowcount_var = @@ROWCOUNT
  
  IF @rowcount_var = 0
  BEGIN
  SELECT tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode
  FROM gentablesitemtype
  WHERE tableid = 583
 
	  EXEC qutl_insert_gentablesitemtype tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, 
	  @o_error_code, @o_error_desc END
   
	  -- Save the @@ERROR and @@ROWCOUNT values in local 
	  -- variables before they are cleared.
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'error getting web relationship tab data: itemtypecode = ' + cast(@i_itemtypecode AS VARCHAR) +
							' and usageclass = ' + cast(COALESCE(@i_usageclasscode,0) AS VARCHAR)
		RETURN
	  END
	END
END 

GO

GRANT EXEC ON qproject_get_marketing_relationship_tabs TO PUBLIC
GO


