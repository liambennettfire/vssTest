PRINT 'STORED PROCEDURE : dbo.webvirtcatdetail_sp'
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.webvirtcatdetail_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.webvirtcatdetail_sp
end

GO
create proc dbo.webvirtcatdetail_sp @i_categorycode int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @c_dummy varchar (25)
DECLARE @i_count int
DECLARE @i_count1 int
DECLARE @i_categorysubcode int

DECLARE @c_title varchar (500)
DECLARE @c_title2 varchar (500)

DECLARE @c_authorlastname varchar (100)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_authormiddlename varchar (100)
DECLARE @c_alllastname varchar (1000)

DECLARE @i_bookkey int
DECLARE @i_workkey int
DECLARE @i_customkey int
DECLARE @c_booktitle varchar (2000)
DECLARE @c_title_reg varchar (2000)
DECLARE @c_title_rich varchar (2000)
DECLARE @c_subtitle varchar (2000)
DECLARE @c_subtitle_reg varchar (2000)
DECLARE @c_subtitle_rich varchar (2000)

DECLARE @c_titleprefix varchar (50)

DECLARE @c_pubyear varchar (255)
DECLARE @d_pubdate datetime
DECLARE @d_actdate datetime
DECLARE @d_estdate datetime

DECLARE @i_primaryind int
DECLARE @i_sortorder int

DECLARE @i_status int
DECLARE @i_authorstatus int
DECLARE @i_status2 int

DECLARE @c_nullvalue varchar (10)
DECLARE @searchtest1 int
DECLARE @i_volumenumber int
DECLARE @c_volume_reg varchar (2000)
DECLARE @c_volume varchar (2000)


/*7-9-04 change desc to coalesce(alternatedesc1,datadesc)
0 is placeholder in gentables select if no subgentable
10-27-04 crm 02045 no longer add volume number to title if present leave as is*/

truncate table webcat

select @c_nullvalue = null

/*******************************************/
/* Output the beginning Product tag for this subjects */
/*******************************************/
insert into webcat (fdtxt) select '<html>'

select @c_title = rtrim(g.datadesc)
  from gentables g
	where g.tableid=414
		and g.datacode= @i_categorycode	

insert into webcat (fdtxt) 
   select '<head><title>' + @c_title + '</title></head>'

insert into webcat (fdtxt) 
select '<body>'

insert into webcat (fdtxt) 
   select '<h2>' + @c_title + '</h2>'

select @i_categorysubcode = 0
select @i_count =0

/*check for subgentable row*/
	select @i_count = count(*)
			from booksubjectcategory b, bookauthor bb, book bo, author a,subgentables sg
		 		 where b.bookkey = bo.bookkey
					and b.bookkey = bb.bookkey
					and bb.authorkey=a.authorkey
					and b.categorytableid=sg.tableid
					and bb.primaryind = 1 and bb.sortorder = 1
					and sg.tableid=414  
					and b.categorycode=sg.datacode
					and b.categorysubcode = sg.datasubcode
					and b.categorycode = @i_categorycode
  if @i_count > 0 
    begin	
	DECLARE cursor_catalog INSENSITIVE CURSOR
	  FOR
		select distinct b.categorysubcode,coalesce(alternatedesc1,datadesc) datadesc,sg.sortorder
			from booksubjectcategory b, bookauthor bb, book bo, author a,subgentables sg
		 		 where b.bookkey = bo.bookkey
					and b.bookkey = bb.bookkey
					and bb.authorkey=a.authorkey
					and b.categorytableid=sg.tableid
					and bb.primaryind = 1 and bb.sortorder = 1
					and sg.tableid=414  
					and b.categorycode=sg.datacode
					and b.categorysubcode = sg.datasubcode
					and b.categorycode = @i_categorycode
						order by sg.sortorder,sg.datadesc
		FOR READ ONLY
   end 
 else
    begin
	DECLARE cursor_catalog INSENSITIVE CURSOR
	  FOR
		select distinct 0 categorysubcode,coalesce(alternatedesc1,datadesc) datadesc,sg.sortorder
			from booksubjectcategory b, bookauthor bb, book bo, author a,gentables sg
		 		 where b.bookkey = bo.bookkey
					and b.bookkey = bb.bookkey
					and bb.authorkey=a.authorkey
					and b.categorytableid=sg.tableid
					and bb.primaryind = 1 and bb.sortorder = 1
					and sg.tableid=414 
					and b.categorycode=sg.datacode
					and b.categorycode = @i_categorycode
						order by sg.sortorder,sg.datadesc
  		FOR READ ONLY
  end

	OPEN cursor_catalog 

	FETCH NEXT FROM cursor_catalog
	INTO @i_categorysubcode,@c_title2,@i_sortorder

	select @i_status2 = @@FETCH_STATUS
	
	while (@i_status2<>-1 )
	  begin
		IF (@i_status2<>-2)
	  	  begin
			insert into webcat (fdtxt) 
			   select '<p><strong>' + @c_title2 + '</strong>'

			insert into webcat (fdtxt) select '<ul>'

/*******************************************/
/*      Output subcode, author: and title */
/*******************************************/
	
	if @i_count > 0
	  begin
		DECLARE cursor_catalog_ind INSENSITIVE CURSOR
		FOR
					select distinct bo.workkey,a.lastname,a.firstname,a.middlename,bo.title ,bo.subtitle,bk.titleprefix,volumenumber
						from booksubjectcategory b,bookdetail bk, bookauthor bb, book bo, author a
		 				 where b.bookkey=bk.bookkey
							and b.bookkey=bb.bookkey and b.bookkey= bo.bookkey and bb.authorkey=a.authorkey
							and b.categorytableid=414 and bk.bisacstatuscode in (1,4)
							and bb.primaryind = 1 and bb.sortorder = 1
							and b.categorycode = @i_categorycode  
							and b.categorysubcode = @i_categorysubcode				
						order by a.lastname,bo.title		
		FOR READ ONLY
	  end
	else
	  begin
		DECLARE cursor_catalog_ind INSENSITIVE CURSOR
			FOR
				select distinct bo.workkey,a.lastname,a.firstname,a.middlename,bo.title ,bo.subtitle,bk.titleprefix,volumenumber
					from booksubjectcategory b,bookdetail bk, bookauthor bb, book bo, author a
		 				 where b.bookkey=bk.bookkey
							and b.bookkey=bb.bookkey and b.bookkey= bo.bookkey and bb.authorkey=a.authorkey
							and b.categorytableid=414 and bk.bisacstatuscode in (1,4)
							and bb.primaryind = 1 and bb.sortorder = 1
							and b.categorycode = @i_categorycode  				
						order by a.lastname,bo.title		
		FOR READ ONLY
	
	  end

	OPEN cursor_catalog_ind 

			FETCH NEXT FROM cursor_catalog_ind 
				INTO @i_workkey, @c_authorlastname, @c_authorfirstname, @c_authormiddlename,@c_booktitle,@c_subtitle,@c_titleprefix,@i_volumenumber

				select @i_status = @@FETCH_STATUS
	
				while (@i_status<>-1 )
				  begin
					IF (@i_status<>-2)
				  	  begin


						select @c_title_rich = ''
						select @c_title_reg = ''
						select @c_subtitle_reg = ''
						select @c_subtitle_rich = ''
						select @c_volume_reg = ''
						select @c_volume = ''

/*remove multiple if present*/
						select @i_count1 = 0
						select @i_count1 = count(*)  from bookdetail bo, book b where workkey = @i_workkey
							and b.bookkey=bo.bookkey and bo.bisacstatuscode in (1,4)

						if @i_count1 = 1
						  begin
							select @i_bookkey = b.bookkey  from bookdetail bo, book b where workkey = @i_workkey
							and b.bookkey=bo.bookkey and bo.bisacstatuscode in (1,4)
			 			 end
		
						if @i_count1 > 1  /* multiple titles so parent should be workkey*/
						  begin
							select @i_bookkey = @i_workkey
						  end

						select @c_alllastname  = ''

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

						if @c_subtitle is null
						  begin
							select @c_subtitle = ''
						  end
					
						select @i_count1 = 0
						select @i_count1 = count(*) from bookcomments where printingkey=1 and
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
							select @i_count1 = 0
							select @i_count1 = charindex(upper(@c_volume),upper(@c_booktitle))
							if @i_count1 = 0 
							  begin
								select @c_booktitle = @c_booktitle +', ' + @c_volume
							  end
 						 end
					**/
						select @i_count1 = 0

						select @i_count1 = count(*) from bookcommenthtml where printingkey=1 and
							bookkey= @i_bookkey and commenttypecode=1 and
							commenttypesubcode = 29

						if @i_count1 > 0 
 						  begin
							select @c_title_rich = commenttext from bookcommenthtml where printingkey=1 and
								bookkey= @i_bookkey and commenttypecode=1 and
								commenttypesubcode = 29
						  end

						select @i_count1 = 0

						select @i_count1 = count(*) from bookcomments where printingkey=1 and
							bookkey= @i_bookkey and commenttypecode=1 and
							commenttypesubcode = 29
						
						if @i_count1 > 0 
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

						select @i_count1 = 0

						select @i_count1 = count(*) from bookcommenthtml where printingkey=1 and
							bookkey= @i_bookkey and commenttypecode=1 and
							commenttypesubcode = 30

						if @i_count1 > 0 
 			 			 begin
							select @c_subtitle_rich = commenttext from bookcommenthtml where printingkey=1 and
								bookkey= @i_bookkey and commenttypecode=1 and
								commenttypesubcode = 30
						  end
	
						select @i_count1 = 0

						select @i_count1 = count(*) from bookcomments where printingkey=1 and
							bookkey= @i_bookkey and commenttypecode=1 and
							commenttypesubcode = 30

						if @i_count1 > 0 
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
			/*author*/
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


						insert into webcat (fdtxt) 
							select '<li><i>' +@c_alllastname +':</i> <a href="http://www.press.uchicago.edu/cgi-bin/hfs.cgi/00/' + convert(varchar (25), @i_customkey) +
							  '.ctl">'  + @c_booktitle + '</a></li>'
					   end

				FETCH NEXT FROM cursor_catalog_ind 
					  INTO  @i_workkey, @c_authorlastname, @c_authorfirstname, @c_authormiddlename,@c_booktitle,@c_subtitle,@c_titleprefix,@i_volumenumber
      				  select @i_status = @@FETCH_STATUS
			   end
close cursor_catalog_ind
deallocate cursor_catalog_ind
	
		insert into webcat (fdtxt) select '</ul>'

		FETCH NEXT FROM cursor_catalog 
		  INTO  @i_categorysubcode,@c_title2,@i_sortorder
		  select @i_status2 = @@FETCH_STATUS
	   end

end
	insert into webcat (fdtxt) select '</body>'

	insert into webcat (fdtxt) select '</html>'

close cursor_catalog
deallocate cursor_catalog

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO