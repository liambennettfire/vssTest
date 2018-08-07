SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_web') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.feed_out_web
end

GO

create proc dbo.feed_out_web @i_websitekey tinyint,@i_groupchoice tinyint
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/*7-29-04 CRM 1395:  title length now 255 so substring variable title select to 80*/

DECLARE @err_msg varchar (100)

DECLARE @feed_system_date datetime
DECLARE @feedout_isbn varchar(10) 
DECLARE @feedout_title varchar(80)
DECLARE @feedout_descshort varchar(1000)
DECLARE @feedout_desclong varchar(4000)/*text datatype*/
DECLARE @feedout_price numeric(9,2)
DECLARE @feedout_pages int 
DECLARE @feedout_trimsize varchar(10)  
DECLARE @feedout_authortype varchar(40) /*type from sortorder= 1, first author*/
DECLARE @feedout_authorname1 varchar(100)
DECLARE @feedout_authorname2 varchar(100)
DECLARE @feedout_authorname3 varchar(100)
DECLARE @feedout_authorname4 varchar(100)
DECLARE @feedout_authorname5 varchar(100)
DECLARE @feedout_cat1 varchar(40)
DECLARE @feedout_cat2 varchar(40)
DECLARE @feedout_cat3 varchar(40)
DECLARE @feedout_cat4 varchar(40)
DECLARE @feedout_cat5 varchar(40)
DECLARE @feedout_cat6 varchar(40)
DECLARE @feedout_cat7 varchar(40)
DECLARE @feedout_cat8 varchar(40)
DECLARE @feedout_cat9 varchar(40)
DECLARE @feedout_cat10 varchar(40)
DECLARE @feedout_media varchar(1000)
DECLARE @feedout_relatedtit varchar(100)
DECLARE @feedout_bestseller varchar(100)
DECLARE @feedout_newrelease varchar(100)
DECLARE @feedout_forthcoming varchar(100)
DECLARE @feedout_exportcode varchar(100)
DECLARE @feedout_exportrestrict varchar(100)
DECLARE @feedout_upc varchar(50)
DECLARE @feedout_ean varchar(50)
DECLARE @i_bookkey int
DECLARE @i_isbn int
DECLARE @i_cat int
DECLARE @feedout_count int
DECLARE @feedout_code int
DECLARE @c_subjectcat varchar(30)
DECLARE @i_sortorder int
DECLARE @feedout_relatedisbn varchar(10)

BEGIN tran
 
SELECT @feed_system_date = getdate()

 
 /* delete old records */ 
 delete from  feedout_web 
 
if @i_groupchoice = 1 /*trade groug*/
  begin

DECLARE feed_titles INSENSITIVE CURSOR
  FOR
 select distinct b.bookkey
 	from bookdetail b, website w, catalog c, catalogsection cs, bookcatalog bc
 		 where c.catalogkey= w.websitecatalogkey
			and c.catalogkey= cs.catalogkey
			and cs.sectionkey=bc.sectionkey
			and bc.bookkey=b.bookkey 
			and bisacstatuscode <> 6 
  			and w.websitekey= @i_websitekey
 FOR READ ONLY
end

if @i_groupchoice = 2 /*consumer group*/
  begin

DECLARE feed_titles INSENSITIVE CURSOR
  FOR
 select distinct b.bookkey
	from bookdetail b, website w, catalog c, catalogsection cs, bookcatalog bc
 		 where c.catalogkey= w.websitecatalogkey
			and c.catalogkey= cs.catalogkey
			and cs.sectionkey=bc.sectionkey
			and bc.bookkey=b.bookkey 
			and  bisacstatuscode not in (4, 6) 
   			and w.websitekey= @i_websitekey
  
 FOR READ ONLY
end
		
OPEN feed_titles
FETCH NEXT FROM feed_titles 
INTO  
	@i_bookkey

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedout_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
end

