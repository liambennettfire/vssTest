if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixoutbook_sp_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixoutbook_sp_v2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE      proc [dbo].[eloonixoutbook_sp_v2] @i_bookkey int, @i_onixlevel int, @i_websitekey int
as
/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

i_onixlevel can equal 1 for generic onix (Level 1), 2 fodr Onix Level 2, 3 for QSI WEB Site Onix 
**/


DECLARE @c_dummy varchar (25)
DECLARE @c_bisacmediacode varchar (25)
DECLARE @c_bisacformatcode varchar (25)
DECLARE @c_onixformatcode varchar (25)
DECLARE @c_onixformatdesc varchar (100)
DECLARE @c_formatdesc varchar (40)
DECLARE @c_alternatedesc2 varchar (255)
DECLARE @c_externalformatdesc varchar (100)
DECLARE @c_title varchar (255)
DECLARE @c_subtitle varchar (255)
DECLARE @c_titleprefix varchar (100)
DECLARE @i_authortypecode smallint
DECLARE @i_authorsortorder int
DECLARE @i_authorcursorstatus int
DECLARE @c_authordisplayname varchar (100)
DECLARE @c_authorlastname varchar (100)
DECLARE @c_authorfirstname varchar (100)
DECLARE @c_onixauthortypecode varchar (10)
DECLARE @c_authortypedesc varchar (100)
DECLARE @i_editioncode int
DECLARE @c_editiondesc varchar (100)
DECLARE @i_seriescode int
DECLARE @c_seriesdesc varchar (100)
DECLARE @i_pagecount smallint
DECLARE @c_fullauthordisplayname varchar (255)
DECLARE @c_illus varchar (200)
DECLARE @c_bisacsubjectcode varchar (100)
DECLARE @i_subjectcursorstatus int
DECLARE @i_rownumber int
DECLARE @d_pubdate datetime
DECLARE @c_pubdate varchar(8)
DECLARE @i_returncode int
DECLARE @i_rowcount int
DECLARE @c_bisacstatuscode varchar(10)
DECLARE @c_notificationbisacstatuscode varchar(10)
DECLARE @c_onixstatuscode varchar(10)
DECLARE @d_usretail decimal (10,2)
DECLARE @c_postfix varchar(255)
DECLARE @i_agelow int
DECLARE @i_agelowupind int
DECLARE @i_agehigh int
DECLARE @i_agehighupind int
DECLARE @c_ean varchar (20)
DECLARE @c_trimsizewidth varchar (20)
DECLARE @c_trimsizelength varchar (20)
DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_validationerrorind int
DECLARE @c_onixlanguagecode varchar (25)
DECLARE @c_elolanguagecode varchar (25)
DECLARE @c_tempmessage varchar (255)
DECLARE @c_territory varchar (40)
DECLARE @c_webweighttag varchar (50)
DECLARE @i_webweightcode int 
DECLARE @c_internalstat varchar (50)
DECLARE @d_canadaprice decimal (10,2)  /*3-2-04 added*/ 
DECLARE @i_cartonqty int
DECLARE @i_filetypecode int
DECLARE @c_filetypedesc varchar(40)
DECLARE @c_filenotes varchar(8000)
DECLARE @c_filepathname varchar(255)
DECLARE @i_weblinkscursorstatus int
DECLARE @i_webhotind int
DECLARE @i_globalcontactkey int
DECLARE @i_contributorkey int
DECLARE @i_craftsourcecursorstatus int
DECLARE @i_craftrole int
DECLARE @i_googlesrchind int
DECLARE @d_boundbookdate datetime
DECLARE @c_boundbookdate varchar(8)
DECLARE @d_whdate datetime
DECLARE @c_whdate varchar(8)
DECLARE @d_lastchangedate datetime
DECLARE @c_lastchangedate varchar(8)
DECLARE @i_announcedfirstprint int
DECLARE @v_mediatypecode int
DECLARE @v_datacode int
DECLARE @v_count int
DECLARE @v_ebook_bookkey int
DECLARE @c_PrimaryEAN varchar (20)
DECLARE @v_ebook_ean varchar(20)
DECLARE @v_ebook_usretail decimal(10,2)
DECLARE @v_ebook_mediatypecode int
DECLARE @i_newtitleheading int
DECLARE @c_newtitleheading varchar(40)


/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 2

begin tran

/** Initialize the Validation Error to zero (False) **/
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/
/** for this bookkey.  Processing will continue to the next bookkey **/

select @i_validationerrorind = 0

/*******************************************/
/* Output the beginning Product tag for this book */
/*******************************************/
insert into eloonixfeed (feedtext) select '<product>'

/*******************************************/
/* Output RecordReference - unique product number - we will use bookkey */
/*******************************************/

insert into eloonixfeed (feedtext) 
	select '<a001>' + convert (varchar (25),@i_bookkey) + '</a001>'

/*******************************************/
/* Output NotificationType - set to '03' for confirmed book */
/*******************************************/


select @c_notificationbisacstatuscode=''

select @c_notificationbisacstatuscode=g.bisacdatacode
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode
if @@error <>0
begin

	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_notificationbisacstatuscode = 'NYP' /** Notification Type = 02 for 'Not Yet Published **/
begin

	insert into eloonixfeed (feedtext) select '<a002>02</a002>'
end
else /** Notification Type = 03 for all other status **/
begin
	insert into eloonixfeed (feedtext) select '<a002>03</a002>'
end

/*******************************************/
/* Output b004 ISBN - ISBN 10 (without hyphens) */
/*******************************************/

insert into eloonixfeed (feedtext) select '<isbnnodashes>' + isbn10 + '</isbnnodashes>'
	from isbn where bookkey= @i_bookkey and isbn10 is not null
	if @@rowcount<=0
	begin
		select @i_validationerrorind = 1
		/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'*/
	end
	if @@error <>0
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end

/*******************************************/
/* Output  ISBN13 - ISBN with hyphens      */
/*******************************************/

insert into eloonixfeed (feedtext) select '<isbn>' + isbn + '</isbn>'
	from isbn where bookkey= @i_bookkey and isbn10 is not null
	if @@rowcount<=0
	begin
		select @i_validationerrorind = 1
		/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'*/
	end
	if @@error <>0
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end
/*******************************************/
/* Output <ean13> EAN - EAN13 */
/*******************************************/

select @c_ean=ean 
from isbn where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_ean is not null and @c_ean <> ''
begin

  	insert into eloonixfeed (feedtext) select '<ean13>' + replace (@c_ean,'-','') + '</ean13>'
	

end		


/*******************************************/
/* Output <b012> ProductForm - Media/Format as an EPICS code.  */
/**************************************************/

/*  Initialize the description field . It will be used in cases where the format is */
/* not supported by Onix i.e. Calender */
select @c_onixformatdesc = '' 

/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/
 

select @c_bisacmediacode=g.bisacdatacode,@c_bisacformatcode = sg.bisacdatacode,
@c_formatdesc = sg.datadesc, @c_externalformatdesc = sg.externalcode, @c_alternatedesc2 = sg.alternatedesc2
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



/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/

/**  Convert Bisac Media Types to ONIX Product Types **/
if @c_bisacmediacode='A' /* Audio Media Type */
begin
	select @c_onixformatcode = 
	case @c_bisacformatcode
	when 'AA' then 'AB'
	when 'CD' then 'AC'
	when 'DA' then 'AD'
	when 'OO' then 'AA'
	when 'TA' then 'AF'
	else 'AF'
	end
end


else if @c_bisacmediacode='B' /* Book Media Type */
begin
	select @c_onixformatcode =
	case @c_bisacformatcode
	when 'TC' then 'BB'
	when 'TP' then 'BC'
	when 'SP' then 'BE'
	when 'WC' then 'BE'
	when 'OT' then 'BC'
	when 'BD' then 'BH'
	when 'MM' then 'BC'
	else  'BA'
	end
end
else if @c_bisacmediacode='R' /* CD Rom Media Type */
begin
	select @c_onixformatcode = 'DB' /* DB=Onix CD-ROM designation */
end
else if @c_bisacmediacode='C' /* Calender Media Type */
begin

	select @c_onixformatdesc = 'Calender' /* set the description to be output for unspecified */
end

else if @c_bisacmediacode='D' /* Diskette */
begin
	select @c_onixformatcode = 'DF' /* DF=Onix Diskette designation */
end

else if @c_bisacmediacode='F' /* Film */
begin
	select @c_onixformatcode = 'FB' /* FB=Onix Film designation */
end
else if @c_bisacmediacode='J' /* Journal */
begin
	select @c_onixformatcode = 'BC' /* BC=Onix Paperback designation */
end
else if @c_bisacmediacode='K' /* Maps */
begin
	select @c_onixformatcode =
	case @c_bisacformatcode
	when 'FF' then 'CB'  /* Folded */
	when 'GG' then 'CE'  /* Globe */
	when 'NF' then 'CD'  /* Rolled */
	else  'CZ' /* other */
	end
end
else if @c_bisacmediacode='M' /* Microform */
begin
	select @c_onixformatcode =
	case @c_bisacformatcode
	when 'FI' then 'MB'  /* Microfiche */
	when 'MF' then 'MC'  /* Microfilm */
	else  'MZ' /* other */
	end
end
else if @c_bisacmediacode='N' /* Books and Things */
begin
	/** Set the Onix Format Code to Mixed Media 'WW' **/

	select @c_onixformatcode = 'WW'
	/** Then set the Format Desc to the description **/

	select @c_onixformatdesc =
	case @c_bisacformatcode
	when 'DL' then 'Book and Doll'  
	when 'MU' then 'Book and Music'
	when 'OO' then 'Book and Other'
	when 'PL' then 'Book and Plush Toy'
	when 'TY' then 'Book and Toy'
	else  'Book and Other' /* other */
	end
end
else if @c_bisacmediacode='V' /* Video */
begin
	select @c_onixformatcode = 'FB' /* FB=Onix Film designation */
end


else 
begin
select @c_onixformatcode='00'  /* Set all other types to 'Undefined'*/
end

/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/

insert into eloonixfeed (feedtext) select '<b012>' + @c_onixformatcode + '</b012>'

if @c_onixformatdesc <> ''
begin
	/** b014 ProductFormDescription **/
	insert into eloonixfeed (feedtext) select '<b014>' + @c_onixformatdesc + '</b014>'
end

/** PM 5/9/06 CRM 3881 Output Format Alternate Description 2 **/




if @c_alternatedesc2 <> '' and @c_alternatedesc2 is not null
begin
	/** formatdesc **/
	insert into eloonixfeed (feedtext) select '<formatdesc><![CDATA[' + @c_alternatedesc2 + ']]></formatdesc>'
end
else if @c_formatdesc <> '' and @c_formatdesc is not null
begin
	/** formatdesc **/
	insert into eloonixfeed (feedtext) select '<formatdesc><![CDATA[' + @c_formatdesc + ']]></formatdesc>'
end


/*****************************************/
/** Output series composite            **/
/*****************************************/

select @i_seriescode = seriescode from bookdetail where bookkey=@i_bookkey
if @i_seriescode is not null and @i_seriescode > 0
begin
	begin
	select @c_seriesdesc=datadesc from gentables where tableid=327 
	and datacode=@i_seriescode
	end

	exec convert_char_to_unicode_column @c_seriesdesc output

	insert into eloonixfeed (feedtext) 
	select '<series>'

      /** b018 TitleOfSeries ***/
	insert into eloonixfeed (feedtext) 
	select '<b018><![CDATA[' + @c_seriesdesc + ']]></b018>'

	insert into eloonixfeed (feedtext) 
	select '</series>'

end
/*****************************************/
/** Output b028 DistinctiveTitle - Title Prefix plus Title **/
/** To be used only if NOT using b030 (TitlePrefix) and b031 (Title without Prefix) **/
/** USE ONLY WHEN TITLEPREFIX IS NULL - For QSI Web Site ALWAYS output b028  **/
/*****************************************/

select @c_titleprefix=titleprefix 
from bookdetail where bookkey=@i_bookkey
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

select @c_title=title from book where bookkey=@i_bookkey
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

exec convert_char_to_unicode_column @c_title output

if @i_onixlevel = 3
begin
	/** Always outout b028 'Title' for the QSI WEB Site procedure **/
	if @c_titleprefix is null or @c_titleprefix = ''  /*10-10-02 output prefix if present on b028**/
	  begin
		insert into eloonixfeed (feedtext) 
		select '<b028><![CDATA[' + @c_title + ']]></b028>'
	  end
	else
	  begin
		insert into eloonixfeed (feedtext) 
		select '<b028><![CDATA[' + @c_titleprefix + ' ' + @c_title + ']]></b028>'
	  end
