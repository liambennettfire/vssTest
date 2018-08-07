
/****** Object:  StoredProcedure [dbo].[qtitle_get_relationship_tabs]    Script Date: 12/6/2017 10:51:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[qtitle_get_relationship_tabs]
 (@i_itemtypecode   integer,
  @i_usageclasscode  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************************
**  Name: qtitle_get_relationship_tabs
**  Desc: This stored procedure returns all title relationship tabs
**        for the given itemtype and usageclass. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 9 September 2008
*****************************************************************************************************************
**    Change History
*****************************************************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    2/3/16      UK              Case 29745 - Task 003. Not using gentable sort order as default   
**    08/25/16    UK              Case 39986
*****************************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_gentablesrelationshipkey INT

  IF @i_usageclasscode > 0 BEGIN
    SELECT g.datacode, g.datadesc, g.qsicode, CASE WHEN i.sortorder is not null THEN i.sortorder ELSE g.sortorder END sortorder, 	
    g.alternatedesc1, g.alternatedesc2, 0 assotitlestabind, gx.gentext2
    FROM gentables g, gentablesitemtype i, gentables_ext gx
     WHERE g.tableid = i.tableid and i.tableid = 583 and gx.tableid = 583
       and (g.qsicode = 14 OR (g.datacode in (SELECT datacode FROM gentablesitemtype i 
                                           WHERE i.tableid = 583
                                             and i.itemtypecode = @i_itemtypecode
                                             and COALESCE(i.itemtypesubcode,0) in (0,@i_usageclasscode))))
	   and (deletestatus <> 'Y' or deletestatus <> 'y') 
	   and g.datacode = i.datacode and i.itemtypecode = @i_itemtypecode 
	   and gx.datacode = g.datacode
	   and (i.itemtypesubcode = @i_usageclasscode OR i.itemtypesubcode = 0)
	   and NOT EXISTS (SELECT * 
					FROM gentablesitemtype i2
				WHERE i2.datacode  = i.datacode AND i.datasubcode = i2.datasubcode AND i.datasub2code = i2.datasub2code 					
					AND i2.tableid = i.tableid AND i2.itemtypecode = i.itemtypecode AND i.itemtypesubcode = 0 AND i2.itemtypesubcode > 0)
    ORDER BY sortorder ASC
  END
  ELSE BEGIN
    SELECT g.datacode, g.datadesc, g.qsicode, CASE WHEN i.sortorder is not null THEN i.sortorder ELSE g.sortorder END sortorder, 
    g.alternatedesc1, g.alternatedesc2, 0 assotitlestabind, gx.gentext2
    FROM gentables g, gentablesitemtype i, gentables_ext gx
     WHERE g.tableid = i.tableid and i.tableid = 583 and gx.tableid = 583
       and (g.qsicode = 14 OR (g.datacode in (SELECT datacode FROM gentablesitemtype i 
                                           WHERE i.tableid = 583
                                             and i.itemtypecode = @i_itemtypecode)))
	   and (deletestatus <> 'Y' or deletestatus <> 'y') 
	   and g.datacode = i.datacode and i.itemtypecode = @i_itemtypecode 
	   and gx.datacode = g.datacode
	   and (i.itemtypesubcode = @i_usageclasscode OR i.itemtypesubcode = 0)
	   and NOT EXISTS (SELECT * 
					FROM gentablesitemtype i2
				WHERE i2.datacode  = i.datacode AND i.datasubcode = i2.datasubcode AND i.datasub2code = i2.datasub2code 					
					AND i2.tableid = i.tableid AND i2.itemtypecode = i.itemtypecode AND i.itemtypesubcode = 0 AND i2.itemtypesubcode > 0)
    ORDER BY sortorder ASC
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
