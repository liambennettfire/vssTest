IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'get_two_level_gentables_by_tableids')
	BEGIN
		PRINT 'Dropping Procedure get_two_level_gentables_by_tableids'
		DROP  Procedure  get_two_level_gentables_by_tableids
	END

GO

PRINT 'Creating Procedure get_two_level_gentables_by_tableids'
GO
CREATE Procedure get_two_level_gentables_by_tableids
  @s_tableids varchar(300),
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: 
**		Name: get_two_level_gentables_by_tableids
**		Desc: 
**
**		This routine gets the second level information that is needed
**      to be able to get sub-sections as second level tables.
**              
**		Return values:
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------						-----------
**
**		Auth: 
**		Date: 
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------	--------			-------------------------------------------
**    
*******************************************************************************/


	declare
  	@sql_block nvarchar(2000)

	select @o_error_code = 0
	select @o_error_desc = ''

	begin
	  SET ANSI_NULLS ON
	  set @sql_block= 'select gentables.tableid, gentables.tablemnemonic, gentables.datacode,  gentables.datadesc, subgentables.datasubcode, subgentables.datadesc AS subdatadesc, gentables.datadescshort, subgentables.bisacdatacode, gentables.sortorder, subgentables.sortorder AS subsortorder, gentables.eloquencefieldtag, subgentables.eloquencefieldtag AS subeloquencefieldtag, gentables.numericdesc1, gentables.gen1ind, gentables.onixcode, subgentables.onixsubcode As onixsubcode
			from   gentables INNER JOIN
                      subgentables ON gentables.tableid = subgentables.tableid AND gentables.datacode = subgentables.datacode INNER JOIN
                      gentablesdesc ON gentables.tableid = gentablesdesc.tableid
			where (gentables.tableid in (' + @s_tableids +   ')) 
			 AND (gentables.deletestatus = ''N'') 
			 AND (subgentables.deletestatus = ''N'')
			 AND (gentables.onixcode is not null)
			 AND (subgentables.onixsubcode is not null)
			order by gentables.tableid, gentables.sortorder, subgentables.sortorder, gentables.datacode, subgentables.datasubcode' 
                                        
	print @sql_block

 	EXECUTE sp_executesql  @sql_block
 
	end

GO

GRANT EXEC ON get_two_level_gentables_by_tableids TO PUBLIC

GO