end
else if @c_titleprefix is null or @c_titleprefix = '' 
begin
	/** Only output b028 for Onix if Title Prefix is not available **/
	/** If Title Prefix is populated, outout b030 and b031 **/
	insert into eloonixfeed (feedtext) 
	select '<b028><![CDATA[' + @c_title + ']]></b028>'
	
end


/**** OLD CODE - CHANGED BY DSL 3/26/01 - Do not output b028 at all if title prefix exists
if @c_titleprefix is not null and @c_titleprefix <> ''
begin
insert into eloonixfeed (feedtext) 
	select '<b028><![CDATA[' + @c_titleprefix + ' ' + @c_title + ']]></b028>'
	
end
else
begin
insert into eloonixfeed (feedtext) 
	select '<b028><![CDATA[' + @c_title + ']]></b028>'
end
*****/




/*****************************************/
/** Output b030 Title Prefix **/
/*****************************************/

/** c_titleprefix loaded in b028 **/
if @c_titleprefix is not null and @c_titleprefix <> ''
begin
	
      if @i_onixlevel = 2 or @i_onixlevel = 3  
		insert into eloonixfeed (feedtext) 
      	select '<b030><![CDATA[' + @c_titleprefix +  ']]></b030>'
	

end

/*****************************************/
/** Output b031 Title Without Prefix **/
/*****************************************/

/** c_title loaded in b028 - only output of titleprefix is not null**/
/** 10/10/02  output always 
if @c_titleprefix is not null and @c_titleprefix <> ''
begin  **/
	if @i_onixlevel = 2 or @i_onixlevel = 3
 	  begin
		insert into eloonixfeed (feedtext) 
		select '<b031><![CDATA[' + @c_title + ']]></b031>'
	  end

/*****************************************/
/** Output b029 Subtitle **/
/*****************************************/
select @c_subtitle = '<b029><![CDATA[' + subtitle + ']]></b029>' 
      from book where bookkey=@i_bookkey
      and subtitle is not null and subtitle <> ''
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

exec convert_char_to_unicode_column @c_subtitle output

insert into eloonixfeed (feedtext) 
values(@c_subtitle)
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*****************************************/
/** Output <Contributor> Author Loop    **/
/*****************************************/



DECLARE cursor_author INSENSITIVE CURSOR
FOR
select ba.authortypecode,ba.sortorder,a.displayname,a.lastname, a.firstname
 from bookauthor ba,author a
 where ba.bookkey=@i_bookkey and a.authorkey=ba.authorkey
 order by ba.sortorder
FOR READ ONLY

OPEN cursor_author

FETCH NEXT FROM cursor_author
INTO @i_authortypecode,@i_authorsortorder,
@c_authordisplayname,@c_authorlastname,@c_authorfirstname

exec convert_char_to_unicode_column @c_authordisplayname output
exec convert_char_to_unicode_column @c_authorlastname output
exec convert_char_to_unicode_column @c_authorfirstname output

select @i_authorcursorstatus = @@FETCH_STATUS

if @i_authorcursorstatus < 0 /** No Authors **/
begin
	select @c_dummy=''
	select @i_validationerrorind = 1
	/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'Author missing'*/
end

while (@i_authorcursorstatus<>-1 )
begin
	IF (@i_authorcursorstatus<>-2)
	begin
	
	/*****************************************/
	/** Output <Contributor> Author Loop    **/
	/*****************************************/
	insert into eloonixfeed (feedtext) select '<contributor>' 
	
	/*****************************************/
	/** Output b034 ContributorSequenceNumber Sortorder **/
	/*****************************************/
	if @i_authorsortorder is not null and @i_authorsortorder > 0
	begin
		insert into eloonixfeed (feedtext) 
		select '<b034>' + 
		convert (varchar (10),@i_authorsortorder) + '</b034>'
	end


	/*****************************************/
	/** Output b035 ContributorRole - Author Type		    **/
	/*****************************************/	
	if @i_authortypecode is not null and @i_authortypecode > 0 
	begin
		select @c_authortypedesc=datadesc from 
		gentables where tableid=134 and datacode=@i_authortypecode

		select @c_onixauthortypecode = 
		case upper (@c_authortypedesc)
		when 'ABRIDGED BY' then 'B04'                              
		when 'ADAPTED BY' then 'B05'                               
		when 'AFTERWARD BY' then 'A19'                             
		when 'ANNOTATIONS BY' then 'A20'                           
		when 'AS TOLD BY' then 'B07'                               
		when 'AS TOLD TO' then 'A01'                               
		when 'AUTHOR' then 'A01'                                   
		when 'AUTHOR/CONTRIBUTOR NOT APPLICABLE' then 'Z99'        
		when 'COMMENTARIES BY' then 'A21'                          
		when 'COMPILED BY' then 'C01'                              
		when 'CONCEPT BY' then 'A10'                               
		when 'CONTRIBUTION BY' then 'A01'                          
		when 'CREATED BY' then 'A09'                               
		when 'DESIGNED BY' then 'A11'                              
		when 'EDITOR' then 'B01'                                   
		when 'EPILOGUE BY' then 'A22'                              
		when 'EXPERIMENTS BY' then 'A27'                          
		when 'FOOTNOTES BY' then 'A25'                             
		when 'FOREWORD BY' then 'A23'                              
		when 'ILLUSTRATOR' then 'A12'                              
		when 'INTRODUCTION BY' then 'A24'                          
		when 'MEMOIR BY' then 'A26'                                
		when 'NARRATED BY' then 'E03'                              
		when 'NOTED BY' then 'A20'                                 
		when 'OTHER' then 'Z99'                                    
		when 'PHOTOGRAPHER' then 'A13'                             
		when 'PREFACE BY' then 'A15'                               
		when 'PRODUCED BY' then 'D01'                              
		when 'PROLOGUE BY' then 'A16'                              
		when 'READ BY' then 'E07'                                  
		when 'RETOLD BY' then 'B03'                                
		when 'REVISED BY' then 'B02'                               
		when 'SELECTED BY' then 'C02'                              
		when 'SUMMARY BY' then 'A17'                               
		when 'SUPPLEMENT BY' then 'A18'                            
		when 'TEXT BY' then 'A14'                                  
		when 'TRANSLATOR' then 'B06'
		else 	'A01'                               
		end /*end case */

		insert into eloonixfeed (feedtext) 
		select '<b035>' + @c_onixauthortypecode + '</b035>'
		end /*if authortypecode */

		/*****************************************/
		/** Output b037 PersonNameInverted - Author Name		    **/
		/** MODIFIED 4/9/01 by DSL - build inverted name rather than use DisplayName **/
		/*****************************************/ 
		if @c_authorfirstname is not null and @c_authorfirstname <> ''
		begin
			insert into eloonixfeed (feedtext) 
			select '<b037><![CDATA[' + @c_authorlastname + ', ' + @c_authorfirstname + ']]></b037>'
		end
		else /* output last name instead */
		begin
			insert into eloonixfeed (feedtext) 
			select '<b037><![CDATA[' + @c_authorlastname + ']]></b037>'
		end
		/*****************************************/
		/** End of <Contributor> Author Loop    **/
		/*****************************************/
		insert into eloonixfeed (feedtext) select '</contributor>' 
	end /* if authorcursorstatus */
	
	FETCH NEXT FROM cursor_author
	INTO @i_authortypecode,@i_authorsortorder,
	@c_authordisplayname,@c_authorlastname, @c_authorfirstname

	exec convert_char_to_unicode_column @c_authordisplayname output
	exec convert_char_to_unicode_column @c_authorlastname output
	exec convert_char_to_unicode_column @c_authorfirstname output
      
	select @i_authorcursorstatus = @@FETCH_STATUS
end

close cursor_author
deallocate cursor_author





/*****************************************/
/** Output b049 ContributorStatement - Full Author Display Name  - Level 2 only    **/
/*****************************************/

select @c_fullauthordisplayname = fullauthordisplayname
	 from bookdetail where bookkey=@i_bookkey
if @c_fullauthordisplayname is not null and @c_fullauthordisplayname  <> ''
begin
	if @i_onixlevel=2 or @i_onixlevel = 3
		exec convert_char_to_unicode_column @c_fullauthordisplayname output
		insert into eloonixfeed (feedtext) 
		select '<b049><![CDATA[' + @c_fullauthordisplayname + ']]></b049>'
	
 end


/*****************************************/
/** Output b058 EditionStatement - using freeform field      **/
/*****************************************/

select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @c_editiondesc=datadesc from gentables where tableid=200 
	and datacode=@i_editioncode

	insert into eloonixfeed (feedtext) 
	select '<b058><![CDATA[' + @c_editiondesc + ']]></b058>'
 end

/*****************************************/
/** Output b059 Language      **/
/*****************************************/

select @c_onixlanguagecode = ''
select @c_elolanguagecode=''

select @c_elolanguagecode=g.eloquencefieldtag
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=318 
and g.datacode=bd.languagecode
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_elolanguagecode is not null and @c_elolanguagecode <> ''
begin
/**  Convert Eloquence Field Tag for Language to ONIX Language Codes **/

	select @c_onixlanguagecode = 
	case @c_elolanguagecode
	when 'EN' then 'eng' /*English*/
	when 'FR' then 'fre' /* French */
	when 'SP' then 'spa' /* Spanish */
	else 'NO MAP' /* Set to 'NO MAP' - Warning message will be output for missing mapping */
	end
	
	if @c_onixlanguagecode = 'NO MAP'
	begin
		select @c_tempmessage =  'No Onix Language Map for: ' + @c_elolanguagecode
		/*exec eloonixvalidation_sp @i_warning, @i_bookkey, @c_tempmessage*/
	end
	else if @c_onixlanguagecode is not null and @c_onixlanguagecode <> ''
	begin

		insert into eloonixfeed (feedtext) select '<b059>' + @c_onixlanguagecode 
		+ '</b059>'
	end
end /** @c_elolanguagecode is not null **/

/*****************************************/
/** Output b061 NumberOfPages - Page Count              **/
/*****************************************/
select @i_pagecount = pagecount from printing where bookkey=@i_bookkey
and printingkey=1

if @i_pagecount is null or @i_pagecount = 0 /* Actual Page Count is null, try Estimated Page count */
begin
	select @i_pagecount = tentativepagecount from printing where bookkey=@i_bookkey
	and printingkey=1
end

if @i_pagecount is not null and @i_pagecount > 0
begin
	
	insert into eloonixfeed (feedtext) 
	select '<b061>' + convert (varchar(10),@i_pagecount) + '</b061>'
 end


/*****************************************/
/** Output b062 IllustrationsNotes - Insert/Illus              **/
/*****************************************/
select @c_illus = actualinsertillus from printing where bookkey=@i_bookkey
and printingkey=1

if @c_illus is not null and @c_illus <> ''
begin
	exec convert_char_to_unicode_column @c_illus output
	insert into eloonixfeed (feedtext) 
	select '<b062><![CDATA[' + @c_illus + ']]></b062>'
 end


/*****************************************/
/** Output b062 IllustrationsNotes - Insert/Illus              **/
/*****************************************/

select @c_trimsizewidth=tmmactualtrimwidth, @c_trimsizelength=tmmactualtrimlength
from printing where bookkey=@i_bookkey and printingkey=1

if @c_trimsizewidth is not null and @c_trimsizewidth <> ''
	if @c_trimsizelength is not null and @c_trimsizelength <> ''
	begin

	insert into eloonixfeed (feedtext) 
	select '<TrimSize><![CDATA[' + @c_trimsizewidth + ' X ' + @c_trimsizelength + ']]></TrimSize>'
	end




/*******************************************/
/* BISAC Subject Categories   */
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
	insert into eloonixfeed (feedtext) 
		select '<b064>' + 
		@c_bisacsubjectcode + '</b064>'


		

			
	end /* First Row processing */
	
	if (@i_rownumber > 1) /** Output additional Subject category blocks **/
	begin


		/*******************************************/
		/* Output <subject>, <b067> SubjectSchemeIdentifier - 10 = BASIC   */
		/**************************************************/

		if @i_onixlevel=2 or @i_onixlevel=3
		begin
			insert into eloonixfeed (feedtext)select '<subject>'
			insert into eloonixfeed (feedtext) 
			select '<b067>10</b067>'
		
			/*******************************************/
			/* Output <b069> SubjectCode  */
			/**************************************************/
			insert into eloonixfeed (feedtext) 
			select '<b069>' + @c_bisacsubjectcode + '</b069>'
			insert into eloonixfeed (feedtext) select '</subject>'
		end /* if level 2*/

	end /** Additional Category Blocks **/

	end /* if subjectcursorstatus */
	
	FETCH NEXT FROM cursor_subject
	INTO @c_bisacsubjectcode
      
	select @i_subjectcursorstatus = @@FETCH_STATUS
end

close cursor_subject
deallocate cursor_subject


/*****************************************/
/** Output b190 Interest Ages              **/
/*****************************************/
select @i_pagecount = pagecount from printing where bookkey=@i_bookkey
and printingkey=1

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
	insert into eloonixfeed (feedtext)
	select '<b190>from ' + convert (varchar(10),@i_agelow) + ' to ' + convert (varchar(10),@i_agehigh) + '</b190>'
end

/*** Example:  'up to 7' ***/
if @i_agelowupind=1 and @i_agehigh is not null and @i_agehigh > 0

begin
	insert into eloonixfeed (feedtext)
	select '<b190>up to ' + convert (varchar(10),@i_agehigh) + '</b190>'
end

/*** Example:  '3 upwards' ***/
if  @i_agelow is not null and @i_agelow > 0 and @i_agehighupind=1
begin
	insert into eloonixfeed (feedtext)
	select '<b190>' + convert (varchar(10),@i_agelow) + ' upwards</b190>'
end

/*** Example:  Age Low only - no upwards - '3' ***/
if @i_agehighupind=0 or @i_agehighupind is null 
	if @i_agelow is not null and @i_agelow > 0	
		if @i_agehigh is null or @i_agehigh=0
			insert into eloonixfeed (feedtext)
			select '<b190>' + convert (varchar(10),@i_agelow) + '</b190>'
 

/*****************************************/
/** Output b079 ImprintName              **/
/*****************************************/

insert into eloonixfeed (feedtext)
select '<b079><![CDATA[' + oe.orgentrydesc + ']]></b079>'
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=4 and oe.orgentrykey=bo.orgentrykey

/*****************************************/
/** Output b081 PublisherName              **/
/* Modified 7/11/02 by DSL to pull Spine Imprint (Level 4) */
/*****************************************/
insert into eloonixfeed (feedtext)
select '<b081><![CDATA[' + oe.orgentrydesc + ']]></b081>'
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=4 and oe.orgentrykey=bo.orgentrykey


/*****************************************/
/** Output b003 PublicationDate         **/
/*****************************************/
select @d_pubdate=NULL

select @d_pubdate = activedate from bookdates 
where bookkey=@i_bookkey  and printingkey=1 and datetypecode=8

if @d_pubdate is NOT NULL
begin

	/* Call the Date conversion function, 
	then retrieve the resuling date from eloconverteddate */
	exec eloformatdateYYYYMMDD_sp @d_pubdate

	select @c_pubdate=converteddate from eloconverteddate
	
	insert into eloonixfeed (feedtext)
	select '<b003>' + @c_pubdate + '</b003>'
	/*
	insert into eloonixfeed (feedtext)
	select '<b003>' + datename (month, @d_pubdate) + ' ' 
                + convert (varchar (4),datepart (yy,@d_pubdate)) + '</b003>'
	*/
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
	
		insert into eloonixfeed (feedtext)
		select '<b003>' + @c_pubdate + '</b003>'
		
		/*
		insert into eloonixfeed (feedtext)
		select '<b003>' + datename (month, @d_pubdate) + ' ' 
               	 + convert (varchar (4),datepart (yy,@d_pubdate)) + '</b003>'
		*/
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
			select @c_pubdate=converteddate from eloconverteddate
	
			insert into eloonixfeed (feedtext)
			select '<b003>' + @c_pubdate + '</b003>'
	
			
			/* 
			insert into eloonixfeed (feedtext)
			select '<b003>' + datename (month, @d_pubdate) + ' ' 
               			+ convert (varchar (4),datepart (yy,@d_pubdate)) + '</b003>'
			*/
		end
		else /** No Possibility for pub date exists - send Validation error **/
		begin
			select @i_validationerrorind = 1
			/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'Pub Date and Pub Month missing'*/
		end

	end
end /** End Else Check Est Pub DatePub Year **/



/*****************************************/
/** Output Descriptive Content          **/
/*****************************************/

/*****************************************/
/** Output d100 Annotation - Brief Description             **/
/*****************************************/
 exec @i_returncode = elooutputcomment_sp_v2 @i_bookkey,'BD','<d100><![CDATA[',']]></d100>',@i_websitekey

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*****************************************/
/** Output d101 Main Description             **/
/*****************************************/
/*** PM 5/9/06 CRM 3881 Remove Trim Size and Illustration Comment from Description **/

select @c_postfix = NULL

-- PM 05/09/06 REMOVED TRIM AND INSTERILLUS LOGIC

if @c_postfix is null or @c_postfix = ''
	select @c_postfix=']]></d101>'

/* Modified to remove priority of Brief Description - will rely on new
   websitecommenttype table - DSL 12/4/2002**/

exec @i_returncode = elooutputcomment_sp_v2 @i_bookkey,'D','<d101><![CDATA[',@c_postfix,@i_websitekey


if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/***Comment Types not currently supported in Onix
ACOM	(e) Author Comments
AFB	(e) Audience For Book
PCOM	(e) Publisher Comments
SET	(e) Setting
P 	(e) Publicity
SLH	(e) Sales Handle
PTI	(e) Pub Date Tie In
CB	(e) Catalog Bullets
***/

/*****************************************/
/** Output OtherText LEVEL 2 and 3 ONLY             	**/
/* Includes OtherText header, d102 TextTypeCode, d104 Text */
/* Can include in future d103 TextFormat */
/*****************************************/
if @i_onixlevel=2 or @i_onixlevel=3
begin
/* 04 - Table of Contents */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'04','TOC',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 08 Q1  Quote 1 */
exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'08','Q1',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 13 - Author Bio */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'13','AI',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 23 EX  Excerpt */
exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'23','EX',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 31 BC Catalog Body Copy */
exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'31','BC',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 17 FC Inside Flap Copy */
exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'17','FC',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 18 BPC Back Panel Copy */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'18','BPC',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 12 SRDSC Series Description */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'12','SRDSC',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end 

/* 25 DISCARD Catalog Marketing Info */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'25','DISCARD',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 75 RECFAB Recommended Fabrics */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'75','RECFAB',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
/* 38 Author Rsidence */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'38','AURES',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 73 Catalog Sales Point */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'73','catsale',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
/* 77 “Illustrator Residence */

exec @i_returncode = eloonixothertext_sp_v2 @i_bookkey,'77','illusres',@i_websitekey
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end
--select top 1 @i_craftrole = roletypecode
--from bookcontributor where roletypecode = 59
--and bookkey = @i_bookkey and printingkey = 1
--if @i_craftrole is not null
--begin

-- insert into eloonixfeed (feedtext) select '<craftsources>'

-- DECLARE cursor_craftsource INSENSITIVE CURSOR
--  FOR
--  select b.contributorkey  
--   from bookcontributor b
--   where roletypecode = 59
--    and bookkey = @i_bookkey
--    and printingkey = 1
--  FOR READ ONLY

--  OPEN cursor_craftsource

--  FETCH NEXT FROM cursor_craftsource
--  INTO @i_contributorkey

--  select @i_craftsourcecursorstatus = @@FETCH_STATUS

--  if @i_craftsourcecursorstatus < 0 
--  begin
--	select @c_dummy=''
--	select @i_validationerrorind = 1
	
--  end

--  while (@i_craftsourcecursorstatus<>-1 )
--  begin
--	IF (@i_craftsourcecursorstatus<>-2)
--	begin
	
--	select @i_globalcontactkey=dbo.get_globalcontact_from_contributor (@i_bookkey,59,@i_contributorkey)
	
--	insert into eloonixfeed (feedtext) select '<globalcontactkey>'+CAST(@i_globalcontactkey as varchar)+'</globalcontactkey>'
	
--	end 
		
--	FETCH NEXT FROM cursor_craftsource
--	INTO @i_contributorkey
      
--	select @i_craftsourcecursorstatus = @@FETCH_STATUS
--  end

--  close cursor_craftsource
--  deallocate cursor_craftsource

-- insert into eloonixfeed (feedtext) select '</craftsources>'

-- end
end /*** If Level 2 for Other Text Items ***/

/*****************************************/
/** Output e110 ReviewQuote - Repeats three times    **/
/*****************************************/

exec @i_returncode = elooutputcomment_sp_v2 @i_bookkey,'Q1','<e110><![CDATA[',']]></e110>',@i_websitekey

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

exec @i_returncode = elooutputcomment_sp_v2 @i_bookkey,'Q2','<e110><![CDATA[',']]></e110>',@i_websitekey

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

exec @i_returncode = elooutputcomment_sp_v2 @i_bookkey,'Q3','<e110><![CDATA[',']]></e110>',@i_websitekey

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/***************************************/
/** Output SupplyDetail Data		  **/
/***************************************/



insert into eloonixfeed (feedtext) select '<supplydetail>'

/***************************************/
/** Output j137 Supplier Name - Use Publisher Name  **/
/***************************************/
insert into eloonixfeed (feedtext)
select '<j137><![CDATA[' + oe.orgentrydesc + ']]></j137>'
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=1 and oe.orgentrykey=bo.orgentrykey


/***************************************/
/** Output j141 AvailabilityCode - 		  **/
/***************************************/

select @c_onixstatuscode = ''
select @c_bisacstatuscode=''

select @c_bisacstatuscode=g.bisacdatacode
from bookdetail bd,gentables g
where bd.bookkey= @i_bookkey and g.tableid=314 
and g.datacode=bd.bisacstatuscode
if @@error <>0
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

if @c_bisacstatuscode is null or @c_bisacstatuscode = ''
begin
	select @i_validationerrorind = 1
	/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'BISAC Status missing'*/
end

/**  Convert Bisac Status Code to ONIX Status Codes **/

	select @c_onixstatuscode = 
	case @c_bisacstatuscode
	when 'ACT' then 'IP' /*Active-Available*/
	when 'NL' then 'RF' /* No Longer Our Publication */
	when 'NOP' then 'RF' /* Not Our Publication */
	when 'NYP' then 'NP' /* Not Yet Published */
	when 'OD' then 'MD' /* On Demand */
	when 'OP' then 'OP' /* Out of Print*/
	when 'OS' then 'TU' /* Temporarily out of stock */
	when 'OSI' then 'OI' /* Out of stock indefinately */
	when 'PC' then 'AB' /* Publication Canceled */
	else 'IP' /* Set to Active-Available */
	end

insert into eloonixfeed (feedtext) select '<j141>' + @c_onixstatuscode 
+ '</j141>'

/***************************************/
/** Output Price Group - for US Retail  3-2-04 add Canadian **/
/***************************************/

select @d_usretail=0
select @d_canadaprice =0

select @d_usretail=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=6

select @d_canadaprice=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=11

if @d_usretail=0 /* Retail Price Not Found - Try for Suggested List Price */
begin

select @d_usretail=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=11
and currencytypecode=6

end

if @d_canadaprice=0 /* Canada Retail Price Not Found - Try for Suggested List Price */
begin

select @d_canadaprice=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=11
and currencytypecode=11

end

/** j148 = Price Type Code - 01 = Retail, j151 = price amount **/
if @d_usretail>0 or @d_canadaprice>0
begin
	/*** Sending Price field only - send composite when additional 
		currencies are added
	insert into eloonixfeed (feedtext) select '<j151>' + 
		convert (varchar (10),@d_usretail) + '</j151>'***/
	/**** This is the composite field to be used later -- 3-2-04 using now  ****/

	if @d_usretail>0 
	begin
		insert into eloonixfeed (feedtext) select '<price>' 
		insert into eloonixfeed (feedtext) select '<j148>01</j148>'
		insert into eloonixfeed (feedtext) select '<j151>' + 
			convert (varchar (10),@d_usretail) + '</j151>'
    		insert into eloonixfeed (feedtext) select '<j152>USD</j152>' 
		insert into eloonixfeed (feedtext) select '</price>'
	end
	if  @d_canadaprice>0
	begin
	/***NOTE: Add CurrencyCode Here for UK/Canadian***/
		insert into eloonixfeed (feedtext) select '<price>' 
		insert into eloonixfeed (feedtext) select '<j148>01</j148>'
		insert into eloonixfeed (feedtext) select '<j151>' + 
			convert (varchar (10),@d_canadaprice) + '</j151>'
    		insert into eloonixfeed (feedtext) select '<j152>CAD</j152>' 
		insert into eloonixfeed (feedtext) select '</price>'
	end


	/*** END of Composite***/  
end
else /** No Price found - output Validation Error **/
begin
	select @i_validationerrorind = 1
	/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'Retail Price missing'*/
end

/** PM 5/9/06 CRM 3881 Output Carton Quantity **/
	Select @i_cartonqty = cartonqty1 from bindingspecs
	where bookkey = @i_bookkey
	and printingkey = (Select max(printingkey) 
				from bindingspecs 
				where bookkey = @i_bookkey
				  and cartonqty1 is not null
			   Group by bookkey)

	If @i_cartonqty > 0
	begin
	insert into eloonixfeed (feedtext) Select '<j145>'+CAST(@i_cartonqty as varchar)+'</j145>'
	end

/***************************************/
/** Output Supply Detail Ending Line  **/
/***************************************/
insert into eloonixfeed (feedtext) select '</supplydetail>'

/***************************************/
/**  Territory                       **/
/***************************************/
Select @c_territory = ISNULL(g.datadesc,'')
from book b, gentables g
where b.bookkey = @i_bookkey
and b.territoriescode = g.datacode
and g.tableid = 131

If @c_territory <> ''
begin
insert into eloonixfeed (feedtext) select '<territory><![CDATA['+@c_territory+']]></territory>'
end

/***************************************/
/**  Web Weight                       **/
/***************************************/

/*** Select the eloquencefieldtag which will match the weight tag **/
/** in the style sheet allowing flexibility of the display of titles **/

/** First check the catalog weight code on bookcustom **/

select @i_webweightcode = NULL

select @i_webweightcode = customcode03 
from bookcustom
where bookkey = @i_bookkey


/* If not found, check the Catalog Weight on the Catalog designated for this website */

if @i_webweightcode = 0 or @i_webweightcode is NULL
begin
	declare webweight_cursor insensitive cursor
		FOR
			select bc.catalogweightcode 
			from catalogsection cs, website w, bookcatalog bc
			where w.websitekey = @i_websitekey
			and bc.bookkey = @i_bookkey
			and cs.sectionkey = bc.sectionkey
			and cs.catalogkey = w.websitecatalogkey 
			order by cs.sortorder
		FOR READ ONLY

		open webweight_cursor
		fetch next from webweight_cursor 
		into @i_webweightcode
		

		/** we are only interested in the first row, so close the 
			the cursor and disregard other potential rows */
		close webweight_cursor
		deallocate webweight_cursor


	select @c_webweighttag = NULL
	
	if @i_webweightcode is not null and @i_webweightcode > 0
	begin
		select @c_webweighttag= externalcode
		from gentables
		where tableid=290
		and datacode = @i_webweightcode
	end

end /** End If Web Weight not found on bookcustom **/
else /** Web Weight Found on BookCustom **/
begin


	select @c_webweighttag = NULL
	
	if @i_webweightcode is not null and @i_webweightcode > 0
	begin
		select @c_webweighttag= externalcode
		from gentables
		where tableid=419
		and datacode = @i_webweightcode
	end

end /* Web Weight found on bookcustom */			

if @c_webweighttag is NULL 
begin 
	select @c_webweighttag = ''
end



if @c_webweighttag = 'WEBWEIGHT1' 
	select @c_webweighttag = '1'
else if @c_webweighttag = 'WEBWEIGHT2' 
	select @c_webweighttag = '2'
else if @c_webweighttag = 'WEBWEIGHT3' 
	select @c_webweighttag = '3'
else if @c_webweighttag = 'WEBWEIGHT4' 
	select @c_webweighttag = '4'
else if @c_webweighttag = 'WEBWEIGHT5' 
	select @c_webweighttag = '5'
else if @c_webweighttag = 'WEBWEIGHT6' 
	select @c_webweighttag = '6'
else if @c_webweighttag = 'WEBWEIGHT7' 
	select @c_webweighttag = '7'
else if @c_webweighttag = 'WEBWEIGHT8' 
	select @c_webweighttag = '8'
else if @c_webweighttag = 'WEBWEIGHT9' 
	select @c_webweighttag = '9'
else if @c_webweighttag = 'WEBWEIGHT10' 
	select @c_webweighttag = '10'
else
	select @c_webweighttag = '10'

insert into eloonixfeed (feedtext)
select '<webweight>' + @c_webweighttag + '</webweight>'

/*6/6/02  add internal status */


select @c_internalstat = ''

select @c_internalstat =  datadesc  from book b, gentables g
where bookkey=@i_bookkey and g.datacode=b.titlestatuscode
and tableid=149

if @c_internalstat is not null and @c_internalstat <> ''
	begin

		insert into eloonixfeed (feedtext) 
		select '<intstat>' + @c_internalstat + '</intstat>'
end
/*******************************************/
-- Website Hot titles
/*******************************************/
select @i_webhotind = longvalue 
from bookmisc 
where misckey = 11 and 
bookkey = @i_bookkey

set @i_webhotind = IsNull(@i_webhotind, 0)
insert into eloonixfeed (feedtext) select '<webhot>' + cast(@i_webhotind as char(1)) + '</webhot>'

/*******************************************/
-- Google Book Search
/*******************************************/
select @i_googlesrchind = longvalue 
from bookmisc 
where misckey = 14 and 
bookkey = @i_bookkey

set @i_googlesrchind = IsNull(@i_googlesrchind, 0)
insert into eloonixfeed (feedtext) select '<googlesrch>' + cast(@i_googlesrchind as char(1)) + '</googlesrch>'

/*******************************************/
-- Bound Book Date
/*******************************************/
select @d_boundbookdate=dbo.get_BestDate(@i_bookkey,1,30)
exec eloformatdateYYYYMMDD_sp @d_boundbookdate
select @c_boundbookdate=converteddate from eloconverteddate
	

insert into eloonixfeed (feedtext) select 
'<BBD>'+ @c_boundbookdate + '</BBD>'


/*******************************************/
-- Warehouse Date
/*******************************************/
select @d_whdate=dbo.get_BestDate(@i_bookkey,1,47)
exec eloformatdateYYYYMMDD_sp @d_whdate
select @c_whdate=converteddate from eloconverteddate
	

insert into eloonixfeed (feedtext) select 
'<WHD>'+ @c_whdate + '</WHD>'


/*******************************************/
-- Last Date of Change (Paper cut off Date)
/*******************************************/
select @d_lastchangedate=dbo.get_BestDate(@i_bookkey,1,612)
exec eloformatdateYYYYMMDD_sp @d_lastchangedate
select @c_lastchangedate from eloconverteddate
	

insert into eloonixfeed (feedtext) select 
'<LDC>'+ @c_lastchangedate + '</LDC>'

/*******************************************/
-- Announced Firt Printing
/*******************************************/
select @i_announcedfirstprint = dbo.get_BestReleaseQty(@i_bookkey)

set @i_announcedfirstprint = IsNull(@i_announcedfirstprint, 0)
insert into eloonixfeed (feedtext) select '<announcedfirstprint>' + cast(@i_announcedfirstprint as char(1)) + '</announcedfirstprint>'

/*******************************************/
-- Primary Hardcover EAN
/*******************************************/
select @c_PrimaryEAN = eanx 
from coretitleinfo 
where printingkey = 1 
and formatname like 'HC%' 
and bookkey in (
select workkey from coretitleinfo where formatname in ('Flexibound',
'Flexibound with Flaps',
'PB with CD',
'PB-Flexibound',
'PB-Paper with Deluxe Flaps',
'PB-Trade Paperback',
'PB-Trade Paperback with Jacket',
'PB-with Flaps')and workkey <> bookkey and bookkey = @i_bookkey)

if @c_PrimaryEAN is not null and @c_PrimaryEAN <> ''
begin

  	insert into eloonixfeed (feedtext) select '<PrimaryEAN>' + @c_PrimaryEAN+ '</PrimaryEAN>'

end 
/******************************************************/
/** E-Book  ISBN (EAN with dashes)  AND E-Book US Price                      **/
/******************************************************/
SELECT @v_mediatypecode = mediatypecode 
   FROM coretitleinfo
 WHERE bookkey = @i_bookkey

SELECT @v_datacode = datacode
  FROM gentables
WHERE tableid = 312 AND datadesc = 'Book'

IF @v_mediatypecode = @v_datacode
BEGIN
    
    DECLARE subordinate_titles_cur CURSOR FOR
		SELECT bookkey,ean
		  FROM coretitleinfo
		WHERE bookkey in (SELECT bookkey FROM book WHERE propagatefrombookkey = @i_bookkey AND linklevelcode = 20) 
			  AND mediatypecode = (SELECT datacode FROM gentables WHERE tableid = 312 and datadesc = 'E Publication')
--print '@i_bookkey'
--print @i_bookkey	
	OPEN subordinate_titles_cur 	
	FETCH NEXT FROM subordinate_titles_cur INTO @v_ebook_bookkey,@v_ebook_ean
    WHILE (@@FETCH_STATUS = 0)   /*FOR subordinate_titles_cur FOUND */
	BEGIN
---print '@v_ebook_bookkey'
---print @v_ebook_bookkey
--print '@v_ebook_ean'
--print @v_ebook_ean
		IF @v_ebook_ean IS NOT NULL AND @v_ebook_ean <> ''
		BEGIN
			INSERT INTO eloonixfeed (feedtext) select '<ebookISBN>' + @v_ebook_ean + '</ebookISBN>'
		END		

        SELECT @v_ebook_usretail=CONVERT (decimal (10,2),finalprice)  
          FROM bookprice
	    WHERE bookkey=@v_ebook_bookkey AND pricetypecode=8 AND currencytypecode=6

        IF @v_ebook_usretail>0 
		BEGIN
			INSERT INTO eloonixfeed (feedtext) select '<ebookPrice>' + convert (varchar (10),@v_ebook_usretail) + '</ebookPrice>'
    	END
        FETCH NEXT FROM subordinate_titles_cur INTO @v_ebook_bookkey,@v_ebook_ean
	END  /*LOOP subordinate_titles_cur */
	CLOSE subordinate_titles_cur 
	DEALLOCATE subordinate_titles_cur 
END
/*******************************************/
/* BISAC Subject Categories   */
/**************************************************/
/** PM 05/09/06 CRM 3881 Output File Locations for Web Links **/

DECLARE cursor_weblinks INSENSITIVE CURSOR
FOR
select f.filetypecode, g.datadesc, CAST(f.notes as varchar(8000)), f.pathname 
 from filelocation f, gentables g
 where g.tableid = 354
   and f.filetypecode = g.datacode
   and f.filetypecode IN (1,8,9,10)
   and f.filestatuscode = 1
   and bookkey = @i_bookkey
   and printingkey = 1
FOR READ ONLY

OPEN cursor_weblinks

FETCH NEXT FROM cursor_weblinks
INTO @i_filetypecode,@c_filetypedesc, @c_filenotes, @c_filepathname

select @i_weblinkscursorstatus = @@FETCH_STATUS

if @i_weblinkscursorstatus < 0 /** No links  **/
begin
	select @c_dummy=''
	select @i_validationerrorind = 1
	/*exec eloonixvalidation_sp @i_error, @i_bookkey, 'Author missing'*/
end

while (@i_weblinkscursorstatus<>-1 )
begin
	IF (@i_weblinkscursorstatus<>-2)
	begin
	

	insert into eloonixfeed (feedtext) select '<weblink>'
	insert into eloonixfeed (feedtext) select '<weblinktypecode>'+CAST(@i_filetypecode as varchar)+'</weblinktypecode>'
	insert into eloonixfeed (feedtext) select '<weblinktypedesc>'+@c_filetypedesc+'</weblinktypedesc>'
	insert into eloonixfeed (feedtext) select '<weblinkname><![CDATA['+@c_filenotes+']]></weblinkname>'
	insert into eloonixfeed (feedtext) select '<weblinkaddress><![CDATA['+@c_filepathname+']]></weblinkaddress>'
	insert into eloonixfeed (feedtext) select '</weblink>'


	end /* if @i_weblinkscursorstatus */
		
	FETCH NEXT FROM cursor_weblinks
	INTO @i_filetypecode,@c_filetypedesc, @c_filenotes, @c_filepathname
      
	select @i_weblinkscursorstatus = @@FETCH_STATUS
end

close cursor_weblinks
deallocate cursor_weblinks

/*****************************************/
/** Output Title Heading                **/
/*****************************************/

select @i_newtitleheading = newtitleheading from bookdetail where bookkey=@i_bookkey
if @i_newtitleheading is not null and @i_newtitleheading > 0
begin
	begin
	select @c_newtitleheading=datadesc from gentables where tableid=427 
	and datacode=@i_newtitleheading
	end

	insert into eloonixfeed (feedtext) 
	select '<titleheading>' + @c_newtitleheading + '</titleheading>'
end

/***************************************/
/** Output Product Group Ending Line  **/
/***************************************/
insert into eloonixfeed (feedtext) 
	select '</product>'


commit tran

return 0

