SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixoutbook_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixoutbook_sp]
GO



CREATE proc dbo.eloonixoutbook_sp @i_bookkey int, @i_onixlevel int
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

i_onixlevel can equal 1 for generic onix (Level 1), 2 for Onix Level 2, 3 for QSI WEB Site Onix 
**/


DECLARE @c_dummy varchar (25)
DECLARE @c_bisacmediacode varchar (25)
DECLARE @c_bisacformatcode varchar (25)
DECLARE @c_onixformatcode varchar (25)
DECLARE @c_onixformatdesc varchar (100)
DECLARE @c_title varchar (255)
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
DECLARE @i_audiencecode int
DECLARE @c_audiencecode varchar (25)
DECLARE @i_seriescode int
DECLARE @c_seriesdesc varchar (100)
DECLARE @i_seriesdesclength int
DECLARE @i_pagecount smallint
DECLARE @c_fullauthordisplayname varchar (255)
DECLARE @c_illus varchar (200)
DECLARE @c_bisacsubjectcode varchar (100)
DECLARE @i_subjectcursorstatus int
DECLARE @i_rownumber int
DECLARE @d_pubdate datetime
DECLARE @c_pubdate varchar(8)
DECLARE @i_returncode int
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
DECLARE @d_effectivedate datetime
DECLARE @c_effectivedate varchar(8)
DECLARE @i_desccount int
DECLARE @i_packqty int

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

insert into eloonixfeed (feedtext) select '<b004>' + isbn10 + '</b004>'
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

/*******************************************/
/* Output b005 EAN - EAN13 */
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
  	insert into eloonixfeed (feedtext) select '<b005>' + replace (@c_ean,'-','') + '</b005>'
	if @@error <>0
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end		
end		

/*******************************************/
/* Output <b012> ProductForm - Media/Format as an EPICS code.  */
/**************************************************/

/*  Initialize the description field . It will be used in cases where the format is */
/* not supported by Onix i.e. Calender */
select @c_onixformatdesc = '' 

/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/
 

select @c_bisacmediacode=g.bisacdatacode,@c_bisacformatcode = sg.bisacdatacode
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


/*if @c_bisacmediacode is null or @c_bisacmediacode = ''*/
/*begin */
	/* Made into warning instead of error 9/27/01 DSL */
	/* select @i_validationerrorind = 1 -**/
	/* Removed this message - if Media fails, Format will fail, so one message */
	/* is sufficient - 03-18-2002 DSL **/
	/*exec eloonixvalidation_sp @i_warning, @i_bookkey, 'Media Type missing'*/
/*end*/

if @c_bisacformatcode is null or @c_bisacformatcode = ''
begin
	select @i_validationerrorind = 1 
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Format Type missing'
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
	/*print 'Before Case - Bisac format code = ' + 	@c_bisacformatcode */
	select @c_onixformatcode =
	case @c_bisacformatcode
	when 'TC' then 'BB'
	when 'TP' then 'BC'
	when 'SP' then 'BE'
	when 'WC' then 'BE'
	when 'OT' then 'BC'
	when 'BD' then 'BH'
	when 'MM' then 'BC'
	when 'FU' then 'BI'
	when 'PO' then 'BB'
	when 'BX' then 'WX'
	when 'RL' then 'BB'
	else  'BA'
	end
	/*print 'After Case - onix format code = ' + 	@c_onixformatcode*/
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

/* Added 5/9/02 by DSL to output Book Form Detail = 07 if binding is Reinforced Library Binding */
if @c_bisacformatcode='RL' 
begin
	insert into eloonixfeed (feedtext) select '<b013>07</b013>'
end

/* Set the description for Plush Books */
if @c_onixformatcode='BI' 
begin
	select @c_onixformatdesc = 'Plush Book'
end
if @c_onixformatdesc <> ''
begin
	/** b014 ProductFormDescription **/
	insert into eloonixfeed (feedtext) select '<b014>' + @c_onixformatdesc + '</b014>'
end

/*****************************************/
/** Output series composite            **/
/*****************************************/
/* 9/10/02 - CT - modifed to use alternatedesc1 for series title if this field is populated */

select @i_seriescode = seriescode from bookdetail where bookkey=@i_bookkey
if @i_seriescode is not null and @i_seriescode > 0
begin 
	/* first try for alternatedesc 1  (this allows > 40 characters ) */
	select @c_seriesdesc = alternatedesc1 from gentables where tableid=327 
	and datacode=@i_seriescode
	/* get length of datadesc title to use if alternatedesc1 is null or blank */
	select @i_seriesdesclength = LEN(datadesc) from gentables where tableid = 327 
	and datacode = @i_seriescode
	
	if @c_seriesdesc is NULL or @c_seriesdesc = ' ' /* alternatedesc1 is blank, so use datadesc  */
	begin
		select @c_seriesdesc=datadesc from gentables where tableid=327 
		and datacode=@i_seriescode

		/** added 07/17/02 - CT- Output warning message if series desc length = 40 - this implies series name was truncated on import ***/
		if @i_seriesdesclength = 40 
		begin
			select @c_tempmessage =  'Series Description Truncated at 40 characters: ' + @c_seriesdesc
			exec eloonixvalidation_sp @i_warning, @i_bookkey, @c_tempmessage
		end

	end

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
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Title Missing'
end

if @i_onixlevel = 3
begin
	/** Always outout b028 'Title' for the QSI WEB Site procedure **/
	insert into eloonixfeed (feedtext) 
	select '<b028><![CDATA[' + @c_title + ']]></b028>'
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
if @c_titleprefix is not null and @c_titleprefix <> ''
begin
	if @i_onixlevel = 2 or @i_onixlevel = 3
		insert into eloonixfeed (feedtext) 
		select '<b031><![CDATA[' + @c_title + ']]></b031>'
end

/*****************************************/
/** Output b029 Subtitle **/
/*****************************************/

insert into eloonixfeed (feedtext) 
	select '<b029><![CDATA[' + subtitle + ']]></b029>' 
      from book where bookkey=@i_bookkey
      and subtitle is not null and subtitle <> ''
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
		exec eloonixvalidation_sp @i_warning, @i_bookkey, @c_tempmessage
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
else
begin
	if @c_bisacmediacode='B' /* Only Output Pagecount Warning for Media Type = Book */
		begin
		if  @c_onixformatcode <> 'BI' /** Not for Plush Books **/
			exec eloonixvalidation_sp @i_warning, @i_bookkey, 'Page Count missing'
		end
end

/*****************************************/
/** Output b062 IllustrationsNotes - Insert/Illus              **/
/*****************************************/
select @c_illus = actualinsertillus from printing where bookkey=@i_bookkey
and printingkey=1

if @c_illus is not null and @c_illus <> ''
begin
	
	insert into eloonixfeed (feedtext) 
	select '<b062><![CDATA[' + @c_illus + ']]></b062>'
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
if @i_subjectcursorstatus = -1 
begin
	exec eloonixvalidation_sp @i_warning, @i_bookkey, 'No BISAC Subject Categories'
end

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

/**************************************************************/
/**  output Audience Code  <AudienceCode> <b073>             **/
/*************************************************************/
select @i_audiencecode=audiencecode
from bookdetail where bookkey=@i_bookkey

if  @i_audiencecode is not null and @i_audiencecode > 0 and @i_audiencecode < 8
	begin
		insert into eloonixfeed(feedtext)
		select '<b073>' + '0' + convert(varchar(25),@i_audiencecode) + '</b073>'
	end
else  

if  @i_audiencecode is not null /** Invalid Audience code - send Validation error **/
	begin
			select @i_validationerrorind = 1
			exec eloonixvalidation_sp @i_error, @i_bookkey, 'Invalid Audience Code'
	end


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
	select '<b190>from ' + convert (varchar(10),@i_agelow) + '</b190>'
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
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey

/*****************************************/
/** Output b081 PublisherName              **/
/*****************************************/
insert into eloonixfeed (feedtext)
select '<b081><![CDATA[' + oe.orgentrydesc + ']]></b081>'
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey

/*****************************************/
/** Output b003 PublicationDate         **/
/*****************************************/
select @d_pubdate=NULL

