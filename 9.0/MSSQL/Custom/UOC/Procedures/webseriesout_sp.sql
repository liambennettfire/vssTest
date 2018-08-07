if exists (select * from dbo.sysobjects where id = Object_id('dbo.webseriesout_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.webseriesout_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.webseriesout_sp  
	@d_cutoffdate datetime, 
	@c_output_dir VARCHAR(256),
	@c_user VARCHAR(30),
	@c_password VARCHAR(30)

AS

DECLARE @c_seriescode varchar (100)
DECLARE @c_datadesc varchar (200)
DECLARE @i_series_cursor_status int
DECLARE @i_output_onix_book int
DECLARE @i_count int
DECLARE @cmd sysname,@var sysname
DECLARE @i_datacode int
DECLARE @c_nullvalue varchar (10)
DECLARE @c_filename varchar(50)

begin tran

/*9-30-04 crm 01936:  change header in series.htm file and change datadesc to alternatedesc1 
add parameters output dir, user and password*/
/* Truncate the output table in preparation for new feed */

truncate table webseriesidxfeed
truncate table webserieshtmfeed

select @c_nullvalue = null
select @i_count = 0

select @i_count = count(*) 
	  from bookdetail b, webbookkeys w,gentables g
		 where b.bookkey = w.bookkey and b.seriescode = g.datacode
		and tableid = 327 and bisacstatuscode in (1,4)
if @i_count > 0 
  begin

/*SERIES IDX -- file will be name series.idx*/

	insert into webseriesidxfeed (feedtext) 
    		select 'File=series.html'

	insert into webseriesidxfeed (feedtext) 
    		select 'Includes = ../header.sgml, ../footer.html'

	insert into webseriesidxfeed (feedtext) 
    		select @c_nullvalue


	DECLARE cursor_series INSENSITIVE CURSOR
	  FOR
		select distinct g.externalcode,g.datacode 
			from bookdetail b, webbookkeys w,gentables g
		   where b.bookkey = w.bookkey and b.seriescode = g.datacode
			and tableid = 327 and bisacstatuscode in (1,4)
				order by g.externalcode
	  FOR READ ONLY
	  OPEN cursor_series

		FETCH NEXT FROM cursor_series
		   INTO @c_seriescode,@i_datacode

			select @i_series_cursor_status = @@FETCH_STATUS

			while (@i_series_cursor_status<>-1 )
			   begin
				IF (@i_series_cursor_status<>-2)
				   begin
	
					insert into webseriesidxfeed (feedtext) 
    					select 'File=' + @c_seriescode + '.html'

					insert into webseriesidxfeed (feedtext) 
    					select 'Includes = ../header.html, ../footer.html'

					insert into webseriesidxfeed (feedtext) 
					  select @c_nullvalue
				end

				FETCH NEXT FROM cursor_series
				  INTO @c_seriescode,@i_datacode
       					 select @i_series_cursor_status = @@FETCH_STATUS
			end					

close cursor_series
deallocate cursor_series
commit tran

/*SERIES HTM  -- file will be name series.htm*/
begin tran

	insert into webserieshtmfeed (feedtext) 
    		select '<html>'
	insert into webserieshtmfeed (feedtext) 
    		select '<head>'

	insert into webserieshtmfeed (feedtext) 
		select '<BASE HREF="http://www.press.uchicago.edu/Complete/Series/series.html">'	

		insert into webserieshtmfeed (feedtext) 
			select '<title>The University of Chicago Press Series Index</title></head>'

	insert into webserieshtmfeed (feedtext) 
		select @c_nullvalue

	insert into webserieshtmfeed (feedtext) 
		select @c_nullvalue

	insert into webserieshtmfeed (feedtext) 
		select '<p><font face="Verdana,Arial,Helvetica" size=+2><b>The University of Chicago Press<br>Series Index</b></font></p>'

	insert into webserieshtmfeed (feedtext) 
		select @c_nullvalue

	insert into webserieshtmfeed (feedtext) 
		select '<p>'

	insert into webserieshtmfeed (feedtext) 
		select 'For a selection of new and recommended books in many of the subject areas 
			in which we publish, you may wish to consult our 
			<A HREF = "http://www.press.uchicago.edu/Subjects/index.html">subject catalogs</A> page.'

	insert into webserieshtmfeed (feedtext) 
		select '</p>'


	insert into webserieshtmfeed (feedtext) 
    		select '<ul>'
	
	DECLARE cursor_series2 INSENSITIVE CURSOR
	  FOR
		select distinct g.externalcode,g.datacode,g.alternatedesc1
			from bookdetail b, webbookkeys w,gentables g
		   where b.bookkey = w.bookkey and b.seriescode = g.datacode
			and tableid = 327 and bisacstatuscode in (1,4)
				order by g.externalcode
	  FOR READ ONLY
	  OPEN cursor_series2

		FETCH NEXT FROM cursor_series2
		   INTO @c_seriescode,@i_datacode,@c_datadesc

			select @i_series_cursor_status = @@FETCH_STATUS

			while (@i_series_cursor_status<>-1 )
			   begin
				IF (@i_series_cursor_status<>-2)
				   begin

					insert into webserieshtmfeed (feedtext) 
    					select '<li><a href="' + @c_seriescode + '.html' + '">' + @c_datadesc +  '</a></li>'

				end

				FETCH NEXT FROM cursor_series2
				  INTO @c_seriescode,@i_datacode,@c_datadesc
       					 select @i_series_cursor_status = @@FETCH_STATUS
			end					

close cursor_series2
deallocate cursor_series2

	insert into webserieshtmfeed (feedtext) 
    	select '</ul>'

	insert into webserieshtmfeed (feedtext) 
	select '</body>'


	insert into webserieshtmfeed (feedtext) 
	select '</html>'

commit tran


/*SERIES DETAILS*/
	DECLARE cursor_series3 INSENSITIVE CURSOR
	  FOR
		select distinct g.externalcode,g.datacode 
			from bookdetail b, webbookkeys w,gentables g
		   where b.bookkey = w.bookkey and b.seriescode = g.datacode
			and tableid = 327 and bisacstatuscode in (1,4)
				order by g.externalcode
	  FOR READ ONLY
	  OPEN cursor_series3

		FETCH NEXT FROM cursor_series3
		   INTO @c_seriescode,@i_datacode

			select @i_series_cursor_status = @@FETCH_STATUS

			while (@i_series_cursor_status<>-1 )
			   begin
				IF (@i_series_cursor_status<>-2)
				   begin
begin tran

					exec @i_output_onix_book=webseriesdetail_sp @c_seriescode, @i_datacode, @d_cutoffdate
commit tran

					set @cmd = 'bcp '
					set @cmd = @cmd + '"select fdtxt from PSS5..webseries order by sqn" queryout ' 
					set @cmd = @cmd + ' ' + @c_output_dir + upper(@c_seriescode) + '.HTM '  
					set @cmd = @cmd + ' -U' + @c_user + ' -P' + @c_password + ' '
					set @cmd = @cmd + ' -c -CACP'

					exec master..xp_cmdshell  @cmd

				end

				FETCH NEXT FROM cursor_series3
				  INTO @c_seriescode,@i_datacode
       					 select @i_series_cursor_status = @@FETCH_STATUS
			end					
  end

close cursor_series3
deallocate cursor_series3

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO