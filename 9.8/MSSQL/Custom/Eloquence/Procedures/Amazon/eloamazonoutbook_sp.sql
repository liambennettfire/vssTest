if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloamazonoutbook_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloamazonoutbook_sp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


create proc dbo.eloamazonoutbook_sp @i_bookkey int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/


DECLARE @c_dummy varchar (25)
DECLARE @c_bisacmediacode varchar (100)
DECLARE @c_bisacformatcode varchar (100)
DECLARE @c_bisacformatdesc varchar (100)
DECLARE @c_onixformatcode varchar (100)
DECLARE @c_title varchar (255)
DECLARE @c_subtitle varchar (255)
DECLARE @c_titleprefix varchar (100)
DECLARE @i_authortypecode smallint
DECLARE @i_authorsortorder int
DECLARE @i_authorcursorstatus int
DECLARE @c_authordisplayname varchar (100)
DECLARE @c_authorlastname varchar (100)
DECLARE @c_authormiddlename varchar (100)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_onixauthortypecode varchar (10)
DECLARE @c_authortypedesc varchar (100)
DECLARE @i_maindesccount int
DECLARE @i_editioncode int
DECLARE @c_editiondesc varchar (100)
DECLARE @i_pagecount smallint
DECLARE @c_fullauthordisplayname varchar (255)
DECLARE @c_illus varchar (200)
DECLARE @c_bisacsubjectcode varchar (100)
DECLARE @i_subjectcursorstatus int
DECLARE @i_rownumber int
DECLARE @d_pubdate datetime
DECLARE @c_pubdate varchar(8)
DECLARE @i_returncode int
DECLARE @i_numcitations int
DECLARE @c_bisacstatuscode varchar(10)
DECLARE @i_discountcode int
DECLARE @c_discountdesc varchar (40)
DECLARE @c_onixstatuscode varchar(10)
DECLARE @d_usretail decimal (10,2)
DECLARE @d_estusretail decimal (10,2)
DECLARE @c_firstauthorname varchar(255)
DECLARE @c_authorname varchar(255)
DECLARE @c_authoroutput varchar(255)
DECLARE @c_photographeroutput varchar(255)
DECLARE @c_illustratoroutput varchar(255)
DECLARE @c_editoroutput varchar(255)
DECLARE @c_translatoroutput varchar(255)
DECLARE @c_postfix varchar (255)
DECLARE @i_error int
DECLARE @i_warning int

begin tran

select @i_error = 1
select @i_warning = 2






/*******************************************/
/* Output b004 ISBN - ISBN 10 (without hyphens) */
/*******************************************/

insert into eloamazonfeed (feedtext) select 'ISBN: ' + isbn10
	from isbn where bookkey= @i_bookkey and isbn10 is not null
	if @@rowcount<=0
	begin
		rollback tran
		exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'
		/*exec eloprocesserror_sp @i_bookkey,@@error,
		'ISBN10 Not Available in eloonixoutbook_sp'*/
		return -2  /** ISBN Not Available **/
	end
	if @@error <>0
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end		


/*****************************************/
/** Output b028 DistinctiveTitle - Title Prefix plus Title plus subtitle **/
/*****************************************/

select @c_titleprefix=titleprefix 
from bookdetail where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

select @c_title=title, @c_subtitle=subtitle from book where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*3/5/03 - CT - modified to add subtitle to tile string instead of printing with seperate tag */

if @c_titleprefix is not null and @c_titleprefix <> '' 
begin
	if @c_subtitle is not null and @c_subtitle <> ''
		insert into eloamazonfeed (feedtext) 
		select 'TITLE: ' + @c_titleprefix + ' ' + @c_title + ' : ' + @c_subtitle
	else
		insert into eloamazonfeed (feedtext) 
		select 'TITLE: ' + @c_titleprefix + ' ' + @c_title	

end
else
if @c_title is not null and @c_title <> ''
begin
	if @c_subtitle is not null and @c_subtitle <> ''
		insert into eloamazonfeed (feedtext) 
		select 'TITLE: ' + @c_title + ' : ' + @c_subtitle
	else
		insert into eloamazonfeed (feedtext) 
		select 'TITLE: ' + @c_title 
end
else /* modified 2/22/03 to discard record when no title present */
begin
		exec eloonixvalidation_sp @i_error, @i_bookkey,  'Title Missing'
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,
		'Title Not Available in eloonixoutbook_sp'*/
		return -2  /** No title**/
end



/*****************************************/
/** Output  Author Loop    **/
/*****************************************/
select @c_firstauthorname=''
select @c_authorname=''
select @c_authoroutput=''
select @c_photographeroutput=''
select @c_illustratoroutput=''
select @c_editoroutput=''
select @c_translatoroutput=''


DECLARE cursor_author INSENSITIVE CURSOR
FOR
select ba.authortypecode,ba.sortorder,a.displayname,a.lastname,a.firstname,a.middlename
 from bookauthor ba,author a
 where ba.bookkey=@i_bookkey and a.authorkey=ba.authorkey
 order by ba.sortorder
FOR READ ONLY

OPEN cursor_author

FETCH NEXT FROM cursor_author
INTO @i_authortypecode,@i_authorsortorder,
@c_authordisplayname,@c_authorlastname, @c_authorfirstname, @c_authormiddlename

select @i_authorcursorstatus = @@FETCH_STATUS

/* modified 2/22/03 to discard record when no author present */
/*if @c_authordisplayname is null and @c_authorlastname is null and @c_authorfirstname is null */
if @i_authorcursorstatus <1 /** No Authors **/
	select @c_dummy = ''
if @c_authordisplayname is not null and @c_authordisplayname <> ''
begin
	select @c_firstauthorname= @c_authordisplayname
end
else /* output last name instead */
begin
	select @c_firstauthorname=@c_authorlastname
end

while (@i_authorcursorstatus<>-1 )
begin
	IF (@i_authorcursorstatus<>-2)
	begin
	/* Changed 2/27/02 to build name from Last and First instead of Display Name */
	/* Modified 2/22/03 to Include middle name when present*/
	if @c_authorfirstname is not null and @c_authorfirstname <> ''
	begin
		if @c_authormiddlename is not null and @c_authormiddlename <> '' /* use middle name too */
		begin
			select @c_authorname= @c_authorlastname + ', ' + @c_authorfirstname + ' ' + @c_authormiddlename
		end
		else
		begin
			select @c_authorname= @c_authorlastname + ', ' + @c_authorfirstname 
		end
	end
	else /* output last name instead */
	begin
		select @c_authorname=@c_authorlastname
	end	


	/*****************************************/
	/** Determine Author Type		    **/
	/*****************************************/	
	if @i_authortypecode is not null and @i_authortypecode > 0 
	begin
		select @c_authortypedesc=datadesc from 
		gentables where tableid=134 and datacode=@i_authortypecode
		if upper (@c_authortypedesc) = 'AUTHOR'
		begin
			if @c_authoroutput = '' /* First Author in Record */
				select @c_authoroutput = @c_authorname
			else
				select @c_authoroutput = @c_authoroutput + '; ' 
				+ @c_authorname
		end
		else if upper (@c_authortypedesc) = 'PHOTOGRAPHER'
		begin								
				if @c_photographeroutput = '' /* First Photographer in Record */
				select @c_photographeroutput = @c_authorname
			else
				select @c_photographeroutput = @c_photographeroutput + '; ' 
				+ @c_authorname
		end
		else if upper (@c_authortypedesc) = 'ILLUSTRATOR'
		begin								
				if @c_illustratoroutput = '' /* First Illustrator in Record */
				select @c_illustratoroutput = @c_authorname
			else
				select @c_illustratoroutput = @c_illustratoroutput + '; ' 
				+ @c_authorname
		end
		else if upper (@c_authortypedesc) = 'EDITOR'
		begin								
				if @c_editoroutput = '' /* First Editor in Record */
				select @c_editoroutput = @c_authorname
			else
				select @c_editoroutput = @c_editoroutput + '; ' 
				+ @c_authorname
		end
		else if upper (@c_authortypedesc) = 'TRANSLATOR'
		begin								
				if @c_translatoroutput = '' /* First translator in Record */
				select @c_translatoroutput = @c_authorname
			else
				select @c_translatoroutput = @c_translatoroutput + '; ' 
				+ @c_authorname
		end /* else if TRANSLATOR */
		
	end /* If Authortypecode is not null */	
		
		
		

	end /* if authorcursorstatus */
	
	FETCH NEXT FROM cursor_author
	INTO @i_authortypecode,@i_authorsortorder,
	@c_authordisplayname,@c_authorlastname,@c_authorfirstname, @c_authormiddlename
      
	select @i_authorcursorstatus = @@FETCH_STATUS
end

if @c_authoroutput <> '' and @c_authoroutput is not NULL
	insert into eloamazonfeed (feedtext) 
 	select 'AUTHOR: ' + @c_authoroutput
	 
if @c_photographeroutput <> ''  and @c_photographeroutput is not NULL
	insert into eloamazonfeed (feedtext) 
 	select 'PHOTOGRAPHER: ' + @c_photographeroutput

if @c_illustratoroutput <> '' and @c_illustratoroutput is not NULL
	insert into eloamazonfeed (feedtext) 
 	select 'ILLUSTRATOR: ' + @c_illustratoroutput
		
if @c_editoroutput <> ''  and @c_editoroutput is not NULL
	insert into eloamazonfeed (feedtext) 
 	select 'EDITOR: ' + @c_editoroutput
		
if @c_translatoroutput <> ''  and @c_translatoroutput is not NULL
	insert into eloamazonfeed (feedtext) 
 	select 'TRANSLATOR: ' + @c_translatoroutput

/** If all entries do not fall into the above author types, then
at least output the first author as 'AUTHOR' so that the record doesn't fail **/

if @c_authoroutput = '' and 	@c_photographeroutput = '' and @c_illustratoroutput = ''
and   @c_editoroutput = '' and @c_translatoroutput = ''
begin
	if @c_firstauthorname <> '' and @c_firstauthorname is not NULL
		insert into eloamazonfeed (feedtext) 
 		select 'AUTHOR: ' + @c_firstauthorname
	else
	begin
		exec eloonixvalidation_sp @i_error, @i_bookkey, 'Author missing'

		rollback tran
		close cursor_author
		deallocate cursor_author
		/*exec eloprocesserror_sp @i_bookkey,@@error,
		'No Author*/
		return -2  /** No Author**/
	end

end
 	
close cursor_author
deallocate cursor_author


/*******************************************/
/* BISAC Subject Categories   */
/** Amazon accepts only one subject code, but the loop */
/*  has been left inplace in case they expand this */
/**************************************************/


DECLARE cursor_subject INSENSITIVE CURSOR
FOR
select sg.bisacdatacode 
from bookbisaccategory bb, subgentables sg
where bb.bookkey=@i_bookkey and bb.printingkey=1 and sg.tableid = 339 and 
sg.datacode=bb.bisaccategorycode
and sg.datasubcode=bb.bisaccategorysubcode
order by bb.sortorder
FOR READ ONLY

OPEN cursor_subject

FETCH NEXT FROM cursor_subject
INTO @c_bisacsubjectcode

select @i_subjectcursorstatus = @@FETCH_STATUS
select @i_rownumber=0

while (@i_subjectcursorstatus<>-1 )
begin
	select @i_rownumber = @i_rownumber + 1
	IF (@i_subjectcursorstatus<>-2)
	begin
	

	if (@i_rownumber=1) /* This is the first record-output main record */
	begin

	/*******************************************/
	/* Output <b064> BASICMainSubject -   */
	/**************************************************/
		insert into eloamazonfeed (feedtext) 
			select 'SUBJECT: ' + @c_bisacsubjectcode
	end

	end /* if subjectcursorstatus */
	
	FETCH NEXT FROM cursor_subject
	INTO @c_bisacsubjectcode
      
	select @i_subjectcursorstatus = @@FETCH_STATUS
end

close cursor_subject
deallocate cursor_subject


/*****************************************/
/** Output EDITION - using freeform field      **/
/*****************************************/

select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @c_editiondesc=datadesc from gentables where tableid=200 
	and datacode=@i_editioncode

	insert into eloamazonfeed (feedtext) 
	select 'EDITION: ' + @c_editiondesc
 end

/*****************************************/
/** Output PAGES:              **/
/*****************************************/
select @i_pagecount = pagecount from printing where bookkey=@i_bookkey
and printingkey=1

if @i_pagecount is not null and @i_pagecount > 0
begin
	
	insert into eloamazonfeed (feedtext) 
	select 'PAGES: ' + convert (varchar(10),@i_pagecount)
 end

/* 8/27/02 - CT - Modified code to return to outputting 
Publisher as Publisher and Imprint as Imprint instead of outputting Imprint as Publisher */

/*****************************************/
/** Output PUBLISHER NAME     **/
/*****************************************/

insert into eloamazonfeed (feedtext)
select 'PUBLISHER: ' + oe.orgentrydesc
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey

/* 8/27/02 - CT - Modified code to return to outputting 
Publisher as Publisher and Imprint as Imprint instead of outputting Imprint as Publisher */

/*****************************************/
/** Output Imprint Name **/
/*****************************************/

insert into eloamazonfeed (feedtext)
select 'IMPRINT: ' + oe.orgentrydesc
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey


/*******************************************/
/* Output BINDING  */
/**************************************************/

select @c_bisacmediacode=g.bisacdatacode,@c_bisacformatcode = sg.bisacdatacode,
@c_bisacformatdesc=sg.datadesc
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

/*** FIX BELOW Incorrect syntax near 'End Probably no statements in block'
if @@rowcount<=0
	begin
		
		exec eloprocesserror_sp @i_bookkey,@@error, 'WARNING'
		'Media TypeFormat missing in eloonixoutbook_sp. Setting to Book Unspecified'
		
	end
FIX ABOVE***/

/**  Convert Bisac Media Types to ONIX Product Types **/
if @c_bisacmediacode='A' /* Audio Media Type */
begin
	select @c_onixformatcode = 
	case @c_bisacformatcode
	when 'AA' then 'AC'
	when 'CD' then 'AD'
	else ''
	end
end


else if @c_bisacmediacode='B' /* Book Media Type */
begin
	select @c_onixformatcode =
	case @c_bisacformatcode
	when 'TC' then 'HC'
	when 'TP' then 'TP'
	when 'SP' then 'SP'
	when 'MM' then 'MM'
	else  ' '
	end
end
if @c_onixformatcode=' ' /* default to Format Description */
	begin
	select @c_onixformatcode=@c_bisacformatdesc 
	end

if @c_onixformatcode <> '' and @c_onixformatcode is not null
	insert into eloamazonfeed (feedtext) select 'BINDING: ' + @c_onixformatcode
else
begin
	/* modified 2/22/03 to discard record when no binding present */
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Binding missing'

	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,
	'Binding type Not Available in eloonixoutbook_sp'*/
	return -2  /** Binding Not Available **/
end



/***************************************/
/** Output LISTPRICE - for US Retail **/
/***************************************/

/** Modified 10/8/2002 by DSL to output Estimate price if Final not available **/

select @d_usretail=0
select @d_estusretail=0

select 
@d_usretail=convert (decimal (10,2),finalprice),
@d_estusretail=convert (decimal (10,2),budgetprice)  
from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=6

if @d_usretail=0 or @d_usretail is null  /* Final price not found, use budget */
begin
	if @d_estusretail > 0 and @d_estusretail is not null
	begin
		select @d_usretail=@d_estusretail
	end
end

if @d_usretail=0 or @d_usretail is null /* Retail Price Not Found - Try for Suggested List Price */
begin
	select @d_usretail=convert (decimal (10,2),finalprice),
	@d_estusretail=convert (decimal (10,2),budgetprice)  
	from bookprice
	where bookkey=@i_bookkey and pricetypecode=11
	and currencytypecode=6

	if @d_usretail=0 or @d_usretail is null  /* Final price not found, use budget */
	begin
		if @d_estusretail > 0 and @d_estusretail is not null
		begin
			select @d_usretail=@d_estusretail
		end
	end
end



if @d_usretail>0
begin

	insert into eloamazonfeed (feedtext) select 'LISTPRICE: ' + 
		convert (varchar (10),@d_usretail)

end
else
begin
	/* modified 2/22/03 to discard record when no price present */
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Price missing'
 
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,
	'Price Not Available in eloonixoutbook_sp'*/
	return -2  /** Price Not Available **/
end


/*****************************************************************/
/** Output Discount Code - added 01/02/03 by CT                 **/
/*****************************************************************/
select @i_discountcode = 0;
select @i_discountcode=discountcode 
from bookdetail where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @i_discountcode is NOT NULL and @i_discountcode <> 0
begin
	select @c_discountdesc=datadesc from gentables where tableid=459 
	and datacode=@i_discountcode

	insert into eloamazonfeed (feedtext) 
	select 'DISCOUNTCODE: ' + @c_discountdesc 

end


/*****************************************/
/** Output PUBDATE		         **/
/*****************************************/
select @d_pubdate=NULL
select @c_bisacstatuscode = ' '

select @c_bisacstatuscode=g.bisacdatacode
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode

if @c_bisacstatuscode NOT in ('PP','NL','PC') /* get pubdate */
	Begin
		select @d_pubdate = activedate from bookdates 
		where bookkey=@i_bookkey and datetypecode=8
	End
/*** Commented Out - FIX BELOW Incorrect syntax near 'End Probably no statements in block'
if @@rowcount<=0
	begin
		
		exec eloprocesserror_sp @i_bookkey,@@error, 'WARNING',
		'Pub Date missing in eloonixoutbook_sp.'
		
	end
FIX ABOVE***/
if @d_pubdate is NOT NULL
begin
	/* Call the Date conversion function, 
	then retrieve the resuling date from eloconverteddate */
	exec eloformatdateYYYYMMDD_sp @d_pubdate
	select @c_pubdate=converteddate from eloconverteddate
	
	insert into eloamazonfeed (feedtext)
	select 'PUBDATE: ' + @c_pubdate
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
			select @c_pubdate=converteddate from eloconverteddate
	
			insert into eloamazonfeed (feedtext)
			select 'PUBDATE: ' + @c_pubdate

		end
		else 
		/*** Actual or Estimated Pub Date does not exist, Try Pub Month/Year from Printing. Pub Month/Year is set in Java Import
	    	to Pub Month + Pub Year, with day set to '01'. i.e. 03/01/2001 ***/
		/** Ignore Pub Month/Year = 01/01/1900 which is a default date */
		begin
			select @d_pubdate=pubmonth from printing
      			where bookkey=@i_bookkey and printingkey=1 
			if @d_pubdate is NOT NULL and @d_pubdate > '01/01/1900'
			begin
				/* Call the Date conversion function, 
				then retrieve the resuling date from eloconverteddate */
				exec eloformatdateYYYYMMDD_sp @d_pubdate
				select @c_pubdate=converteddate from eloconverteddate
	
				insert into eloamazonfeed (feedtext)
				select 'PUBDATE: ' + @c_pubdate

			end
			else /** No Possibility for pub date exists - send Validation error **/
			begin
				exec eloonixvalidation_sp @i_error, @i_bookkey, 'Pubdate missing'

				rollback tran
				return -2	
			end

		end /** check printing **/
	end /** End Else Check Est Pub DatePub Year **/


/*****************************************/
/** Output Main Description             **/
/*****************************************/

/** 10/26/02 - commented out this section  - no longer want to do append illus to description*/
/*If Insert Illus is not null, append to description **/

/************   
select @c_illus = actualinsertillus from printing where bookkey=@i_bookkey
and printingkey=1

if @c_illus is not null and @c_illus <> ''
begin
	select @c_postfix='  ' + @c_illus
end
else
begin
	select @c_postfix=''
end 
***********************/
select @c_postfix=''
/* 09/25/02 - CT - use brief description is description is not available */

select @i_maindesccount=count(*)
	from bookcomments where bookkey = @i_bookkey 
	and commenttypecode = 3 and commenttypesubcode = 8

if @i_maindesccount <> 0 /* main description */
begin
	exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'D','DESCRIPTION: ',@c_postfix
end

if @i_maindesccount = 0 /* else use brief description */
begin
	exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'BD','DESCRIPTION: ',@c_postfix
end

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
/*****************************************/
/** Output Reader Guide Discussion Notes  */
/*****************************************/
exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'RG','DISCUSSIONQUES: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
/*****************************************/
/** Output Reader Guide Source*/
/*****************************************/
exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'RS','RGGSOURCE: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/*****************************************/
/** Output AUTHORBIO             **/
/*****************************************/

exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'AI','AUTHORBIO: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*****************************************/
/** Output TOC*/
/*****************************************/
exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'TOC','TOC: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end



/*****************************************/
/** Output Excerpts             **/
/*****************************************/

exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'EX','EXCERPTS: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*****************************************/
/** Output Back Panel Copy             **/
/*****************************************/

exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'BPC','BACKCOVER: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
/*****************************************/
/** Output Inside Flap             **/
/*****************************************/

exec @i_returncode = eloamazonoutputcomment_sp @i_bookkey,'FC','INSIDEFLAP: ',''

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/*****************************************/
/** Output citations           	  **/
/*****************************************/

select @i_numcitations = count(*)
 from citation
 where bookkey=@i_bookkey 

if @i_numcitations > 0 
	begin
		exec @i_returncode = eloamazoncitations_sp @i_bookkey

		if @i_returncode=-1
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
	end


/***************************************/
/** Output END  **/
/***************************************/
insert into eloamazonfeed (feedtext) select 'END'


commit tran

return 0





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

