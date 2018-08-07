PRINT 'STORED PROCEDURE : dbo.webseriesdetail_sp'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.webseriesdetail_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.webseriesdetail_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.webseriesdetail_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.webseriesdetail_sp
end

GO
create proc dbo.webseriesdetail_sp @c_seriescode varchar, @i_datacode int, @d_cutoffdate datetime
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @c_dummy varchar (25)
DECLARE @i_count int

DECLARE @c_title varchar (2000)


DECLARE @c_authorlastname varchar (100)
DECLARE @c_alllastname varchar (1000)
DECLARE @c_lastname varchar (100)

DECLARE @i_bookkey int
DECLARE @i_workkey int
DECLARE @i_customkey int
DECLARE @c_booktitle varchar (2000)
DECLARE @c_title_rich varchar (2000)
DECLARE @c_title_reg varchar (2000)
DECLARE @c_subtitle varchar (2000)
DECLARE @c_subtitle_rich varchar (2000)
DECLARE @c_subtitle_reg varchar (2000)
DECLARE @c_titleprefix varchar (50)

DECLARE @c_pubyear varchar (255)
DECLARE @d_pubdate datetime
DECLARE @d_actdate datetime
DECLARE @d_estdate datetime

DECLARE @i_primaryind int
DECLARE @i_sortorder int
DECLARE @i_firsttime int

DECLARE @i_status int
DECLARE @i_authorstatus int
DECLARE @i_volumenumber int
DECLARE @i_suppress_auth int
DECLARE @i_suppress_title int
DECLARE @i_sort_title_or_pub_auth int
DECLARE @c_shortdesc varchar (20)
DECLARE @c_evaluate_short varchar (2)
DECLARE @c_series_editor varchar (255)
DECLARE @c_volume_reg varchar (2000)
DECLARE @c_volume varchar (2000)
DECLARE @searchtest1 int


truncate table webseries

/*******************************************/
/* Output the beginning Product tag for this series */
/*******************************************/
insert into webseries (fdtxt) select '<html>'

insert into webseries (fdtxt) select '<head>'

select @c_title = coalesce(alternatedesc1,datadesc), @c_series_editor = alternatedesc2, @c_shortdesc = datadescshort
  from gentables where tableid=327 and datacode=@i_datacode

/*** set sorting and suppress author or title*/
if @c_shortdesc is null
  begin
	select @c_shortdesc = ''
  end
/*first value sorting N = volumenumber sort otherwise pubdate author 
  second value author N= suppress author otherwise do not
  third value title F= suppress title otherwise do not*/

select @i_sort_title_or_pub_auth = 0  /*pubdate author*/	
select @i_suppress_auth = 0  /*do not suppress author*/	
select @i_suppress_title = 0  /*do not suppress author*/	

if datalength(@c_shortdesc) > 0
   begin

	select @searchtest1 =  0
	select @searchtest1 = charindex(':',@c_shortdesc)

	if @searchtest1 > 0 
  	  begin
		select @searchtest1 = @searchtest1 + 1
	  end

	select @c_evaluate_short = substring(@c_shortdesc,@searchtest1,1)
        
	if @c_evaluate_short = 'N'
	   begin
		select @i_sort_title_or_pub_auth = 1  /*volume sort*/	
	   end
	else
	  begin
		select @i_sort_title_or_pub_auth = 0  /*pubdate author*/	
	   end
	select @searchtest1 = @searchtest1 + 2

	select @c_evaluate_short = substring(@c_shortdesc,@searchtest1,1)
        
	if @c_evaluate_short = 'N'
	   begin
		select @i_suppress_auth = 1  /*suppress author*/	
	   end
	else
	  begin
		select @i_suppress_auth = 0  /*do not suppress author*/	
	   end
	
	select @searchtest1 = @searchtest1 + 2

	select @c_evaluate_short = substring(@c_shortdesc,@searchtest1,1)

        
	if @c_evaluate_short = 'F'
	   begin
		select @i_suppress_title = 1  /*suppress title*/	
	   end
	else
	  begin
		select @i_suppress_title = 0  /*do not suppress title*/	
	   end
end


insert into webseries (fdtxt) select '<title>' + @c_title + '</title>'

insert into webseries (fdtxt) select '</head>'

insert into webseries (fdtxt) select '<!-- #include -->'

insert into webseries (fdtxt) select '<p><font face="Verdana,Arial,Helvetica" size="+2"><b>' + @c_title + '</b></font></p>'

insert into webseries (fdtxt) select '<font face="Verdana,Arial,Helvetica" size="+1"><b>A series from the University of Chicago Press</b></font></p>'

if @c_series_editor is null
  begin
	select @c_series_editor = ''
  end

