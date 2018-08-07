if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_qtybreakdown_outlet') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_qtybreakdown_outlet
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_qtybreakdown_outlet
 (@i_projectkey      integer,
  @i_itemtypecode    integer,
  @i_itemtypesubcode integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_qtybreakdown_outlet
**  Desc: This stored procedure returns a list of distinct qtybreakdowns
**        from gentables filtered by usageclass. 
**
**  Auth: Alan Katzen
**  Date: 25 January 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
*******************************************************************************/

  DECLARE 
    @error_var    INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT g.datadesc, g.datadescshort, g.datacode, o.orgentrykey, COALESCE(g.sortorder,0) sortorder,
         dbo.qproject_get_qtysuboutlet_total(COALESCE(@i_projectkey,0), g.datacode, 'A') totalqty,
         dbo.qproject_get_qtysuboutlet_total(COALESCE(@i_projectkey,0), g.datacode, 'E') totalestqty
    FROM gentables g LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid and g.datacode = o.datacode,
         gentablesitemtype i
   WHERE g.tableid = i.tableid AND
         g.datacode = i.datacode AND
         upper(g.deletestatus) = 'N' AND
         g.tableid = 527 AND
         i.itemtypecode = @i_itemtypecode AND
         COALESCE(i.itemtypesubcode,0) in (@i_itemtypesubcode,0)
ORDER BY sortorder,g.datadesc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: qtybreakdown.'   
  END 

GO

GRANT EXEC ON qproject_get_qtybreakdown_outlet TO PUBLIC
GO

