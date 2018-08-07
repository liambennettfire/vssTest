if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewbuildtitlecomments_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewbuildtitlecomments_sp]
GO


create procedure whviewbuildtitlecomments_sp @i_tablenumber int
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. For example, the whtitle*/
declare @c_sqlstmt varchar (8000)
declare @c_sqlstmtfrom varchar (100)
declare @c_columndesc varchar (150)
declare @c_scheduletype varchar (100)
declare @c_viewname varchar (100)
declare @i_cursor_status int 
declare @i_firstlinenumber int
declare @i_lastlinenumber int
declare @i_linenumber int
declare @i_substringbegin int
declare @i_substringend int
declare @c_linenumber varchar (5)
declare @c_tablenumber varchar (5)


select @c_tablenumber = convert (varchar(5),@i_tablenumber)


if @i_tablenumber=1
begin

	select @i_firstlinenumber = 1
	select @i_lastlinenumber = 40
	select @c_sqlstmtfrom = ' from whtitlecomments'
	select @c_viewname = 'whtitlecomments_view'


	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select g.datadesc + '_' + sg.datadesc,w.linenumber,w.substringbegin,w.substringend
	from whccommenttype w, gentables g, subgentables sg
	where 
	w.linenumber >= @i_firstlinenumber and w.linenumber <= @i_lastlinenumber
        and g.tableid=284
	and g.datacode=w.commenttypecode
	and sg.tableid = 284
	and sg.datacode=w.commenttypecode
	and sg.datasubcode=w.commenttypesubcode
	order by linenumber
	FOR READ ONLY

end


if @i_tablenumber=2
begin

	select @i_firstlinenumber = 41
	select @i_lastlinenumber = 80

	select @c_sqlstmtfrom = ' from whtitlecomments' + @c_tablenumber
	select @c_viewname = 'whtitlecomments'+ @c_tablenumber + '_view'



	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select g.datadesc + '_' + sg.datadesc,w.linenumber,w.substringbegin,w.substringend
	from whccommenttype w, gentables g, subgentables sg
	where 
	w.linenumber >= @i_firstlinenumber and w.linenumber <= @i_lastlinenumber
        and g.tableid=284
	and g.datacode=w.commenttypecode
	and sg.tableid = 284
	and sg.datacode=w.commenttypecode
	and sg.datasubcode=w.commenttypesubcode
	order by linenumber
	FOR READ ONLY

end


if @i_tablenumber=3
begin

	select @i_firstlinenumber = 81
	select @i_lastlinenumber = 120

	select @c_sqlstmtfrom = ' from whtitlecomments' + @c_tablenumber
	select @c_viewname = 'whtitlecomments'+ @c_tablenumber + '_view'



	DECLARE cursor_controltable INSENSITIVE CURSOR
	FOR
	select g.datadesc + '-' + sg.datadesc,w.linenumber,w.substringbegin,w.substringend
	from whccommenttype w, gentables g, subgentables sg
	where 
	w.linenumber >= @i_firstlinenumber and w.linenumber <= @i_lastlinenumber
        and g.tableid=284
	and g.datacode=w.commenttypecode
	and sg.tableid = 284
	and sg.datacode=w.commenttypecode
	and sg.datasubcode=w.commenttypesubcode
	order by linenumber
	FOR READ ONLY

end

OPEN cursor_controltable

FETCH NEXT FROM cursor_controltable
INTO @c_columndesc,@i_linenumber,@i_substringbegin,@i_substringend

select @i_cursor_status = @@FETCH_STATUS
select @c_sqlstmt=''
while (@i_cursor_status<>-1 )
begin
	IF (@i_cursor_status<>-2)
	begin

        select @c_columndesc = dbo.whviewcleancolumnname_func(@c_columndesc)
	select @c_linenumber=convert (varchar (5),@i_linenumber)

	/** If this comment type is substringed in the datawarehouse we need to add the substring **/
	/** begin and end to the column name for the view, otherwise there could be duplicate column **/
	/** names because the same comment type can be exported with different substrings   ****/
	/** Substring values 1 and 4000 are default, so these will be ignored                **/

	if @i_substringbegin is null
		select @i_substringbegin=0

	if @i_substringbegin is null
		select @i_substringend=0

	if @i_substringbegin > 1 and @i_substringend <> 4000
	begin
		select @c_columndesc = @c_columndesc + '_' + convert (varchar (20),@i_substringbegin) 
		select @c_columndesc = @c_columndesc +  '_' + convert (varchar (20),@i_substringend)
	end
	
	if @i_linenumber > @i_firstlinenumber
	begin
		select @c_sqlstmt = @c_sqlstmt + ','
	end


	select @c_sqlstmt = @c_sqlstmt + 'CAST(commenttext' + @c_linenumber + ' as text) "'+ @c_columndesc + '",'
	select @c_sqlstmt = @c_sqlstmt + 'isnull (releloind' + @c_linenumber + ', ''N'') "'+ @c_columndesc + '_eloreleased"'
        	
	end /*End If Status */

	FETCH NEXT FROM cursor_controltable
        INTO @c_columndesc,@i_linenumber,@i_substringbegin,@i_substringend
        select @i_cursor_status = @@FETCH_STATUS
end /* End While Cursor*/

close cursor_controltable
deallocate cursor_controltable


select @c_sqlstmt = @c_sqlstmt + @c_sqlstmtfrom


exec whviewexec_sp @c_viewname,'bookkey',@c_sqlstmt

end

GO
