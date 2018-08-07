IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentables_by_ids')
BEGIN
  PRINT 'Dropping Procedure qutl_get_gentables_by_ids'
  DROP  Procedure  qutl_get_gentables_by_ids
END
GO

PRINT 'Creating Procedure qutl_get_gentables_by_ids'
GO

CREATE Procedure qutl_get_gentables_by_ids
  @s_tableids varchar(2000),
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		Name: qutl_get_gentables_by_ids
*******************************************************************************/

declare
  @sql_block nvarchar(800)

begin

  select @o_error_code = 0
  select @o_error_desc = ''

  set @sql_block= 'SELECT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, d.itemtypefilterind, 
    COALESCE(g.datadescshort,g.datadesc) shortdesc, COALESCE(g.gen1ind,0) gen1ind, g.*
    FROM gentables g 
      LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid and g.datacode = o.datacode) 
      LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
    WHERE g.tableid in (' + @s_tableids + ') 
    ORDER BY g.tableid ASC, g.sortorder ASC, g.datadesc ASC, g.datacode ASC; ' 

  PRINT @sql_block
                              
  EXECUTE sp_executesql  @sql_block

end
GO

GRANT EXEC ON qutl_get_gentables_by_ids TO PUBLIC

GO
