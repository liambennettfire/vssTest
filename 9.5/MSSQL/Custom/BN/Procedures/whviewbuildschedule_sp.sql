if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewbuildschedule_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewbuildschedule_sp]
GO


create procedure whviewbuildschedule_sp @i_tablenumber int
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. For example, the whtitle*/
declare @c_sqlstmt varchar (8000)
declare @c_columndesc varchar (100)
declare @c_scheduletype varchar (100)
declare @c_viewname varchar (100)
declare @i_cursor_status int 
declare @i_linenumber int
declare @i_scheduletypecode int
declare @c_linenumber varchar (5)
declare @c_tablenumber varchar (5)

select @i_scheduletypecode=0
select @c_tablenumber = convert (varchar(5),@i_tablenumber)

/*************************************************************/
/**                                                         **/
/**                    SCHEDULE 1                           **/
/**                                                         **/
/*************************************************************/
select @i_scheduletypecode=0
select @i_scheduletypecode=scheduletypecode from whcscheduletype where linenumber = @i_tablenumber

/*** If there is no scheduled defined for this tablenumber, skip the rest of the procedure **/
if @i_scheduletypecode = 0  or @i_scheduletypecode is null
begin
	return
end

if @i_tablenumber=1
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule1 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=2
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule2 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=3
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule3 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=4
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule4 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=5
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule5 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=6
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule6 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end
if @i_tablenumber=7
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule7 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=8
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule8 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=9
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule9 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

if @i_tablenumber=10
begin
	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select d.description,w.linenumber
	from whcschedule10 w, datetype d
	where d.datetypecode=w.scheduledatetype
	order by linenumber
	FOR READ ONLY
end

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

	select @c_sqlstmt = @c_sqlstmt + 'actualdate' + @c_linenumber + ' "'+ @c_columndesc + '_actual",'
        select @c_sqlstmt = @c_sqlstmt + 'bestdate' + @c_linenumber + ' "'+ @c_columndesc + '_best",'
        select @c_sqlstmt = @c_sqlstmt + 'estdate' + @c_linenumber + ' "'+ @c_columndesc + '_est",'
        select @c_sqlstmt = @c_sqlstmt + 'assignedperson' + @c_linenumber + ' "'+ @c_columndesc + '_assigned_to",'
        select @c_sqlstmt = @c_sqlstmt + 'role' + @c_linenumber + ' "'+ @c_columndesc + '_role",'
        select @c_sqlstmt = @c_sqlstmt + 'duration' + @c_linenumber + ' "'+ @c_columndesc + '_duration"'
        	
	end /*End If Status */

	FETCH NEXT FROM cursor_controltable
        INTO @c_columndesc,@i_linenumber
        select @i_cursor_status = @@FETCH_STATUS
end /* End While Cursor*/

close cursor_controltable
deallocate cursor_controltable


select @c_sqlstmt = @c_sqlstmt + ' from whschedule' + @c_tablenumber
select @c_viewname = 'whschedule'+ @c_tablenumber + '_view'

exec whviewexec_sp @c_viewname,'bookkey',@c_sqlstmt

end

GO