/* 8/27/02 - CT - Ignore pubdate if bisac status = Cancelled, Postponed,
 or No longer Our Publication */

if @c_bisacstatuscode NOT in ('NL','CC','PP')  
Begin
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
	
				insert into eloonixfeed (feedtext)
				select '<b003>' + @c_pubdate + '</b003>'
			end
			else /** No Possibility for pub date exists - send Validation error **/
				begin
				select @i_validationerrorind = 1
				exec eloonixvalidation_sp @i_error, @i_bookkey, 'Pub Date and Pub Month missing'
			end

		end
	end /** End Else Check Est Pub DatePub Year **/
end/** End Else if NOT Cancelled, Postponed, or No longer our Pub **/

/*****************************************/
/** Output Descriptive Content          **/
/*****************************************/

/*****************************************/
/** Output d100 Annotation - Brief Description             **/
/*****************************************/
 exec @i_returncode = elooutputcomment_sp @i_bookkey,'BD','<d100>','</d100>'

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/*****************************************/
/** Output d101 Main Description            **/
/** THIS SECTION IS NO LONGER USED - MAIN DESCRIPTION WILL BE **/
/** SENT AS 'OTHER TEXT' . Trim Size and Insert Illus will no longer be sent as part of description **/
/** To keep this code clean, I have deleted the old code. A copy of this stored procedure prior to **/
/** these changes can be found in k:\exports\applications\onix\backup04252002 **/
/** DSL - 4/25/2002 **/
/*****************************************/


/** If description is missing, try send Series Description **/
select @i_desccount=0

select @i_desccount=count (*) from bookcomments 
where bookkey=@i_bookkey and 
commenttypecode=3 and commenttypesubcode=8

if @i_desccount=0 or @i_desccount is null
begin
	select @i_desccount=0
	select @i_desccount=count (*) from bookcomments 
	where bookkey=@i_bookkey and commenttypecode=3 and commenttypesubcode=29
	if @i_desccount > 0
	begin

		if @i_onixlevel=3 /** Output D101 for eloquence web site **/
		begin

			exec @i_returncode = elooutputcomment_sp @i_bookkey,'SRDSC','<d101>','</d101>'
			if @i_returncode=-1
			begin
				rollback tran
				/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
				return -1  /** Fatal SQL Error **/
			end

		end
		/*exec eloonixvalidation_sp @i_warning, @i_bookkey, 'Description missing: Sending Series Desc'
		*/
		exec @i_returncode = eloonixothertext_sp @i_bookkey,'01','SRDSC'
		if @i_returncode=-1
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end

	end
end
else
begin

	if @i_onixlevel=3 /** Output D101 for eloquence web site **/
	begin
		exec @i_returncode = elooutputcomment_sp @i_bookkey,'D','<d101>','</d101>'
		if @i_returncode=-1
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
	end	
	exec @i_returncode = eloonixothertext_sp @i_bookkey,'01','D'
	if @i_returncode=-1
	begin
		rollback tran
		/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
		return -1  /** Fatal SQL Error **/
	end

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

exec @i_returncode = eloonixothertext_sp @i_bookkey,'04','TOC'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 08 Q1  Quote 1 */
exec @i_returncode = eloonixothertext_sp @i_bookkey,'08','Q1'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 13 - Author Bio */

exec @i_returncode = eloonixothertext_sp @i_bookkey,'13','AI'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 23 EX  Excerpt */
exec @i_returncode = eloonixothertext_sp @i_bookkey,'23','EX'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 31 BC Catalog Body Copy */
exec @i_returncode = eloonixothertext_sp @i_bookkey,'31','BC'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end


/* 17 FC Inside Flap Copy */
exec @i_returncode = eloonixothertext_sp @i_bookkey,'17','FC'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

/* 18 BPC Back Panel Copy */

exec @i_returncode = eloonixothertext_sp @i_bookkey,'18','BPC'
if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

end /*** If Level 2 for Other Text Items ***/

/*****************************************/
/** Output e110 ReviewQuote - Repeats three times    **/
/*****************************************/

exec @i_returncode = elooutputcomment_sp @i_bookkey,'Q1','<e110><![CDATA[',']]></e110>'

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

