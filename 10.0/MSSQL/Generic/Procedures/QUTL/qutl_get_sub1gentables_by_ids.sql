  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub1gentables_by_ids')
	BEGIN
		PRINT 'Dropping Procedure qutl_get_sub1gentables_by_ids'
		DROP  Procedure  qutl_get_sub1gentables_by_ids
	END

GO

PRINT 'Creating Procedure qutl_get_sub1gentables_by_ids'
GO

CREATE Procedure qutl_get_sub1gentables_by_ids
  @s_tableids varchar(2000),
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: 
**		Name: qutl_get_sub1gentables_by_ids
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
  	@sql_block nvarchar(max)

	select @o_error_code = 0
	select @o_error_desc = ''

	begin
    -- Misc dropdowns with orgentry filtering on some databases cause huge wait times for the data to be retrieved
    -- so we will not put the orgentry info into the cache for that tableid (525)
    -- To get orgentry filtering for misc dropdowns call qutl_get_sub1gentables_by_org
	  set @sql_block= 'SELECT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.qsicode gen_qsicode, s.*, g.sortorder gen_sortorder,
	        COALESCE(s.datadescshort,s.datadesc) shortdesc
          FROM gentables g, subgentables s LEFT OUTER JOIN subgentablesorglevel o
          ON (s.tableid = o.tableid and s.datacode = o.datacode and s.datasubcode = o.datasubcode) LEFT OUTER JOIN gentablesdesc d ON (s.tableid = d.tableid)
			    where  g.tableid = s.tableid AND g.datacode = s.datacode AND s.tableid in (' + @s_tableids +   ') and s.tableid <> 525
          UNION
          SELECT null orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.qsicode gen_qsicode, s.*, g.sortorder gen_sortorder,
	        COALESCE(s.datadescshort,s.datadesc) shortdesc
          FROM gentables g, subgentables s
          JOIN gentablesdesc d ON (s.tableid = d.tableid)
			    where  g.tableid = s.tableid AND g.datacode = s.datacode and s.tableid = 525
			    order by s.tableid ASC, g.sortorder ASC, s.datacode ASC, s.sortorder ASC, s.datadesc ASC, s.datasubcode ASC' 
     
     --PRINT @sql_block
                                        
 	EXECUTE sp_executesql  @sql_block
 
	end

GO

GRANT EXEC ON qutl_get_sub1gentables_by_ids TO PUBLIC

GO
 