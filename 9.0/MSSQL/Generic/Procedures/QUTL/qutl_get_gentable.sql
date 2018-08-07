IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentable')
BEGIN
  PRINT 'Dropping Procedure qutl_get_gentable'
  DROP  Procedure  qutl_get_gentable
END
GO

PRINT 'Creating Procedure qutl_get_gentable'
GO

CREATE PROCEDURE qutl_get_gentable
 (@i_tableid        integer,
  @i_itemtype       integer,
  @i_usageclass     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_gentable
**  Desc: This stored procedure returns all of the gentable
**        information for a single level gentable, and is
**        the basis for doing multi-level gentable development.
**
**    Auth: James P. Weber
**    Date: 25 Feb 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  DECLARE 
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_itemtype > 0  --itemtype passed - include itemtype/usageclass filter
    SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, d.itemtypefilterind,
    COALESCE(g.datadescshort,g.datadesc) shortdesc, COALESCE(g.gen1ind,0) gen1ind, g.*
    FROM gentables g 
        LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid AND g.datacode = o.datacode)  
        LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
        JOIN gentablesitemtype i ON (g.tableid = i.tableid AND g.datacode = i.datacode 
          AND i.itemtypecode = @i_itemtype AND (i.itemtypesubcode = @i_usageclass OR i.itemtypesubcode = 0))
    WHERE g.tableid = @i_tableid 
    ORDER BY g.tableid ASC, g.sortorder ASC, g.datadesc ASC, g.datacode ASC
  ELSE
    SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, d.itemtypefilterind,
    COALESCE(g.datadescshort,g.datadesc) shortdesc, COALESCE(g.gen1ind,0) gen1ind, g.*
    FROM gentables g 
        LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid AND g.datacode = o.datacode)  
        LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
    WHERE g.tableid = @i_tableid 
    ORDER BY g.tableid ASC, g.sortorder ASC, g.datadesc ASC, g.datacode ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid = ' + CONVERT(varchar, @i_tableid) 
  END 
GO

GRANT EXEC ON qutl_get_gentable TO PUBLIC
GO