while (@i_isbn<>-1 )  /* sttus 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

		 if @i_bookkey > 0 
		   begin
/* clear fields for next record*/ 
  			select @feedout_count = 0
			select @feedout_code = 0
  			select @feedout_title = ''
			select @feedout_descshort = ''
			select @feedout_desclong = ''
	  		select @feedout_price = 0
			select @feedout_pages = 0
	  		select @feedout_trimsize = ''  
	  		select @feedout_authortype = ''
	  		select @feedout_media = '' 
	  		select @feedout_relatedtit = ''
	  		select @feedout_bestseller = ''
	  		select @feedout_newrelease = ''
	  		select @feedout_forthcoming = ''
	  		select @feedout_exportcode = ''
	  		select @feedout_exportrestrict = ''
	  		select @feedout_upc = ''
	  		select @feedout_ean = ''
			select @feedout_authorname1 = ''
			select @feedout_authorname2 = ''
			select @feedout_authorname3 = ''
			select @feedout_authorname4 = ''
			select @feedout_authorname5  = ''
			select @feedout_cat1 = ''
			select @feedout_cat2 = ''
			select @feedout_cat3 = ''
			select @feedout_cat4 = ''
			select @feedout_cat5 = ''
			select @feedout_cat6 = ''
			select @feedout_cat7 = ''
			select @feedout_cat8 = ''
			select @feedout_cat9 = ''
			select @feedout_cat10 = ''
			select @c_subjectcat = ''

/*title, ean, upc, media, pagecount,trimsize, price, author use warehouse*/
   			select @feedout_count = count(*) 
			     from whtitleinfo 
  				   where bookkey=@i_bookkey  
  			if @feedout_count > 0 
			  begin
   				select @feedout_isbn=isbn10,@feedout_title = substring(title,1,80),@feedout_ean = ean, @feedout_upc = upc, @feedout_media = format,
					@feedout_pages = pagecountbest, @feedout_trimsize = trimsizebest, @feedout_price= uspricebest
				    from whtitleinfo
     					where bookkey=@i_bookkey 
 
   				if len(RTRIM(@feedout_isbn))= 0 
				  begin 
				    insert into feedhistory (numisbnsucceeded, 
     						numisbnfailed,batchnumber,processdate,messagetext) 
  					  values (0, @i_bookkey,1,@feed_system_date,'NO ISBN ENTERED') 
     				  end
  			  end
			else
			  begin
 				insert into feedhistory (numisbnsucceeded, 
     					numisbnfailed,batchnumber,processdate,messagetext) 
  				  values (0, @i_bookkey,1,@feed_system_date,'NO ROW on WHTITLEINFO TABLE for this title') 
			   end


/* media -> format, use alternatedesc1 if present*/
			select @feedout_count = datalength(alternatedesc1) 
				from bookdetail b, subgentables s
					where s.datacode= b.mediatypecode
						and s.datasubcode = b.mediatypesubcode
						and b.bookkey=@i_bookkey and s.tableid=312
			if @feedout_count > 0
			  begin	
				select @feedout_media = alternatedesc1 
					from bookdetail b, subgentables s
						where s.datacode= b.mediatypecode
							and s.datasubcode = b.mediatypesubcode
							and b.bookkey=@i_bookkey and s.tableid=312
			  end 			
	
			select @feedout_count = count(*) 
			     from whauthor 
  				   where bookkey=@i_bookkey  
  			if @feedout_count > 0 
			  begin
    				 select @feedout_authortype = authortype1,@feedout_authorname1 = completeauthorname1,
					@feedout_authorname2 = completeauthorname2, 
					@feedout_authorname3 = completeauthorname3,@feedout_authorname4 = completeauthorname4, 
					 @feedout_authorname5  = completeauthorname5 
          					from  whauthor
          				 where bookkey = @i_bookkey
			end
    			else 
     		  	  begin
 				insert into feedhistory (numisbnsucceeded, 
     					numisbnfailed,batchnumber,processdate,messagetext) 
  				 values (0, @i_bookkey,1,@feed_system_date,'NO ROW on WHAUTHOR TABLE for this title') 
			 end

    /* cat 1 to 10 booksubjectcategory need to know what categorysub2code is????*/
		select @i_sortorder = 0
   		DECLARE feed_category INSENSITIVE CURSOR
 		 FOR
 			select externalcode
 				from booksubjectcategory b, subgentables g
  					where b.categorycode=g.datacode
						and b.categorysubcode = g.datasubcode
						and b.categorytableid = g.tableid
						and g.tableid=412
						and b.bookkey = @i_bookkey
							order by b.sortorder
  
 			FOR READ ONLY
		
		OPEN feed_category
			FETCH NEXT FROM feed_category 
			INTO  
				@c_subjectcat

				select @i_cat  = @@FETCH_STATUS

				while (@i_cat<>-1 )  /* sttus 1*/
				  begin
					IF (@i_cat<>-2) /* status 2*/
						begin
							select @i_sortorder = @i_sortorder + 1
							if @i_sortorder = 1 
							  begin
							    select @feedout_cat1 = @c_subjectcat
							  end
							if @i_sortorder = 2 
							  begin
							    select @feedout_cat2 = @c_subjectcat
							  end
							if @i_sortorder = 3 
							  begin
							    select @feedout_cat3 = @c_subjectcat
							  end
							if @i_sortorder = 4 
							  begin
							    select @feedout_cat4 = @c_subjectcat
							  end
							if @i_sortorder = 5 
							  begin
							    select @feedout_cat5 = @c_subjectcat
							  end
							if @i_sortorder = 6 
							  begin
							    select @feedout_cat6 = @c_subjectcat
							  end
							if @i_sortorder = 7 
							  begin
							    select @feedout_cat7 = @c_subjectcat
							  end
							if @i_sortorder = 8 
							  begin
							    select @feedout_cat8 = @c_subjectcat
							  end
							if @i_sortorder = 9 
							  begin
							    select @feedout_cat9 = @c_subjectcat
							  end
							if @i_sortorder = 10 
							  begin
							    select @feedout_cat10 = @c_subjectcat
							  end
							if @i_sortorder > 10 
							  begin
							    break
							  end

						end

						FETCH NEXT FROM feed_category
						  INTO 
							@c_subjectcat

				 	select @i_cat= @@FETCH_STATUS
				end

		close feed_category
		deallocate feed_category

/* comment brief description datacode 3 and subcode 7*/
			select @feedout_count = 0
			select @feedout_count = count(*) 
			     from bookcommenthtml 
  				   where bookkey=@i_bookkey  
					and printingkey=1
					and commenttypecode=3 and commenttypesubcode=7
  			if @feedout_count > 0 
			  begin
    				 select @feedout_descshort = commenttext 
					from bookcommenthtml
  				 	  where bookkey=@i_bookkey 
						and printingkey=1 
						and commenttypecode=3 and commenttypesubcode=7
				end
			  else
			    begin	
					select @feedout_count = count(*) 
					     from bookcomments 
		  				   where bookkey=@i_bookkey  
							and printingkey=1
							and commenttypecode=3 and commenttypesubcode=7
		  			if @feedout_count > 0 
					  begin
    						 select @feedout_descshort = commenttext 
							from bookcomments 
  							   where bookkey=@i_bookkey 
								and printingkey=1 
								and commenttypecode=3 and commenttypesubcode=7
					end
			  end
  /* comment description datacode 3 and subcode 8*/
			select @feedout_count = 0

			select @feedout_count = count(*) 
			     from bookcommenthtml
  				   where bookkey=@i_bookkey  
					and printingkey=1
					and commenttypecode=3 and commenttypesubcode=8
			  if @feedout_count > 0 
			    begin
  				 select @feedout_desclong = commenttext 
					from bookcommenthtml 
  				   where bookkey=@i_bookkey 
					and printingkey=1 
					and commenttypecode=3 and commenttypesubcode=8
				end
			else		
			  begin
				select @feedout_count = 0

				select @feedout_count = count(*) 
				     from bookcomments 
  					   where bookkey=@i_bookkey  
						and printingkey=1
						and commenttypecode=3 and commenttypesubcode=8
	  			if @feedout_count > 0 
				  begin
    					 select @feedout_desclong = commenttext 
						from bookcomments 
  					   where bookkey=@i_bookkey 
						and printingkey=1 
						and commenttypecode=3 and commenttypesubcode=8
				end
  			  end
/* associated titles do not have all the pieces as yet*/
			select @feedout_count = 0
			select @feedout_relatedisbn = ''

			select @feedout_count = count(*) 
			    from associatedtitles a, isbn i
  				where a.associatetitlebookkey =i.bookkey
					and associationtypecode=4
					and a.bookkey = @i_bookkey
			if @feedout_count > 0 
			  begin
  				DECLARE feed_associated INSENSITIVE CURSOR
 				 FOR
 					select isbn10
 						from associatedtitles a, isbn i
  							where a.associatetitlebookkey =i.bookkey
							      and associationtypecode=4
								and a.bookkey = @i_bookkey
 				FOR READ ONLY
		
				OPEN feed_associated
				FETCH NEXT FROM feed_associated
				    INTO  
					@feedout_relatedisbn

				select @i_cat  = @@FETCH_STATUS

				while (@i_cat<>-1 )  /* sttus 1*/
				  begin
					IF (@i_cat<>-2) /* status 2*/
					  begin
						if datalength(@feedout_relatedtit) > 0
						  begin
							select @feedout_relatedtit = @feedout_relatedtit + ' ' + @feedout_relatedisbn
						   end
						else
						  begin
							select @feedout_relatedtit =  @feedout_relatedisbn
						  end
					  end

					FETCH NEXT FROM feed_associated
					  INTO 
					     @feedout_relatedisbn

				 	select @i_cat= @@FETCH_STATUS
				end

		close feed_associated
		deallocate feed_associated
	end /*bookkey > 0*/

  /* 3-25-02  CREATE FEEDOUT  TABLE*/	

	INSERT INTO feedout_web
		(isbn , title ,descshort,desclong,price,pages ,trimsize ,authortype ,authorname1 ,
		authorname2 ,authorname3 ,authorname4,authorname5 ,cat1,cat2,cat3,cat4,cat5,cat6,cat7, 
		cat8,cat9,cat10,media,relatedtit,bestseller,newrelease ,forthcoming, 
		exportcode,exportrestrict,upc,ean) 
	VALUES (@feedout_isbn  ,@feedout_title ,@feedout_descshort,@feedout_desclong,@feedout_price ,
		@feedout_pages ,@feedout_trimsize  ,
		@feedout_authortype ,@feedout_authorname1 ,@feedout_authorname2 ,@feedout_authorname3 ,
		@feedout_authorname4 ,@feedout_authorname5 ,@feedout_cat1 ,@feedout_cat2 ,@feedout_cat3, 
		@feedout_cat4 ,@feedout_cat5 ,@feedout_cat6 ,@feedout_cat7 ,@feedout_cat8 ,@feedout_cat9, 
		@feedout_cat10 ,@feedout_media ,@feedout_relatedtit ,@feedout_bestseller ,@feedout_newrelease, 
		@feedout_forthcoming ,@feedout_exportcode ,@feedout_exportrestrict ,@feedout_upc ,
		@feedout_ean )

	end
		FETCH NEXT FROM feed_titles
		  INTO 	
			@i_bookkey

			select @i_isbn = @@FETCH_STATUS
end

END

close feed_titles
deallocate feed_titles

commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

