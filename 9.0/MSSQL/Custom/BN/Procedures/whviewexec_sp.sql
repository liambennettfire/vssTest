if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewexec_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewexec_sp]
GO

create procedure whviewexec_sp @c_viewname varchar (100), @c_keycolumns varchar (255), @c_sqlstmt varchar (8000)
as
begin

/** This procedure will execute the views sent from the whbuildviews_sp **/
/** Send the name of the view, the key columns (i.e. 'bookkey' or 'bookkey,printingkey' **/
/** and send the complete column list and from statement in c_sqlstmt **/


declare @c_sqlstmtdrop varchar (8000)
declare @c_sqlstmtgrant varchar (8000)

if @c_sqlstmt is null
	select @c_sqlstmt=''

select @c_sqlstmtdrop = 'if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + @c_viewname + ' ]'') and OBJECTPROPERTY(id, N''IsView'') = 1)
drop view [dbo].[' + @c_viewname + ']'

if @c_sqlstmt not like ' from%' 
begin
	/** Add the comma after key columns if additional columns follow the key columns**/
	/** we can determine this by checking the sqltmt to see if it starts with the word 'from' or not */
	select @c_keycolumns = @c_keycolumns + ','
end

select @c_sqlstmt = 'create view ' + @c_viewname + ' as select ' + @c_keycolumns + @c_sqlstmt

select @c_sqlstmtgrant = 'grant select on ' + @c_viewname + ' to public'

/* print @c_sqlstmtdrop */
print @c_sqlstmt
/* print @c_sqlstmtgrant */


EXECUTE (@c_sqlstmtdrop)
EXECUTE (@c_sqlstmt)
EXECUTE (@c_sqlstmtgrant)


end

GO
