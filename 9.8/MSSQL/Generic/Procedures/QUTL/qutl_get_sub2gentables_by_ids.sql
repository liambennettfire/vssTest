   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub2gentables_by_ids')
	BEGIN
		PRINT 'Dropping Procedure qutl_get_sub2gentables_by_ids'
		DROP  Procedure  qutl_get_sub2gentables_by_ids
	END

GO

PRINT 'Creating Procedure qutl_get_sub2gentables_by_ids'
GO

CREATE Procedure qutl_get_sub2gentables_by_ids
  @s_tableids varchar(2000),
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: 
**		Name: qutl_get_sub2gentables_by_ids
**		Desc: 
**
**		This template can be customized:
**              
**		Return values:
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------							-----------
**
**		Auth: 
**		Date: 
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------		--------				-------------------------------------------
**    
*******************************************************************************/

	declare
  	@sql_block nvarchar(800)

	select @o_error_code = 0
	select @o_error_desc = ''

	begin

	  set @sql_block= 'SELECT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.*,
	        COALESCE(g.datadescshort,g.datadesc) shortdesc
          FROM sub2gentables g LEFT OUTER JOIN sub2gentablesorglevel o
          ON (g.tableid = o.tableid and g.datacode = o.datacode and g.datasubcode = o.datasubcode and g.datasub2code = o.datasub2code) 
          LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
			    where  g.tableid in (' + @s_tableids +   ') 
			    order by g.tableid ASC, g.datacode ASC, g.datasubcode ASC, g.sortorder ASC, g.datadesc ASC, g.datasub2code ASC' 
     
     PRINT @sql_block
                                        
 	EXECUTE sp_executesql  @sql_block
 
	end

GO

GRANT EXEC ON qutl_get_sub2gentables_by_ids TO PUBLIC

GO
 