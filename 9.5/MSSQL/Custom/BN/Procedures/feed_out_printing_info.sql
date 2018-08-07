if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_printing_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_printing_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



create proc dbo.feed_out_printing_info
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

**/

/* 11/9/04 CRM 02094: modification, add media, format, cartonqty,allocation,prod manager*/
/*2/9/05 CRM 2440: add FOB and bookweight*/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_key int

DECLARE @feed_pagecount int
DECLARE @feed_trimsizewidth varchar (20)
DECLARE @feed_trimsizelength  varchar (20)
DECLARE @feed_boardtrimsizewidth  varchar (20)
DECLARE @feed_boardtrimsizelength	varchar (20)
DECLARE @feed_vendor_print int
DECLARE @feed_vendor_bind  int
DECLARE @feed_count int
DECLARE @feed_mediatypecode int
DECLARE @feed_mediatypesubcode int

DECLARE @feedout_bookkey  int
DECLARE @feedout_printingkey int
DECLARE @feedout_isbn10 varchar (10)
DECLARE @feed_prefix varchar (25) 
DECLARE @feedout_titlewithprefix varchar (255)
DECLARE @feedout_printingnumber varchar (25) 
DECLARE @feedout_jobnumberalpha varchar (40)  
DECLARE @feedout_printingcreationdate varchar (40)  
DECLARE @feedout_warehousedate varchar (40)
DECLARE @feedout_revisedwarehousedate varchar (40)  
DECLARE @feedout_printqty int 
DECLARE @feedout_printvendorphonebookkey varchar (40) 
DECLARE @feedout_printvendor varchar (100)  
DECLARE @feedout_bindvendorphonebookkey varchar (40) 
DECLARE @feedout_bindvendor varchar (100) 
DECLARE @feedout_spinesize  varchar (40)
DECLARE @feedout_trimsize  varchar (40)
DECLARE @feedout_boardtrimsize  varchar (40)
DECLARE @feedout_formatcode varchar(100) 
DECLARE @feedout_formatdesc varchar(80)
DECLARE @feedout_mediacode varchar(100)
DECLARE @feedout_mediadesc varchar(120) 
DECLARE @feedout_paperallocation   int	
DECLARE @feedout_cartonqty	int 
DECLARE @feedout_prodmanagerdisplayname varchar(80) 
DECLARE @feedout_prodmanagerpphonebookkey varchar(40) 
DECLARE @feedout_freightterms varchar(50)
DECLARE @feedout_bookweight varchar(10)
DECLARE @feed_freightcountry varchar(25)
DECLARE @feed_freightprice int

DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Printings AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitsprintingfeed

DECLARE feedout_printings INSENSITIVE CURSOR
FOR

select distinct bookkey,printingkey from bnpubprintingfeedkeys

/* table above created in job scheduler*/
	
FOR READ ONLY
	
select @feed_count = 0

		
OPEN feedout_printings
FETCH NEXT FROM feedout_printings
	INTO @feedout_bookkey, @feedout_printingkey
 
select @i_key  = @@FETCH_STATUS

if @i_key <> 0 /*no printings*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('2',@feed_system_date,'NO ROWS to PROCESS - Printings')
  commit tran
end

while (@i_key<>-1 )  /* status 1*/
begin
	IF (@i_key<>-2) /* status 2*/
	begin

	/** Increment Title Count, Print Status every 500 rows **/
	select @titlecount=@titlecount + 1
	select @titlecountremainder=0
	select @titlecountremainder = @titlecount % 500
	if(@titlecountremainder = 0)
	begin
		select @titlestatusmessage =  convert (varchar (50),getdate()) + '   ' + convert (varchar (10),@titlecount) + '   Rows Processed'
		print @titlestatusmessage
	end 

	select @feed_count = 0
	select @feed_vendor_bind  = 0
	select @feed_vendor_print = 0

	select @feedout_isbn10 = ''
	select @feed_prefix = ''
	select @feedout_titlewithprefix = ''
	select @feedout_printingnumber = ''
	select @feedout_jobnumberalpha = ''  
	select @feedout_printingcreationdate = '' 
	select @feedout_warehousedate = '' 
	select @feedout_revisedwarehousedate = '' 
	select @feedout_printqty = 0 
	select @feedout_printvendorphonebookkey = '' 
	select @feedout_printvendor = ''  
	select @feedout_bindvendorphonebookkey = ''
	select @feedout_bindvendor = ''
	select @feedout_spinesize = ''
	select @feed_pagecount  = 0
	select @feedout_trimsize = ''
	select @feedout_boardtrimsize = ''
	select @feedout_formatcode = ''
	select @feed_mediatypecode  = 0
	select @feed_mediatypesubcode  = 0
	select @feedout_mediacode = ''
	select @feedout_mediadesc = ''
	select @feedout_cartonqty = 0
	select @feedout_prodmanagerdisplayname  = ''
	select @feedout_prodmanagerpphonebookkey = ''
	select @feedout_freightterms  = ''
	select @feedout_bookweight  = ''
	select @feed_freightcountry = ''
	select @feed_freightprice = 0

/*isbn, title, prefix,media,format*/

	select @feedout_isbn10 = isbn10,@feedout_titlewithprefix = title,
		@feed_prefix =titleprefix,@feed_mediatypecode = mediatypecode, @feed_mediatypesubcode = mediatypesubcode
			from isbn i,book b, bookdetail b2
			  where i.bookkey = b.bookkey and 
	 		    i.bookkey = b2.bookkey and b.bookkey = @feedout_bookkey

	if @feed_prefix is null
	  begin
		select @feed_prefix = ''
	  end
	
	if datalength(@feed_prefix) > 0
	  begin
		select @feedout_titlewithprefix = @feedout_titlewithprefix + ', ' + @feed_prefix
	  end
	if @feed_mediatypecode> 0 
	  begin
		select  @feedout_mediadesc =  datadesc,@feedout_mediacode =  externalcode
			from gentables where tableid= 312
			   and datacode=  @feed_mediatypecode
	  end 

	if @feed_mediatypecode> 0 and @feed_mediatypesubcode > 0
	  begin
		select  @feedout_formatdesc =  datadesc,@feedout_formatcode =  externalcode
			from subgentables where tableid= 312
			   and datacode=  @feed_mediatypecode
			   and datasubcode = @feed_mediatypesubcode
	  end 

	select @feed_count = 0
	select @feed_count  = count(*)
		from printing where
		  bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey 
	
	if @feed_count > 0
	  begin
		select @feedout_printingnumber = printingnum,@feed_trimsizelength = trimsizelength,@feed_trimsizewidth = trimsizewidth,
	  	  @feedout_printingcreationdate=convert(varchar,creationdate, 101),@feed_pagecount = pagecount,
			@feedout_printqty = tentativeqty, @feedout_spinesize = spinesize 
			from printing where
			 bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey
		
		select @feed_count = 0
		select @feed_count  = count(*)
			from printing where
		 		bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey

		select @feedout_jobnumberalpha = jobnumberalpha
			FROM printing
			 WHERE bookkey = @feedout_bookkey
			AND  printingkey = @feedout_printingkey 
		
		select @feed_boardtrimsizelength = boardtrimsizelength,@feed_boardtrimsizewidth = boardtrimsizewidth
			FROM printing
			 WHERE bookkey = @feedout_bookkey
			AND  printingkey = @feedout_printingkey 
		
	 end

	if datalength(rtrim(@feed_trimsizewidth)) > 0 and datalength(rtrim(@feed_trimsizelength)) > 0 
	  begin
		select @feedout_trimsize = @feed_trimsizewidth + ' x ' + @feed_trimsizelength
	  end
		
	if rtrim(ltrim(@feedout_trimsize)) = 'x' 
  	  begin
		select @feedout_trimsize = ''
	  end

	if datalength(rtrim(@feed_boardtrimsizewidth)) > 0 and datalength(rtrim(@feed_boardtrimsizelength)) > 0 
	  begin
		select @feedout_boardtrimsize = @feed_boardtrimsizewidth + ' x ' + @feed_boardtrimsizelength
	  end
		
	if rtrim(ltrim(@feedout_boardtrimsize)) = 'x' 
  	  begin
		select @feedout_boardtrimsize = ''
	  end

/*warehouse date,revisedwarehousedate */
	select @feed_count = 0 
	select @feed_count = count(*)
		from bookdates where bookkey= @feedout_bookkey
			and printingkey=@feedout_printingkey and datetypecode=417 
	if @feed_count > 0
	  begin
		select @feedout_revisedwarehousedate = convert(varchar,bestdate, 101)
			from bookdates where bookkey= @feedout_bookkey
				and printingkey=@feedout_printingkey and datetypecode=417
	  end

	select @feed_count = 0 
	select @feed_count = count(*)
		from bookdates where bookkey= @feedout_bookkey
			and printingkey=@feedout_printingkey and datetypecode= 47

	if @feed_count > 0
	  begin
		select @feedout_warehousedate = convert(varchar,bestdate, 101)
		   from bookdates where bookkey= @feedout_bookkey
			and printingkey=@feedout_printingkey and datetypecode=47
	 end

	select @feed_count = 0
	select @feed_count  = count(*)
		from printing p, textspecs t where
		  p.bookkey = t.bookkey and p.printingkey = t.printingkey and
		  p.bookkey =  @feedout_bookkey and p.printingkey = @feedout_printingkey

 	if @feed_count > 0 /*Vendor print*/
	  begin
		 select @feed_vendor_print  = vendorkey
		   from printing p, textspecs t where
			  p.bookkey = t.bookkey and p.printingkey = t.printingkey and
			  p.bookkey =  @feedout_bookkey and p.printingkey = @feedout_printingkey

		
		select @feedout_printvendorphonebookkey = vendorid, @feedout_printvendor = name
			from vendor where vendorkey = @feed_vendor_print
	  end

	select @feed_count = 0
	select @feed_count  = count(*)
		from printing p, bindingspecs t where
		  p.bookkey = t.bookkey and p.printingkey = t.printingkey and
		  p.bookkey =  @feedout_bookkey and p.printingkey = @feedout_printingkey

	if @feed_count > 0 /*Vendor bind*/
	  begin
		 select @feed_vendor_bind  = vendorkey,@feedout_cartonqty = cartonqty1
		   from printing p, bindingspecs t where
			  p.bookkey = t.bookkey and p.printingkey = t.printingkey and
			  p.bookkey =  @feedout_bookkey and p.printingkey = @feedout_printingkey

		
		select @feedout_bindvendorphonebookkey = vendorid, @feedout_bindvendor = name
			from vendor where vendorkey = @feed_vendor_bind
	  end		

	/*prod manager--personnel roletypecode=1*/
		select @feed_count = 0
		select @feed_count  = contributorkey
			from  bookcontributor
				where bookkey=@feedout_bookkey and printingkey = @feedout_printingkey
				  and roletypecode = 1

		if @feed_count  > 0
		begin
			select @feedout_prodmanagerdisplayname  = displayname, @feedout_prodmanagerpphonebookkey = externalcode
			 from person
				where contributorkey = @feed_count
		end	
	
/* allocation-- if multiple add together*/
		select @feed_count = 0
		select @feed_count  = count(*)
			from  materialspecs
				where bookkey=@feedout_bookkey and printingkey = @feedout_printingkey

		if @feed_count  > 0
		  begin
			select @feedout_paperallocation  = sum(allocation)
			from  materialspecs
				where bookkey=@feedout_bookkey and printingkey = @feedout_printingkey and allocation>0
		  end 

/* 2/9/05 bookweight*/

		select @feed_count = 0
		select @feed_count  = count(*)
			from  booksimon
				where bookkey=@feedout_bookkey

		if @feed_count  > 0
		  begin
			select @feedout_bookweight = bookweight
			from  booksimon
				where bookkey=@feedout_bookkey 

			if @feedout_bookweight is null 
			  begin
				select @feedout_bookweight = ''
			  end
		  end 

/* add freightpriceing.. these values are hardcoded */
		select @feed_count = 0
		select @feed_count  = count(*)
			from  gpoimport g, component c, gpo gp
				where g.gpokey=pokey and g.gpokey=gp.gpokey
				 	and c.bookkey=@feedout_bookkey and c.printingkey=@feedout_printingkey 
					and c.compkey = 2 /* bind*/
					and gp.gpostatus in ('F')  /* final*/

		if @feed_count  > 0
		  begin
			select @feed_freightprice  = freightpricingind, @feed_freightcountry = freightpricingcountry
			from  gpoimport g, component c, gpo gp
				where g.gpokey=pokey and g.gpokey=gp.gpokey
				 	and c.bookkey=@feedout_bookkey and c.printingkey=@feedout_printingkey 
					and c.compkey = 2 /* bind*/
					and gp.gpostatus in ('F')  /* final*/
			
		  end
		else
		  begin
			select @feed_count = 0
			select @feed_count  = count(*)
			from  gpoimport g, component c, gpo gp
				where g.gpokey=pokey and g.gpokey=gp.gpokey
				 	and c.bookkey=@feedout_bookkey and c.printingkey=@feedout_printingkey 
					and c.compkey = 2 /* bind*/
					and gp.gpostatus in ('P')  /* Proforma*/
	
			if @feed_count  > 0
			  begin
				select @feed_freightprice  = freightpricingind, @feed_freightcountry = freightpricingcountry
				   from  gpoimport g, component c, gpo gp
					where g.gpokey=pokey and g.gpokey=gp.gpokey
				 	and c.bookkey=@feedout_bookkey and c.printingkey=@feedout_printingkey 
					and c.compkey = 2 /* bind*/
					and gp.gpostatus in ('P')  /* Proforma*/
			  end
		  end
		    
		if @feed_freightprice is null 
		  begin
			select @feed_freightprice = 0
		  end

		if @feed_freightcountry is null 
		  begin
			select @feed_freightcountry = ''
		  end
		if @feed_freightprice = 1
		  begin
			select @feedout_freightterms =  'FOB'
		  end
		if @feed_freightprice = 2
		  begin
			select @feedout_freightterms =  'CIF'
		  end
		if @feed_freightprice = 3
		  begin
			select @feedout_freightterms =  'EXWORKS'
		  end
		
		if len(@feed_freightcountry) > 0
		  begin
			if len(@feedout_freightterms) >0
			  begin
				select @feedout_freightterms = @feedout_freightterms + '-' + @feed_freightcountry
			  end
			else
			  begin
				select @feedout_freightterms =  ' -' + @feed_freightcountry
			  end
		end

/***************************   warning messages  comment for now   
begin tran
	if @feedout_titlewithprefix is null  
	  begin
		select @feedout_titlewithprefix = ''
	  end
	
	if datalength(@feedout_titlewithprefix) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'2',@feed_system_date,'Printing-- warning title missing')
	end

	if @feedout_isbn10 is null  
	  begin
		select @feedout_isbn10 = ''
	  end

	if datalength(@feedout_isbn10) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'2',@feed_system_date,'Printing-- warning isbn missing')
	end

	if @feedout_printingnumber is null  
	  begin
		select @feedout_printingnumber = ''
	  end
	if datalength(@feedout_printingnumber) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'2',@feed_system_date,'Printing-- warning printingnumber missing')
	end
	
	if @feedout_jobnumberalpha is null  
	  begin
		select @feedout_jobnumberalpha = ''
	  end

	if datalength(@feedout_jobnumberalpha) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'2',@feed_system_date,'Printing-- warning jobnumberalpha missing')
	end

	
commit tran

***************************/
	
/*insert into temporary table*/
begin tran
	insert into bnmitsprintingfeed (bookkey,printingkey,isbn10,titlewithprefix,printingnumber,
	jobnumberalpha,printingcreationdate,warehousedate,revisedwarehousedate,
	printqty,printvendorphonebookkey,printvendor,bindvendorphonebookkey,bindvendor,pagecount,
	trimsize,boardtrimsize,spinesize,formatcode,mediacode,mediadesc,paperallocation,cartonqty,
	prodmanagerdisplayname,prodmanagerpphonebookkey,freightterms,bookweight )
	values (@feedout_bookkey ,@feedout_printingkey,@feedout_isbn10,@feedout_titlewithprefix, @feedout_printingnumber,
	@feedout_jobnumberalpha,@feedout_printingcreationdate,@feedout_warehousedate,@feedout_revisedwarehousedate,
	@feedout_printqty,@feedout_printvendorphonebookkey,@feedout_printvendor,@feedout_bindvendorphonebookkey, 
	@feedout_bindvendor,@feed_pagecount,@feedout_trimsize,@feedout_boardtrimsize,@feedout_spinesize,
	@feedout_formatcode,@feedout_mediacode,@feedout_mediadesc,@feedout_paperallocation,@feedout_cartonqty, 
	@feedout_prodmanagerdisplayname,@feedout_prodmanagerpphonebookkey,@feedout_freightterms,@feedout_bookweight)

commit tran

end /*isbn status 2*/

FETCH NEXT FROM feedout_printings 
	INTO @feedout_bookkey,@feedout_printingkey 

select @i_key  = @@FETCH_STATUS
end /*isbn status 1*/

begin tran


/* 8-24-04 move all deletes before count*/

select @feed_count = 0

select @feed_count = count(*) from bnmitsprintingfeed
if @feed_count > 0
  begin
	insert into bnmitsprintingfeed(bookkey,printingkey,printingnumber)
	  values (0,0,'Total Records '+ convert(varchar,@feed_count))
  end	

insert into feederror (batchnumber,processdate,errordesc)
 values ('2',@feed_system_date,'Printing Out Completed')

commit tran

close feedout_printings
deallocate feedout_printings

select @statusmessage = 'END TMM FEED OUT Printings AT ' + convert (char,getdate())
print @statusmessage

return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO