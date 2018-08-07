if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloflatoutbook_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloflatoutbook_sp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





CREATE proc dbo.eloflatoutbook_sp @i_bookkey int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

i_onixlevel can equal 1 for generic onix (Level 1), 2 for Onix Level 2, 3 for QSI WEB Site Onix 
**/

DECLARE @c_isbn13 varchar (13)
DECLARE @c_isbn10 varchar (10)
DECLARE @c_ean varchar (50)
DECLARE @c_titleprefix varchar (100)
DECLARE @c_titlewithprefix varchar (255)
DECLARE @c_titlewithoutprefix varchar (255)
DECLARE @c_title varchar (100)
DECLARE @c_subtitle varchar (255)
DECLARE @c_publishername varchar (100)
DECLARE @i_publisherorgentrykey int
DECLARE @c_imprintname varchar (100)



DECLARE @i_authortypecode smallint
DECLARE @i_authorsortorder int
DECLARE @i_authorcursorstatus int
DECLARE @c_authordisplayname varchar (100)
DECLARE @c_authorlastname varchar (100)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_authorsuffix varchar (75)
DECLARE @c_authortypedesc varchar (100)
DECLARE @i_authorprimaryind tinyint
DECLARE @c_authorprimaryflag varchar (3)

DECLARE @c_authorlastname1 varchar (100)
DECLARE @c_authorfirstname1 varchar (100)
DECLARE @c_authordisplayname1 varchar (100)
DECLARE @c_authorprimaryflag1 varchar (3)
DECLARE @c_authortype1 varchar (100)
DECLARE @c_authorsuffix1 varchar (75)

	
DECLARE @c_authorlastname2 varchar (100)
DECLARE @c_authorfirstname2 varchar (100)
DECLARE @c_authordisplayname2 varchar (100)
DECLARE @c_authorprimaryflag2 varchar (3)
DECLARE @c_authortype2 varchar (100)
DECLARE @c_authorsuffix2 varchar (75)

	
DECLARE @c_authorlastname3 varchar (100)
DECLARE @c_authorfirstname3 varchar (100)
DECLARE @c_authordisplayname3 varchar (100)
DECLARE @c_authorprimaryflag3 varchar (3)
DECLARE @c_authortype3 varchar (100)
DECLARE @c_authorsuffix3 varchar (75)

	
DECLARE @c_authorlastname4 varchar (100)
DECLARE @c_authorfirstname4 varchar (100)
DECLARE @c_authordisplayname4 varchar (100)
DECLARE @c_authorprimaryflag4 varchar (3)
DECLARE @c_authortype4 varchar (100)
DECLARE @c_authorsuffix4 varchar (75)


DECLARE @c_fullauthordisplayname varchar (255)
DECLARE @d_usretailprice decimal (10,2)
DECLARE @d_canadaretailprice decimal (10,2)	
DECLARE @d_ukretailprice decimal (10,2)	
DECLARE @d_estusretailprice decimal (10,2)
DECLARE @d_estcanadaretailprice decimal (10,2)	
DECLARE @d_estukretailprice decimal (10,2)	

DECLARE @c_mediatypedesc varchar (100)
DECLARE @c_mediabisaccode varchar (25)
DECLARE @c_formatdesc varchar (100)
DECLARE @c_formatbisaccode varchar (25)
DECLARE @i_pagecount smallint
DECLARE @c_trimsizewidth varchar (20)
DECLARE @c_trimsizelength varchar (20)

DECLARE @d_pubdate datetime
DECLARE @c_pubdateYYYYMMDD varchar(8)
DECLARE @c_pubmonthname varchar (20)
DECLARE @c_pubyear varchar (20)
DECLARE @c_pubmonth varchar (20)

DECLARE @c_bisaccategorymajorcode varchar (100)
DECLARE @c_bisaccategorymajordesc varchar (100)
DECLARE @c_bisaccategoryminorcode varchar (100)
DECLARE @c_bisaccategoryminordesc varchar (100)

DECLARE @c_bisaccategorymajorcode1 varchar (100)
DECLARE @c_bisaccategorymajordesc1 varchar (100)
DECLARE @c_bisaccategoryminorcode1 varchar (100)
DECLARE @c_bisaccategoryminordesc1 varchar (100)

DECLARE @c_bisaccategorymajorcode2 varchar (100)
DECLARE @c_bisaccategorymajordesc2 varchar (100)
DECLARE @c_bisaccategoryminorcode2 varchar (100)
DECLARE @c_bisaccategoryminordesc2 varchar (100)

DECLARE @c_bisaccategorymajorcode3 varchar (100)
DECLARE @c_bisaccategorymajordesc3 varchar (100)
DECLARE @c_bisaccategoryminorcode3 varchar (100)
DECLARE @c_bisaccategoryminordesc3 varchar (100)

DECLARE @c_bisaccategorymajorcode4 varchar (100)
DECLARE @c_bisaccategorymajordesc4 varchar (100)
DECLARE @c_bisaccategoryminorcode4 varchar (100)
DECLARE @c_bisaccategoryminordesc4 varchar (100)

DECLARE @c_bisaccategorymajorcode5 varchar (100)
DECLARE @c_bisaccategorymajordesc5 varchar (100)
DECLARE @c_bisaccategoryminorcode5 varchar (100)
DECLARE @c_bisaccategoryminordesc5 varchar (100)

DECLARE @i_seriescode int
DECLARE @c_series varchar (100)
DECLARE @c_adultchildrensflag varchar (100)

DECLARE @i_territoriescode int
DECLARE @c_territories varchar (100)

DECLARE @i_editioncode int
DECLARE @c_edition varchar (100)
DECLARE @d_editionnumber decimal (10,2)
DECLARE @c_editiondesc varchar (40)

DECLARE @c_briefdescription varchar (8000)
DECLARE @c_description varchar (8000)
DECLARE @c_authorbio varchar (8000)
DECLARE @c_tableofcontents varchar (8000)
DECLARE @c_excerpt varchar (8000)

DECLARE @i_cartonqty int

DECLARE @i_agelow int
DECLARE @i_agelowupind int
DECLARE @i_agehigh int
DECLARE @i_agehighupind int
DECLARE @c_ages varchar (25)
DECLARE @c_agelow varchar (25)
DECLARE @c_agehigh varchar (25)
DECLARE @c_bisacstatuscode varchar (25)
DECLARE @c_bisacstatusdesc varchar (100)
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @c_insertillusdesc varchar (255)


DECLARE @c_dummy varchar (25)
DECLARE @i_subjectcursorstatus int
DECLARE @i_rownumber int

DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_validationerrorind int
DECLARE @c_tempmessage varchar (255)

DECLARE @i_audiencecode int
DECLARE @c_audiencecode1 varchar (40)
DECLARE @c_audiencecode2 varchar (40)
DECLARE @i_audiencecursorstatus int
DECLARE @i_discountcode int
DECLARE @c_discountcode varchar (40)

/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 2

begin tran

/** Initialize the Validation Error to zero (False) **/
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/
/** for this bookkey.  Processing will continue to the next bookkey **/

select @i_validationerrorind = 0

/*******************************************/
/* Output ISBN13,ISBN10, EAN (with Hyphens) */
/*******************************************/

select @c_isbn13=isbn, @c_isbn10=isbn10, @c_ean=ean
	from isbn where bookkey= @i_bookkey and isbn10 is not null
	if @@rowcount<=0
	begin
		select @i_validationerrorind = 1
		exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'
	end
	if @@error <>0
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end


/*****************************************/
/** Output titleprefix, titlewithoutprefix,titlewithprefix,subtitle  **/
/*****************************************/

select @c_titleprefix=titleprefix 
from bookdetail where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

select @c_titlewithoutprefix=title, @c_subtitle=subtitle from book where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_titlewithoutprefix is null or @c_titlewithoutprefix = ''
begin
	select @i_validationerrorind = 1
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Title Missing'
end


if @c_titleprefix is not null and @c_titleprefix <> ''
begin
	select @c_titlewithprefix= @c_titleprefix + ' ' + @c_titlewithoutprefix
end
else
begin
	select @c_titlewithprefix= @c_titlewithoutprefix
end



/*****************************************/
/** Output PublisherName - Orglevel 2   **/
/*****************************************/

select @i_publisherorgentrykey=oe.orgentrykey, @c_publishername= oe.orgentrydesc 
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey


/*****************************************/
/** Output ImprintName - Orglevel 3     **/
/*****************************************/


select @c_imprintname= oe.orgentrydesc
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey



/*****************************************/
/** Output <Contributor> Author Loop    **/
/*****************************************/



DECLARE cursor_author INSENSITIVE CURSOR
FOR
select ba.authortypecode,ba.sortorder, ba.primaryind, a.displayname,a.lastname, a.firstname,a.authorsuffix
 from bookauthor ba,author a
 where ba.bookkey=@i_bookkey and a.authorkey=ba.authorkey
 order by ba.sortorder
FOR READ ONLY

OPEN cursor_author

FETCH NEXT FROM cursor_author
INTO @i_authortypecode,@i_authorsortorder, @i_authorprimaryind,
@c_authordisplayname,@c_authorlastname,@c_authorfirstname, @c_authorsuffix

select @i_authorcursorstatus = @@FETCH_STATUS

if @i_authorcursorstatus < 0 /** No Authors **/
begin
	select @c_dummy=''
	select @i_validationerrorind = 1
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Author missing'
end

while (@i_authorcursorstatus<>-1 )
begin
	IF (@i_authorcursorstatus<>-2)
	begin
	
		if @i_authortypecode is not null and @i_authortypecode > 0 
		begin
			select @c_authortypedesc=datadesc from 
			gentables where tableid=134 and datacode=@i_authortypecode
		end
	
		if @c_authortypedesc is null or @c_authortypedesc = ''
		begin
			select @c_authortypedesc = 'Author'
		end
	
		if @i_authorprimaryind=1
			select @c_authorprimaryflag='Yes'
		else
			select @c_authorprimaryflag='No'

		
		if @i_authorsortorder = 1
		begin
			select @c_authorlastname1=@c_authorlastname
			select @c_authorfirstname1=@c_authorfirstname
			select @c_authordisplayname1=@c_authordisplayname
			select @c_authorprimaryflag1=@c_authorprimaryflag
			select @c_authortype1=@c_authortypedesc
			select @c_authorsuffix1=@c_authorsuffix
			
		end
		else if @i_authorsortorder = 2
		begin
			select @c_authorlastname2=@c_authorlastname
			select @c_authorfirstname2=@c_authorfirstname
			select @c_authordisplayname2=@c_authordisplayname
			select @c_authorprimaryflag2=@c_authorprimaryflag
			select @c_authortype2=@c_authortypedesc
			select @c_authorsuffix2=@c_authorsuffix
		end
		else if @i_authorsortorder = 3
		begin
			select @c_authorlastname3=@c_authorlastname
			select @c_authorfirstname3=@c_authorfirstname
			select @c_authordisplayname3=@c_authordisplayname
			select @c_authorprimaryflag3=@c_authorprimaryflag
			select @c_authortype3=@c_authortypedesc
			select @c_authorsuffix3=@c_authorsuffix
		end
		else if @i_authorsortorder = 4
		begin
			select @c_authorlastname4=@c_authorlastname
			select @c_authorfirstname4=@c_authorfirstname
			select @c_authordisplayname4=@c_authordisplayname
			select @c_authorprimaryflag4=@c_authorprimaryflag
			select @c_authortype4=@c_authortypedesc
			select @c_authorsuffix4=@c_authorsuffix
		end

	end /* if authorcursorstatus <> -2*/
	
	FETCH NEXT FROM cursor_author
	INTO @i_authortypecode,@i_authorsortorder, @i_authorprimaryind,
	@c_authordisplayname,@c_authorlastname, @c_authorfirstname, @c_authorsuffix
      
	select @i_authorcursorstatus = @@FETCH_STATUS
end /** End While Loop **/

close cursor_author
deallocate cursor_author



/*****************************************/
/** Output Full Author Display Name     **/
/*****************************************/

select @c_fullauthordisplayname = fullauthordisplayname
	 from bookdetail where bookkey=@i_bookkey

/******************************************/
/** Output US Retail and Canadian Retail***/
/******************************************/


/** Modified 10/8/2002 by DSL to output Estimate price if Final not available **/

select @d_usretailprice=0
select @d_estusretailprice=0

select 
@d_usretailprice=convert (decimal (10,2),finalprice),
@d_estusretailprice=convert (decimal (10,2),budgetprice)  
from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=6

if @d_usretailprice=0 or @d_usretailprice is null  /* Final price not found, use budget */
begin
	if @d_estusretailprice > 0 and @d_estusretailprice is not null
	begin
		select @d_usretailprice=@d_estusretailprice
	end
end

if @d_usretailprice=0 or @d_usretailprice is null /* Retail Price Not Found - Try for Suggested List Price */
begin
	select @d_usretailprice=convert (decimal (10,2),finalprice),
	@d_estusretailprice=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=11
	and currencytypecode=6

	if @d_usretailprice=0 or @d_usretailprice is null  /* Final price not found, use budget */
	begin
		if @d_estusretailprice > 0 and @d_estusretailprice is not null
		begin
			select @d_usretailprice=@d_estusretailprice
		end
	end
end


select @d_canadaretailprice=0
select @d_estcanadaretailprice=0

select 
@d_canadaretailprice=convert (decimal (10,2),finalprice),
@d_estcanadaretailprice=convert (decimal (10,2),budgetprice)  
from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=11

if @d_canadaretailprice=0 or @d_canadaretailprice is null  /* Final price not found, use budget */
begin
	if @d_estcanadaretailprice > 0 and @d_estcanadaretailprice is not null
	begin
		select @d_canadaretailprice=@d_estcanadaretailprice
	end
end

if @d_canadaretailprice=0 or @d_canadaretailprice is null /* Retail Price Not Found - Try for Suggested List Price */
begin
	select @d_canadaretailprice=convert (decimal (10,2),finalprice),
	@d_estcanadaretailprice=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=11
	and currencytypecode=11

	if @d_canadaretailprice=0 or @d_canadaretailprice is null  /* Final price not found, use budget */
	begin
		if @d_estcanadaretailprice > 0 and @d_estcanadaretailprice is not null
		begin
			select @d_canadaretailprice=@d_estcanadaretailprice
		end
	end
end


select @d_ukretailprice=0
select @d_estukretailprice=0

select 
@d_ukretailprice=convert (decimal (10,2),finalprice),
@d_estukretailprice=convert (decimal (10,2),budgetprice)  
from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=37

if @d_ukretailprice=0 or @d_ukretailprice is null  /* Final price not found, use budget */
begin
	if @d_estukretailprice > 0 and @d_estukretailprice is not null
	begin
		select @d_ukretailprice=@d_estukretailprice
	end
end

if @d_ukretailprice=0 or @d_ukretailprice is null /* Retail Price Not Found - Try for Suggested List Price */
begin
	select @d_ukretailprice=convert (decimal (10,2),finalprice),
	@d_estukretailprice=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=11
	and currencytypecode=37

	if @d_ukretailprice=0 or @d_ukretailprice is null  /* Final price not found, use budget */
	begin
		if @d_estukretailprice > 0 and @d_estukretailprice is not null
		begin
			select @d_ukretailprice=@d_estukretailprice
		end
	end
end

/**********************************************/
/* Added 12/02 - CT - Add discount code and audience code */
/**********************************************/
select @c_discountcode=g.datadesc
	from bookdetail bd,gentables g
	where bd.bookkey= @i_bookkey and g.tableid=459 
	and g.datacode=bd.discountcode
	
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* new */
/**************************************************************/
/**  output Audience Code  - modified 6/2003 for new bookaudience table            **/
/*************************************************************/

/* initialize variables each time */
select @c_audiencecode1 = ''
select @c_audiencecode2 = ''
 
DECLARE cursor_bookaudience INSENSITIVE CURSOR
FOR
select convert (varchar (3),audiencecode) 
from bookaudience where bookkey=@i_bookkey 
order by sortorder
FOR READ ONLY

OPEN cursor_bookaudience

FETCH NEXT FROM cursor_bookaudience
INTO @i_audiencecode

select @i_audiencecursorstatus = @@FETCH_STATUS
select @i_rownumber=0
if @i_audiencecursorstatus = -1 
begin
	exec eloonixvalidation_sp @i_warning, @i_bookkey, 'No Audience Code'
end

while (@i_audiencecursorstatus<>-1 )
begin
	select @i_rownumber = @i_rownumber + 1
	IF (@i_audiencecursorstatus<>-2)
	begin
	

	if (@i_rownumber >= 1) and (@i_rownumber <= 2) /* Begin code processing - Output first two audience codes only*/
	begin


	/*******************************************/
	/* Output <b073>  audience code*/
	/**************************************************/
	
	if (@i_rownumber=1) /* This is the first record */
		begin	
			if (@i_audiencecode <10)
			begin /* prepend the '0' */
				select @c_audiencecode1= '0' + convert(varchar(25),@i_audiencecode) 
			end
		else
			begin
			select @c_audiencecode1   = convert(varchar(25),@i_audiencecode) 
			end
	end /* end first audience code */

	if (@i_rownumber=2) /* This is the first record */
		begin	
			if (@i_audiencecode <10)
			begin /* prepend the '0' */
				select @c_audiencecode1= '0' + convert(varchar(25),@i_audiencecode) 
			end
		else
			begin
			select @c_audiencecode1   = convert(varchar(25),@i_audiencecode) 
			end
	end /* end second audience code */



	end /*code processing */

	end /* if audiencecursorstatus */
	
	FETCH NEXT FROM cursor_bookaudience
	INTO @i_audiencecode
      
	select @i_audiencecursorstatus = @@FETCH_STATUS
end

close cursor_bookaudience
deallocate cursor_bookaudience



/*******************************************/
/* Output Media/Format  */
/**************************************************/



select @c_mediabisaccode=g.bisacdatacode,@c_mediatypedesc=g.datadesc,
@c_formatbisaccode = sg.bisacdatacode, @c_formatdesc = sg.datadesc
from bookdetail bd,gentables g,subgentables sg
where bd.bookkey= @i_bookkey and g.tableid=312 
and g.datacode=bd.mediatypecode and sg.tableid=312 
and sg.datacode=bd.mediatypecode and sg.datasubcode=bd.mediatypesubcode
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/*****************************************/
/** Output -  Page Count                **/
/*****************************************/
select @i_pagecount = pagecount from printing where bookkey=@i_bookkey
and printingkey=1

if @i_pagecount is null or @i_pagecount = 0 /* Actual Page Count is null, try Estimated Page count */
begin
	select @i_pagecount = tentativepagecount from printing where bookkey=@i_bookkey
	and printingkey=1
end


/*****************************************/
/** Output -  Trim Size                 **/
/*****************************************/
select @c_trimsizewidth = trimsizewidth, @c_trimsizelength = trimsizelength from printing where bookkey=@i_bookkey
and printingkey=1

if @c_trimsizewidth is null or @c_trimsizewidth = '' /* Actual Trim is null, try Estimated Trim */
begin
	select @c_trimsizewidth = esttrimsizewidth, @c_trimsizelength = esttrimsizelength from printing where bookkey=@i_bookkey
	and printingkey=1
end


/*****************************************/
/** Output  PublicationDate             **/
/*****************************************/
select @d_pubdate=NULL

/* 8/27/02 - CT- don't output pubdate for Cancelled, Postponed, No longer our Publication */

select @c_bisacstatuscode=g.bisacdatacode
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode

if @c_bisacstatuscode NOT in ('PP','PC','NL') /* don't output pubdate for these status types */
Begin
	select @d_pubdate = activedate from bookdates 
	where bookkey=@i_bookkey  and printingkey=1 and datetypecode=8

	if @d_pubdate is NOT NULL
	begin
		/* Call the Date conversion function, 
		then retrieve the resuling date from eloconverteddate */
		exec eloformatdateYYYYMMDD_sp @d_pubdate
		select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
	end
	else /*** Check for Estimated Pub Date ***/
	begin
		select @d_pubdate = estdate from bookdates 
		where bookkey=@i_bookkey and printingkey=1 and datetypecode=8
		if @d_pubdate is NOT NULL
		begin
			/* Call the Date conversion function, 
			then retrieve the resuling date from eloconverteddate */
			exec eloformatdateYYYYMMDD_sp @d_pubdate
			select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
		end
		else 
	/*** Actual or Estimated Pub Date does not exist, Try Pub Year from Printing. Pub Year is set in Java Import
	    to Pub Month + Pub Year, with day set to '01'. i.e. 03/01/2001 ***/
		begin
			select @d_pubdate=pubmonth from printing
      		where bookkey=@i_bookkey and printingkey=1 
			if @d_pubdate is NOT NULL
			begin
				/* Call the Date conversion function, 
				then retrieve the resuling date from eloconverteddate */
				exec eloformatdateYYYYMMDD_sp @d_pubdate
				select @c_pubdateYYYYMMDD=converteddate from eloconverteddate
			end
		end
	end /** End Else Check Est Pub DatePub Year **/
end /** End if bisacstatus is Cancelled, postponed or Not Longer Our Publication **/


/*** FORMAT Pub Month ***/
select @c_pubmonthname=datename(month,pubmonth), @c_pubyear = datepart(year,pubmonth) from printing
      		where bookkey=@i_bookkey and printingkey=1 
if @c_pubmonthname is NOT NULL and @c_pubyear is not null
begin
	select @c_pubmonth = @c_pubmonthname + ' ' + @c_pubyear
end
else
	select @c_pubmonth = ''



/*******************************************/
/* BISAC Subject Categories   */
/**************************************************/


DECLARE cursor_subject INSENSITIVE CURSOR
FOR
select g.bisacdatacode, g.datadesc, sg.bisacdatacode, sg.datadesc 
from bookbisaccategory bb, gentables g, subgentables sg
where bb.bookkey=@i_bookkey and bb.printingkey=1 and 
g.tableid = 339 and 
g.datacode=bb.bisaccategorycode and
sg.tableid = 339 and 
sg.datacode=bb.bisaccategorycode
and sg.datasubcode=bb.bisaccategorysubcode
order by bb.sortorder
FOR READ ONLY

OPEN cursor_subject

FETCH NEXT FROM cursor_subject
INTO @c_bisaccategorymajorcode, @c_bisaccategorymajordesc,
@c_bisaccategoryminorcode, @c_bisaccategoryminordesc

select @i_subjectcursorstatus = @@FETCH_STATUS
select @i_rownumber=0
if @i_subjectcursorstatus = -1 
begin
	exec eloonixvalidation_sp @i_warning, @i_bookkey, 'No BISAC Subject Categories'
end

while (@i_subjectcursorstatus<>-1 )
begin
	select @i_rownumber = @i_rownumber + 1
	IF (@i_subjectcursorstatus<>-2)
	begin
	

		if (@i_rownumber=1) /* This is the first record */
		begin	
			select @c_bisaccategorymajorcode1=@c_bisaccategorymajorcode
			select @c_bisaccategorymajordesc1=@c_bisaccategorymajordesc
			select @c_bisaccategoryminorcode1=@c_bisaccategoryminorcode
			select @c_bisaccategoryminordesc1=@c_bisaccategoryminordesc
				
		end /* First Row processing */


		if (@i_rownumber=2) /* This is the second record */
		begin	
			select @c_bisaccategorymajorcode2=@c_bisaccategorymajorcode
			select @c_bisaccategorymajordesc2=@c_bisaccategorymajordesc
			select @c_bisaccategoryminorcode2=@c_bisaccategoryminorcode
			select @c_bisaccategoryminordesc2=@c_bisaccategoryminordesc
				
		end /* Second Row processing */


		if (@i_rownumber=3) /* This is the third record */
		begin	
			select @c_bisaccategorymajorcode3=@c_bisaccategorymajorcode
			select @c_bisaccategorymajordesc3=@c_bisaccategorymajordesc
			select @c_bisaccategoryminorcode3=@c_bisaccategoryminorcode
			select @c_bisaccategoryminordesc3=@c_bisaccategoryminordesc
				
		end /* Third Row processing */


		if (@i_rownumber=4) /* This is the Fourth record */
		begin	
			select @c_bisaccategorymajorcode4=@c_bisaccategorymajorcode
			select @c_bisaccategorymajordesc4=@c_bisaccategorymajordesc
			select @c_bisaccategoryminorcode4=@c_bisaccategoryminorcode
			select @c_bisaccategoryminordesc4=@c_bisaccategoryminordesc
				
		end /* Fourth Row processing */


		if (@i_rownumber=5) /* This is the Fifth record */
		begin	
			select @c_bisaccategorymajorcode5=@c_bisaccategorymajorcode
			select @c_bisaccategorymajordesc5=@c_bisaccategorymajordesc
			select @c_bisaccategoryminorcode5=@c_bisaccategoryminorcode
			select @c_bisaccategoryminordesc5=@c_bisaccategoryminordesc
				
		end /* Fifth Row processing */
	end /* if subjectcursorstatus */
	
	FETCH NEXT FROM cursor_subject
	INTO @c_bisaccategorymajorcode, @c_bisaccategorymajordesc,
	@c_bisaccategoryminorcode, @c_bisaccategoryminordesc
      
	select @i_subjectcursorstatus = @@FETCH_STATUS
end /** End While loop **/

close cursor_subject
deallocate cursor_subject












/*****************************************/
/** Output series                       **/
/*****************************************/
/* 9/10/02 - CT - modifed to use alternatedesc1 for series title if this field is populated */

select @i_seriescode = seriescode from bookdetail where bookkey=@i_bookkey
if @i_seriescode is not null and @i_seriescode > 0
begin 
	/* first try for alternatedesc 1  (this allows > 40 characters ) */
	select @c_series = alternatedesc1 from gentables where tableid=327 
	and datacode=@i_seriescode
	if @c_series is NULL or @c_series = ' ' /* alternatedesc1 is blank, so use datadesc  */
	begin
		select @c_series=datadesc from gentables where tableid=327 
		and datacode=@i_seriescode

	end

end


/*****************************************/
/** Output Territories                  **/
/*****************************************/

select @i_territoriescode = territoriescode from book where bookkey=@i_bookkey
if @i_territoriescode is not null and @i_territoriescode > 0
begin
	select @c_territories=datadesc from gentables where tableid=131
	and datacode=@i_territoriescode
end


/*****************************************/
/** Output Edition                      **/
/*****************************************/

select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @c_edition=datadesc from gentables where tableid=200 
	and datacode=@i_editioncode

end

/**********************************************************************************/
/* Output  edition number (added - CT 1/03/03        */
/**********************************************************************************/

select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @d_editionnumber=Numericdesc1 from gentables where tableid=200 
	and datacode=@i_editioncode
	 end


/*****************************************/
/** OutputEditionStatement - using freeform field  added CT 1/3/03    **/
/*****************************************/

select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @c_editiondesc=datadesc from gentables where tableid=200 
	and datacode=@i_editioncode
 end


/***************************************/
/** Output Bisac Status 		  **/
/***************************************/



select @c_bisacstatuscode=g.bisacdatacode, @c_bisacstatusdesc=g.datadesc
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end



/*****************************************/
/** Output Carton Quantity              **/
/*****************************************/

select @i_cartonqty=cartonqty1 from bindingspecs where bookkey=@i_bookkey and printingkey=1



/*****************************************/
/** Output Insert/Illustration Notes    **/
/*****************************************/
select @c_insertillusdesc = actualinsertillus from printing where bookkey=@i_bookkey
and printingkey=1


/*****************************************/
/** Output Interest Ages              **/
/*****************************************/

select @i_agelow = agelow,  @i_agehigh=agehigh, @i_agelowupind=agelowupind,@i_agehighupind=agehighupind
from bookdetail
where bookkey=@i_bookkey

/** Age Low and Age Low Up indicator are mutually exclusive **/
if @i_agelow is not null and @i_agelow > 0 and @i_agelowupind = 1
begin
	select @i_agelowupind=0
end

/** Age High and Age High Up indicator are mutually exclusive **/
if @i_agehigh is not null and @i_agehigh > 0 and @i_agehighupind = 1
begin
	select @i_agehighupind=0
end


/*** Example:  'from 3 to 7' ***/
if @i_agelow is not null and @i_agelow > 0 and @i_agehigh is not null and @i_agehigh > 0
begin
	select @c_ages='From ' + convert (varchar(10),@i_agelow) + ' to ' + convert (varchar(10),@i_agehigh)
	select @c_agelow=convert (varchar(10),@i_agelow)
	select @c_agehigh=convert (varchar(10),@i_agehigh)
end

/*** Example:  'up to 7' ***/
if @i_agelowupind=1 and @i_agehigh is not null and @i_agehigh > 0
begin
	select @c_ages='Up to ' + convert (varchar(10),@i_agehigh)
	select @c_agelow='Up to '
	select @c_agehigh=convert (varchar(10),@i_agehigh)
end

/*** Example:  '3 upwards' ***/
if  @i_agelow is not null and @i_agelow > 0 and @i_agehighupind=1
begin
	select @c_ages = convert (varchar(10),@i_agelow) + ' upwards'
	select @c_agelow=convert (varchar(10),@i_agelow)
	select @c_agehigh='upwards'
end

/*** Example:  Age Low only - no upwards - '3' ***/
if @i_agehighupind=0 or @i_agehighupind is null 
	if @i_agelow is not null and @i_agelow > 0	
		if @i_agehigh is null or @i_agehigh=0
			begin
			select @c_ages= convert (varchar(10),@i_agelow)
			select @c_agelow=convert (varchar(10),@i_agelow)
			end
 

/***************************************************/
/** Output adultchildrensflag for Harcourt Only   **/
/** Set the to adult for 'Harcourt' or 'Harvest', all others set to childrens **/
/***************************************************/
if @i_publisherorgentrykey = 74725
begin
	if @c_imprintname = 'Harcourt' or @c_imprintname = 'Harvest Books'
		select @c_adultchildrensflag = 'adult'
	else
		select @c_adultchildrensflag = 'childrens'
end

/**********************************************************/
/**                                                      **/
/** Insert the row into the eloflatfeed table            **/
/**                                                      **/  
/**********************************************************/


insert into eloflatfeed
(
	bookkey ,
	isbn13 ,
	isbn10 ,	
	ean ,
	titleprefix ,
	titlewithoutprefix ,
	titlewithprefix ,
	subtitle ,
	publishername ,
	imprintname ,
	authorlastname1 ,
	authorfirstname1 ,
	authorsuffix1,
	authordisplayname1 ,
	authorprimaryflag1 ,
	authortype1 ,
	authorlastname2 ,
	authorfirstname2 ,
	authorsuffix2,
	authordisplayname2 ,
	authorprimaryflag2 ,
	authortype2 ,
	authorlastname3 ,
	authorfirstname3 ,
	authorsuffix3,
	authordisplayname3 ,
	authorprimaryflag3 ,
	authortype3 ,
	authorlastname4 ,
	authorfirstname4 ,
	authorsuffix4,
	authordisplayname4 ,
	authorprimaryflag4 ,
	authortype4  ,
	fullauthordisplayname ,
	usretailprice ,
	canadaretailprice ,
	ukretailprice ,
	mediatypedesc ,
	mediabisaccode ,
	formatdesc ,
	formatbisaccode ,
	pagecount,
	trimsizewidth ,
	trimsizelength ,
	pubdateYYYYMMDD  ,
	pubmonth ,
	bisaccategorymajorcode1  ,
	bisaccategorymajordesc1  ,	
	bisaccategoryminorcode1  ,
	bisaccategoryminordesc1  ,	
	bisaccategorymajorcode2  ,
	bisaccategorymajordesc2  ,
	bisaccategoryminorcode2  ,
	bisaccategoryminordesc2  ,	
	bisaccategorymajorcode3  ,
	bisaccategorymajordesc3  ,
	bisaccategoryminorcode3  ,
	bisaccategoryminordesc3  ,
	bisaccategorymajorcode4  ,
	bisaccategorymajordesc4  ,
	bisaccategoryminorcode4  ,
	bisaccategoryminordesc4  ,
	bisaccategorymajorcode5  ,
	bisaccategorymajordesc5  ,
	bisaccategoryminorcode5  ,
	bisaccategoryminordesc5  ,
	series  ,
	territories ,
	edition ,
	editionnumber,
	editiondesc,
	bisacstatuscode  ,
	bisacstatusdesc ,
	briefdescription ,
	description ,
	authorbio ,
	tableofcontents ,
	excerpt,
	cartonqty,
	insertillusdesc,
	ages,
	agelow,
	agehigh,
	adultchildrensflag,	
	discountcode,
	audiencecode1,
	audiencecode2

)
values
(
	@i_bookkey,
	@c_isbn13,
	@c_isbn10,
	@c_ean,
	@c_titleprefix,
	@c_titlewithoutprefix,
	@c_titlewithprefix,
	@c_subtitle,
	@c_publishername,
	@c_imprintname,
	@c_authorlastname1 ,
	@c_authorfirstname1 ,
	@c_authorsuffix1,
	@c_authordisplayname1 ,
	@c_authorprimaryflag1 ,
	@c_authortype1 ,
	@c_authorlastname2 ,
	@c_authorfirstname2 ,
	@c_authorsuffix2,
	@c_authordisplayname2 ,
	@c_authorprimaryflag2 ,
	@c_authortype2 ,
	@c_authorlastname3 ,
	@c_authorfirstname3 ,
	@c_authorsuffix3,
	@c_authordisplayname3 ,
	@c_authorprimaryflag3 ,
	@c_authortype3 ,
	@c_authorlastname4 ,
	@c_authorfirstname4 ,
	@c_authorsuffix4,
	@c_authordisplayname4 ,
	@c_authorprimaryflag4 ,
	@c_authortype4 ,
        @c_fullauthordisplayname,
	@d_usretailprice ,
	@d_canadaretailprice ,
	@d_ukretailprice ,
	@c_mediatypedesc ,
	@c_mediabisaccode ,
	@c_formatdesc ,
	@c_formatbisaccode ,
	@i_pagecount ,
	@c_trimsizewidth ,
	@c_trimsizelength ,
	@c_pubdateYYYYMMDD  ,
	@c_pubmonth ,
	@c_bisaccategorymajorcode1  ,
	@c_bisaccategorymajordesc1  ,	
	@c_bisaccategoryminorcode1  ,
	@c_bisaccategoryminordesc1  ,	
	@c_bisaccategorymajorcode2  ,
	@c_bisaccategorymajordesc2  ,
	@c_bisaccategoryminorcode2  ,
	@c_bisaccategoryminordesc2  ,	
	@c_bisaccategorymajorcode3  ,
	@c_bisaccategorymajordesc3  ,
	@c_bisaccategoryminorcode3  ,
	@c_bisaccategoryminordesc3  ,
	@c_bisaccategorymajorcode4  ,
	@c_bisaccategorymajordesc4  ,
	@c_bisaccategoryminorcode4  ,
	@c_bisaccategoryminordesc4  ,
	@c_bisaccategorymajorcode5  ,
	@c_bisaccategorymajordesc5  ,
	@c_bisaccategoryminorcode5  ,
	@c_bisaccategoryminordesc5  ,
        @c_series,
	@c_territories,
	@c_edition,
	@d_editionnumber,
	@c_editiondesc,
	@c_bisacstatuscode  ,
	@c_bisacstatusdesc ,
	@c_briefdescription,
	@c_description ,
	@c_authorbio ,
	@c_tableofcontents ,
	@c_excerpt,
	@i_cartonqty, 
	@c_insertillusdesc,
	@c_ages,
	@c_agelow,
	@c_agehigh,
	@c_adultchildrensflag,
	@c_discountcode,
	@c_audiencecode1,
	@c_audiencecode2
)


if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/

end



/*****************************************/
/** Output  Brief Description             **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='BD'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set briefdescription=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end

/*****************************************/
/** Output Description                  **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='D'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set description=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end

/*****************************************/
/** Output Author Bio                   **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='AI'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set authorbio=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Table of Contents            **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='TOC'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set tableofcontents=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Excerpt                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='EX'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set excerpt=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Keynote                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='KEY'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set keynote=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Subright Notes                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='SUBN'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set subrightnotes=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Subright Sales                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='SUBS'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set subrightsales=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Copyyear                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='CPYR'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set copyrightyear=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Catalog Quotes                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='CATQ'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set catalogquotes=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Quote 1                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='Q1'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set quote1=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Quote 2                     **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='Q2'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set quote2=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end


/*****************************************/
/** Output Quote 3                      **/
/*****************************************/


select @i_commenttypecode=datacode,@i_commenttypesubcode=datasubcode
from subgentables where tableid=284 and eloquencefieldtag='Q3'

if @i_commenttypecode<>0 and @i_commenttypecode is not null
begin
	update eloflatfeed 
	set quote3=commenttext
	from bookcomments bc 
	where eloflatfeed.bookkey=@i_bookkey 
	and eloflatfeed.bookkey=bc.bookkey 
	and bc.printingkey=1 
	and bc.commenttypecode=@i_commenttypecode 
	and bc.commenttypesubcode=@i_commenttypesubcode
end



if @i_validationerrorind = 1
begin
	rollback tran
end
else
begin
	commit tran
end

return 0




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

