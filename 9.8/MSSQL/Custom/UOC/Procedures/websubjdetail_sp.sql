PRINT 'STORED PROCEDURE : dbo.websubjdetail_sp'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.websubjdetail_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.websubjdetail_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.websubjdetail_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.websubjdetail_sp
end

GO
create proc dbo.websubjdetail_sp @i_categorycode int, @i_categorysubcode int, @d_cutoffdate datetime
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @c_dummy varchar (25)
DECLARE @i_count int

DECLARE @c_title varchar (500)

DECLARE @c_authorlastname varchar (100)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_authormiddlename varchar (100)
DECLARE @c_alllastname varchar (1000)

DECLARE @i_bookkey int
DECLARE @i_workkey int
DECLARE @i_customkey int
DECLARE @c_booktitle varchar (2000)
DECLARE @c_title_rich varchar (2000)
DECLARE @c_title_reg varchar (2000)
DECLARE @c_subtitle varchar (255)
DECLARE @c_titleprefix varchar (50)

DECLARE @c_pubyear varchar (255)
DECLARE @d_pubdate datetime
DECLARE @d_actdate datetime
DECLARE @d_estdate datetime

DECLARE @i_primaryind int
DECLARE @i_sortorder int

DECLARE @i_catsub int
DECLARE @i_authorkey int

DECLARE @i_status int
DECLARE @i_authorstatus int
DECLARE @c_nullvalue varchar (10)
DECLARE @searchtest1 int
DECLARE @i_volumenumber int
DECLARE @c_volume_reg varchar (2000)
DECLARE @c_volume varchar (2000)

/*6-3-04  remove subtitle, do filter on linklevel and do not show distributed title,show
primary author
10-27-04 crm 02045 no longer add volume number to title if present leave as is*/

truncate table websubject

select @c_nullvalue = null

/*******************************************/
/* Output the beginning Product tag for this subjects */
/*******************************************/
insert into websubject (fdtxt) select '<html>'

insert into websubject (fdtxt) select '<head>'

if @i_categorysubcode is null
  begin
	select @i_catsub = 0
 end
else
  begin
	select @i_catsub = @i_categorysubcode
  end

if @i_catsub >0
 begin
	select @c_title = coalesce(rtrim(g.alternatedesc1), rtrim(g.datadesc)) + ': ' + coalesce(rtrim(sg.alternatedesc1), rtrim(sg.datadesc))
		from gentables g, subgentables sg
			where g.tableid= sg.tableid
				and g.tableid = 412
				and g.datacode= sg.datacode
				and g.datacode= @i_categorycode
				and sg.datasubcode = @i_categorysubcode
 end
else
  begin	
	select @c_title = coalesce(rtrim(g.alternatedesc1), rtrim(g.datadesc))
	  from gentables g
		where g.tableid=412
			and g.datacode= @i_categorycode	
  end


insert into websubject (fdtxt) 
   select '<title>' + @c_title + '</title>'

insert into websubject (fdtxt) 
   select '</head>'

insert into websubject (fdtxt) select '<!-- #include -->'

insert into websubject (fdtxt) 
   select '<p><font face="Verdana,Arial,Helvetica" size="+2"><b>Books in ' +@c_title + '</font></b></p>'

insert into websubject (fdtxt)
  select '<p><font face="Verdana,Arial,Helvetica" size="+1"><b>from the University of Chicago Press</b></font></p>'


insert into websubject (fdtxt) select '<ul>'

/*******************************************/
/*      Output author: and title */
/*******************************************/

if @i_catsub = 0
  begin
	DECLARE cursor_subject_ind INSENSITIVE CURSOR
	  FOR
		select distinct bo.workkey,a.lastname,bo.title ,bo.subtitle,bk.titleprefix,volumenumber
			from booksubjectcategory b,bookdetail bk, bookauthor bb, webbookkeys w , book bo, author a
		 		 where b.bookkey = w.bookkey and b.bookkey=bk.bookkey 
					and b.bookkey=bb.bookkey and b.bookkey= bo.bookkey and bb.authorkey=a.authorkey
					and b.categorytableid=412 and bk.bisacstatuscode in (1,4)
					and bb.primaryind = 1 and bb.sortorder = 1 
					and b.categorycode = @i_categorycode
						order by a.lastname,bo.title
	FOR READ ONLY
 end