if datalength(@c_series_editor) > 0
  begin
	insert into webseries (fdtxt) 
		select '<p><strong>' + @c_series_editor + '</strong>'
  end 

insert into webseries (fdtxt) select '<ul>'
/** check if all authors in the series are same*/

/*******************************************/
/*      Output author: and title */
/*******************************************/

if @i_sort_title_or_pub_auth = 1
  begin
	DECLARE cursor_series_ind INSENSITIVE CURSOR
	  FOR
		select distinct bo.workkey,convert(varchar,commenttext) pubyear, lastname,bo.title ,subtitle,volumenumber,
		b.titleprefix
		from bookdetail b, webbookkeys e, book bo, bookcomments bk,bookauthor ba, author a
			where b.bookkey= e.bookkey and b.bookkey=bk.bookkey and b.bookkey= bo.bookkey
				and b.bisacstatuscode in (1,4) 
				and bk.printingkey=1 and commenttypecode= 1 and commenttypesubcode= 33
				and b.bookkey= ba.bookkey and ba.authorkey=a.authorkey and primaryind=1 and ba.sortorder=1
				and b.seriescode = @i_datacode 
			  order by b.volumenumber
		FOR READ ONLY
 end
else
 begin
	DECLARE cursor_series_ind INSENSITIVE CURSOR
	 FOR

		select distinct bo.workkey,convert(varchar,commenttext) pubyear, lastname,bo.title , subtitle,volumenumber,
		 b.titleprefix
			from bookdetail b, webbookkeys e, book bo, bookcomments bk,bookauthor ba, author a
				where b.bookkey= e.bookkey and b.bookkey=bk.bookkey and b.bookkey= bo.bookkey
					and b.bisacstatuscode in (1,4) 
					and bk.printingkey=1 and commenttypecode= 1 and commenttypesubcode= 33
					and b.bookkey= ba.bookkey and ba.authorkey=a.authorkey and primaryind=1 and ba.sortorder=1
					and b.seriescode = @i_datacode 
				order by pubyear,lastname,volumenumber,bo.title
		FOR READ ONLY
  end

OPEN cursor_series_ind 

FETCH NEXT FROM cursor_series_ind 
	INTO @i_workkey, @c_pubyear,@c_lastname,@c_booktitle,@c_subtitle,@i_volumenumber,@c_titleprefix

select @i_status = @@FETCH_STATUS
	
	while (@i_status<>-1 )
	  begin
		IF (@i_status<>-2)
	  	  begin

			select @c_volume_reg = ''
			select @c_volume = ''
			select @c_title_rich = ''
			select @c_title_reg = ''
			select @c_subtitle_reg = ''
			select @c_subtitle_rich = ''

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


			if @c_titleprefix is null 
			  begin
				select @c_titleprefix = ''
			  end

			if datalength(@c_titleprefix) > 0
			  begin
			 	select @c_booktitle = @c_titleprefix + ' ' + @c_booktitle
			  end

			if @c_subtitle is null
			  begin
				select @c_subtitle = ''
			  end
			
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

			select @i_count = 0

			select @i_count = count(*) from bookcommenthtml where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and
				commenttypesubcode = 30

			if @i_count > 0 
 			  begin
				select @c_subtitle_rich = commenttext from bookcommenthtml where printingkey=1 and
					bookkey= @i_bookkey and commenttypecode=1 and
					commenttypesubcode = 30
			  end

			select @i_count = 0

			select @i_count = count(*) from bookcomments where printingkey=1 and
				bookkey= @i_bookkey and commenttypecode=1 and
				commenttypesubcode = 30

			if @i_count > 0 
 			  begin
				select @c_subtitle_reg = commenttext from bookcomments where printingkey=1 and
					bookkey= @i_bookkey and commenttypecode=1 and
					commenttypesubcode = 30
			  end

			 if @c_subtitle_rich is null 
   			   begin
				select @c_subtitle_rich = ''
	   		   end

 			if @c_subtitle_reg is null 
   	  		 begin
				select @c_subtitle_reg = ''
	 		 end

			if datalength(@c_subtitle_rich)> 0
	 		 begin
		
				select @c_subtitle = @c_subtitle_rich
	  		  end
			else if datalength(@c_subtitle_reg)> 0
	 		 begin
				select @c_subtitle = @c_subtitle_reg
	  		  end

			select @c_alllastname  = ''
			select @d_pubdate = ''
			select @d_estdate = ''
			select @d_actdate = ''

			select @i_customkey = customint09 from bookcustom where bookkey = @i_bookkey

			if @i_customkey is null or @i_customkey = 0
			  begin
				select @i_customkey = @i_bookkey
			  end 

			if datalength(@c_subtitle) > 0
			  begin
			   if datalength(@c_subtitle_rich)> 0 
			     begin
				select @c_booktitle = @c_booktitle + ' ' + @c_subtitle
			     end
			   else
				begin
				    select @c_booktitle = @c_booktitle + ': ' + @c_subtitle
				end
			  end

			if @c_pubyear is null
			  begin
				select @c_pubyear = ''
			  end

			/*pubdate*/
			select @d_pubdate= bestdate,  @d_estdate=estdate,
				 @d_actdate= activedate from bookdates where bookkey=@i_bookkey
				and printingkey=1 and datetypecode=8

			/*authors lastnames*/

			select @c_alllastname  = ''
			select @i_firsttime = 1

			DECLARE cursor_author INSENSITIVE CURSOR
				FOR
					select distinct lastname,primaryind,sortorder
						from bookauthor b, author a
							where b.bookkey= @i_bookkey
							and b.authorkey= a.authorkey
								order by primaryind,sortorder
				FOR READ ONLY

			OPEN cursor_author 

			FETCH NEXT FROM cursor_author
				INTO @c_authorlastname,@i_primaryind,@i_sortorder

			select @i_authorstatus = @@FETCH_STATUS
	
				while (@i_authorstatus<>-1 )
	 			  begin
					IF (@i_authorstatus<>-2)
	  	 			  begin

						if @i_firsttime = 1
						   begin
							select @c_alllastname =  @c_authorlastname 			
						    end
						   else
						     begin
							select @c_alllastname = @c_alllastname + '/' + @c_authorlastname 			
						     end		

						select @i_firsttime = @i_firsttime + 1

		 			  end

					FETCH NEXT FROM cursor_author 
					  INTO  @c_authorlastname,@i_primaryind,@i_sortorder
      				 	 select @i_authorstatus = @@FETCH_STATUS
		 	 	 end

