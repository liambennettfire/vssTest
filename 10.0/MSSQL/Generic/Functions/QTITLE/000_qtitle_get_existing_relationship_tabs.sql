IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_existing_relationship_tabs') )
	DROP FUNCTION dbo.qtitle_get_existing_relationship_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION dbo.qtitle_get_existing_relationship_tabs 
(
	@i_itemtypecode   integer,
	@i_usageclasscode integer 
)
RETURNS @tabslist TABLE(
	windowname VARCHAR(255),
	windowtitle VARCHAR(255),
	datacode INT,
	qsicode INT,
	gen1ind TINYINT,
	alternatedesc1 VARCHAR(255),
	alternatedesc2 VARCHAR(255),
	gentext2 VARCHAR(255)
)
AS
/*******************************************************************************************************
**  Name: qtitle_get_existing_relationship_tabs
**  Desc: This function returns a list of existing relationship tabs
**
**  Auth: Dustin Miller
**  Date: January 20, 2017
*******************************************************************************************************/

BEGIN 
  IF @i_usageclasscode > 0
	INSERT INTO @tabslist
    SELECT w.windowname, COALESCE(gx.gentext1, g.datadesc) windowtitle, 
      g.datacode, g.qsicode, COALESCE(g.gen1ind, 0) gen1ind, g.alternatedesc1, g.alternatedesc2, gx.gentext2
    FROM qsiwindows w,
      gentables g,
      gentables_ext gx
    WHERE w.windowname = REPLACE(g.datadesc, ' ', '') AND 
      w.applicationind = 14 AND 
      w.windowcategoryid = 118 AND 
      w.windowtitle LIKE '%Relationships%' AND
      UPPER(g.deletestatus) = 'N' AND
      g.tableid = gx.tableid AND
      g.datacode = gx.datacode AND
      g.tableid = 440 AND
      g.datacode IN (SELECT datacode FROM gentablesitemtype
                     WHERE tableid = 440 AND itemtypecode = @i_itemtypecode AND COALESCE(itemtypesubcode,0) IN (0,@i_usageclasscode))   
    ORDER BY COALESCE(g.sortorder, 0)
  ELSE
	INSERT INTO @tabslist
    SELECT w.windowname, COALESCE(gx.gentext1, g.datadesc) windowtitle, 
      g.datacode, g.qsicode, COALESCE(g.gen1ind, 0) gen1ind, g.alternatedesc1, g.alternatedesc2, gx.gentext2
    FROM qsiwindows w,
      gentables g,
      gentables_ext gx
    WHERE w.windowname = REPLACE(g.datadesc, ' ', '') AND 
      w.applicationind = 14 AND 
      w.windowcategoryid = 118 AND 
      w.windowtitle LIKE '%Relationships%' AND
      UPPER(g.deletestatus) = 'N' AND
      g.tableid = gx.tableid AND
      g.datacode = gx.datacode AND
      g.tableid = 440 AND
      g.datacode IN (SELECT datacode FROM gentablesitemtype
                     WHERE tableid = 440 AND itemtypecode = @i_itemtypecode)   
    ORDER BY COALESCE(g.sortorder, 0)  
      
  RETURN
  
END
go

grant all on dbo.qtitle_get_existing_relationship_tabs to public
go