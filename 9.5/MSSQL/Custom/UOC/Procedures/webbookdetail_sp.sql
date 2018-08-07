PRINT 'STORED PROCEDURE : dbo.webbookdetail_sp'
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.webbookdetail_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.webbookdetail_sp
end

GO
create proc dbo.webbookdetail_sp @i_bookkey int,@i_workkey int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/* 6-1-04 format use coalesce(datadescshort,datadesc) and rich text title and subtitle;
	add edition to title block*/
/*7-29-04 CRM 1395:  title length now 255 so change variable title select to 255*/
/* 8-2-04 CRM 1600: only show parent(primary) ISBN of a format, show other format only if primary not
active... use workkey (primary bookkey) to get info for child.. leave actual bookkey for 
prices,page,trim,illus,lcc,isbn,format,discount,season,pubyear,orglevels since these should be different for each format.*/
/*9-30-04 CRM 01936: get min sortorder contributor to go in <st> tag; add series, change territory suppress World; discount,suppress trade externalcode;
add comment see also; add publication note in biblio data; account for more than 1 child to each parent, 
if parent no longer published use bookcustom.customint09; add co=publisher syntax; remove extra spaces in ur copy commenttext html*/
/* 10-19-04 crm 02045 margin error needs to be fixed outside of here. change use orgentrykey for imprint clearing instead of orgentrydesc/altdesc1
child not always displaying because customint09 not present so now check if present if not then use workkey;
no longer add volume number to title if volume present then leave as is*/
/*2-21-05 change bookcommenthtml select to bookcomments.commenthtmllite or commenthtml not sure which one is best yet*/
 
DECLARE @c_dummy varchar (25)
DECLARE @i_count int
DECLARE @i_length int
DECLARE @i_bisacmediacode int
DECLARE @i_bisacformatcode int
DECLARE @c_bisacformatdesc varchar (40)
DECLARE @i_territorycode int
DECLARE @c_territory varchar(40)
DECLARE @i_discountcode int
DECLARE @c_discount varchar(40)
DECLARE @i_editioncode int
DECLARE @c_title varchar (255)
DECLARE @c_titleprefix varchar (100)
DECLARE @c_subtitle varchar (2000) 

DECLARE @i_authortypecode smallint
DECLARE @c_authormiddlename varchar (100)
DECLARE @c_authorlastname varchar (1000)
DECLARE @c_authorlastname2 varchar (1000)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_authortypedesc varchar (100)
DECLARE @c_authoreditors varchar (1000)
DECLARE @c_authorcontributors varchar(1000)
DECLARE @c_authorprimary varchar(1000)
DECLARE @c_authorprimary_withdesc varchar(1000)

DECLARE @i_seasonkey int
DECLARE @c_seasondesc varchar (100)
DECLARE @i_customkey int

DECLARE @c_illus varchar (200)

DECLARE @c_pubyear varchar (255)
DECLARE @c_pubdate varchar(8)

DECLARE @c_division varchar (255)
DECLARE @c_publisher varchar (255)
DECLARE @c_imprint varchar (255)

DECLARE @d_usretail decimal (10,2)

DECLARE @c_lccn varchar (50)
DECLARE @c_lcc varchar (50)

DECLARE @c_isbn varchar (20)
DECLARE @c_isbn10 varchar (20)

DECLARE @c_trimsizewidth varchar (20)
DECLARE @c_trimsizelength varchar (20)
DECLARE @c_trimsize varchar (40)
DECLARE @c_esttrimsizewidth  varchar (20)
DECLARE @c_esttrimsizelength varchar (20)

DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_validationerrorind int
DECLARE @i_pricecode int
DECLARE @i_currencycode int
DECLARE @i_pricebudget decimal (10,2)
DECLARE @i_pricefinal decimal (10,2)
DECLARE @boilertext varchar (4000)
DECLARE @boilertext_orig varchar (1000)
DECLARE @boilertext_ch varchar (1000)
DECLARE @boilertext_pa varchar (1000)
DECLARE @boilertext_ch_noseasn varchar (1000)
DECLARE @boilertext_pa_noseasn varchar (1000)
DECLARE @boilertext_ch_isbn10 varchar (1000)
DECLARE @boilertext_pa_isbn10 varchar (1000)
DECLARE @subjects_all varchar (1000)
DECLARE @subjects varchar (1000)
DECLARE @subjects_all_codes varchar (1000)
DECLARE @c_keywords varchar (1000)

DECLARE @i_childkey int
DECLARE @i_parentkey int

DECLARE @i_formatstatus int
DECLARE @i_categorycode int
DECLARE @i_categorysubcode int
DECLARE @c_nullvalue varchar (10)
DECLARE @c_tempmessage varchar (255)

DECLARE @c_isbn_alt varchar (20)
DECLARE @c_isbn10_alt varchar (20)
DECLARE @i_bisacmediacode_alt int
DECLARE @i_bisacformatcode_alt int
DECLARE @c_bisacformatdesc_alt varchar (40)
DECLARE @i_pricefinal_alt decimal(10,2)
DECLARE @i_pricebudget_alt decimal(10,2)
DECLARE @d_usretail_alt  decimal(10,2)
DECLARE @c_territory_alt varchar (40)
DECLARE @i_territorycode_alt  int
DECLARE @c_seasondesc_alt varchar (60)
DECLARE @i_discountcode_alt int
DECLARE @c_discount_alt varchar(40)
DECLARE @i_firsttime int

DECLARE @c_char varchar (255)
DECLARE @c_title_rich varchar (2000)
DECLARE @c_subtitle_reg varchar (2000) 
DECLARE @c_title_reg varchar (2000)
DECLARE @c_subtitle_rich varchar (2000) 
DECLARE @c_edition varchar (40) 
DECLARE @c_edition_rich varchar (2000) 
DECLARE @c_edition_reg varchar (2000) 
DECLARE @c_forward varchar (2000) 
DECLARE @c_preface varchar (2000) 
DECLARE @c_introduction varchar (2000) 
DECLARE @c_afterword varchar (2000) 
DECLARE @c_forward_rich varchar (2000) 
DECLARE @c_preface_rich varchar (2000) 
DECLARE @c_introduction_rich varchar (2000) 
DECLARE @c_afterword_rich varchar (2000) 
DECLARE @i_pagecount int
DECLARE @i_tentativepagecount int
DECLARE @searchtest1 int
DECLARE @i_volumenumber int
DECLARE @c_volume_reg varchar (2000)
DECLARE @c_volume varchar (2000)
DECLARE @c_series varchar(300)
DECLARE @i_seriescode int
DECLARE @c_reference varchar(2000)
DECLARE @c_publication varchar(2000)
DECLARE @c_copublisher varchar(1000)
DECLARE @c_text varchar(8000)
DECLARE @i_imprintkey int
DECLARE @i_nocustomkey int

/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 1
select @c_nullvalue = null
select @c_lcc =''

begin tran

/** Initialize the Validation Error to zero (False) **/
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/
/** for this bookkey.  Processing will continue to the next bookkey **/

select @i_validationerrorind = 0

/*******************************************/
/* Output the beginning Product tag for this book */
/*******************************************/
insert into webbookxmlfeed (feedtext) select '<control>'

/*******************************************/
/* Output RecordReference - unique product number - we will use bookkey if no bookcustom.customint09 */
/*******************************************/

select @i_nocustomkey = 0

select @i_customkey = customint09 from bookcustom where bookkey = @i_workkey

if @i_customkey is null or @i_customkey = 0
  begin
	select @i_customkey = @i_workkey
	select @i_nocustomkey = 1
  end

insert into webbookxmlfeed (feedtext) 
	select '<fn>' 

insert into webbookxmlfeed (feedtext) 
	select  convert(varchar (25),@i_customkey) + '.ctl'

insert into webbookxmlfeed (feedtext) 
	select  '</fn>'

/*******************************************/
/*      Output author: and title */
/*******************************************/


select @i_bisacmediacode = mediatypecode, @i_bisacformatcode=mediatypesubcode,
	@i_discountcode = discountcode,@i_seriescode = seriescode
  from bookdetail where bookkey=@i_bookkey

select @c_titleprefix=ltrim(rtrim(titleprefix)) ,@i_editioncode = editioncode,@i_volumenumber = volumenumber
  from bookdetail where bookkey=@i_workkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if  @i_bisacmediacode is  null 
  begin 
	select @i_bisacmediacode  = 0
  end

if @i_bisacformatcode is null
  begin
	select @i_bisacformatcode = 0
  end

if @i_discountcode is null
  begin
	select @i_discountcode = 0
  end

if @i_discountcode > 0
  begin
	select @c_discount = lower(externalcode) from gentables where tableid =459
		and datacode = @i_discountcode

	if @i_discountcode = 2  /*trade*/
	  begin
		select @c_discount = ''
	  end
  end
else
  begin
	select @c_discount = ''
  end

select @c_title=rtrim(title),@c_subtitle = subtitle,@i_territorycode = territoriescode from book where bookkey=@i_workkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_title is null or @c_title = ''
begin
	select @i_validationerrorind = 1
	/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'Title Missing'*/
end

if @c_titleprefix is null 
  begin
	select @c_titleprefix = ''
  end

if datalength(@c_titleprefix) > 0
  begin
 	select @c_title = @c_titleprefix + ' ' + @c_title
  end

if @c_subtitle is null 
  begin
	select @c_subtitle = ''
  end

/*6-1-04 get volume,rich text title and subtitle, forward, preface, introduction, afterword*/
select @i_count = 0
select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and commenttypesubcode = 31

if @i_count > 0 
  begin
	select @c_volume_reg = commenttext  from bookcomments where printingkey=1 and
		bookkey= @i_workkey and commenttypecode=1 and commenttypesubcode = 31
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

/** no longer add volume number to title if present leave as is
if datalength(@c_title) > 0 and datalength(@c_volume)>0 
  begin
	select @i_count = 0
	select @i_count = charindex(upper(@c_volume),upper(@c_title))
	if @i_count = 0 
	  begin
		select @c_title = @c_title +', ' + @c_volume
	  end
  end
**/
/*9-30-04 add series*/
if @i_seriescode is null
  begin
	select @i_seriescode = 0
  end
if @i_seriescode > 0 
  begin
	select @c_series = 'Series: (' + externalcode + ') ' + alternatedesc1 from gentables g
		where tableid=327 and datacode = @i_seriescode
  end

select @i_count = 0
/* CRM 1600 use workkey to get comment info for child */
select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 29

if @i_count > 0 
 begin
	select @c_title_rich = commenthtml,@c_title_reg = commenttext 
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
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

if datalength(@c_title_reg)> 0
  begin
	select @c_title = @c_title_reg
  end

if datalength(@c_title_rich) = 0
  begin
	select @c_title_rich = @c_title_reg
  end

if datalength(@c_title_rich) = 0
  begin
	select @c_title_rich = @c_title
  end
select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 30

if @i_count > 0 
 begin
	select @c_subtitle_rich = commenthtml,@c_subtitle_reg = commenttext
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
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

  if datalength(@c_subtitle_reg)> 0
    begin
	select @c_subtitle = @c_subtitle_reg
  end

if datalength(@c_subtitle_rich) = 0
  begin
	select @c_subtitle_rich = @c_subtitle_reg
  end

if datalength(@c_subtitle_rich) = 0
  begin
	select @c_subtitle_rich = @c_subtitle
  end

select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 41

if @i_count > 0 
 begin
	select @c_forward_rich = commenthtml,@c_forward = commenttext 
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 41
  end

if @c_forward_rich is null 
   begin
	select @c_forward_rich = ''
 end
if @c_forward is null 
    begin
	select @c_forward = ''
 end

if datalength(@c_forward_rich) = 0
  begin
	select @c_forward_rich = @c_forward
  end

select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 44

if @i_count > 0 
 begin
	select @c_preface_rich = commenthtml, @c_preface = commenttext
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 44
  end

if @c_preface_rich is null 
   begin
	select @c_preface_rich = ''
    end

if @c_preface is null 
  begin
	select @c_preface = ''
 end
if datalength(@c_preface_rich) = 0
  begin
	select @c_preface_rich = @c_preface
  end

select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 42

if @i_count > 0 
 begin
	select @c_introduction_rich = commenthtml,@c_introduction = commenttext
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 42

  end

if @c_introduction_rich is null 
  begin
	select @c_introduction_rich = ''
    end

if @c_introduction is null 
   begin
	select @c_introduction = ''
  end

if datalength(@c_introduction_rich) = 0
  begin
	select @c_introduction_rich = @c_introduction
  end

select @i_count = 0

	select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 45

if @i_count > 0 
 begin
	select @c_afterword_rich = commenthtml,@c_afterword = commenttext
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 45

  end

if @c_afterword_rich is null 
   begin
	select @c_afterword_rich = ''
   end

if @c_afterword is null 
   begin
	select @c_afterword = ''
  end
if datalength(@c_afterword_rich) = 0
  begin
	select @c_afterword_rich = @c_afterword
  end

select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 36

	
if @i_count > 0 
 begin
	select @c_edition_rich = commenthtml,@c_edition_reg = commenttext
	 from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 36
  end

if @c_edition_reg is null 
   begin
	select @c_edition_reg = ''
    end
 if @c_edition_rich is null 
  begin
	select @c_edition_rich = ''
   end

if @i_editioncode > 0
     begin

	select @c_edition = datadesc from gentables where tableid =200
		and datacode = @i_editioncode
	
	if @c_edition is null
	  begin
		select @c_edition = ''
	  end
     end
   
if datalength(@c_edition_reg) > 0
  begin
	select @c_edition = @c_edition_reg
  end


if @i_territorycode is null
  begin
	select @i_territorycode = 0
  end

if @i_territorycode > 0
  begin
	select @c_territory = externalcode from gentables where tableid =131
		and datacode = @i_territorycode
	if @c_territory is null
	  begin
		select @c_territory = ''
	  end
  end
else
  begin
	select @c_territory = ''
  end

if @c_territory is null
  begin
	select @c_territory = ''
  end

if  @i_territorycode = 1 /*world suppress*/
  begin
	select @c_territory = ''
  end

/*9-30-04 add publication note*/

select @i_count = 0

select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 40

if @i_count > 0 
 begin
	select @c_publication = commenttext from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and
	commenttypesubcode = 40
  end

/*6-2-04 build author*/
/* 1= only author, 2 = editor 3 = other contriburtors including editor 4= author for <st> tag only 5=author with desc*/

exec authorbuild_uoc_sp @i_workkey,1, @c_authorlastname OUTPUT
exec authorbuild_uoc_sp @i_workkey,2, @c_authoreditors OUTPUT
exec authorbuild_uoc_sp @i_workkey,3, @c_authorcontributors OUTPUT
exec authorbuild_uoc_sp @i_workkey,4, @c_authorprimary OUTPUT
exec authorbuild_uoc_sp @i_workkey,5, @c_authorprimary_withdesc OUTPUT

if @c_authorlastname is null
  begin
	select @c_authorlastname = ''
  end

if @c_authoreditors is null
  begin
	select @c_authoreditors = ''
  end

if @c_authorcontributors is null
  begin
	select @c_authorcontributors = ''
  end
	
if @c_authorprimary is null
  begin
	select @c_authorprimary = ''
  end

if @c_authorprimary_withdesc is null
  begin
	select @c_authorprimary_withdesc = ''
  end

if len(@c_authoreditors)> 0  and len(@c_authorlastname) = ''  /*get multiple editors and remove from contributor list*/
  begin
	select @c_authorprimary_withdesc = @c_authoreditors
  end

if len(@c_authorlastname)> 0  and @c_authorlastname  <> @c_authorprimary_withdesc  /*get multiple authors*/
  begin
	select @c_authorprimary_withdesc = @c_authorlastname
  end


insert into webbookxmlfeed (feedtext) 
    select '<st>'

insert into webbookxmlfeed (feedtext) 
    select @c_authorprimary + ': ' +  @c_title
	
insert into webbookxmlfeed (feedtext) 
    select '</st>'


/*******************************************/
/*      Output boliler plate text */
/*******************************************/

insert into webbookxmlfeed (feedtext) 
    select '<pc>'

insert into webbookxmlfeed (feedtext) 
    select 'CHICAGO'

insert into webbookxmlfeed (feedtext) 
    select '</pc>'

insert into webbookxmlfeed (feedtext) 
    select '<of>'

insert into webbookxmlfeed (feedtext) 
    select '/Order_forms/chicago'

insert into webbookxmlfeed (feedtext) 
    select '</of>'

/*******************************************/
/*      Output bibliographic info */
/*******************************************/

insert into webbookxmlfeed (feedtext) 
    select '<gopher>'

/*publisher,division, imprint*/

select @c_publisher = orgentrydesc from bookorgentry b, orgentry o
	where b.orgentrykey = o.orgentrykey
	  and b.bookkey=@i_bookkey and b.orglevelkey=1
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

select @c_division = orgentrydesc from bookorgentry b, orgentry o
	where b.orgentrykey = o.orgentrykey
	  and b.bookkey=@i_bookkey and b.orglevelkey=2

if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

select @i_imprintkey = 0
select @c_imprint = coalesce(altdesc1,orgentrydesc),@i_imprintkey= b.orgentrykey from bookorgentry b, orgentry o
	where b.orgentrykey = o.orgentrykey
	  and b.bookkey=@i_bookkey and b.orglevelkey=3

if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*9-30-04 co-pubisher -- co-published with = orgentrykey= 5*/

select @i_count = 0

select @i_count = count(*) from bookorgentry where orgentrykey=5 and bookkey= @i_bookkey

if @i_count > 0 
 begin
	select @c_copublisher = orgentrydesc from orgentry where orgentrykey=5
	
	if len(@c_copublisher) > 0
	  begin
		select @c_imprint =  ' ' + @c_copublisher +' ' + @c_imprint
	  end
	else
	  begin	
		if @i_imprintkey = 4 /*upper(@c_imprint) = 'UNIVERSITY OF CHICAGO PRESS' or upper(@c_imprint) = 'PRESS'*/
		  begin
			select @c_imprint = '' 
 		  end
		else
		  begin
			select @c_imprint = ' Distributed for the ' + @c_imprint
		  end
	  end
  end
 else
  begin
	if @i_imprintkey = 4 /*upper(@c_imprint) = 'UNIVERSITY OF CHICAGO PRESS' or upper(@c_imprint) = 'PRESS'*/
	  begin
		select @c_imprint = '' 
 	  end
	else
	  begin
	  	select @c_imprint = ' Distributed for the ' + @c_imprint
	  end

  end

select @c_isbn = isbn, @c_isbn10 = isbn10, @c_lccn = lccn from isbn
	where bookkey=@i_bookkey

if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_lccn is null
  begin
	select @c_lccn = ''
  end

if  @i_bisacmediacode > 0 and  @i_bisacformatcode > 0
   begin
	select @c_bisacformatdesc = coalesce(datadescshort,datadesc) 
	   from subgentables where tableid=312 and
		datacode = @i_bisacmediacode  and datasubcode =  @i_bisacformatcode 
  end

select @c_illus = actualinsertillus,@c_esttrimsizewidth =esttrimsizewidth, @c_esttrimsizelength=esttrimsizelength,
	@i_tentativepagecount = tentativepagecount
 		from printing where bookkey=@i_bookkey
		and printingkey=1

/*copyright*/
select @c_pubyear = commenttext from bookcomments where bookkey=@i_bookkey
	and printingkey=1 and commenttypecode=1 and commenttypesubcode=33

if @c_illus is null
  begin
	select @c_illus = estimatedinsertillus from printing where bookkey=@i_bookkey
	and printingkey=1
  end

if @c_illus is null
  begin
	select @c_illus = ''
  end

select @i_count = optionvalue from clientoptions
	where optionid = 7  /*9-9-03 clientoptions trim*/
if @i_count = 1
  begin
	select @c_trimsizelength = tmmactualtrimlength,@c_trimsizewidth =tmmactualtrimwidth
		FROM printing
			WHERE bookkey = @i_bookkey
		AND  printingkey = 1 
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

  end
else
 begin	
	select @c_trimsizelength = trimsizelength,@c_trimsizewidth = trimsizewidth
	  FROM printing
		 WHERE bookkey = @i_bookkey
		AND  printingkey = 1 

if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

 end

if datalength(rtrim(@c_trimsizewidth)) > 0 and datalength(rtrim(@c_trimsizelength)) > 0 
  begin
	select @c_trimsize = @c_trimsizewidth + ' x ' + @c_trimsizelength
 end
else if datalength(rtrim(@c_esttrimsizewidth)) > 0 and datalength(rtrim(@c_esttrimsizelength)) > 0 
 begin
	select @c_trimsize = @c_esttrimsizewidth + ' x ' + @c_esttrimsizelength
 end
else
  begin
	 select @c_trimsize = ''
 end
		
 if rtrim(ltrim(@c_trimsize)) = 'x' 
  begin
	select @c_trimsize = ''
  end

select @i_count = 0

	select @i_count = optionvalue from clientoptions
		where optionid = 4  /*9-9-03 clientoptions pagecount*/
	if @i_count = 1
	  begin
		select @i_pagecount = tmmpagecount 
		FROM printing
		 WHERE bookkey = @i_bookkey
			AND  printingkey = 1 
	  end
	else
	  begin	
		select @i_pagecount = pagecount 
		FROM printing
		 WHERE bookkey = @i_bookkey
		AND  printingkey = 1 
	end

	if @i_pagecount is null
	  begin
		select @i_pagecount = 0
	  end

	if @i_tentativepagecount is null
	  begin
		select @i_tentativepagecount = 0
	  end

	if @i_pagecount = 0
	  begin
		select @i_pagecount =  @i_tentativepagecount
	  end
	
select @i_count = 0
select @i_count = count(*) from filterpricetype
	where filterkey = 5 /*currency and price types*/

if @i_count > 0 
 begin
	select @i_pricecode= pricetypecode, @i_currencycode = currencytypecode
		 from filterpricetype
			where filterkey = 5 /*currency and price types*/
 end

select @i_count = 0
select @i_count = max(pricekey) from bookprice
	WHERE  bookkey = @i_bookkey
		   and pricetypecode = @i_pricecode
		    and currencytypecode = @i_currencycode
if @i_count > 0
 begin	
	SELECT @i_pricebudget = budgetprice,@i_pricefinal = finalprice
		   FROM bookprice
		  	 WHERE  bookkey = @i_bookkey
			   and pricetypecode = @i_pricecode
			    and currencytypecode = @i_currencycode
	if @i_pricefinal > 0 
	  begin
		select @d_usretail = @i_pricefinal
	  end
	else
	 begin
		select @d_usretail = @i_pricebudget
	  end
end

select @i_count = 0
select @i_count  = seasonkey 
	from printing 
	where bookkey=@i_bookkey and printingkey = 1

if @i_count  > 0
  begin
	select @c_seasondesc = seasondesc from season
		where seasonkey = @i_count
  end
else
  begin
	select @i_count = 0
	select @i_count  = estseasonkey 
	   from printing 
		where bookkey=@i_bookkey and printingkey = 1

	if @i_count  > 0
	  begin
		select @c_seasondesc = seasondesc from season
			where seasonkey = @i_count
	  end
  end

select @boilertext = @c_authorprimary_withdesc  + ' ' + @c_title
 
if datalength(@c_subtitle ) >0
 begin
	select @boilertext = @boilertext + ': ' + @c_subtitle + '. '
  end
else
  begin
	select @boilertext = @boilertext + '. '
  end

if len(@c_authorcontributors) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_authorcontributors + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_forward) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_forward + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_preface) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_preface + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_introduction) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_introduction + '.'
  end
select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_afterword) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_afterword + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_edition) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_edition
  end

select @i_length = 0

select @i_length= charindex('  ',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,' ')
  end

if datalength(@c_edition) >0 or datalength(@c_afterword) >0 or datalength(@c_introduction) >0 
or datalength(@c_preface) >0 or datalength(@c_authorcontributors) >0
  begin
	 select @boilertext = @boilertext + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_publication) >0
 begin
	select @boilertext = @boilertext + ' ' + @c_publication + '.'
  end

if len(@c_imprint)>0
  begin
 	select @boilertext = @boilertext +  @c_imprint + '.'
 end
select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end
if @i_pagecount >0
 begin
	select @boilertext = @boilertext + ' ' +  convert(varchar,@i_pagecount) + ' p.'
  end

if datalength(@c_illus) > 0
  begin
	select @boilertext = @boilertext + ', ' + @c_illus + '.' 
  end

if datalength(@c_trimsize) > 0
  begin
	select @boilertext = @boilertext  + ' '+ @c_trimsize 
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

select @i_length = 0
select @i_length = charindex('  ',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,' ')
  end

insert into webbookxmlfeed (feedtext) 
    select @boilertext

if @c_pubyear is null
  begin
	select @c_pubyear = ''
  end

if datalength(@c_pubyear) > 0 
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_pubyear 
  end

/*add series 9-30-04*/
if len(@c_series) > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_series
  end
select @boilertext = ''  /*clear to start new line*/

if datalength(@c_lccn) > 0
  begin
	select @boilertext = @boilertext + 'LC: ' + @c_lccn + ' '
  end

if datalength(@c_lcc) > 0
  begin
	select @boilertext = @boilertext + 'Class: ' + @c_lcc 
  end
 
if datalength(@c_lcc) > 0 or datalength(@c_lccn) > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @boilertext
  end

select @boilertext = ''  /*clear to start new line*/

select @boilertext_orig = @c_isbn10 +'	'

if datalength(@c_bisacformatdesc) > 0
  begin
	select @boilertext = @boilertext + @c_bisacformatdesc + '	'+ @c_territory + '	'

	select @boilertext_orig = @boilertext_orig + @c_bisacformatdesc
  end
 
if @d_usretail > 0 
 begin
	select @boilertext = @boilertext + '$' + convert(varchar,@d_usretail) 

	select @boilertext_orig = @boilertext_orig + '	' +  convert(varchar,@d_usretail)
  end
else
  begin
	select @boilertext = @boilertext + '$0.00'  

	select @boilertext_orig = @boilertext_orig + '	0.00' 
  end

 if len(@c_discount)> 0
   begin
	select @boilertext = @boilertext + @c_discount 
   end

  select @boilertext =@boilertext +'	' + @c_isbn

if datalength(@c_seasondesc) > 0
  begin
	select @boilertext = @boilertext +  '	' + @c_seasondesc
  end

insert into webbookxmlfeed (feedtext) 
    select @boilertext

select @boilertext = ''  /*clear to start new line*/

/*other format*/
/*8-2-04 child format will no longer be present in webbookkeys table if parent 
present so do not check for it
9-30-04 use bookcustom instead of workkey
10-21-04 if no bookcustom.customint09 then use workkey again*/

if @i_nocustomkey = 1  /*no customint09 use workkey*/
  begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
/* get all related books that is not a parent base on customkey*/
		select distinct bb.bookkey 
		from book bb,bookdetail b, isbn i
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bb.workkey = @i_workkey
				and bb.linklevelcode=20 and bb.bookkey not in (select bookkey from webbookkeys)
		FOR READ ONLY
end
else
 begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
		select distinct bc.bookkey 
		from book bb,bookdetail b, isbn i,bookcustom bc
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey and bc.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bc.customint09= @i_customkey
	  				and bb.linklevelcode=20 and bc.bookkey not in (select bookkey from webbookkeys)
	 FOR READ ONLY
end



OPEN cursor_child

FETCH NEXT FROM cursor_child
	INTO @i_childkey

select @i_formatstatus = @@FETCH_STATUS
	
	while (@i_formatstatus<>-1 )
	  begin
		IF (@i_formatstatus<>-2)
	  	  begin
		    select @c_isbn_alt = ''
		    select @c_isbn10_alt = ''
		    select @i_bisacmediacode_alt = 0
		    select @i_bisacformatcode_alt = 0
		    select @c_bisacformatdesc_alt = ''
		    select @i_pricefinal_alt = 0
		    select @i_pricebudget_alt = 0
		    select @d_usretail_alt = 0
		    select @c_territory_alt = ''
		    select @i_territorycode_alt = 0
		    select @c_seasondesc_alt =''
		    select @c_discount_alt = ''
		    select @i_discountcode_alt = 0

		select @c_isbn_alt = isbn, @c_isbn10_alt = isbn10 from isbn
			where bookkey=@i_childkey

		select @i_bisacmediacode_alt = mediatypecode, @i_bisacformatcode_alt=mediatypesubcode,@i_discountcode_alt = discountcode
  			from bookdetail where bookkey=@i_childkey

		if  @i_bisacmediacode_alt is  null 
		  begin 
			select @i_bisacmediacode_alt  = 0
		  end

		if @i_bisacformatcode_alt is null
		  begin
			select @i_bisacformatcode_alt = 0
		  end
		if  @i_bisacmediacode_alt > 0 and  @i_bisacformatcode_alt > 0
   		  begin
			select @c_bisacformatdesc_alt = coalesce(datadescshort,datadesc)  
			   from subgentables where tableid=312 and
				datacode = @i_bisacmediacode_alt  and datasubcode =  @i_bisacformatcode_alt 
 		  end

		if @i_discountcode_alt is null
		  begin
			select @i_discountcode_alt = 0
		  end

		if @i_discountcode_alt > 0
		  begin
			select @c_discount_alt = lower(externalcode) from gentables where tableid =459
				and datacode = @i_discountcode_alt

			if @i_discountcode_alt = 2  /*trade*/
	 		 begin
				select @c_discount_alt = ''
	  		end
		  end
		else
		  begin
			select @c_discount_alt = ''
		  end

		if @c_discount_alt is null
		  begin
			select @c_discount_alt = ''
		  end
		select @i_territorycode_alt = territoriescode from book where bookkey=@i_childkey
		
		if @i_territorycode_alt is null
		  begin	
			select @i_territorycode_alt = 0
		  end

		if @i_territorycode_alt > 0
		  begin
			select @c_territory_alt = alternatedesc1 from gentables where tableid =131
				and datacode = @i_territorycode_alt
		  end
		else
		  begin
			select @c_territory_alt = ''
		  end

		 if @c_territory_alt is null
		   begin
			select @c_territory_alt = ''
		  end

		if  @i_territorycode_alt = 1 /*world*/
  		begin
			select @c_territory_alt = ''
  		end
		select @i_count = 0
		select @i_count = max(pricekey) from bookprice
			WHERE  bookkey = @i_childkey
		 	  and pricetypecode = @i_pricecode
		 	   and currencytypecode = @i_currencycode
		if @i_count > 0
 		  begin	
			SELECT @i_pricebudget_alt = budgetprice,@i_pricefinal_alt = finalprice
			   FROM bookprice
		  		 WHERE  bookkey = @i_childkey
				   and pricetypecode = @i_pricecode
				    and currencytypecode = @i_currencycode
			if @i_pricefinal_alt > 0 
	  		  begin
				select @d_usretail_alt = @i_pricefinal_alt
			  end
			else
			 begin
				select @d_usretail_alt = @i_pricebudget_alt
			  end
		end

		select @i_count = 0
		select @i_count  = seasonkey
			from printing 
				where bookkey=@i_childkey and printingkey = 1

		if @i_count  > 0
 		 begin
			select @c_seasondesc_alt = seasondesc from season
				where seasonkey = @i_count
		  end
		else
 		 begin
			select @i_count = 0
			select @i_count  = estseasonkey 
			   from printing 
				where bookkey=@i_childkey and printingkey = 1

			if @i_count  > 0
	 		 begin
				select @c_seasondesc_alt = seasondesc from season
					where seasonkey = @i_count
	 		 end
 		 end

		select @boilertext_ch_isbn10 = @c_isbn10_alt + '	'

		if datalength(@c_bisacformatdesc_alt) > 0
  		  begin
			select @boilertext_ch =  @c_bisacformatdesc_alt + '	'+ @c_territory_alt + '	'

			select @boilertext_ch_isbn10 = @boilertext_ch_isbn10  + @c_bisacformatdesc_alt 
  		  end
 
		if @d_usretail_alt > 0 
 		  begin
			select @boilertext_ch = @boilertext_ch + '$' + convert(varchar,@d_usretail_alt) 

			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + convert(varchar,@d_usretail_alt)
  		  end
		else
		  begin
			select @boilertext_ch  = @boilertext_ch + '$0.00'  

			select  @boilertext_ch_isbn10 =  @boilertext_ch_isbn10 + '	0.00' 
  		end
		 if len(@c_discount_alt)> 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_discount_alt 
		  end
		
		 select @boilertext_ch = @boilertext_ch + '	' + @c_isbn_alt + '	'


		select @boilertext_ch_noseasn = @boilertext_ch

		if datalength(@c_seasondesc_alt) > 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_seasondesc_alt
		  end

		insert into webbookxmlfeed (feedtext) 
   		 select @boilertext_ch

	end /* if @i_format*/


	FETCH NEXT FROM cursor_child
		INTO @i_childkey
      
	select @i_formatstatus = @@FETCH_STATUS
end

close cursor_child
deallocate cursor_child

insert into webbookxmlfeed (feedtext) 
    select @c_nullvalue

/*******************************************/
/* Output regular comments */
/*******************************************/

/*Ur copy*/
select @i_count = 0

select @i_count = count(*) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=8
if @i_count > 0
  begin
	insert into webbookxmlfeed (feedtext) 
   	 select commenttext from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=8
  end

/*table of content*/

select @i_count = 0

select @i_count = count(*) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=24

if @i_count > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select 'TABLE OF CONTENTS'


	insert into webbookxmlfeed (feedtext) 
   	 select commenttext from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=24
  end


/*******************************************/
/* Output subjects */
/*******************************************/
select @i_firsttime = 1
select @i_count = 0

select @i_count = count(*)
		from booksubjectcategory 
		  where bookkey = @i_workkey and categorytableid=412
if @i_count > 0
  begin
   insert into webbookxmlfeed (feedtext) 
    select 'Subjects:'
  end

DECLARE cursor_subjects INSENSITIVE CURSOR
FOR
	select categorycode,categorysubcode  
		from booksubjectcategory 
		  where bookkey = @i_workkey and categorytableid=412
			order by sortorder,categorycode,categorysubcode
FOR READ ONLY

OPEN cursor_subjects

FETCH NEXT FROM cursor_subjects
	INTO @i_categorycode,@i_categorysubcode

select @i_formatstatus = @@FETCH_STATUS
	
	while (@i_formatstatus<>-1 )
	  begin
		IF (@i_formatstatus<>-2)
	  	  begin

			if @i_categorysubcode is null
	  		  begin
				select @i_categorysubcode = 0
			  end

			if @i_categorysubcode >0
			  begin
					select @subjects = rtrim(upper(g.datadesc)) + ': ' + coalesce(rtrim(sg.alternatedesc1),rtrim(sg.datadesc))
						  from gentables g, subgentables sg
							where g.tableid= sg.tableid
								and g.datacode= sg.datacode
								and g.tableid=412
								and g.datacode= @i_categorycode
								and sg.datasubcode = @i_categorysubcode
			  end
			else
			   begin	
					select @subjects = rtrim(upper(g.datadesc)) 
						  from gentables g
							where g.tableid=412
								and g.datacode= @i_categorycode	
			  end

			insert into webbookxmlfeed (feedtext)
				select @subjects						

			if @i_firsttime = 1
			   begin
				select @subjects_all =  @subjects
			    end			
			   else
			     begin
				select @subjects_all = @subjects_all  + '<LI>' + @subjects 					
			     end	
			
				select @i_firsttime = @i_firsttime + 1	
			
				end /* if @i_subject*/
	
		FETCH NEXT FROM cursor_subjects
			INTO @i_categorycode,@i_categorysubcode

	select @i_formatstatus = @@FETCH_STATUS
end

close cursor_subjects
deallocate cursor_subjects

/*6-1-04  get subject codes from function*/

select @subjects_all_codes = dbo.ucp_web_subject_category_list (@i_workkey)

insert into webbookxmlfeed (feedtext)
	select @c_nullvalue

insert into webbookxmlfeed (feedtext)
	select 'The ' + @c_publisher

insert into webbookxmlfeed (feedtext)
	select @c_nullvalue

insert into webbookxmlfeed (feedtext)
	select '</gopher>'

insert into webbookxmlfeed (feedtext)
	select '<www>'

/* Output  image tag - hard code for now comments 1, 51 tells if jpeg or gif etc */
/**************************************************************************************/
select @i_count = 0

select @i_count = count(*) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=51

if @i_count > 0
  begin
	select @c_char = commenttext
	  from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=51

	insert into webbookxmlfeed (feedtext) 
	    select '<A><IMG SRC="http://www.press.uchicago.edu/Images/Chicago/' +
	   @c_char + '" ALT="[jacket image]"></A>'
		
  end

/*when I figure out what commenttype copy notes is*/
/*** insert into webbookxmlfeed (feedtext) 
   	 select commenttext from bookcomments
		where bookkey = @i_workkey and printingkey = 
		   and commenttypecode= 1 and commenttypesubcode=
***/		

/*******************************************/
/* WWW */
/*******************************************/


if datalength(@c_title_rich)> 0 and @c_title_rich <> @c_title
 begin
	select @boilertext = '<P>' + @c_authorprimary_withdesc + ' ' +  @c_title_rich 
 end
else
  begin
	select @boilertext = '<P>' + @c_authorprimary_withdesc+  ' <B>' + @c_title_rich + '</B>' 
  end


if datalength(@c_subtitle_rich)> 0 and @c_subtitle_rich <> @c_subtitle
 begin
 
	select @boilertext = @boilertext + ' '  + @c_subtitle_rich  
  end  
else if datalength(@c_subtitle)> 0
  begin
	select @boilertext = @boilertext + ': ' + '<I>' + @c_subtitle_rich + '</I>'  + '. '
  end
else
  begin
	select @boilertext = @boilertext +  '. '
  end

if datalength(@c_authorcontributors) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_authorcontributors + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end


if datalength(@c_forward_rich) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_forward_rich + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_preface_rich) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_preface_rich + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_introduction_rich) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_introduction_rich + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_afterword_rich) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_afterword_rich + '.'
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_edition_rich) = 0
  begin
	select @c_edition_rich = @c_edition_reg
  end

if datalength(@c_edition_rich) = 0
  begin
	select @c_edition_rich = @c_edition
  end

if datalength(@c_edition_rich) >0
 begin
	select @boilertext = @boilertext + ' ' +  @c_edition_rich
  end


if datalength(@c_edition) >0 or datalength(@c_afterword) >0 or datalength(@c_introduction) >0 or 
	datalength(@c_preface) >0  or datalength(@c_authorcontributors) >0
  begin
	 select @boilertext = @boilertext + '.'
  end


select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_publication) >0
 begin
	select @boilertext = @boilertext + ' ' + @c_publication
  end

select @boilertext = @boilertext  + @c_imprint + '.'

if @i_pagecount >0
 begin
	select @boilertext = @boilertext + ' ' +  convert(varchar,@i_pagecount) + ' p.'
  end

if datalength(@c_illus) > 0
  begin
	select @boilertext = @boilertext + ', ' + @c_illus + '.' 
  end

if datalength(@c_trimsize) > 0
  begin
	select @boilertext = @boilertext + ' ' + @c_trimsize
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

if datalength(@c_pubyear) > 0 
  begin
	select @boilertext = @boilertext + ' ' + @c_pubyear
  end

/*add series 9-30-04*/
if len(@c_series) > 0
  begin
	   select @boilertext = @boilertext + ' ' + @c_series
  end

select @i_length = 0

select @i_length = charindex('..',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,'.')
  end
select @i_length = 0

select @i_length= charindex('. .',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,3,'.')
  end

select @i_length = 0

select @i_length= charindex('  ',@boilertext)
if @i_length > 0
  begin
	select @boilertext = STUFF(@boilertext,@i_length,2,' ')
  end

insert into webbookxmlfeed (feedtext) 
    select @boilertext + '</P>'

select @boilertext = ''  /*clear to start new line*/

if datalength(@c_lccn) > 0
  begin
	select @boilertext = '<P>'+ @boilertext + 'LC: ' + @c_lccn + '</P>'
  end

if datalength(@c_lcc) > 0 or datalength(@c_lccn) > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @boilertext
  end

select @boilertext = ''  /*clear to start new line*/

if datalength(@c_bisacformatdesc) > 0
  begin
	select @boilertext = @boilertext + @c_bisacformatdesc + '	'+ @c_territory + '	'
  end
 
if @d_usretail > 0 
 begin
	select @boilertext = @boilertext + '$' + convert(varchar,@d_usretail) 
  end
else
  begin
	select @boilertext  = @boilertext + '$0.00'  
end

if len(@c_discount)>0
  begin
	select @boilertext = @boilertext +  @c_discount  
  end

select @boilertext = @boilertext +  '	' + @c_isbn 

if datalength(@c_seasondesc) > 0
  begin
	select @boilertext = @boilertext +  '	' +@c_seasondesc
  end

insert into webbookxmlfeed (feedtext) 
    select '<P>'+ @boilertext + '</P>'

select @boilertext = ''  /*clear to start new line*/

/*other format*/
/*8-2-04 child format will no longer be present in webbookkeys table if parent present so do not check for it
9-30-04 use bookcustom instead of workkey*/

if @i_nocustomkey = 1  /*no customint09 use workkey*/
  begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
/* get all related books that is not a parent base on customkey*/
		select distinct bb.bookkey 
		from book bb,bookdetail b, isbn i
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bb.workkey = @i_workkey
				and bb.linklevelcode=20 and bb.bookkey not in (select bookkey from webbookkeys)
		FOR READ ONLY
end
else
 begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
		select distinct bc.bookkey 
		from book bb,bookdetail b, isbn i,bookcustom bc
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey and bc.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bc.customint09= @i_customkey
	  				and bb.linklevelcode=20 and bc.bookkey not in (select bookkey from webbookkeys)
	 FOR READ ONLY
end

OPEN cursor_child

FETCH NEXT FROM cursor_child
	INTO @i_childkey

select @i_formatstatus = @@FETCH_STATUS
	
	while (@i_formatstatus<>-1 )
	  begin
		IF (@i_formatstatus<>-2)
	  	  begin
		    select @c_isbn_alt = ''
		    select @c_isbn10_alt = ''
		    select @i_bisacmediacode_alt = 0
		    select @i_bisacformatcode_alt = 0
		    select @c_bisacformatdesc_alt = ''
		    select @i_pricefinal_alt = 0
		    select @i_pricebudget_alt = 0
		    select @d_usretail_alt = 0
		    select @c_territory_alt = ''
		    select @i_territorycode_alt = 0
		    select @c_seasondesc_alt =''
		    select @c_discount_alt = ''
		    select @i_discountcode_alt = 0

		select @c_isbn_alt = isbn, @c_isbn10_alt = isbn10 from isbn
			where bookkey=@i_childkey

		select @i_bisacmediacode_alt = mediatypecode, @i_bisacformatcode_alt=mediatypesubcode,@i_discountcode_alt = discountcode
  			from bookdetail where bookkey=@i_childkey

		if  @i_bisacmediacode_alt is  null 
		  begin 
			select @i_bisacmediacode_alt  = 0
		  end

		if @i_bisacformatcode_alt is null
		  begin
			select @i_bisacformatcode_alt = 0
		  end
		if  @i_bisacmediacode_alt > 0 and  @i_bisacformatcode_alt > 0
   		  begin
			select @c_bisacformatdesc_alt = coalesce(datadescshort,datadesc)  
			   from subgentables where tableid=312 and
				datacode = @i_bisacmediacode_alt  and datasubcode =  @i_bisacformatcode_alt 
 		  end

		if @i_discountcode_alt is null
		  begin
			select @i_discountcode_alt = 0
		  end

		if @i_discountcode_alt > 0
		  begin
			select @c_discount_alt = lower(externalcode) from gentables where tableid =459
				and datacode = @i_discountcode_alt

			if @i_discountcode_alt = 2  /*trade*/
	 		 begin
				select @c_discount_alt = ''
	  		end
		  end
		else
		  begin
			select @c_discount_alt = ''
		  end

		if @c_discount_alt is null
		  begin
			select @c_discount_alt = ''
		  end
		select @i_territorycode_alt = territoriescode from book where bookkey=@i_childkey
		
		if @i_territorycode_alt is null
		  begin	
			select @i_territorycode_alt = 0
		  end

		if @i_territorycode_alt > 0
		  begin
			select @c_territory_alt = alternatedesc1 from gentables where tableid =131
				and datacode = @i_territorycode_alt
		  end
		else
		  begin
			select @c_territory_alt = ''
		  end

		 if @c_territory_alt is null
		   begin
			select @c_territory_alt = ''
		  end
		if  @i_territorycode_alt = 1 /*world*/
  		begin
			select @c_territory_alt = ''
  		end
		select @i_count = 0
		select @i_count = max(pricekey) from bookprice
			WHERE  bookkey = @i_childkey
		 	  and pricetypecode = @i_pricecode
		 	   and currencytypecode = @i_currencycode
		if @i_count > 0
 		  begin	
			SELECT @i_pricebudget_alt = budgetprice,@i_pricefinal_alt = finalprice
			   FROM bookprice
		  		 WHERE  bookkey = @i_childkey
				   and pricetypecode = @i_pricecode
				    and currencytypecode = @i_currencycode
			if @i_pricefinal_alt > 0 
	  		  begin
				select @d_usretail_alt = @i_pricefinal_alt
			  end
			else
			 begin
				select @d_usretail_alt = @i_pricebudget_alt
			  end
		end

		select @i_count = 0
		select @i_count  = seasonkey
			from printing 
				where bookkey=@i_childkey and printingkey = 1

		if @i_count  > 0
 		 begin
			select @c_seasondesc_alt = seasondesc from season
				where seasonkey = @i_count
		  end
		else
 		 begin
			select @i_count = 0
			select @i_count  = estseasonkey 
			   from printing 
				where bookkey=@i_childkey and printingkey = 1

			if @i_count  > 0
	 		 begin
				select @c_seasondesc_alt = seasondesc from season
					where seasonkey = @i_count
	 		 end
 		 end

		select @boilertext_ch_isbn10 = @c_isbn10_alt + '	'

		if datalength(@c_bisacformatdesc_alt) > 0
  		  begin
			select @boilertext_ch =  @c_bisacformatdesc_alt + '	'+ @c_territory_alt + '	'

			select @boilertext_ch_isbn10 = @boilertext_ch_isbn10  + @c_bisacformatdesc_alt 
  		  end
 
		if @d_usretail_alt > 0 
 		  begin
			select @boilertext_ch = @boilertext_ch + '$' + convert(varchar,@d_usretail_alt) 

			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + convert(varchar,@d_usretail_alt)
  		  end
		else
  		begin
			select @boilertext_ch  = @boilertext_ch + '$0.00'  
			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + '$0.00' 
		end
		 if len(@c_discount_alt)> 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_discount_alt 
		  end
		
		 select @boilertext_ch = @boilertext_ch + '	' + @c_isbn_alt + '	'
		select @boilertext_ch_noseasn = @boilertext_ch

		if datalength(@c_seasondesc_alt) > 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_seasondesc_alt
		  end

		if datalength(@boilertext_ch) > 0
 	 	 begin
			insert into webbookxmlfeed (feedtext) 
    			select '<P>' + @boilertext_ch + '</P>'
		  end

	end /* if @i_format*/


	FETCH NEXT FROM cursor_child
		INTO @i_childkey
      
	select @i_formatstatus = @@FETCH_STATUS
end

close cursor_child
deallocate cursor_child


insert into webbookxmlfeed (feedtext) 
    		select @c_nullvalue
/*Ur copy*/
/*9-30-04  remove extra spacing in ur comment hopefully just a conversion issue and no new ones will be created*/
select @i_count = 0
select @i_count = count(*) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=8
if @i_count > 0
  begin

	select @c_text = cast(commenthtml as varchar(8000)) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=8

	select @c_text = replace(@c_text," style=' margin-right:3273pt;'>",'>')

/*select @i_count = 0
	select @i_count = charindex(' style='' margin-right:3273pt;''>',@c_text)

	if @i_count > 0
	  begin
		  while @i_count > 0  
		    begin
			select @c_text  = STUFF(@c_text,@i_count,30,'')

			select @i_count = 0
			select @i_count = charindex(' style='' margin-right:3273pt;''>',@c_text)
	   	end	

		insert into webbookxmlfeed (feedtext) 
	 	select @c_text
	  end
	else
	  begin	
		insert into webbookxmlfeed (feedtext) 
   		 select commenthtml from bookcomments
			where bookkey = @i_workkey and printingkey = 1
			   and commenttypecode= 1 and commenttypesubcode=8
	  end
*/
	insert into webbookxmlfeed (feedtext) 
	 	select @c_text
  end

/*table of content*/

select @i_count = 0

select @i_count = count(*) from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=24

if @i_count > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select '<P><B>TABLE OF CONTENTS</B></P>'
 
	insert into webbookxmlfeed (feedtext) 
   	 select commenthtml from bookcomments
		where bookkey = @i_workkey and printingkey = 1
		   and commenttypecode= 1 and commenttypesubcode=24
end

if datalength(@subjects_all) >0
  begin
	insert into webbookxmlfeed (feedtext)
		select '<P><B>Subjects:</B></P>'

	insert into webbookxmlfeed (feedtext) 
	    select '<UL><LI>'+ @subjects_all + '</UL>'
  end

insert into webbookxmlfeed (feedtext) 
 select @c_nullvalue


/*******************************************/
/* hard code purchase info seems to be the same */
/*******************************************/

insert into webbookxmlfeed (feedtext)
select '<P>You may purchase this title at 
<A HREF="http://www.press.uchicago.edu/Misc/Chicago/bookstores.html">
these fine bookstores</A>. Outside the USA, consult our 
<A HREF="http://www.press.uchicago.edu/Misc/Chicago/intlsale.html">international 
information page</A>.</P>
<P><I>File last modified on ' + convert(varchar,getdate(),101) +'.</I></P>'

/*9/30/04 add see also text*/
select @i_count = 0
select @i_count = count(*) from bookcomments where printingkey=1 and
	bookkey= @i_workkey and commenttypecode=1 and commenttypesubcode = 39

if @i_count > 0 
  begin
	select @c_reference= commenttext  from bookcomments where printingkey=1 and
		bookkey= @i_workkey and commenttypecode=1 and commenttypesubcode = 39

	insert into webbookxmlfeed (feedtext) 
	 select @c_nullvalue

 	insert into webbookxmlfeed (feedtext) 
		select '<P><I>See also:</I>'
 
	insert into webbookxmlfeed (feedtext) 
		select '<UL>'

	insert into webbookxmlfeed (feedtext) 
		select '<LI>'+ @c_reference

	insert into webbookxmlfeed (feedtext) 
		select '</LI></UL>'

  end
else
  begin
	insert into webbookxmlfeed (feedtext) 
	 select @c_nullvalue
  end

insert into webbookxmlfeed (feedtext) 
 select @c_nullvalue

insert into webbookxmlfeed (feedtext) 
    select '</www>'

/***************************************/
/** Output Order Form Biblio info  **/
/***************************************/
insert into webbookxmlfeed (feedtext) 
    select '<pr>'

insert into webbookxmlfeed (feedtext) 
    select '													Qty   Amount'

insert into webbookxmlfeed (feedtext) 
    select @c_nullvalue

select @boilertext = ''

select @boilertext = @c_authorprimary + ': ' + @c_title

insert into webbookxmlfeed (feedtext) 
    select @boilertext 

select @boilertext = ''

if datalength(@c_bisacformatdesc) > 0
  begin
	select @boilertext = @boilertext + @c_bisacformatdesc + '	'+ @c_territory + '	'
  end
 
if @d_usretail > 0 
 begin
	select @boilertext = @boilertext + '$' + convert(varchar,@d_usretail) 

  end
else
  begin
	select @boilertext_ch  = @boilertext_ch + '$0.00'  
	select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + '$0.00' 
end
if len(@c_discount) > 0
  begin
	select @boilertext = @boilertext +  @c_discount 
  end

 select @boilertext = @boilertext  + '	' + @c_isbn + '							___   ______'
 

insert into webbookxmlfeed (feedtext) 
    select @boilertext 

select @boilertext = ''

/*other format*/
/*8-2-04 child format will no longer be present in webbookkeys table if parent present so do not check for it
9-30-04 use bookcustom instead of workkey*/

if @i_nocustomkey = 1  /*no customint09 use workkey*/
  begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
/* get all related books that is not a parent base on customkey*/
		select distinct bb.bookkey 
		from book bb,bookdetail b, isbn i
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bb.workkey = @i_workkey
				and bb.linklevelcode=20 and bb.bookkey not in (select bookkey from webbookkeys)
		FOR READ ONLY
end
else
 begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
		select distinct bc.bookkey 
		from book bb,bookdetail b, isbn i,bookcustom bc
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey and bc.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bc.customint09= @i_customkey
	  				and bb.linklevelcode=20 and bc.bookkey not in (select bookkey from webbookkeys)
	 FOR READ ONLY
end
OPEN cursor_child

FETCH NEXT FROM cursor_child
	INTO @i_childkey

select @i_formatstatus = @@FETCH_STATUS
	
	while (@i_formatstatus<>-1 )
	  begin
		IF (@i_formatstatus<>-2)
	  	  begin
		    select @c_isbn_alt = ''
		    select @c_isbn10_alt = ''
		    select @i_bisacmediacode_alt = 0
		    select @i_bisacformatcode_alt = 0
		    select @c_bisacformatdesc_alt = ''
		    select @i_pricefinal_alt = 0
		    select @i_pricebudget_alt = 0
		    select @d_usretail_alt = 0
		    select @c_territory_alt = ''
		    select @i_territorycode_alt = 0
		    select @c_seasondesc_alt =''
		    select @c_discount_alt = ''
		    select @i_discountcode_alt = 0

		select @c_isbn_alt = isbn, @c_isbn10_alt = isbn10 from isbn
			where bookkey=@i_childkey

		select @i_bisacmediacode_alt = mediatypecode, @i_bisacformatcode_alt=mediatypesubcode,@i_discountcode_alt = discountcode
  			from bookdetail where bookkey=@i_childkey

		if  @i_bisacmediacode_alt is  null 
		  begin 
			select @i_bisacmediacode_alt  = 0
		  end

		if @i_bisacformatcode_alt is null
		  begin
			select @i_bisacformatcode_alt = 0
		  end
		if  @i_bisacmediacode_alt > 0 and  @i_bisacformatcode_alt > 0
   		  begin
			select @c_bisacformatdesc_alt = coalesce(datadescshort,datadesc)  
			   from subgentables where tableid=312 and
				datacode = @i_bisacmediacode_alt  and datasubcode =  @i_bisacformatcode_alt 
 		  end

		if @i_discountcode_alt is null
		  begin
			select @i_discountcode_alt = 0
		  end

		if @i_discountcode_alt > 0
		  begin
			select @c_discount_alt = lower(externalcode) from gentables where tableid =459
				and datacode = @i_discountcode_alt

			if @i_discountcode_alt = 2  /*trade*/
	 		 begin
				select @c_discount_alt = ''
	  		end
		  end
		else
		  begin
			select @c_discount_alt = ''
		  end

		if @c_discount_alt is null
		  begin
			select @c_discount_alt = ''
		  end
		select @i_territorycode_alt = territoriescode from book where bookkey=@i_childkey
		
		if @i_territorycode_alt is null
		  begin	
			select @i_territorycode_alt = 0
		  end

		if @i_territorycode_alt > 0
		  begin
			select @c_territory_alt = alternatedesc1 from gentables where tableid =131
				and datacode = @i_territorycode_alt
		  end
		else
		  begin
			select @c_territory_alt = ''
		  end

		 if @c_territory_alt is null
		   begin
			select @c_territory_alt = ''
		  end
		if  @i_territorycode_alt = 1 /*world*/
  		begin
			select @c_territory_alt = ''
  		end
		select @i_count = 0
		select @i_count = max(pricekey) from bookprice
			WHERE  bookkey = @i_childkey
		 	  and pricetypecode = @i_pricecode
		 	   and currencytypecode = @i_currencycode
		if @i_count > 0
 		  begin	
			SELECT @i_pricebudget_alt = budgetprice,@i_pricefinal_alt = finalprice
			   FROM bookprice
		  		 WHERE  bookkey = @i_childkey
				   and pricetypecode = @i_pricecode
				    and currencytypecode = @i_currencycode
			if @i_pricefinal_alt > 0 
	  		  begin
				select @d_usretail_alt = @i_pricefinal_alt
			  end
			else
			 begin
				select @d_usretail_alt = @i_pricebudget_alt
			  end
		end

		select @i_count = 0
		select @i_count  = seasonkey
			from printing 
				where bookkey=@i_childkey and printingkey = 1

		if @i_count  > 0
 		 begin
			select @c_seasondesc_alt = seasondesc from season
				where seasonkey = @i_count
		  end
		else
 		 begin
			select @i_count = 0
			select @i_count  = estseasonkey 
			   from printing 
				where bookkey=@i_childkey and printingkey = 1

			if @i_count  > 0
	 		 begin
				select @c_seasondesc_alt = seasondesc from season
					where seasonkey = @i_count
	 		 end
 		 end

		select @boilertext_ch_isbn10 = @c_isbn10_alt + '	'

		if datalength(@c_bisacformatdesc_alt) > 0
  		  begin
			select @boilertext_ch =  @c_bisacformatdesc_alt + '	'+ @c_territory_alt + '	'

			select @boilertext_ch_isbn10 = @boilertext_ch_isbn10  + @c_bisacformatdesc_alt 
  		  end
 
		if @d_usretail_alt > 0 
 		  begin
			select @boilertext_ch = @boilertext_ch + '$' + convert(varchar,@d_usretail_alt) 

			select @boilertext_ch_isbn10 = @boilertext_ch_isbn10   +'	' + convert(varchar,@d_usretail_alt)
  		  end
		else
  		 begin
			select @boilertext_ch  = @boilertext_ch + '$0.00'  
			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + '$0.00' 
		  end
		 if len(@c_discount_alt)> 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_discount_alt 
		  end
		
		 select @boilertext_ch = @boilertext_ch + '	' + @c_isbn_alt + '	'

		select @boilertext_ch_noseasn = @boilertext_ch

		if datalength(@c_seasondesc_alt) > 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_seasondesc_alt
		  end

		if datalength(@boilertext_ch_noseasn) > 0 
  		begin
			insert into webbookxmlfeed (feedtext)
			select @boilertext_ch_noseasn + '						___   ______'
  		end

	end /* if @i_format*/


	FETCH NEXT FROM cursor_child
		INTO @i_childkey
      
	select @i_formatstatus = @@FETCH_STATUS
end

close cursor_child
deallocate cursor_child


insert into webbookxmlfeed (feedtext) 
    select '</pr>'

insert into webbookxmlfeed (feedtext) 
    select '<opr>'

insert into webbookxmlfeed (feedtext) 
    select '1	' + @boilertext_orig


/*other format*/
/*8-2-04 child format will no longer be present in webbookkeys table if parent present so do not check for it
9-30-04 use bookcustom instead of workkey*/

if @i_nocustomkey = 1  /*no customint09 use workkey*/
  begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
/* get all related books that is not a parent base on customkey*/
		select distinct bb.bookkey 
		from book bb,bookdetail b, isbn i
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bb.workkey = @i_workkey
				and bb.linklevelcode=20 and bb.bookkey not in (select bookkey from webbookkeys)
		FOR READ ONLY
end
else
 begin
	DECLARE cursor_child INSENSITIVE CURSOR
	FOR
		select distinct bc.bookkey 
		from book bb,bookdetail b, isbn i,bookcustom bc
		where b.bookkey=bb.bookkey and b.bookkey=i.bookkey and bc.bookkey=i.bookkey
			and bisacstatuscode in  (1,4)
				and datalength(isbn)>0
				and  bc.customint09= @i_customkey
	  				and bb.linklevelcode=20 and bc.bookkey not in (select bookkey from webbookkeys)
	 FOR READ ONLY
end

OPEN cursor_child

FETCH NEXT FROM cursor_child
	INTO @i_childkey

select @i_formatstatus = @@FETCH_STATUS
	
	while (@i_formatstatus<>-1 )
	  begin
		IF (@i_formatstatus<>-2)
	  	  begin
		    select @c_isbn_alt = ''
		    select @c_isbn10_alt = ''
		    select @i_bisacmediacode_alt = 0
		    select @i_bisacformatcode_alt = 0
		    select @c_bisacformatdesc_alt = ''
		    select @i_pricefinal_alt = 0
		    select @i_pricebudget_alt = 0
		    select @d_usretail_alt = 0
		    select @c_territory_alt = ''
		    select @i_territorycode_alt = 0
		    select @c_seasondesc_alt =''
		    select @c_discount_alt = ''
		    select @i_discountcode_alt = 0

		select @c_isbn_alt = isbn, @c_isbn10_alt = isbn10 from isbn
			where bookkey=@i_childkey

		select @i_bisacmediacode_alt = mediatypecode, @i_bisacformatcode_alt=mediatypesubcode,@i_discountcode_alt = discountcode
  			from bookdetail where bookkey=@i_childkey

		if  @i_bisacmediacode_alt is  null 
		  begin 
			select @i_bisacmediacode_alt  = 0
		  end

		if @i_bisacformatcode_alt is null
		  begin
			select @i_bisacformatcode_alt = 0
		  end
		if  @i_bisacmediacode_alt > 0 and  @i_bisacformatcode_alt > 0
   		  begin
			select @c_bisacformatdesc_alt = coalesce(datadescshort,datadesc)  
			   from subgentables where tableid=312 and
				datacode = @i_bisacmediacode_alt  and datasubcode =  @i_bisacformatcode_alt 
 		  end

		if @i_discountcode_alt is null
		  begin
			select @i_discountcode_alt = 0
		  end

		if @i_discountcode_alt > 0
		  begin
			select @c_discount_alt = lower(externalcode) from gentables where tableid =459
				and datacode = @i_discountcode_alt

			if @i_discountcode_alt = 2  /*trade*/
	 		 begin
				select @c_discount_alt = ''
	  		end
		  end
		else
		  begin
			select @c_discount_alt = ''
		  end

		if @c_discount_alt is null
		  begin
			select @c_discount_alt = ''
		  end
		select @i_territorycode_alt = territoriescode from book where bookkey=@i_childkey
		
		if @i_territorycode_alt is null
		  begin	
			select @i_territorycode_alt = 0
		  end

		if @i_territorycode_alt > 0
		  begin
			select @c_territory_alt = alternatedesc1 from gentables where tableid =131
				and datacode = @i_territorycode_alt
		  end
		else
		  begin
			select @c_territory_alt = ''
		  end

		 if @c_territory_alt is null
		   begin
			select @c_territory_alt = ''
		  end

		if  @i_territorycode_alt = 1 /*world*/
  		begin
			select @c_territory_alt = ''
  		end

		select @i_count = 0
		select @i_count = max(pricekey) from bookprice
			WHERE  bookkey = @i_childkey
		 	  and pricetypecode = @i_pricecode
		 	   and currencytypecode = @i_currencycode
		if @i_count > 0
 		  begin	
			SELECT @i_pricebudget_alt = budgetprice,@i_pricefinal_alt = finalprice
			   FROM bookprice
		  		 WHERE  bookkey = @i_childkey
				   and pricetypecode = @i_pricecode
				    and currencytypecode = @i_currencycode
			if @i_pricefinal_alt > 0 
	  		  begin
				select @d_usretail_alt = @i_pricefinal_alt
			  end
			else
			 begin
				select @d_usretail_alt = @i_pricebudget_alt
			  end
		end

		select @i_count = 0
		select @i_count  = seasonkey
			from printing 
				where bookkey=@i_childkey and printingkey = 1

		if @i_count  > 0
 		 begin
			select @c_seasondesc_alt = seasondesc from season
				where seasonkey = @i_count
		  end
		else
 		 begin
			select @i_count = 0
			select @i_count  = estseasonkey 
			   from printing 
				where bookkey=@i_childkey and printingkey = 1

			if @i_count  > 0
	 		 begin
				select @c_seasondesc_alt = seasondesc from season
					where seasonkey = @i_count
	 		 end
 		 end

		select @boilertext_ch_isbn10 = @c_isbn10_alt + '	'

		if datalength(@c_bisacformatdesc_alt) > 0
  		  begin
			select @boilertext_ch =  @c_bisacformatdesc_alt + '	'+ @c_territory_alt + '	'

			select @boilertext_ch_isbn10 = @boilertext_ch_isbn10  + @c_bisacformatdesc_alt 
  		  end
 		
		if @d_usretail_alt > 0 
 		  begin
			select @boilertext_ch = @boilertext_ch + '$' + convert(varchar,@d_usretail_alt) 

			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + convert(varchar,@d_usretail_alt)
  		  end
		else
  		 begin
			select @boilertext_ch  = @boilertext_ch + '$0.00'  
			select @boilertext_ch_isbn10= @boilertext_ch_isbn10   +'	' + '$0.00' 
		  end
		 if len(@c_discount_alt)> 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_discount_alt 
		  end
		
		 select @boilertext_ch = @boilertext_ch + '	' + @c_isbn_alt + '	'

		select @boilertext_ch_noseasn = @boilertext_ch

		if datalength(@c_seasondesc_alt) > 0
		  begin
			select @boilertext_ch = @boilertext_ch +  @c_seasondesc_alt
		  end

		if datalength(@boilertext_ch_isbn10) > 0
 		 begin 
			insert into webbookxmlfeed (feedtext) 
	   		 select '1	' + @boilertext_ch_isbn10
  	end
	end /* if @i_format*/


	FETCH NEXT FROM cursor_child
		INTO @i_childkey
      
	select @i_formatstatus = @@FETCH_STATUS
end

close cursor_child
deallocate cursor_child

insert into webbookxmlfeed (feedtext) 
    select '</opr>'

insert into webbookxmlfeed (feedtext) 
    select '<lcn>'

if datalength(@c_lccn) >0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_lccn 
  end
else
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_nullvalue 
  end

insert into webbookxmlfeed (feedtext) 
    select '</lcn>'

insert into webbookxmlfeed (feedtext) 
    select '<lcc>'

if datalength(@c_lcc) > 0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_lcc 
  end
else
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @c_nullvalue 
  end

insert into webbookxmlfeed (feedtext) 
    select '</lcc>'

insert into webbookxmlfeed (feedtext) 
    select '<sc>'

if datalength(@subjects_all_codes) >0
  begin
	insert into webbookxmlfeed (feedtext) 
	    select @subjects_all_codes
  end

insert into webbookxmlfeed (feedtext) 
    select '</sc>'

insert into webbookxmlfeed (feedtext) 
    select '<kw>'

/*where do we get keywords*/

 insert into webbookxmlfeed (feedtext) 
     select @c_nullvalue
/*    select @c_keywords = commenttext from bookcomments where bookkey= @i_workkey, printingkey=1
	and commenttypecode=? and commenttypesubcode = ?
*/
insert into webbookxmlfeed (feedtext) 
    select '</kw>'

/***************************************/
/** Output Product Group Ending Line  **/
/***************************************/
insert into webbookxmlfeed (feedtext) 
	select '</control>'


commit tran

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO