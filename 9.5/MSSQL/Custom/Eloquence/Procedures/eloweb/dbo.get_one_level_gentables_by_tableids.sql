IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'get_one_level_gentables_by_tableids')
	BEGIN
		PRINT 'Dropping Procedure get_one_level_gentables_by_tableids'
		DROP  Procedure  get_one_level_gentables_by_tableids
	END

GO

PRINT 'Creating Procedure get_one_level_gentables_by_tableids'
GO
CREATE Procedure get_one_level_gentables_by_tableids
  @s_tableids varchar(300),
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: 
**		Name: get_one_level_gentables_by_tableids
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
	  set @sql_block= 'select gentables.tableid, gentables.tablemnemonic, gentables.datacode,  gentables.datadesc, gentables.datadescshort,  gentables.sortorder, gentables.eloquencefieldtag, gentables.numericdesc1, gentables.numericdesc2, gentables.gen1ind, gentables.gen2ind, gentables.onixcode
			from gentables
			where  gentables.tableid in (' + @s_tableids +   ') 
			and gentables.deletestatus = ''N''
			 AND (gentables.onixcode is not null)
			order by gentables.tableid, gentables.sortorder, gentables.datacode; ' 
                                        
 	EXECUTE sp_executesql  @sql_block
 
	end

GO

GRANT EXEC ON get_one_level_gentables_by_tableids TO PUBLIC

GO
