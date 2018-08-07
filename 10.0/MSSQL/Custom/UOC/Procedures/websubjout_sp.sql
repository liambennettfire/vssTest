if exists (select * from dbo.sysobjects where id = Object_id('dbo.websubjout_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.websubjout_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.websubjout_sp  
	@d_cutoffdate datetime, 
	@c_output_dir VARCHAR(256),
	@c_user VARCHAR(30),
	@c_password VARCHAR(30)

AS

DECLARE @i_categorycode int
DECLARE @i_categorysubcode int
DECLARE @i_subj_cursor_status int
DECLARE @i_output_onix_book int
DECLARE @i_count int
DECLARE @i_sequence int
DECLARE @cmd sysname, @var sysname
DECLARE @c_subjects varchar (500)
DECLARE @c_nullvalue varchar (10)

begin tran

/*9-30-04 crm 01936:  change header info for subject.htm and add parameters output dir, user and password*/

/* Truncate the output table in preparation for new feed */
truncate table websubjectidxfeed
truncate table websubjecthtmfeed

select @c_nullvalue = null
select @i_count = 0

select @i_count = count(*)
	from booksubjectcategory b,webbookkeys w, bookdetail bk 
		 where b.bookkey = w.bookkey and b.bookkey = bk.bookkey 
			and categorytableid=412 and bk.bisacstatuscode in (1,4)
if @i_count > 0 
  begin

/*SUBJECT INDEX  -- file will be name subject.idx*/

	insert into websubjectidxfeed (feedtext) 
    		select 'File=subjects.html'

	insert into websubjectidxfeed (feedtext) 
    		select 'Includes = ../header.html, ../footer.html'

	insert into websubjectidxfeed (feedtext) 
    		select @c_nullvalue

	select @i_sequence = 0 

	DECLARE cursor_subject INSENSITIVE CURSOR
	  FOR
		select distinct categorycode,COALESCE(categorysubcode,0) categorysubcode  
			from booksubjectcategory b,webbookkeys w, bookdetail bk 
			   where b.bookkey = w.bookkey and b.bookkey = bk.bookkey 
				and categorytableid=412 and bk.bisacstatuscode in (1,4)
					order by categorycode,categorysubcode
	  FOR READ ONLY

	OPEN cursor_subject


	FETCH NEXT FROM cursor_subject
	   INTO @i_categorycode,@i_categorysubcode 

		select @i_subj_cursor_status = @@FETCH_STATUS

		while (@i_subj_cursor_status<>-1 )
		  begin
			IF (@i_subj_cursor_status<>-2)
		          begin
	
				insert into websubjectidxfeed (feedtext) 
    				select 'File=' + convert(varchar,@i_sequence) + '.html'

				insert into websubjectidxfeed (feedtext) 
    				select 'Includes = ../header.html, ../footer.html'

				insert into websubjectidxfeed (feedtext) 
				  select @c_nullvalue
				
		    		select @i_sequence = @i_sequence + 1
			  end

			FETCH NEXT FROM cursor_subject
			  INTO @i_categorycode,@i_categorysubcode 
      				  select @i_subj_cursor_status = @@FETCH_STATUS
		   end
close cursor_subject
deallocate cursor_subject
commit tran

/*SUBJECT HTM  -- file will be name subject.htm*/
/*7-9-04  use alternatedesc1 incase length> 40:  missing quote after .html" */ 

begin tran
	insert into websubjecthtmfeed (feedtext) 
    		select '<html><head>'

	insert into websubjecthtmfeed (feedtext) 
    		select '<BASE HREF="http://www.press.uchicago.edu/Complete/Subjects/subjects.html">'

	insert into websubjecthtmfeed (feedtext) 
    		select '<title>The University of Chicago Press Subject Index</title></head><body>'

	insert into websubjecthtmfeed (feedtext) 
    		select '<p><font face="Verdana,Arial,Helvetica" size=+2><b>The University of Chicago Press<br>Subject Index</b></font></p>'

	insert into websubjecthtmfeed  (feedtext) 
		select @c_nullvalue

	insert into websubjecthtmfeed (feedtext) 
		select '<p>'

	insert into websubjecthtmfeed (feedtext) 
		select 'For a selection of new and recommended books in many of the subject areas 
		in which we publish, you may wish to consult our 
		<A HREF = "http://www.press.uchicago.edu/Subjects/index.html">subject catalogs</A> page.'


	insert into websubjecthtmfeed  (feedtext) 
		select '</p>'


	insert into websubjecthtmfeed (feedtext) 
    		select '<ul>'
	
	select @i_sequence = 0 

	DECLARE cursor_subject2 INSENSITIVE CURSOR
	  FOR
		select distinct categorycode,COALESCE(categorysubcode,0) categorysubcode 
			from booksubjectcategory b,webbookkeys w, bookdetail bk 
				where b.bookkey = w.bookkey and b.bookkey = bk.bookkey 
					and categorytableid=412 and bk.bisacstatuscode in (1,4)
						order by categorycode,categorysubcode
	  FOR READ ONLY
		OPEN cursor_subject2

		FETCH NEXT FROM cursor_subject2
		   INTO @i_categorycode,@i_categorysubcode 

			select @i_subj_cursor_status = @@FETCH_STATUS

			while (@i_subj_cursor_status<>-1 )
			   begin
				IF (@i_subj_cursor_status<>-2)
				   begin

					if @i_categorysubcode is null
	  				  begin
						select @i_categorysubcode = 0
					  end

					if @i_categorysubcode >0
					  begin
						select @c_subjects = coalesce(rtrim(g.alternatedesc1), rtrim(g.datadesc)) + ': ' + coalesce(rtrim(sg.alternatedesc1), rtrim(sg.datadesc))
						  from gentables g, subgentables sg
							where g.tableid= sg.tableid
								and g.datacode= sg.datacode
								and g.tableid=412
								and g.datacode= @i_categorycode
								and sg.datasubcode = @i_categorysubcode
			 		 end
					else
			 		  begin	
						select @c_subjects = coalesce(rtrim(alternatedesc1), rtrim(g.datadesc))
						  from gentables g
							where g.tableid=412
								and g.datacode= @i_categorycode	
			  		end

					insert into websubjecthtmfeed (feedtext) 
    					select '<li><a href="' + convert(varchar,@i_sequence) + '.html"' + '>' + @c_subjects + '</a></li>'

			    		select @i_sequence = @i_sequence + 1
				end

				FETCH NEXT FROM cursor_subject2
				  INTO @i_categorycode,@i_categorysubcode 
       					 select @i_subj_cursor_status = @@FETCH_STATUS
			end
close cursor_subject2
deallocate cursor_subject2

	insert into websubjecthtmfeed (feedtext) 
    	select '</ul>'

	insert into websubjecthtmfeed (feedtext) 
	select '</body>'


	insert into websubjecthtmfeed (feedtext) 
	select '</html>'

	select @i_sequence = 0 

commit tran

/*SUBJECT DETAILS*/
	DECLARE cursor_subject3 INSENSITIVE CURSOR
	  FOR
		select distinct categorycode,COALESCE(categorysubcode,0) categorysubcode 
			from booksubjectcategory b,webbookkeys w, bookdetail bk 
			 where b.bookkey = w.bookkey and b.bookkey = bk.bookkey 
				and categorytableid=412 and bk.bisacstatuscode in (1,4)
					order by categorycode,categorysubcode
	  FOR READ ONLY

	  OPEN cursor_subject3

		FETCH NEXT FROM cursor_subject3
		   INTO @i_categorycode,@i_categorysubcode 

			select @i_subj_cursor_status = @@FETCH_STATUS

			while (@i_subj_cursor_status<>-1 )
			   begin
				IF (@i_subj_cursor_status<>-2)
				   begin

begin tran
					exec @i_output_onix_book=websubjdetail_sp @i_categorycode, @i_categorysubcode, @d_cutoffdate

commit tran
					--set @var = '"select fdtxt from PSS5..websubject order by sqn"' + ' queryout c:\' + convert(varchar,@i_sequence) + '.HTM -Uqsidba -Pqsidba -c -CACP'
					--set @cmd = 'bcp ' + @var


					set @cmd = 'bcp '
					set @cmd = @cmd + '"select fdtxt from PSS5..websubject order by sqn" queryout ' 
					set @cmd = @cmd + ' ' + @c_output_dir + convert(varchar,@i_sequence) + '.HTM '  
					set @cmd = @cmd + ' -U' + @c_user + ' -P' + @c_password + ' '
					set @cmd = @cmd + ' -c -CACP'
					exec master..xp_cmdshell  @cmd

			    		select @i_sequence = @i_sequence + 1

				end

				FETCH NEXT FROM cursor_subject3
				  INTO @i_categorycode,@i_categorysubcode 
       					 select @i_subj_cursor_status = @@FETCH_STATUS
			end					
  end

close cursor_subject3
deallocate cursor_subject3

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO