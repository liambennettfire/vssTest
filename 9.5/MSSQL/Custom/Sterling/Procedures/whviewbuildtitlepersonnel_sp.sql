if exists (select * from dbo.sysobjects where id = object_id(N'dbo.whviewbuildtitlepersonnel_sp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.whviewbuildtitlepersonnel_sp
GO


create procedure whviewbuildtitlepersonnel_sp
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. For example, the whtitle*/
declare @c_sqlstmt varchar (max)
declare @c_sqlstmt1 varchar (max)
declare @c_sqlstmt2 varchar (max)
declare @c_columndesc varchar (100)
declare @c_viewname varchar (100)
declare @i_cursor_status int 
declare @i_linenumber int
declare @c_linenumber varchar (5)
declare @c_length int


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
select @c_sqlstmt1=''
select @c_sqlstmt2=''
while (@i_cursor_status<>-1 )
begin
	IF (@i_cursor_status<>-2)
	begin

    select @c_sqlstmt=''

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
    
    select @c_length = datalength(@c_sqlstmt1) + datalength(@c_sqlstmt)
    if @c_length < 7800 begin -- 7800 bdecause we may need to concatenate more to this string
      select @c_sqlstmt1 = @c_sqlstmt1 + @c_sqlstmt
    end
    else begin
      select @c_length = datalength(@c_sqlstmt2) + datalength(@c_sqlstmt)
      if @c_length < 8000 begin
        select @c_sqlstmt2 = @c_sqlstmt2 + @c_sqlstmt
      end 
      else begin
        -- error - more than 16000 chars - go to sql server 2005 and use varchar(max)
        print 'Cannot build whtitlepersonnel_view - create statement is too long'
      end 
    end  
	end /*End If Status */

	FETCH NEXT FROM cursor_controltable
        INTO @c_columndesc,@i_linenumber
        select @i_cursor_status = @@FETCH_STATUS
end /* End While Cursor*/

close cursor_controltable
deallocate cursor_controltable


if datalength(@c_sqlstmt2) > 0 begin
  select @c_sqlstmt2 = @c_sqlstmt1 + @c_sqlstmt2 + ' from whtitlepersonnel'
end
else begin 
  select @c_sqlstmt1 = @c_sqlstmt1 + ' from whtitlepersonnel'
end

select @c_viewname = 'whtitlepersonnel_view'

--print '@c_sqlstmt2'
--print @c_sqlstmt2
--print '@c_sqlstmt1'
--print @c_sqlstmt1
if datalength(@c_sqlstmt2) > 0 begin
  ---exec whviewexec_sp @c_viewname,'bookkey',@c_sqlstmt1,@c_sqlstmt2
	exec whviewexec_sp @c_viewname,'bookkey',@c_sqlstmt2
end
else begin
  exec whviewexec_sp @c_viewname,'bookkey',@c_sqlstmt1
end

end