exec @i_returncode = elooutputcomment_sp @i_bookkey,'Q2','<e110><![CDATA[',']]></e110>'

if @i_returncode=-1
begin
	rollback tran
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
	return -1  /** Fatal SQL Error **/
end

exec @i_returncode = elooutputcomment_sp @i_bookkey,'Q3','<e110><![CDATA[',']]></e110>'

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
/** Output j137 Supplier Name - Use Company Name  **/
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


/** We will no longer provide any information regarding Bisac Status **/
/** The trading partners can handle the transaction without it DSL 2/28/02**/
/*if @c_bisacstatuscode is null or @c_bisacstatuscode = ''
begin
	select @i_validationerrorind = 1
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'BISAC Status missing'
end
*/

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
	else 'NP' /* Set to NYP */
	end

insert into eloonixfeed (feedtext) select '<j141>' + @c_onixstatuscode 
	+ '</j141>'


/***************************************/
/** j142 Output Availability Date       **/
/** if the status us Not Yet Published or Uncertain, send Pub Date **/
/** as availability date if it exists **/
/***************************************/

if @c_pubdate is not null and @c_pubdate <> ''
begin
	/** if the status us Not Yet Published or Uncertain, send Pub Date
		as availability date if it exists **/
	if @c_onixstatuscode = 'NP' or @c_onixstatuscode = 'CS' 
	begin
		insert into eloonixfeed (feedtext)
		select '<j142>' + @c_pubdate + '</j142>'
	end
end


/**************************************************************/
/**  output carton qty  <PackQuantity> <j145>             **/
/*************************************************************/
select @i_packqty = cartonqty1
from bindingspecs
where bookkey=@i_bookkey and printingkey = 1

if  @i_packqty is not null and @i_packqty > 0 
	begin
		insert into eloonixfeed(feedtext)
		select '<j145>' + convert(varchar(25),@i_packqty) + '</j145>'
	end

/**************************************************************/
/**  output discount code  <DiscountGroupCode> <j150>        **/
/**************************************************************/

/******************************************/
/** Output Price Group - for US Retail ***/
/****************************************/

select @d_usretail=0

select @d_usretail=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=8
and currencytypecode=6

if @d_usretail=0 /* Retail Price Not Found - Try for Suggested List Price */
begin

select @d_usretail=convert (decimal (10,2),finalprice)  from bookprice
where bookkey=@i_bookkey and pricetypecode=11
and currencytypecode=6

end

/** j148 = Price Type Code - 01 = Retail, j151 = price amount **/
if @d_usretail>0
begin
/** Modified to send the Composite instead of j151 - 10/29/01 - DSL **/
	/*** j151 is price field only - no longer using this. ***/
	/** insert into eloonixfeed (feedtext) select '<j151>' + 
		convert (varchar (10),@d_usretail) + '</j151>' **/
	
	insert into eloonixfeed (feedtext) select '<price>'
	insert into eloonixfeed (feedtext) select '<j148>01</j148>'
	insert into eloonixfeed (feedtext) select '<j151>' + 
		convert (varchar (10),@d_usretail) + '</j151>'
	insert into eloonixfeed (feedtext) select '<j152>USD</j152>'
	/**NOTE: Add CurrencyCode Here for UK/Canadian in future**/

	/* J161 - Price effective Date - Call the Date conversion function, 
	then retrieve the resuling date from eloconverteddate */
	select @d_effectivedate=getdate()
	exec eloformatdateYYYYMMDD_sp @d_effectivedate
	select @c_effectivedate=converteddate from eloconverteddate
	
	insert into eloonixfeed (feedtext)
	select '<j161>' + @c_effectivedate + '</j161>'


	insert into eloonixfeed (feedtext) select '</price>'
	/****** END of Composite  ***/
end
else /** No Price found - output Validation Error **/
begin
	select @i_validationerrorind = 1
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Retail Price missing'
end

/***************************************/
/** Output Supply Detail Ending Line  **/
/***************************************/
insert into eloonixfeed (feedtext) select '</supplydetail>'

/***************************************/
/** Output Product Group Ending Line  **/
/***************************************/
insert into eloonixfeed (feedtext) 
	select '</product>'

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

