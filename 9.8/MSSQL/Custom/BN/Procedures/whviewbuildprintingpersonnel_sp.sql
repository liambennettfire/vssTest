if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewbuildprintingpersonnel_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewbuildprintingpersonnel_sp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure whviewbuildprintingpersonnel_sp
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. For example, the whtitle*/
declare @c_sqlstmt varchar (8000)
declare @c_columndesc varchar (100)
declare @c_viewname varchar (100)
declare @i_cursor_status int 
declare @i_linenumber int
declare @c_linenumber varchar (5)



DECLARE cursor_controltable INSENSITIVE CURSOR
FOR
select g.datadesc,w.linenumber
from whcroletype w, gentables g
where g.tableid=285
and g.datacode=w.roletypecode
order by linenumber
FOR READ ONLY


OPEN cursor_controltable

FETCH NEXT FROM cursor_controltable
INTO @c_columndesc,@i_linenumber

select @i_cursor_status = @@FETCH_STATUS
select @c_sqlstmt=''
while (@i_cursor_status<>-1 )
begin
	IF (@i_cursor_status<>-2)
	begin

        select @c_columndesc = dbo.whviewcleancolumnname_func(@c_columndesc)
	select @c_linenumber=convert (varchar (5),@i_linenumber)

	if @i_linenumber > 1
	begin
		select @c_sqlstmt = @c_sqlstmt + ','
	end

	select @c_sqlstmt = @c_sqlstmt + 'displayname' + @c_linenumber + ' "'+ @c_columndesc + '_displayname",'
        select @c_sqlstmt = @c_sqlstmt + 'firstname' + @c_linenumber + ' "'+ @c_columndesc + '_firstname",'
        select @c_sqlstmt = @c_sqlstmt + 'middlename' + @c_linenumber + ' "'+ @c_columndesc + '_middlename",'
        select @c_sqlstmt = @c_sqlstmt + 'lastname' + @c_linenumber + ' "'+ @c_columndesc + '_lastname",'
        select @c_sqlstmt = @c_sqlstmt + 'resourcedesc' + @c_linenumber + ' "'+ @c_columndesc + '_resourcedesc",'
        select @c_sqlstmt = @c_sqlstmt + 'shortname' + @c_linenumber + ' "'+ @c_columndesc + '_shortname"'
        	
	end /*End If Status */

	FETCH NEXT FROM cursor_controltable
        INTO @c_columndesc,@i_linenumber
        select @i_cursor_status = @@FETCH_STATUS
end /* End While Cursor*/

close cursor_controltable
deallocate cursor_controltable


select @c_sqlstmt = @c_sqlstmt + ' from whprintingpersonnel'
select @c_viewname = 'whprintingpersonnel_view'


exec whviewexec_sp @c_viewname,'bookkey,printingkey',@c_sqlstmt

end



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

