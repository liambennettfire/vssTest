if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewbuildtitledates_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewbuildtitledates_sp]
GO


create procedure whviewbuildtitledates_sp
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. For example, the whtitle*/
declare @c_sqlstmt varchar (8000)
declare @c_sqlstmtdrop varchar (8000)
declare @c_sqlstmtgrant varchar (8000)
declare @c_columndesc varchar (100)
declare @i_cursor_status int 
declare @i_linenumber int
declare @c_linenumber varchar (5)


/**** whtitledates *****/

DECLARE cursor_controltable INSENSITIVE CURSOR
FOR
select d.description,w.linenumber
from whcdatetype w, datetype d
where d.datetypecode=w.datetypecode
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

	select @c_sqlstmt = @c_sqlstmt + 'actdate' + @c_linenumber + ' "'+ @c_columndesc + '_actual",'
        select @c_sqlstmt = @c_sqlstmt + 'bestdate' + @c_linenumber + ' "'+ @c_columndesc + '_best",'
        select @c_sqlstmt = @c_sqlstmt + 'estdate' + @c_linenumber + ' "'+ @c_columndesc + '_est"'
		
	/*exec @i_output_onix_book=eloamazonoutbook_sp @i_bookkey*/
	end /*End If Status */

	FETCH NEXT FROM cursor_controltable	
        INTO @c_columndesc,@i_linenumber
        select @i_cursor_status = @@FETCH_STATUS
end /* End While Cursor*/

close cursor_controltable
deallocate cursor_controltable

select @c_sqlstmt = @c_sqlstmt + ' from whtitledates'
exec whviewexec_sp 'whtitledates_view','bookkey',@c_sqlstmt



end

GO
