if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentablesitemtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_gentablesitemtype
GO

CREATE PROCEDURE qutl_get_gentablesitemtype
  (@i_tableid     integer,
  @i_itemtype     integer,
  @i_usageclass   integer,
  @i_activeonly   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_gentablesitemtype
**  Desc: This stored procedure returns Item Type filter information
**        from gentablesitemtype table.
**
**  Auth: Kate J. Wiewiora
**  Date: September 20 2007
*******************************************************************************/

  DECLARE
    @v_error  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_tableid = 323 BEGIN  -- datetype - fake gentable 
    IF @i_activeonly = 1
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datadesc,
        d.alternatedesc1, d.alternatedesc2, d.date1ind gen1ind, null gen2ind, d.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + d.sortorder), 99999) prod_order, 
        0 subgen_count, gi.* 
      FROM gentablesitemtype gi, datetype d
      WHERE gi.datacode = d.datetypecode AND
          d.activeind = 1 AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype AND
          (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
    ELSE IF @i_usageclass = 0
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datadesc,
        d.alternatedesc1, d.alternatedesc2, d.date1ind gen1ind, null gen2ind, d.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + d.sortorder), 99999) prod_order,
        0 subgen_count, gi.* 
      FROM gentablesitemtype gi, datetype d
      WHERE gi.datacode = d.datetypecode AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype  
    ELSE  
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datadesc,
        d.alternatedesc1, d.alternatedesc2, d.date1ind gen1ind, null gen2ind, d.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + d.sortorder), 99999) prod_order,
        0 subgen_count, gi.* 
      FROM gentablesitemtype gi, datetype d
      WHERE gi.datacode = d.datetypecode AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype AND
          (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)      
  END    
  ELSE BEGIN
    -- regular gentable
    IF @i_activeonly = 1
      SELECT g.datadesc, g.alternatedesc1, g.alternatedesc2, g.gen1ind, g.gen2ind, e.gen3ind, g.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + g.sortorder), 99999) prod_order, 
        (SELECT COUNT(*) FROM subgentables WHERE tableid = @i_tableid AND datacode = g.datacode) subgen_count, gi.* 
      FROM gentablesitemtype gi, gentables g
	       LEFT OUTER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode
      WHERE gi.tableid = g.tableid AND
          gi.datacode = g.datacode AND
          g.deletestatus = 'N' AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype AND
          (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
    ELSE IF @i_usageclass = 0
      SELECT g.datadesc, g.alternatedesc1, g.alternatedesc2, g.gen1ind, g.gen2ind, e.gen3ind, g.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + g.sortorder), 99999) prod_order,
        (SELECT COUNT(*) FROM subgentables WHERE tableid = @i_tableid AND datacode = g.datacode) subgen_count, gi.* 
      FROM gentablesitemtype gi, gentables g
	       LEFT OUTER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode
      WHERE gi.tableid = g.tableid AND
          gi.datacode = g.datacode AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype  
    ELSE  
      SELECT g.datadesc, g.alternatedesc1, g.alternatedesc2, g.gen1ind, g.gen2ind, e.gen3ind, g.qsicode,
        COALESCE(COALESCE(gi.sortorder, 10000 + g.sortorder), 99999) prod_order,
        (SELECT COUNT(*) FROM subgentables WHERE tableid = @i_tableid AND datacode = g.datacode) subgen_count, gi.* 
      FROM gentablesitemtype gi, gentables g
	       LEFT OUTER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode
      WHERE gi.tableid = g.tableid AND
          gi.datacode = g.datacode AND
          gi.tableid = @i_tableid AND
          gi.itemtypecode = @i_itemtype AND
          (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)  
  END		
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesitemtype table (tableid=' + CONVERT(VARCHAR, @i_tableid) + ').'
  END
GO

GRANT EXEC ON qutl_get_gentablesitemtype TO PUBLIC
GO