else
  begin
	DECLARE cursor_subject_ind INSENSITIVE CURSOR
	  FOR
		select distinct bo.workkey,a.lastname,bo.title ,bo.subtitle,bk.titleprefix,volumenumber
			from booksubjectcategory b,bookdetail bk, bookauthor bb, webbookkeys w , book bo, author a
		 		 where b.bookkey = w.bookkey and b.bookkey=bk.bookkey 
					and b.bookkey=bb.bookkey and b.bookkey= bo.bookkey and bb.authorkey=a.authorkey
					and b.categorytableid=412 and bk.bisacstatuscode in (1,4)
					and bb.primaryind = 1 and bb.sortorder = 1
					and b.categorycode = @i_categorycode
					and b.categorysubcode = @i_categorysubcode					
						order by a.lastname,bo.title
	FOR READ ONLY
  end
OPEN cursor_subject_ind 

FETCH NEXT FROM cursor_subject_ind 
	INTO @i_workkey, @c_authorlastname,@c_booktitle,@c_subtitle,@c_titleprefix,@i_volumenumber

select @i_status = @@FETCH_STATUS
	
	while (@i_status<>-1 )
	  begin
		IF (@i_status<>-2)
	  	  begin

			select @c_alllastname  = ''
			select @d_pubdate = ''
			select @d_estdate = ''
			select @d_actdate = ''
			select @i_authorkey = 0
			select @c_title_rich = ''
			select @c_title_reg = ''
			select @c_volume_reg = ''
			select @c_volume = ''

/*remove multiple if present*/
			select @i_count = 0
			select @i_count = count(*)  from bookdetail bo, book b where workkey = @i_workkey
				and b.bookkey=bo.bookkey and bo.bisacstatuscode in (1,4)

			if @i_count = 1
			  begin
				select @i_bookkey = b.bookkey  from bookdetail bo, book b where workkey = @i_workkey
				and b.bookkey=bo.bookkey and bo.bisacstatuscode in (1,4)
			  end
		
			if @i_count > 1  /* multiple titles so parent should be workkey*/
			  begin
				select @i_bookkey = @i_workkey
			  end

			select @i_customkey = customint09 from bookcustom where bookkey = @i_bookkey

			if @i_customkey is null or @i_customkey = 0
			  begin
				select @i_customkey = @i_bookkey
			  end 

			if @c_titleprefix is null 
			  begin
				select @c_titleprefix = ''
			  end

			if datalength(@c_titleprefix) > 0
			  begin
			 	select @c_booktitle = @c_titleprefix + ' ' + @c_booktitle
			  end
/**** 6-3-04 remove subtitle 

			if @c_subtitle is null
			  begin
				select @c_subtitle = ''
			  end
			if datalength(@c_subtitle) > 0
			  begin
				select @c_booktitle = @c_booktitle + ': ' + @c_subtitle
			  end

****/
			select @i_count = 0

			select @i_count = count(*) from bookcomments where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and commenttypesubcode = 31

			if @i_count > 0 
			  begin
				select @c_volume_reg = commenttext  from bookcomments where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and commenttypesubcode = 31
			  end


			if @c_volume_reg is null
			  begin
				select @c_volume_reg = ''
			  end


 			if @i_volumenumber is null
			  begin 
				select @i_volumenumber = 0
			  end

			if datalength(@c_volume_reg) > 0
			 begin
				if upper(substring(@c_volume_reg,1,1)) <> 'V'
				  begin
					select @c_volume_reg = 'Volume ' + @c_volume_reg 
				  end
				select @c_volume = @c_volume_reg
			  end
			else if @i_volumenumber > 0
			  begin 
				select @c_volume = 'Volume ' + convert(varchar,@i_volumenumber)
			  end

			/** do not add volume
			if datalength(@c_booktitle) > 0 and datalength(@c_volume)>0 
  			  begin
				select @i_count = 0
				select @i_count = charindex(upper(@c_volume),upper(@c_booktitle))
				if @i_count = 0 
				  begin
					select @c_booktitle = @c_booktitle +', ' + @c_volume
				  end
 			 end
			**/

			select @i_count = 0

			select @i_count = count(*) from bookcommenthtml where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and
				commenttypesubcode = 29

			if @i_count > 0 
 			  begin
				select @c_title_rich = commenttext from bookcommenthtml where printingkey=1 and
					bookkey= @i_bookkey and commenttypecode=1 and
					commenttypesubcode = 29
			  end

			select @i_count = 0

			select @i_count = count(*) from bookcomments where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and
				commenttypesubcode = 29
				
			if @i_count > 0 
 			  begin	
				select @c_title_reg = commenttext from bookcomments where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and
				commenttypesubcode = 29
			  end

			if @c_title_rich is null 
   	  		 begin
				select @c_title_rich = ''
	  		 end

			if @c_title_reg is null 
   	 		 begin
				select @c_title_reg = ''
	   		 end

			if datalength(@c_title_rich)> 0
	  		  begin
				select @c_booktitle = @c_title_rich
	  		 end
			else if datalength(@c_title_reg)> 0
  			 begin
				select @c_booktitle = @c_title_reg
	  		 end

			/*pubyear*/
			select @d_pubdate= bestdate,  @d_estdate=estdate,
				 @d_actdate= activedate from bookdates where bookkey=@i_bookkey
				and printingkey=1 and datetypecode=8

			/*author*/
			select @i_authorkey = min(a.authorkey)
			  from author a,bookauthor ba where ba.bookkey = @i_bookkey
				and ba.authorkey= a.authorkey and primaryind=1 and sortorder = 1

			select @c_authorlastname=lastname,@c_authorfirstname = firstname, @c_authormiddlename = middlename
			  from author where authorkey= @i_authorkey

			if @c_authormiddlename is null 
  			  begin
				select @c_authormiddlename = ''
  			  end
		
			if @c_authorfirstname is null 
			  begin
				select @c_authorfirstname = ''
			  end

			if datalength(@c_authorfirstname) > 0 and datalength(@c_authormiddlename) > 0
  			  begin
				select @c_alllastname = @c_authorlastname + ', ' + @c_authormiddlename + ' ' + @c_authorfirstname
  			  end
			else if datalength(@c_authorfirstname) > 0 
  			 begin
				select @c_alllastname = @c_authorlastname + ', ' + @c_authorfirstname
 			 end	
				
			else  
  			 begin
				select @c_alllastname = @c_authorlastname 
 			 end	

 			if @c_alllastname is null 
			  begin
				 select @c_alllastname  = ''
			 end

			if @c_pubyear is null
			  begin
				select @c_pubyear = ''
			  end

 			if @d_pubdate is null
			 begin
				if @d_actdate is null
				  begin
					select @d_pubdate = @d_estdate
				  end
				else
				  begin
					select @d_pubdate = @d_actdate
				  end
			  end
			if @d_pubdate is null
			  begin
				insert into websubject (fdtxt) 
					select '<li><a href="/cgi-bin/hfs.cgi/00/' + convert(varchar (25), @i_customkey) +
				  '.ctl">' + @c_alllastname + ': ' + @c_booktitle + ' </a></li>'
			  end
			
			else if @d_pubdate > @d_cutoffdate
			  begin
				insert into websubject (fdtxt) 
					select '<li><img src="/Images/Chicago/newtag.gif" alt="New!"> <a href="/cgi-bin/hfs.cgi/00/' +
					 convert(varchar (25), @i_customkey) +
					  '.ctl">' + @c_alllastname + ': ' + @c_booktitle + ' </a></li>'
			  end
			else
			  begin
					insert into websubject (fdtxt) 
					select '<li><a href="/cgi-bin/hfs.cgi/00/' + convert(varchar (25), @i_customkey) +
					  '.ctl">' + @c_alllastname + ': ' + @c_booktitle + ' </a></li>'
			 end
		   end

			FETCH NEXT FROM cursor_subject_ind 
			  INTO  @i_workkey, @c_authorlastname,@c_booktitle,@c_subtitle,@c_titleprefix,@i_volumenumber
      				  select @i_status = @@FETCH_STATUS
		   end

close cursor_subject_ind
deallocate cursor_subject_ind

insert into websubject (fdtxt) select '</ul>'

insert into websubject (fdtxt) select '<!-- #include -->'

insert into websubject (fdtxt) select '</body>'

insert into websubject (fdtxt) select '</html>'

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO