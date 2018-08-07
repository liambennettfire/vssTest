PRINT 'STORED PROCEDURE : dbo.feed_out_cops'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_cops') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.feed_out_cops
end

GO

create proc dbo.feed_out_cops
@p_location varchar(100),
@typeofrun  tinyint /*1 =  full run; all isbns otherwise new isbns for the day only*/

AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/*7-29-04 CRM 1395:  title length now 255 so change variable length*/

DECLARE
 
@lv_output_string VARCHAR (8000) 

DECLARE @isbn varchar(10)
DECLARE @bookkey int
DECLARE @title varchar (255)
DECLARE @subtitle varchar (255)
DECLARE @shorttitle varchar (24)
DECLARE @titleprefix varchar (10)
DECLARE @editioncode  int 
DECLARE @orgentrykey int

DECLARE @i_count int

DECLARE @publisher varchar(20)
DECLARE @profitcenter varchar(20)
DECLARE @imprint varchar(20)
DECLARE @media varchar(2)
DECLARE @format varchar(3)
DECLARE @salesdiv varchar (20)
DECLARE @category3_bind varchar(20)
DECLARE @category2_bind varchar(20)
DECLARE @category1_bind varchar(20)
DECLARE @pubdate datetime
DECLARE @bookedition varchar(2)  /*might need to change length*/
DECLARE @copyyear int
DECLARE @authorlast varchar(10)
DECLARE @shorttitle2 varchar(40)
DECLARE @unitprice varchar(2)  /*for now variable once figure switch to numeric  */
DECLARE @majorsub varchar(20)
DECLARE @seriesann  int
DECLARE @setkitcode varchar(20)
DECLARE @gratflag varchar(2) /*for now default to 01 */
DECLARE @dualedition varchar(1)
DECLARE @authordisplayname varchar(80)
DECLARE @fulltitle  varchar(270)
DECLARE @simulflag varchar (1)

DECLARE @i_isbn  int
BEGIN tran

if @typeofrun = 1 
 begin
DECLARE feed_titles INSENSITIVE CURSOR
FOR

select i.isbn10,
	i.bookkey,
	b.title,	
	subtitle,
	shorttitle,
	titleprefix,
	editioncode,
	bo.orgentrykey
	from isbn i, book b, bookorgentry bo, orgentry o, bookdetail bd
		where i.bookkey=b.bookkey 
			and i.bookkey=bo.bookkey 
			and i.bookkey=bd.bookkey 
			and bo.orgentrykey = o.orgentrykey
			and o.orgentryparentkey in (2,3,4) /*01,02,06 of level group level 3*/
			and o.orglevelkey=3
			and bo.orglevelkey=3
			and  i.isbn is not null

FOR READ ONLY
  end
else
  begin

DECLARE feed_titles INSENSITIVE CURSOR
FOR

select i.isbn10,
	i.bookkey,
	b.title,
	subtitle,
	shorttitle,
	titleprefix,
	editioncode,
	bo.orgentrykey
	from isbn i, book b, bookorgentry bo, orgentry o, bookdetail bd
		where i.bookkey=b.bookkey 
			and i.bookkey=bo.bookkey 
			and i.bookkey=bd.bookkey 
			and bo.orgentrykey = o.orgentrykey
			and o.orgentryparentkey in (2,3,4) /*01,02,06 of level group level 3*/
			and o.orglevelkey=3
			and bo.orglevelkey=3
			and  i.isbn is not null
			and b.creationdate >= getdate()

FOR READ ONLY
end

OPEN feed_titles 

FETCH NEXT FROM feed_titles 
INTO @isbn,
	@bookkey,
	@title,	
	@subtitle,
	@shorttitle,
	@titleprefix,
	@editioncode,
	@orgentrykey

select @i_isbn  = @@FETCH_STATUS

/*if @i_isbn < 1 
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@isbn,'1',@feed_system_date,'No new ISBN Today'
end
*/


/* Open Output File */ 

/*if FILE('feedout_cops.txt')
		lv_file_id_num = FOPEN('feedout_cops.txt',1)
else
		lv_file_id_num = FCREATE('feedout_cops.txt')
end
*/

while (@i_isbn<>-1 )  /* sttus 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

 	select @publisher = ''
	 select @profitcenter = ''
	 select @imprint = ''
	 select @media = ''
	 select @format = ''
	 select @salesdiv = ''
	 select @category3_bind = ''
	 select @category2_bind = ''
	 select @category1_bind = ''
	 select @pubdate = ''
	 select @bookedition = ''
	 select @copyyear = 0
	 select @authorlast = ''
	 select @shorttitle2 = ''
	 select @unitprice = '01'
	 select @majorsub = ''
	 select @seriesann  = 0
	 select @setkitcode = ''
	 select @gratflag = ''
	 select @dualedition = ''
	 select @authordisplayname = ''
	 select @fulltitle  = ''
	 select @simulflag = 'N'
	
	if len(@titleprefix) > 0 
	  begin
		select @fulltitle  = @titleprefix + ' ' + @title 
       end
	else
	 begin
		select @fulltitle  = @title 
	 end
		
	select @publisher = o1.orgentryshortdesc, @profitcenter = o2.orgentryshortdesc,
		@imprint = o3.orgentryshortdesc
			from orgentry o1, orgentry o2, orgentry o3
			   where o1.orgentrykey= o2.orgentryparentkey
					and o2.orgentrykey=o3.orgentryparentkey
						and o3.orgentrykey = @orgentrykey
						and o3.orglevelkey=3 
						and o2.orglevelkey=2
						and o1.orglevelkey=1
				
	
	select @i_count = count(*) 
		from bookdetail
			where bookkey= @bookkey

	if @i_count > 0 
	  begin
		select @media= g.datadescshort,@format = g2.datadescshort
			from gentables g, subgentables g2, bookdetail b
				where b.bookkey= @bookkey
				   and b.mediatypecode=g.datacode
				   and b.mediatypesubcode=g2.datasubcode
				   and g.tableid=g2.tableid
				   and g.datacode=g2.datacode
				   and  g.tableid=312

		select @i_count = count(*)
			from  bookdetail b
				where b.bookkey= @bookkey
				   and editioncode in (15,17)  /* desc =1 or 1-Simul*/

		if @i_count>0 
		  begin
			select @bookedition = '01'
			select @dualedition  = 'Y'
		  end
	  	else
		 begin
			select @bookedition = ''
			select @dualedition  = 'N'
		 end
	 end

	select @i_count = 0

	select @i_count = count(*) 
		from bookcategory
			where bookkey= @bookkey
				and sortorder = 1

	if @i_count > 0 
	  begin

	select @category1_bind = g.datadescshort
			from gentables g, bookcategory b
				where b.bookkey = @bookkey
				   and b.sortorder = 1
				   and b.categorycode =g.datacode
				   and  g.tableid=317
	end

	select @i_count = 0

	select @i_count = count(*) 
		from bookcategory
			where bookkey= @bookkey
				and sortorder = 2

	if @i_count > 0 
	  begin

	select @category2_bind = g.datadescshort
			from gentables g, bookcategory b
				where b.bookkey = @bookkey
				   and b.sortorder = 2
				   and b.categorycode =g.datacode
				   and  g.tableid=317
	end

	select @i_count = 0
	select @i_count = count(*) 
		from bookcategory
			where bookkey= @bookkey
			and sortorder = 3
	if @i_count > 0 
	  begin
	select @category3_bind = g.datadescshort
			from gentables g, bookcategory b
				where b.bookkey = @bookkey
				   and b.sortorder = 3
				   and b.categorycode =g.datacode
				   and  g.tableid=317
	end

	select @i_count = 0
	select @i_count = count(*) 
		from bookcategory
			where bookkey= @bookkey

  	if @i_count > 0 
	  begin

	select @seriesann  = max(sortorder)  /* not sure what they want yet*/
			from  bookcategory b
				where b.bookkey = @bookkey
				   and b.categorycode in (127,128)

					

	select @setkitcode = max(datadescshort)   /* not sure what they want yet*/
			from  bookcategory b,gentables g
				where b.bookkey = @bookkey
					and g.datacode=categorycode
					and tableid=317
			  	      and b.categorycode in (129,130)
	end

	select @i_count = 0
	select @i_count = count(*) 
		from bookdates
			where bookkey= @bookkey
				and datetypecode=8 and printingkey=1

  	if @i_count > 0 
	  begin

	  select @pubdate  = estdate 
			from bookdates
			where bookkey= @bookkey
				and datetypecode=8 and printingkey=1
	end

	select @i_count = 0
	select @i_count = count(*) 
		from bookdates
			where bookkey= @bookkey
				and datetypecode=253 and printingkey=1

  	if @i_count > 0 
	  begin

	  select @copyyear  = convert(numeric,(substring(convert(char,estdate,101),1,4)))
			from bookdates
			where bookkey= @bookkey
				and datetypecode=8 and printingkey=1
	  end

	select @i_count = 0	
	select @i_count = count(*) 
		from bookauthor b,author a
			where bookkey= @bookkey
			  and b.authorkey=a.authorkey
			  and primaryind = 1

	if @i_count > 0 
	  begin
		select @authorlast = lastname, @authordisplayname = displayname
		from bookauthor b,author a
			where bookkey= @bookkey
			  and b.authorkey=a.authorkey
			  and primaryind = 1
	  end
	
	if @profitcenter ='01' or @profitcenter = '06'
	begin
		select @majorsub = @category2_bind
	end
	else 
	 begin
		select @majorsub = @imprint
	 end

	select @i_count = 0
		select @i_count = count(*) 
			from bookharcourt
			  where bookkey= @bookkey
			    and merchtype is not null

	if @i_count > 0 
	  begin
		select @gratflag = 'Y'
	  end
	 else
	  begin
		select @gratflag = 'N'
	  end

	select @i_count = 0
		select @i_count = count(*) 
			from bookprice
			  where bookkey= @bookkey
			    and pricetypecode=8
				 and currencytypecode=11

	if @i_count > 0 
	  begin
		select @shorttitle2 = @shorttitle + ' ' + @format + '*'
	  end 
	else
	 begin
	  	select @shorttitle2 = @shorttitle + ' ' + @format 
	 end
	
	select @unitprice = '01'

select @lv_output_string = (@isbn + '|' + @publisher + '|' + @imprint + '|' +
@media + '|' + @salesdiv + '|' + @format + '|' + @category1_bind + '|' + 
@pubdate + '|' + @copyyear + '|' + @bookedition + '|' + @authorlast + '|' +
@shorttitle2 + '|' + @unitprice   + '|' + @majorsub + '|' + @seriesann + '|' +
@setkitcode + '|' + @gratflag + '|' + @dualedition + '|' + @category1_bind + '|' +
@authordisplayname + '|' + @fulltitle + '|' + @subtitle + '|' + @simulflag)

/*UTL_FILE.PUT_LINE(@lv_file_id_num,@lv_output_string)*/

end /*isbn status 2*/
end /*isbn status 1*/

FETCH NEXT FROM feed_titles 
INTO @isbn,
	@bookkey,
	@title,	
	@subtitle,
	@shorttitle,
	@titleprefix,
	@editioncode,
	@orgentrykey


select @i_isbn  = @@FETCH_STATUS

close feed_titles
deallocate feed_titles

commit tran
return 0

GO