close cursor_author
deallocate cursor_author
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
				  
				  if @c_alllastname is null 
				     begin
					   select @c_alllastname  = ''
				     end

				if datalength(@c_alllastname) > 0 and datalength(@c_volume) = 0
				  begin
					select @c_alllastname = @c_alllastname + ', ' 
				  end
/*suppress author*/

				if @i_suppress_auth = 1
				  begin
					select @c_alllastname = ''
				  end

/*suppress title but leave subtitle if present*/

				if @i_suppress_title = 1
				  begin
					select @c_booktitle = ''
					if datalength(@c_subtitle) > 0
					  begin
						select @c_booktitle = @c_subtitle
					  end
				  end

				if datalength(@c_volume) > 0
				  begin
					if datalength(@c_booktitle) > 0 and datalength(@c_alllastname) > 0
					  begin 
						select @c_booktitle = @c_alllastname +  ': ' + @c_booktitle
					  end
					else if datalength(@c_alllastname) >0 and datalength(@c_booktitle) = 0
					  begin
						select @c_booktitle =  @c_alllastname 
					  end

					select @c_alllastname = @c_volume + ':'
				  end

				if @d_pubdate is null
				  begin
					insert into webseries (fdtxt) 
					select '<li><a href="/cgi-bin/hfs.cgi/00/' + convert(varchar (25), @i_customkey) +
					  '.ctl"><strong>' + convert(varchar, @c_pubyear) + '</strong>   <strong>' +
						@c_alllastname + '</strong>' + @c_booktitle + ' </a></li>'
				  end
				else if @d_pubdate > @d_cutoffdate
				  begin
					insert into webseries (fdtxt) 
					select '<li><img src="/Images/Chicago/newtag.gif" alt="New!"><a href="/cgi-bin/hfs.cgi/00/'
					 + convert(varchar (25), @i_customkey) +
					  '.ctl"><strong>' + convert(varchar, @c_pubyear) + '</strong>   <strong>' +
						@c_alllastname + '</strong>' + @c_booktitle + ' </a></li>'
				  end
				else
				  begin
					insert into webseries (fdtxt) 
					select '<li><a href="/cgi-bin/hfs.cgi/00/' + convert(varchar (25), @i_customkey) +
					  '.ctl"><strong>' + convert(varchar, @c_pubyear) + '</strong>   <strong>' +
						@c_alllastname + '</strong>' + @c_booktitle + ' </a></li>'
				 end
			   end

			FETCH NEXT FROM cursor_series_ind 
				INTO @i_workkey, @c_pubyear,@c_lastname,@c_booktitle,@c_subtitle,@i_volumenumber,@c_titleprefix
      				  select @i_status = @@FETCH_STATUS
		   end

close cursor_series_ind
deallocate cursor_series_ind

insert into webseries (fdtxt) select '</ul>'

insert into webseries (fdtxt) select '<!-- #include -->'

insert into webseries (fdtxt) select '</body>'

insert into webseries (fdtxt) select '</html>'

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO