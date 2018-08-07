if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_relationship_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_relationship_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_relationship_tabs
 (@i_itemtypecode   integer,
  @i_usageclasscode  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_relationship_tabs
**  Desc: This stored procedure returns all title relationship tabs
**        for the given itemtype and usageclass. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 9 September 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_gentablesrelationshipkey INT

  IF @i_usageclasscode > 0 BEGIN
    SELECT g.datacode, g.datadesc, g.qsicode, CASE WHEN i.sortorder is not null THEN i.sortorder END, g.sortorder, g.alternatedesc1, g.alternatedesc2, 0 assotitlestabind
    FROM gentables g, gentablesitemtype i
     WHERE g.tableid = i.tableid and i.tableid = 583
       and (g.qsicode = 14 OR (g.datacode in (SELECT datacode FROM gentablesitemtype i 
                                           WHERE i.tableid = 583
                                             and i.itemtypecode = @i_itemtypecode
                                             and COALESCE(i.itemtypesubcode,0) in (0,@i_usageclasscode))))
	   and (deletestatus <> 'Y' or deletestatus <> 'y') and g.datacode = i.datacode and i.itemtypecode = @i_itemtypecode and COALESCE(i.itemtypesubcode,0) IN 
	   (0,@i_usageclasscode)
    ORDER BY CASE WHEN i.sortorder is not null THEN i.sortorder END, g.sortorder
  END
  ELSE BEGIN
    SELECT g.datacode, g.datadesc, g.qsicode, CASE WHEN i.sortorder is not null THEN i.sortorder END, g.sortorder, g.alternatedesc1, g.alternatedesc2, 0 assotitlestabind
    FROM gentables g, gentablesitemtype i
     WHERE g.tableid = i.tableid and i.tableid = 583
       and (g.qsicode = 14 OR (g.datacode in (SELECT datacode FROM gentablesitemtype i 
                                           WHERE i.tableid = 583
                                             and i.itemtypecode = @i_itemtypecode)))
	   and (deletestatus <> 'Y' or deletestatus <> 'y') and g.datacode = i.datacode and i.itemtypecode = @i_itemtypecode and COALESCE(i.itemtypesubcode,0) IN 
	   (0,@i_usageclasscode)
    ORDER BY CASE WHEN i.sortorder is not null THEN i.sortorder END, g.sortorder
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting title relationship tab data: itemtypecode = ' + cast(@i_itemtypecode AS VARCHAR) +
                        ' and usageclass = ' + cast(@i_usageclasscode AS VARCHAR)
    RETURN
  END 
GO
GRANT EXEC ON qtitle_get_relationship_tabs TO PUBLIC
GO


