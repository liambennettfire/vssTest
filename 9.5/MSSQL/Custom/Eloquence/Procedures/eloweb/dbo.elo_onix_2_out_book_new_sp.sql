SET QUOTED_IDENTIFIER ON ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elo_onix_2_out_book_new_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)਍ഀ
drop procedure [dbo].[elo_onix_2_out_book_new_sp]਍ഀ
GO਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
CCREATE proc dbo.elo_onix_2_out_book_new_sp @i_bookkey int,਍ഀ
@detail_level int = 2਍ഀ
as਍ഀ
਍ഀ
/** Returns:਍ഀ
0 Transaction completed successfully਍ഀ
-1 Generic SQL Error਍ഀ
-2 Required field not available - transaction rolled back਍ഀ
਍ഀ
**/਍ഀ
਍ഀ
਍ഀ
DECLARE @c_dummy varchar (25)਍ഀ
DECLARE @c_bisacmediacode varchar (25)਍ഀ
DECLARE @c_bisacformatcode varchar (25)਍ഀ
DECLARE @c_onixbookformdetail varchar (25)਍ഀ
DECLARE @c_onixformatcode varchar (25)਍ഀ
DECLARE @c_onixformatdesc varchar (100)਍ഀ
DECLARE @c_title varchar (255)਍ഀ
DECLARE @c_titleprefix varchar (100)਍ഀ
DECLARE @i_authortypecode smallint਍ഀ
DECLARE @i_authorsortorder int਍ഀ
DECLARE @i_authorcursorstatus int਍ഀ
DECLARE @c_authordisplayname varchar (100)਍ഀ
DECLARE @c_authorlastname varchar (100)਍ഀ
DECLARE @c_authorfirstname varchar (100)਍ഀ
DECLARE @c_authormiddlename varchar (100)਍ഀ
DECLARE @c_authorsuffix varchar (25)਍ഀ
DECLARE @c_authortitle varchar (25)਍ഀ
DECLARE @c_biography varchar (8000)਍ഀ
DECLARE @i_corporatecontributorind int਍ഀ
DECLARE @c_onixauthortypecode varchar (10)਍ഀ
DECLARE @c_authortypedesc varchar (100)਍ഀ
DECLARE @i_editioncode int਍ഀ
DECLARE @c_editiondesc varchar (100)਍ഀ
DECLARE @c_editiontypecode varchar (25)਍ഀ
DECLARE @d_editionnumber decimal (10,2)਍ഀ
DECLARE @d_measuredweight decimal (10,2)਍ഀ
DECLARE @c_measurecode varchar (10)਍ഀ
DECLARE @i_audiencecode int਍ഀ
DECLARE @i_audiencecursorstatus int਍ഀ
DECLARE @c_audiencecode varchar (25)਍ഀ
DECLARE @i_discountcode int਍ഀ
DECLARE @c_discountcode varchar (25)਍ഀ
DECLARE @i_seriescode int਍ഀ
DECLARE @c_seriesdesc varchar (100)਍ഀ
DECLARE @i_seriesdesclength int਍ഀ
DECLARE @i_pagecount smallint਍ഀ
DECLARE @c_fullauthordisplayname varchar (255)਍ഀ
DECLARE @c_illus varchar (200)਍ഀ
DECLARE @c_bisacsubjectcode varchar (100)਍ഀ
DECLARE @i_subjectcursorstatus int਍ഀ
DECLARE @i_rownumber int਍ഀ
DECLARE @d_pubdate datetime਍ഀ
DECLARE @c_pubdate varchar(8)਍ഀ
DECLARE @i_returncode int਍ഀ
DECLARE @c_bisacstatuscode varchar(10)਍ഀ
DECLARE @c_notificationbisacstatuscode varchar(10)਍ഀ
DECLARE @c_onixstatuscode varchar(10)਍ഀ
DECLARE @d_usretail decimal (10,2)਍ഀ
DECLARE @d_estusretail decimal (10,2)਍ഀ
DECLARE @c_postfix varchar(255)਍ഀ
DECLARE @i_agelow int਍ഀ
DECLARE @i_agelowupind int਍ഀ
DECLARE @i_agehigh int਍ഀ
DECLARE @i_agehighupind int਍ഀ
DECLARE @c_ean varchar (20)਍ഀ
DECLARE @c_trimsizewidth varchar (20)਍ഀ
DECLARE @c_trimsizelength varchar (20)਍ഀ
DECLARE @i_error int਍ഀ
DECLARE @i_warning int਍ഀ
DECLARE @i_validationerrorind int਍ഀ
DECLARE @c_onixlanguagecode varchar (25)਍ഀ
DECLARE @c_elolanguagecode varchar (25)਍ഀ
DECLARE @c_tempmessage varchar (255)਍ഀ
DECLARE @d_effectivedate datetime਍ഀ
DECLARE @c_effectivedate varchar(8)਍ഀ
DECLARE @i_desccount int਍ഀ
DECLARE @i_packqty int਍ഀ
਍ഀ
/** Constants for Validation Errors **/਍ഀ
select @i_error = 1਍ഀ
select @i_warning = 2਍ഀ
਍ഀ
/* declare other constants */਍ഀ
select @c_measurecode = '08'਍ഀ
਍ഀ
਍ഀ
begin tran਍ഀ
਍ഀ
/** Initialize the Validation Error to zero (False) **/਍ഀ
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/਍ഀ
/** for this bookkey.  Processing will continue to the next bookkey **/਍ഀ
਍ഀ
select @i_validationerrorind = 0਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output the beginning Product tag for this book */਍ഀ
/*******************************************/਍ഀ
insert into eloonixfeed (feedtext) select '<product>'਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output RecordReference - unique product number - we will use bookkey */਍ഀ
/*******************************************/਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) ਍ഀ
	select '<a001>' + convert (varchar (25),@i_bookkey) + '</a001>'਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output NotificationType - set to '03' for confirmed book */਍ഀ
/*******************************************/਍ഀ
਍ഀ
਍ഀ
select @c_notificationbisacstatuscode=''਍ഀ
਍ഀ
select @c_notificationbisacstatuscode=g.bisacdatacode਍ഀ
from bookdetail bd,gentables g਍ഀ
where bd.bookkey= @i_bookkey and g.tableid=314 ਍ഀ
and g.datacode=bd.bisacstatuscode਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
if @c_notificationbisacstatuscode = 'NYP' /** Notification Type = 02 for 'Not Yet Published **/਍ഀ
begin਍ഀ
	insert into eloonixfeed (feedtext) select '<a002>02</a002>'਍ഀ
end਍ഀ
else /** Notification Type = 03 for all other status **/਍ഀ
begin਍ഀ
	insert into eloonixfeed (feedtext) select '<a002>03</a002>'਍ഀ
end਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output b004 ISBN - ISBN 10 (without hyphens) */਍ഀ
/*******************************************/਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '<b004>' + isbn10 + '</b004>'਍ഀ
	from isbn where bookkey= @i_bookkey and isbn10 is not null਍ഀ
	if @@rowcount<=0਍ഀ
	begin਍ഀ
		select @i_validationerrorind = 1਍ഀ
		exec eloonixvalidation_sp @i_error, @i_bookkey, 'ISBN missing'਍ഀ
	end਍ഀ
	if @@error <>0਍ഀ
	begin਍ഀ
		rollback tran਍ഀ
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/਍ഀ
		return -1  /** Fatal SQL Error **/਍ഀ
	end਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output b005 EAN - EAN13 */਍ഀ
/*******************************************/਍ഀ
਍ഀ
select @c_ean=ean ਍ഀ
from isbn where bookkey=@i_bookkey਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
if @c_ean is not null and @c_ean <> ''਍ഀ
begin਍ഀ
  	insert into eloonixfeed (feedtext) select '<b005>' + replace (@c_ean,'-','') + '</b005>'਍ഀ
	if @@error <>0਍ഀ
	begin਍ഀ
		rollback tran਍ഀ
		/*exec eloprocesserror_sp @i_bookkey,@@error,'SQL Error'*/਍ഀ
		return -1  /** Fatal SQL Error **/਍ഀ
	end		਍ഀ
end		਍ഀ
਍ഀ
/*******************************************/਍ഀ
/* Output <b012> ProductForm - Media/Format as an EPICS code.  */਍ഀ
/**************************************************/਍ഀ
਍ഀ
/*  Initialize the description field . It will be used in cases where the format is */਍ഀ
/* not supported by Onix i.e. Calender */਍ഀ
select @c_onixformatdesc = '' ਍ഀ
਍ഀ
/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/਍ഀ
 ਍ഀ
਍ഀ
select @c_bisacmediacode=g.bisacdatacode,@c_bisacformatcode = sg.bisacdatacode਍ഀ
from bookdetail bd,gentables g,subgentables sg਍ഀ
where bd.bookkey= @i_bookkey and g.tableid=312 ਍ഀ
and g.datacode=bd.mediatypecode and sg.tableid=312 ਍ഀ
and sg.datacode=bd.mediatypecode and sg.datasubcode=bd.mediatypesubcode਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/*if @c_bisacmediacode is null or @c_bisacmediacode = ''*/਍ഀ
/*begin */਍ഀ
	/* Made into warning instead of error 9/27/01 DSL */਍ഀ
	/* select @i_validationerrorind = 1 -**/਍ഀ
	/* Removed this message - if Media fails, Format will fail, so one message */਍ഀ
	/* is sufficient - 03-18-2002 DSL **/਍ഀ
	/*exec eloonixvalidation_sp @i_warning, @i_bookkey, 'Media Type missing'*/਍ഀ
/*end*/਍ഀ
਍ഀ
if @c_bisacformatcode is null or @c_bisacformatcode = ''਍ഀ
begin਍ഀ
	select @i_validationerrorind = 1 ਍ഀ
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Format Type missing'਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/਍ഀ
਍ഀ
/**  Convert Bisac Media Types to ONIX Product Types **/਍ഀ
if @c_bisacmediacode='A' /* Audio Media Type */਍ഀ
begin਍ഀ
	select @c_onixformatcode = ਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'AA' then 'AB'਍ഀ
	when 'CD' then 'AC'਍ഀ
	when 'DA' then 'AD'਍ഀ
	when 'OO' then 'AA'਍ഀ
	when 'TA' then 'AF'਍ഀ
	else 'AF'਍ഀ
	end਍ഀ
end਍ഀ
਍ഀ
਍ഀ
else if @c_bisacmediacode='B' /* Book Media Type */਍ഀ
begin਍ഀ
	/*print 'Before Case - Bisac format code = ' + 	@c_bisacformatcode */਍ഀ
	select @c_onixformatcode =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'TC' then 'BB'਍ഀ
	when 'TP' then 'BC'਍ഀ
	when 'SP' then 'BE'਍ഀ
	when 'WC' then 'BE'਍ഀ
	when 'OT' then 'BC'਍ഀ
	when 'BD' then 'BH'਍ഀ
	when 'MM' then 'BC'਍ഀ
	when 'FU' then 'BI'਍ഀ
	when 'PO' then 'BB'਍ഀ
	when 'BX' then 'WX'਍ഀ
	when 'RL' then 'BB'਍ഀ
	when 'BZ' then 'BZ'਍ഀ
	when 'ZZ' then 'BZ'਍ഀ
	else  'BA'਍ഀ
	end਍ഀ
਍ഀ
/* 12/05/02 - added bookformat detail for <b013> to distinguish MM from TP - can add more formats here*/਍ഀ
	select @c_onixbookformdetail =਍ഀ
	case @c_bisacformatcode਍ഀ
	when  'MM' then '01'਍ഀ
	when  'RL' then '07'਍ഀ
	when  'BD' then '04'਍ഀ
	else  '99'਍ഀ
	end਍ഀ
	/*print 'After Case - onix format code = ' + 	@c_onixformatcode*/਍ഀ
end਍ഀ
else if @c_bisacmediacode='R' /* CD Rom Media Type */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'DB' /* DB=Onix CD-ROM designation */਍ഀ
end਍ഀ
else if @c_bisacmediacode='C' /* Calender Media Type */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'PC' /* modied 11/05/02 - CT - set format code to PC for Calendar */਍ഀ
end਍ഀ
਍ഀ
else if @c_bisacmediacode='D' /* Diskette */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'DF' /* DF=Onix Diskette designation */਍ഀ
end਍ഀ
਍ഀ
else if @c_bisacmediacode='F' /* Film */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'FB' /* FB=Onix Film designation */਍ഀ
end਍ഀ
else if @c_bisacmediacode='J' /* Journal */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'BC' /* BC=Onix Paperback designation */਍ഀ
end਍ഀ
else if @c_bisacmediacode='K' /* Maps */਍ഀ
begin਍ഀ
	select @c_onixformatcode =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'FF' then 'CB'  /* Folded */਍ഀ
	when 'GG' then 'CE'  /* Globe */਍ഀ
	when 'NF' then 'CD'  /* Rolled */਍ഀ
	else  'CZ' /* other */਍ഀ
	end਍ഀ
end਍ഀ
else if @c_bisacmediacode='M' /* Microform */਍ഀ
begin਍ഀ
	select @c_onixformatcode =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'FI' then 'MB'  /* Microfiche */਍ഀ
	when 'MF' then 'MC'  /* Microfilm */਍ഀ
	else 'MZ' /* other */਍ഀ
	end਍ഀ
end਍ഀ
else if @c_bisacmediacode='N' /* Books and Things */਍ഀ
begin਍ഀ
	/** Set the Onix Format Code to Mixed Media 'WW' **/਍ഀ
਍ഀ
	select @c_onixformatcode = 'WW'਍ഀ
	/** Then set the Format Desc to the description **/਍ഀ
਍ഀ
	select @c_onixformatdesc =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'DL' then 'Book and Doll'  ਍ഀ
	when 'MU' then 'Book and Music'਍ഀ
	when 'OO' then 'Book and Other'਍ഀ
	when 'PL' then 'Book and Plush Toy'਍ഀ
	when 'TY' then 'Book and Toy'਍ഀ
	else  'Book and Other' /* other */਍ഀ
	end਍ഀ
end਍ഀ
else if @c_bisacmediacode='V' /* Video */਍ഀ
begin਍ഀ
	select @c_onixformatcode = 'FB' /* FB=Onix Film designation */਍ഀ
end਍ഀ
਍ഀ
else if @c_bisacmediacode='O' /* Other */਍ഀ
begin਍ഀ
	select @c_onixformatcode =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'ZZ' then 'ZZ'਍ഀ
	else  'OO' /* other */਍ഀ
	end਍ഀ
਍ഀ
	select @c_onixformatdesc =਍ഀ
	case @c_bisacformatcode਍ഀ
	when 'ZZ' then 'Other Merchandise'਍ഀ
	when 'OO' then 'Undefined'਍ഀ
	end਍ഀ
end਍ഀ
਍ഀ
਍ഀ
else਍ഀ
begin਍ഀ
select @c_onixformatcode='00'  /* Set all other types to 'Undefined'*/਍ഀ
end਍ഀ
਍ഀ
/*** IMPORTANT NOTE: the variable c_bisacmediacode is also used for page count validation in b061 ***/਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '<b012>' + @c_onixformatcode + '</b012>'਍ഀ
਍ഀ
/* Added 5/9/02 by DSL to output Book Form Detail = 07 if binding is Reinforced Library Binding */਍ഀ
/* 12/06/02 - CT - modified to include <b013> for more formats */਍ഀ
if @c_onixbookformdetail <> '99' ਍ഀ
begin਍ഀ
	insert into eloonixfeed (feedtext) select '<b013>' +@c_onixbookformdetail + '</b013>'਍ഀ
end਍ഀ
਍ഀ
/* Set the description for Plush Books */਍ഀ
if @c_onixformatcode='BI' ਍ഀ
begin਍ഀ
	select @c_onixformatdesc = 'Plush Book'਍ഀ
end਍ഀ
if @c_onixformatdesc <> ''਍ഀ
begin਍ഀ
	/** b014 ProductFormDescription **/਍ഀ
	insert into eloonixfeed (feedtext) select '<b014>' + @c_onixformatdesc + '</b014>'਍ഀ
end਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output series composite            **/਍ഀ
/*****************************************/਍ഀ
/* 9/10/02 - CT - modifed to use alternatedesc1 for series title if this field is populated */਍ഀ
਍ഀ
select @i_seriescode = seriescode from bookdetail where bookkey=@i_bookkey਍ഀ
if @i_seriescode is not null and @i_seriescode > 0਍ഀ
begin ਍ഀ
	/* first try for alternatedesc 1  (this allows > 40 characters ) */਍ഀ
	select @c_seriesdesc = alternatedesc1 from gentables where tableid=327 ਍ഀ
	and datacode=@i_seriescode਍ഀ
	਍ഀ
	/* get length of datadesc title to use if alternatedesc1 is null or blank */਍ഀ
	select @i_seriesdesclength = LEN(datadesc) from gentables where tableid = 327 ਍ഀ
	and datacode = @i_seriescode਍ഀ
	਍ഀ
	if @c_seriesdesc is NULL or @c_seriesdesc = ' ' /* alternatedesc1 is blank, so use datadesc  */਍ഀ
	begin਍ഀ
		select @c_seriesdesc=datadesc from gentables where tableid=327 ਍ഀ
		and datacode=@i_seriescode਍ഀ
਍ഀ
		/** added 07/17/02 - CT- Output warning message if series desc length = 40 - this implies series name was truncated on import ***/਍ഀ
		if @i_seriesdesclength = 40 ਍ഀ
		begin਍ഀ
			select @c_tempmessage =  'Series  may have been truncated ' ਍ഀ
			exec eloonixvalidation_sp @i_warning, @i_bookkey, @c_tempmessage਍ഀ
		end਍ഀ
਍ഀ
	end਍ഀ
਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<series>'਍ഀ
਍ഀ
      /** b018 TitleOfSeries ***/਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<b018><![CDATA[' + @c_seriesdesc + ']]></b018>'਍ഀ
਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '</series>'਍ഀ
਍ഀ
	਍ഀ
end਍ഀ
/*****************************************/਍ഀ
/** Output b028 DistinctiveTitle - Title Prefix plus Title **/਍ഀ
/** To be used only if NOT using b030 (TitlePrefix) and b031 (Title without Prefix) **/਍ഀ
/** USE ONLY WHEN TITLEPREFIX IS NULL - For QSI Web Site ALWAYS output b028  **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
select @c_titleprefix=titleprefix ਍ഀ
from bookdetail where bookkey=@i_bookkey਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
select @c_title=title from book where bookkey=@i_bookkey਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
if @c_title is null or @c_title = ''਍ഀ
begin਍ഀ
	select @i_validationerrorind = 1਍ഀ
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Title Missing'਍ഀ
end਍ഀ
਍ഀ
if @c_titleprefix is null or @c_titleprefix = '' ਍ഀ
begin਍ഀ
	/** Only output b028 for Onix if Title Prefix is not available **/਍ഀ
	/** If Title Prefix is populated, outout b030 and b031 **/਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<b028><![CDATA[' + @c_title + ']]></b028>'਍ഀ
	਍ഀ
end਍ഀ
/*਍ഀ
else਍ഀ
begin਍ഀ
    IF (@detail_level > 2)਍ഀ
    begin਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<b028><![CDATA[' + @c_titleprefix + ' ' + @c_title + ']]></b028>'਍ഀ
    end਍ഀ
end਍ഀ
*/਍ഀ
਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output b030 Title Prefix **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
/** c_titleprefix loaded in b028 **/਍ഀ
if @c_titleprefix is not null and @c_titleprefix <> ''਍ഀ
begin਍ഀ
	਍ഀ
 ਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
      	select '<b030><![CDATA[' + @c_titleprefix +  ']]></b030>'਍ഀ
	਍ഀ
਍ഀ
end਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output b031 Title Without Prefix **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
/** c_title loaded in b028 - only output of titleprefix is not null**/਍ഀ
if @c_titleprefix is not null and @c_titleprefix <> ''਍ഀ
begin਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<b031><![CDATA[' + @c_title + ']]></b031>'਍ഀ
end਍ഀ
/*਍ഀ
else਍ഀ
begin਍ഀ
    IF (@detail_level > 2)਍ഀ
    begin਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<b031><![CDATA[' + @c_title + ']]></b031>'਍ഀ
    end਍ഀ
end਍ഀ
*/਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output b029 Subtitle **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) ਍ഀ
	select '<b029><![CDATA[' + subtitle + ']]></b029>' ਍ഀ
      from book where bookkey=@i_bookkey਍ഀ
      and subtitle is not null and subtitle <> ''਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output <Contributor> Author Loop    **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
/* 10/2002 - modified by CT to output  new author fields */਍ഀ
DECLARE cursor_author INSENSITIVE CURSOR਍ഀ
FOR਍ഀ
select ba.authortypecode,ba.sortorder,a.displayname,a.lastname, a.firstname, a.middlename,a.authorsuffix,਍ഀ
a.corporatecontributorind,a.title, a.biography਍ഀ
 from bookauthor ba,author a਍ഀ
 where ba.bookkey=@i_bookkey and a.authorkey=ba.authorkey਍ഀ
 order by ba.sortorder਍ഀ
FOR READ ONLY਍ഀ
਍ഀ
਍伀倀䔀一 挀甀爀猀漀爀开愀甀琀栀漀爀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀 㴀 　ഀ
਍䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开愀甀琀栀漀爀ഀ
਍䤀一吀伀 䀀椀开愀甀琀栀漀爀琀礀瀀攀挀漀搀攀Ⰰ䀀椀开愀甀琀栀漀爀猀漀爀琀漀爀搀攀爀Ⰰഀ
਍䀀挀开愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀Ⰰ䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀Ⰰ䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀Ⰰ 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀Ⰰ 䀀挀开愀甀琀栀漀爀猀甀昀昀椀砀Ⰰ 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀Ⰰ 䀀挀开愀甀琀栀漀爀琀椀琀氀攀Ⰰ 䀀挀开戀椀漀最爀愀瀀栀礀ഀ
਍ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍ഀ
਍椀昀 䀀椀开愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀 㰀 　 ⼀⨀⨀ 一漀 䄀甀琀栀漀爀猀 ⨀⨀⼀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀挀开搀甀洀洀礀㴀✀✀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开瘀愀氀椀搀愀琀椀漀渀攀爀爀漀爀椀渀搀 㴀 ㄀ഀ
਍ऀ攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开攀爀爀漀爀Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ ✀䄀甀琀栀漀爀 洀椀猀猀椀渀最✀ഀ
਍攀渀搀ഀ
਍ഀ
਍眀栀椀氀攀 ⠀䀀椀开愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㄀ ⤀ഀ
਍戀攀最椀渀ഀ
਍ऀ䤀䘀 ⠀䀀椀开愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㈀⤀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ⼀⨀⨀ 伀甀琀瀀甀琀 㰀䌀漀渀琀爀椀戀甀琀漀爀㸀 䄀甀琀栀漀爀 䰀漀漀瀀    ⨀⨀⼀ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ 猀攀氀攀挀琀 ✀㰀挀漀渀琀爀椀戀甀琀漀爀㸀✀ ഀ
਍ऀഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ⼀⨀⨀ 伀甀琀瀀甀琀 戀　㌀㐀 䌀漀渀琀爀椀戀甀琀漀爀匀攀焀甀攀渀挀攀一甀洀戀攀爀 匀漀爀琀漀爀搀攀爀 ⨀⨀⼀ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ椀昀 䀀椀开愀甀琀栀漀爀猀漀爀琀漀爀搀攀爀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀甀琀栀漀爀猀漀爀琀漀爀搀攀爀 㸀 　ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㌀㐀㸀✀ ⬀ ഀ
਍ऀऀ挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀 ⠀㄀　⤀Ⰰ䀀椀开愀甀琀栀漀爀猀漀爀琀漀爀搀攀爀⤀ ⬀ ✀㰀⼀戀　㌀㐀㸀✀ഀ
਍ऀ攀渀搀ഀ
਍ഀ
਍ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ⼀⨀⨀ 伀甀琀瀀甀琀 戀　㌀㔀 䌀漀渀琀爀椀戀甀琀漀爀刀漀氀攀 ⴀ 䄀甀琀栀漀爀 吀礀瀀攀ऀऀ    ⨀⨀⼀ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ऀഀ
਍ऀ椀昀 䀀椀开愀甀琀栀漀爀琀礀瀀攀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀甀琀栀漀爀琀礀瀀攀挀漀搀攀 㸀 　 ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀऀ猀攀氀攀挀琀 䀀挀开愀甀琀栀漀爀琀礀瀀攀搀攀猀挀㴀搀愀琀愀搀攀猀挀 昀爀漀洀 ഀ
਍ऀऀ最攀渀琀愀戀氀攀猀 眀栀攀爀攀 琀愀戀氀攀椀搀㴀㄀㌀㐀 愀渀搀 搀愀琀愀挀漀搀攀㴀䀀椀开愀甀琀栀漀爀琀礀瀀攀挀漀搀攀ഀ
਍ഀ
਍ऀऀ猀攀氀攀挀琀 䀀挀开漀渀椀砀愀甀琀栀漀爀琀礀瀀攀挀漀搀攀 㴀 ഀ
਍ऀऀ挀愀猀攀 甀瀀瀀攀爀 ⠀䀀挀开愀甀琀栀漀爀琀礀瀀攀搀攀猀挀⤀ഀ
਍ऀऀ眀栀攀渀 ✀䄀䈀刀䤀䐀䜀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䈀　㐀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䄀䐀䄀倀吀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䈀　㔀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀䄀䘀吀䔀刀圀䄀刀䐀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㤀✀                             ഀ
਍ऀऀ眀栀攀渀 ✀䄀一一伀吀䄀吀䤀伀一匀 䈀夀✀ 琀栀攀渀 ✀䄀㈀　✀                           ഀ
਍ऀऀ眀栀攀渀 ✀䄀匀 吀伀䰀䐀 䈀夀✀ 琀栀攀渀 ✀䈀　㜀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀䄀匀 吀伀䰀䐀 吀伀✀ 琀栀攀渀 ✀䄀　㄀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀䄀唀吀䠀伀刀✀ 琀栀攀渀 ✀䄀　㄀✀                                   ഀ
਍ऀऀ眀栀攀渀 ✀䄀唀吀䠀伀刀⼀䌀伀一吀刀䤀䈀唀吀伀刀 一伀吀 䄀倀倀䰀䤀䌀䄀䈀䰀䔀✀ 琀栀攀渀 ✀娀㤀㤀✀        ഀ
਍ऀऀ眀栀攀渀 ✀䌀伀䴀䴀䔀一吀䄀刀䤀䔀匀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㄀✀                          ഀ
਍ऀऀ眀栀攀渀 ✀䌀伀䴀倀䤀䰀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䌀　㄀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䌀伀一䌀䔀倀吀 䈀夀✀ 琀栀攀渀 ✀䄀㄀　✀                               ഀ
਍ऀऀ眀栀攀渀 ✀䌀伀一吀刀䤀䈀唀吀䤀伀一 䈀夀✀ 琀栀攀渀 ✀䄀　㄀✀                          ഀ
਍ऀऀ眀栀攀渀 ✀䌀刀䔀䄀吀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䄀　㤀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀䐀䔀匀䤀䜀一䔀䐀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㄀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䔀䐀䤀吀伀刀✀ 琀栀攀渀 ✀䈀　㄀✀                                   ഀ
਍ऀऀ眀栀攀渀 ✀䔀倀䤀䰀伀䜀唀䔀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㈀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䔀堀倀䔀刀䤀䴀䔀一吀匀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㜀✀                          ഀ
਍ऀऀ眀栀攀渀 ✀䘀伀伀吀一伀吀䔀匀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㔀✀                             ഀ
਍ऀऀ眀栀攀渀 ✀䘀伀刀䔀圀伀刀䐀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㌀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䤀䰀䰀唀匀吀刀䄀吀伀刀✀ 琀栀攀渀 ✀䄀㄀㈀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀䤀一吀刀伀䐀唀䌀吀䤀伀一 䈀夀✀ 琀栀攀渀 ✀䄀㈀㐀✀                          ഀ
਍ऀऀ眀栀攀渀 ✀䴀䔀䴀伀䤀刀 䈀夀✀ 琀栀攀渀 ✀䄀㈀㘀✀                                ഀ
਍ऀऀ眀栀攀渀 ✀一䄀刀刀䄀吀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䔀　㌀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀一伀吀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䄀㈀　✀                                 ഀ
਍ऀऀ眀栀攀渀 ✀伀吀䠀䔀刀✀ 琀栀攀渀 ✀娀㤀㤀✀                                    ഀ
਍ऀऀ眀栀攀渀 ✀倀䠀伀吀伀䜀刀䄀倀䠀䔀刀✀ 琀栀攀渀 ✀䄀㄀㌀✀                             ഀ
਍ऀऀ眀栀攀渀 ✀倀刀䔀䘀䄀䌀䔀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㔀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀倀刀伀䐀唀䌀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䐀　㄀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀倀刀伀䰀伀䜀唀䔀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㘀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀刀䔀䄀䐀 䈀夀✀ 琀栀攀渀 ✀䔀　㜀✀                                  ഀ
਍ऀऀ眀栀攀渀 ✀刀䔀吀伀䰀䐀 䈀夀✀ 琀栀攀渀 ✀䈀　㌀✀                                ഀ
਍ऀऀ眀栀攀渀 ✀刀䔀嘀䤀匀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䈀　㈀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀匀䔀䰀䔀䌀吀䔀䐀 䈀夀✀ 琀栀攀渀 ✀䌀　㈀✀                              ഀ
਍ऀऀ眀栀攀渀 ✀匀唀䴀䴀䄀刀夀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㜀✀                               ഀ
਍ऀऀ眀栀攀渀 ✀匀唀倀倀䰀䔀䴀䔀一吀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㠀✀                            ഀ
਍ऀऀ眀栀攀渀 ✀吀䔀堀吀 䈀夀✀ 琀栀攀渀 ✀䄀㄀㐀✀                                  ഀ
਍ऀऀ眀栀攀渀 ✀吀刀䄀一匀䰀䄀吀伀刀✀ 琀栀攀渀 ✀䈀　㘀✀ഀ
਍ऀऀ攀氀猀攀 ऀ✀䄀　㄀✀                               ഀ
਍ऀऀ攀渀搀 ⼀⨀攀渀搀 挀愀猀攀 ⨀⼀ഀ
਍ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㌀㔀㸀✀ ⬀ 䀀挀开漀渀椀砀愀甀琀栀漀爀琀礀瀀攀挀漀搀攀 ⬀ ✀㰀⼀戀　㌀㔀㸀✀ഀ
਍ऀऀ攀渀搀 ⼀⨀椀昀 愀甀琀栀漀爀琀礀瀀攀挀漀搀攀 ⨀⼀ഀ
਍ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 伀甀琀瀀甀琀 戀　㌀㜀 倀攀爀猀漀渀一愀洀攀䤀渀瘀攀爀琀攀搀 ⴀ 䄀甀琀栀漀爀 一愀洀攀ऀऀ    ⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 䴀伀䐀䤀䘀䤀䔀䐀 㐀⼀㤀⼀　㄀ 戀礀 䐀匀䰀 ⴀ 戀甀椀氀搀 椀渀瘀攀爀琀攀搀 渀愀洀攀 爀愀琀栀攀爀 琀栀愀渀 甀猀攀 䐀椀猀瀀氀愀礀一愀洀攀 ⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 䴀伀䐀䤀䘀䤀䔀䐀 ㄀　⼀㈀　　㈀ 戀礀 䌀吀 ⴀ 瀀攀爀 匀☀匀 䔀氀漀焀甀攀渀挀攀 攀渀栀愀渀挀攀洀攀渀琀猀 猀瀀攀挀ऀ⨀⼀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ ഀ
਍ऀऀ椀昀 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀 㴀 　 漀爀 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀 椀猀 渀甀氀氀ഀ
਍ऀऀ   戀攀最椀渀  ⼀⨀ 愀甀琀栀漀爀 椀猀 渀漀琀 挀漀爀瀀漀爀愀琀攀 挀漀渀琀爀椀戀甀琀漀爀 ⨀⼀ഀ
਍ऀऀऀ椀昀 䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀 㰀㸀 ✀✀ഀ
਍ऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀ 椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀ 猀攀氀攀挀琀 ✀㰀戀　㌀㜀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀 ⬀ ✀Ⰰ ✀ ⬀ 䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㌀㜀㸀✀ഀ
਍ऀऀऀऀഀ
਍ऀऀऀऀ 椀昀 䀀挀开愀甀琀栀漀爀琀椀琀氀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开愀甀琀栀漀爀琀椀琀氀攀 㰀㸀 ✀ ✀ ⼀⨀ 漀甀瀀琀甀琀 琀椀琀氀攀 ⨀⼀ഀ
਍ऀऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㌀㠀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀琀椀琀氀攀 ⬀ ✀崀崀㸀㰀⼀戀　㌀㠀㸀✀ഀ
਍ऀऀऀऀऀ攀渀搀ഀ
਍ऀऀऀऀ 椀昀 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀 㰀㸀 ✀ ✀ഀ
਍ऀऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㌀㤀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀 ⬀ ✀ ✀ ⬀ 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀 ⬀✀崀崀㸀㰀⼀戀　㌀㤀㸀✀ഀ
਍ऀऀऀऀऀ攀渀搀ഀ
਍ऀऀऀऀ 椀昀 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀 椀猀 渀甀氀氀 漀爀 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀 㴀 ✀ ✀ ⼀⨀ ㄀㄀⼀　㄀⼀　㈀ ⴀ 䌀吀 ⴀ 椀渀猀攀爀琀 漀渀氀礀 昀椀爀猀琀渀愀洀攀 椀渀 㰀戀　㌀㤀㸀 ⨀⼀ഀ
਍ऀऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㌀㤀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㌀㤀㸀✀ഀ
਍ऀऀऀऀऀ攀渀搀ഀ
਍ऀऀऀऀ 椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㐀　㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㐀　㸀✀ഀ
਍ഀ
਍ऀऀऀऀ 椀昀 䀀挀开愀甀琀栀漀爀猀甀昀昀椀砀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开愀甀琀栀漀爀猀甀昀昀椀砀 㰀㸀 ✀ ✀ ⼀⨀ 漀甀瀀琀甀琀 猀甀昀昀椀砀 ⨀⼀ഀ
਍ऀऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀㈀㐀㠀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀猀甀昀昀椀砀 ⬀ ✀崀崀㸀㰀⼀戀㈀㐀㠀㸀✀ഀ
਍ऀऀऀऀऀ攀渀搀ഀ
਍ഀ
਍ऀऀऀऀ攀渀搀 ⼀⨀ 椀昀 昀椀爀猀琀渀愀洀攀 椀猀 渀漀琀 渀甀氀氀 漀爀 戀氀愀渀欀 ⨀⼀ഀ
਍ऀऀऀ攀氀猀攀 ⼀⨀ 漀甀琀瀀甀琀 氀愀猀琀 渀愀洀攀 椀渀猀琀攀愀搀 ⨀⼀ഀ
਍ऀऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㐀　㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㐀　㸀✀ഀ
਍ऀऀऀऀ攀渀搀ഀ
਍ऀऀऀഀ
਍ऀऀ  攀渀搀 ⼀⨀ 愀甀栀琀漀爀 椀猀 渀漀琀 挀漀爀瀀漀爀愀琀攀 挀漀渀琀爀椀戀甀琀漀爀 ⨀⼀ഀ
਍ऀऀ攀氀猀攀 ⼀⨀ 愀甀琀栀漀爀 䤀匀 挀漀爀瀀漀爀愀琀攀 挀漀渀琀爀椀戀甀琀漀爀 ⨀⼀ഀ
਍ऀऀ戀攀最椀渀ऀഀ
਍ऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ഀ
਍ऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㐀㜀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀⬀ 䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㐀㜀㸀✀ഀ
਍ऀऀ攀渀搀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 伀甀琀瀀甀琀 戀　㐀㐀 䄀甀琀栀漀爀 䈀椀漀 ऀऀ    ⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 䄀搀搀攀搀 㜀⼀㠀⼀　㈀  戀礀 䐀匀䰀 愀琀 琀栀攀 爀攀焀甀攀猀琀 漀昀 䤀渀最爀愀洀 ⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍ऀऀऀ椀昀 䀀挀开戀椀漀最爀愀瀀栀礀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开戀椀漀最爀愀瀀栀礀 㰀㸀 ✀✀ഀ
਍ऀऀऀ戀攀最椀渀ഀ
਍ऀऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㐀㐀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开戀椀漀最爀愀瀀栀礀 ⬀ ✀崀崀㸀㰀⼀戀　㐀㐀㸀✀ഀ
਍ऀऀऀ攀渀搀ഀ
਍ऀऀഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀ 䔀渀搀 漀昀 㰀䌀漀渀琀爀椀戀甀琀漀爀㸀 䄀甀琀栀漀爀 䰀漀漀瀀    ⨀⨀⼀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ 猀攀氀攀挀琀 ✀㰀⼀挀漀渀琀爀椀戀甀琀漀爀㸀✀ ഀ
਍ऀ攀渀搀 ⼀⨀ 椀昀 愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀 ⨀⼀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀 㴀 　ഀ
਍ऀ䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开愀甀琀栀漀爀ഀ
਍䤀一吀伀 䀀椀开愀甀琀栀漀爀琀礀瀀攀挀漀搀攀Ⰰ䀀椀开愀甀琀栀漀爀猀漀爀琀漀爀搀攀爀Ⰰഀ
਍䀀挀开愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀Ⰰ䀀挀开愀甀琀栀漀爀氀愀猀琀渀愀洀攀Ⰰ䀀挀开愀甀琀栀漀爀昀椀爀猀琀渀愀洀攀Ⰰ 䀀挀开愀甀琀栀漀爀洀椀搀搀氀攀渀愀洀攀Ⰰ 䀀挀开愀甀琀栀漀爀猀甀昀昀椀砀Ⰰ 䀀椀开挀漀爀瀀漀爀愀琀攀挀漀渀琀爀椀戀甀琀漀爀椀渀搀Ⰰ 䀀挀开愀甀琀栀漀爀琀椀琀氀攀Ⰰ 䀀挀开戀椀漀最爀愀瀀栀礀ഀ
਍ഀ
਍      ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开愀甀琀栀漀爀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍攀渀搀ഀ
਍ഀ
਍挀氀漀猀攀 挀甀爀猀漀爀开愀甀琀栀漀爀ഀ
਍搀攀愀氀氀漀挀愀琀攀 挀甀爀猀漀爀开愀甀琀栀漀爀ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀　㐀㤀 䌀漀渀琀爀椀戀甀琀漀爀匀琀愀琀攀洀攀渀琀 ⴀ 䘀甀氀氀 䄀甀琀栀漀爀 䐀椀猀瀀氀愀礀 一愀洀攀  ⴀ 䰀攀瘀攀氀 ㈀ 漀渀氀礀    ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀挀开昀甀氀氀愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀 㴀 昀甀氀氀愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀ഀ
਍ऀ 昀爀漀洀 戀漀漀欀搀攀琀愀椀氀 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍椀昀 䀀挀开昀甀氀氀愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开昀甀氀氀愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀  㰀㸀 ✀✀ഀ
਍戀攀最椀渀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀　㐀㤀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开昀甀氀氀愀甀琀栀漀爀搀椀猀瀀氀愀礀渀愀洀攀 ⬀ ✀崀崀㸀㰀⼀戀　㐀㤀㸀✀ഀ
਍ऀഀ
਍ 攀渀搀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀ 䔀搀椀琀椀漀渀 琀礀瀀攀 挀漀搀攀 ⠀ 戀　㔀㘀 ⤀ 愀搀搀攀搀 ⴀ 䌀吀 ㄀⼀　㌀⼀　㌀        ⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍猀攀氀攀挀琀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㴀 攀搀椀琀椀漀渀挀漀搀攀 昀爀漀洀 戀漀漀欀搀攀琀愀椀氀 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍椀昀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ഀ
਍ऀ猀攀氀攀挀琀 䀀挀开攀搀椀琀椀漀渀琀礀瀀攀挀漀搀攀㴀戀椀猀愀挀搀愀琀愀挀漀搀攀 昀爀漀洀 最攀渀琀愀戀氀攀猀 眀栀攀爀攀 琀愀戀氀攀椀搀㴀㈀　　 ഀ
਍ऀ愀渀搀 搀愀琀愀挀漀搀攀㴀䀀椀开攀搀椀琀椀漀渀挀漀搀攀ഀ
਍ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀　㔀㘀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开攀搀椀琀椀漀渀琀礀瀀攀挀漀搀攀 ⬀ ✀崀崀㸀㰀⼀戀　㔀㘀㸀✀ഀ
਍ 攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀ 䔀搀椀琀椀漀渀  攀搀椀琀椀漀渀 渀甀洀戀攀爀 ⠀戀　㔀㜀⤀ 愀搀搀攀搀 ⴀ 䌀吀 ㄀⼀　㌀⼀　㌀        ⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㴀 攀搀椀琀椀漀渀挀漀搀攀 昀爀漀洀 戀漀漀欀搀攀琀愀椀氀 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍椀昀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ഀ
਍ऀ猀攀氀攀挀琀 䀀搀开攀搀椀琀椀漀渀渀甀洀戀攀爀 㴀 一甀洀攀爀椀挀搀攀猀挀㄀ 昀爀漀洀 最攀渀琀愀戀氀攀猀 眀栀攀爀攀 琀愀戀氀攀椀搀㴀㈀　　 ഀ
਍ऀ愀渀搀 搀愀琀愀挀漀搀攀㴀䀀椀开攀搀椀琀椀漀渀挀漀搀攀ഀ
਍ऀ椀昀 䀀搀开攀搀椀琀椀漀渀渀甀洀戀攀爀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀搀开攀搀椀琀椀漀渀渀甀洀戀攀爀 㸀 　⸀　 ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㔀㜀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀⬀  挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀 ⠀㄀　⤀Ⰰ䀀搀开攀搀椀琀椀漀渀渀甀洀戀攀爀⤀ ⬀ ✀崀崀㸀㰀⼀戀　㔀㜀㸀✀ഀ
਍ऀ攀渀搀ഀ
਍ 攀渀搀ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀　㔀㠀 䔀搀椀琀椀漀渀匀琀愀琀攀洀攀渀琀 ⴀ 甀猀椀渀最 昀爀攀攀昀漀爀洀 昀椀攀氀搀      ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㴀 攀搀椀琀椀漀渀挀漀搀攀 昀爀漀洀 戀漀漀欀搀攀琀愀椀氀 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍椀昀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开攀搀椀琀椀漀渀挀漀搀攀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀挀开攀搀椀琀椀漀渀搀攀猀挀㴀搀愀琀愀搀攀猀挀 昀爀漀洀 最攀渀琀愀戀氀攀猀 眀栀攀爀攀 琀愀戀氀攀椀搀㴀㈀　　 ഀ
਍ऀ愀渀搀 搀愀琀愀挀漀搀攀㴀䀀椀开攀搀椀琀椀漀渀挀漀搀攀ഀ
਍ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀　㔀㠀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开攀搀椀琀椀漀渀搀攀猀挀 ⬀ ✀崀崀㸀㰀⼀戀　㔀㠀㸀✀ഀ
਍ 攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀　㔀㤀 䰀愀渀最甀愀最攀      ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 㴀 ✀✀ഀ
਍猀攀氀攀挀琀 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀㴀✀✀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀㴀最⸀攀氀漀焀甀攀渀挀攀昀椀攀氀搀琀愀最ഀ
਍昀爀漀洀 戀漀漀欀搀攀琀愀椀氀 戀搀Ⰰ最攀渀琀愀戀氀攀猀 最ഀ
਍眀栀攀爀攀 戀搀⸀戀漀漀欀欀攀礀㴀 䀀椀开戀漀漀欀欀攀礀 愀渀搀 最⸀琀愀戀氀攀椀搀㴀㌀㄀㠀 ഀ
਍愀渀搀 最⸀搀愀琀愀挀漀搀攀㴀戀搀⸀氀愀渀最甀愀最攀挀漀搀攀ഀ
਍椀昀 䀀䀀攀爀爀漀爀 㰀㸀　ഀ
਍戀攀最椀渀ഀ
਍ऀ爀漀氀氀戀愀挀欀 琀爀愀渀ഀ
਍ऀ⼀⨀攀砀攀挀 攀氀漀瀀爀漀挀攀猀猀攀爀爀漀爀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ䀀䀀攀爀爀漀爀Ⰰ✀䔀刀刀伀刀✀Ⰰ✀匀儀䰀 䔀爀爀漀爀✀⨀⼀ഀ
਍ऀ爀攀琀甀爀渀 ⴀ㄀  ⼀⨀⨀ 䘀愀琀愀氀 匀儀䰀 䔀爀爀漀爀 ⨀⨀⼀ഀ
਍攀渀搀ഀ
਍ഀ
਍椀昀 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀 㰀㸀 ✀✀ഀ
਍戀攀最椀渀ഀ
਍⼀⨀⨀  䌀漀渀瘀攀爀琀 䔀氀漀焀甀攀渀挀攀 䘀椀攀氀搀 吀愀最 昀漀爀 䰀愀渀最甀愀最攀 琀漀 伀一䤀堀 䰀愀渀最甀愀最攀 䌀漀搀攀猀 ⨀⨀⼀ഀ
਍ഀ
਍ऀ猀攀氀攀挀琀 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 㴀 ഀ
਍ऀ挀愀猀攀 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀ഀ
਍ऀ眀栀攀渀 ✀䔀一✀ 琀栀攀渀 ✀攀渀最✀ ⼀⨀䔀渀最氀椀猀栀⨀⼀ഀ
਍ऀ眀栀攀渀 ✀䘀刀✀ 琀栀攀渀 ✀昀爀攀✀ ⼀⨀ 䘀爀攀渀挀栀 ⨀⼀ഀ
਍ऀ眀栀攀渀 ✀匀倀✀ 琀栀攀渀 ✀猀瀀愀✀ ⼀⨀ 匀瀀愀渀椀猀栀 ⨀⼀ഀ
਍ऀ攀氀猀攀 ✀一伀 䴀䄀倀✀ ⼀⨀ 匀攀琀 琀漀 ✀一伀 䴀䄀倀✀ ⴀ 圀愀爀渀椀渀最 洀攀猀猀愀最攀 眀椀氀氀 戀攀 漀甀琀瀀甀琀 昀漀爀 洀椀猀猀椀渀最 洀愀瀀瀀椀渀最 ⨀⼀ഀ
਍ऀ攀渀搀ഀ
਍ऀഀ
਍ऀ椀昀 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 㴀 ✀一伀 䴀䄀倀✀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀऀ猀攀氀攀挀琀 䀀挀开琀攀洀瀀洀攀猀猀愀最攀 㴀  ✀一漀 伀渀椀砀 䰀愀渀最甀愀最攀 䴀愀瀀 昀漀爀㨀 ✀ ⬀ 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀ഀ
਍ऀऀ攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开眀愀爀渀椀渀最Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ 䀀挀开琀攀洀瀀洀攀猀猀愀最攀ഀ
਍ऀ攀渀搀ഀ
਍ऀ攀氀猀攀 椀昀 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 㰀㸀 ✀✀ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ 猀攀氀攀挀琀 ✀㰀戀　㔀㤀㸀✀ ⬀ 䀀挀开漀渀椀砀氀愀渀最甀愀最攀挀漀搀攀 ഀ
਍ऀऀ⬀ ✀㰀⼀戀　㔀㤀㸀✀ഀ
਍ऀ攀渀搀ഀ
਍攀渀搀 ⼀⨀⨀ 䀀挀开攀氀漀氀愀渀最甀愀最攀挀漀搀攀 椀猀 渀漀琀 渀甀氀氀 ⨀⨀⼀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀　㘀㄀ 一甀洀戀攀爀伀昀倀愀最攀猀 ⴀ 倀愀最攀 䌀漀甀渀琀              ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍猀攀氀攀挀琀 䀀椀开瀀愀最攀挀漀甀渀琀 㴀 瀀愀最攀挀漀甀渀琀 昀爀漀洀 瀀爀椀渀琀椀渀最 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍愀渀搀 瀀爀椀渀琀椀渀最欀攀礀㴀㄀ഀ
਍ഀ
਍椀昀 䀀椀开瀀愀最攀挀漀甀渀琀 椀猀 渀甀氀氀 漀爀 䀀椀开瀀愀最攀挀漀甀渀琀 㴀 　 ⼀⨀ 䄀挀琀甀愀氀 倀愀最攀 䌀漀甀渀琀 椀猀 渀甀氀氀Ⰰ 琀爀礀 䔀猀琀椀洀愀琀攀搀 倀愀最攀 挀漀甀渀琀 ⨀⼀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开瀀愀最攀挀漀甀渀琀 㴀 琀攀渀琀愀琀椀瘀攀瀀愀最攀挀漀甀渀琀 昀爀漀洀 瀀爀椀渀琀椀渀最 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍ऀ愀渀搀 瀀爀椀渀琀椀渀最欀攀礀㴀㄀ഀ
਍攀渀搀ഀ
਍ഀ
਍椀昀 䀀椀开瀀愀最攀挀漀甀渀琀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开瀀愀最攀挀漀甀渀琀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ऀഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀　㘀㄀㸀✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开瀀愀最攀挀漀甀渀琀⤀ ⬀ ✀㰀⼀戀　㘀㄀㸀✀ഀ
਍ 攀渀搀ഀ
਍攀氀猀攀ഀ
਍戀攀最椀渀ഀ
਍ऀ椀昀 䀀挀开戀椀猀愀挀洀攀搀椀愀挀漀搀攀㴀✀䈀✀ ⼀⨀ 伀渀氀礀 伀甀琀瀀甀琀 倀愀最攀挀漀甀渀琀 圀愀爀渀椀渀最 昀漀爀 䴀攀搀椀愀 吀礀瀀攀 㴀 䈀漀漀欀 ⨀⼀ഀ
਍ऀऀ戀攀最椀渀ഀ
਍ऀऀ椀昀  䀀挀开漀渀椀砀昀漀爀洀愀琀挀漀搀攀 㰀㸀 ✀䈀䤀✀ ⼀⨀⨀ 一漀琀 昀漀爀 倀氀甀猀栀 䈀漀漀欀猀 ⨀⨀⼀ഀ
਍ऀऀऀ攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开眀愀爀渀椀渀最Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ ✀倀愀最攀 䌀漀甀渀琀 洀椀猀猀椀渀最✀ഀ
਍ऀऀ攀渀搀ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀　㘀㈀ 䤀氀氀甀猀琀爀愀琀椀漀渀猀一漀琀攀猀 ⴀ 䤀渀猀攀爀琀⼀䤀氀氀甀猀              ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍猀攀氀攀挀琀 䀀挀开椀氀氀甀猀 㴀 愀挀琀甀愀氀椀渀猀攀爀琀椀氀氀甀猀 昀爀漀洀 瀀爀椀渀琀椀渀最 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍愀渀搀 瀀爀椀渀琀椀渀最欀攀礀㴀㄀ഀ
਍ഀ
਍椀昀 䀀挀开椀氀氀甀猀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀挀开椀氀氀甀猀 㰀㸀 ✀✀ഀ
਍戀攀最椀渀ഀ
਍ऀഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀　㘀㈀㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀ ⬀ 䀀挀开椀氀氀甀猀 ⬀ ✀崀崀㸀㰀⼀戀　㘀㈀㸀✀ഀ
਍ 攀渀搀ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀ 䈀䤀匀䄀䌀 匀甀戀樀攀挀琀 䌀愀琀攀最漀爀椀攀猀   ⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍ഀ
਍䐀䔀䌀䰀䄀刀䔀 挀甀爀猀漀爀开猀甀戀樀攀挀琀 䤀一匀䔀一匀䤀吀䤀嘀䔀 䌀唀刀匀伀刀ഀ
਍䘀伀刀ഀ
਍猀攀氀攀挀琀 猀最⸀戀椀猀愀挀搀愀琀愀挀漀搀攀 ഀ
਍昀爀漀洀 戀漀漀欀戀椀猀愀挀挀愀琀攀最漀爀礀 戀戀Ⰰ 猀甀戀最攀渀琀愀戀氀攀猀 猀最ഀ
਍眀栀攀爀攀 戀戀⸀戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀 愀渀搀 戀戀⸀瀀爀椀渀琀椀渀最欀攀礀㴀㄀ 愀渀搀 猀最⸀琀愀戀氀攀椀搀 㴀 ㌀㌀㤀 愀渀搀 ഀ
਍猀最⸀搀愀琀愀挀漀搀攀㴀戀戀⸀戀椀猀愀挀挀愀琀攀最漀爀礀挀漀搀攀ഀ
਍愀渀搀 猀最⸀搀愀琀愀猀甀戀挀漀搀攀㴀戀戀⸀戀椀猀愀挀挀愀琀攀最漀爀礀猀甀戀挀漀搀攀ഀ
਍漀爀搀攀爀 戀礀 戀戀⸀猀漀爀琀漀爀搀攀爀ഀ
਍䘀伀刀 刀䔀䄀䐀 伀一䰀夀ഀ
਍ഀ
਍伀倀䔀一 挀甀爀猀漀爀开猀甀戀樀攀挀琀ഀ
਍ഀ
਍䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开猀甀戀樀攀挀琀ഀ
਍䤀一吀伀 䀀挀开戀椀猀愀挀猀甀戀樀攀挀琀挀漀搀攀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍猀攀氀攀挀琀 䀀椀开爀漀眀渀甀洀戀攀爀㴀　ഀ
਍椀昀 䀀椀开猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 ⴀ㄀ ഀ
਍戀攀最椀渀ഀ
਍ऀ攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开眀愀爀渀椀渀最Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ ✀一漀 䈀䤀匀䄀䌀 匀甀戀樀攀挀琀 䌀愀琀攀最漀爀椀攀猀✀ഀ
਍攀渀搀ഀ
਍ഀ
਍眀栀椀氀攀 ⠀䀀椀开猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㄀ ⤀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开爀漀眀渀甀洀戀攀爀 㴀 䀀椀开爀漀眀渀甀洀戀攀爀 ⬀ ㄀ഀ
਍ऀ䤀䘀 ⠀䀀椀开猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㈀⤀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀഀ
਍ഀ
਍ऀ椀昀 ⠀䀀椀开爀漀眀渀甀洀戀攀爀㴀㄀⤀ ⼀⨀ 吀栀椀猀 椀猀 琀栀攀 昀椀爀猀琀 爀攀挀漀爀搀ⴀ漀甀琀瀀甀琀 洀愀椀渀 爀攀挀漀爀搀 ⨀⼀ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ⼀⨀ 伀甀琀瀀甀琀 㰀戀　㘀㐀㸀 䈀䄀匀䤀䌀䴀愀椀渀匀甀戀樀攀挀琀 ⴀ   ⨀⼀ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㘀㐀㸀✀ ⬀ ഀ
਍ऀऀ䀀挀开戀椀猀愀挀猀甀戀樀攀挀琀挀漀搀攀 ⬀ ✀㰀⼀戀　㘀㐀㸀✀ഀ
਍ഀ
਍ഀ
਍ऀऀഀ
਍ഀ
਍ऀऀऀഀ
਍ऀ攀渀搀 ⼀⨀ 䘀椀爀猀琀 刀漀眀 瀀爀漀挀攀猀猀椀渀最 ⨀⼀ഀ
਍ऀഀ
਍ऀ椀昀 ⠀䀀椀开爀漀眀渀甀洀戀攀爀 㸀 ㄀⤀ ⼀⨀⨀ 伀甀琀瀀甀琀 愀搀搀椀琀椀漀渀愀氀 匀甀戀樀攀挀琀 挀愀琀攀最漀爀礀 戀氀漀挀欀猀 ⨀⨀⼀ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ⼀⨀ 伀甀琀瀀甀琀 㰀猀甀戀樀攀挀琀㸀Ⰰ 㰀戀　㘀㜀㸀 匀甀戀樀攀挀琀匀挀栀攀洀攀䤀搀攀渀琀椀昀椀攀爀 ⴀ ㄀　 㴀 䈀䄀匀䤀䌀   ⨀⼀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀猀攀氀攀挀琀 ✀㰀猀甀戀樀攀挀琀㸀✀ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㘀㜀㸀㄀　㰀⼀戀　㘀㜀㸀✀ഀ
਍ऀऀഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ⼀⨀ 伀甀琀瀀甀琀 㰀戀　㘀㤀㸀 匀甀戀樀攀挀琀䌀漀搀攀  ⨀⼀ഀ
਍ऀऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀ猀攀氀攀挀琀 ✀㰀戀　㘀㤀㸀✀ ⬀ 䀀挀开戀椀猀愀挀猀甀戀樀攀挀琀挀漀搀攀 ⬀ ✀㰀⼀戀　㘀㤀㸀✀ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ 猀攀氀攀挀琀 ✀㰀⼀猀甀戀樀攀挀琀㸀✀ഀ
਍ऀऀഀ
਍ഀ
਍ऀ攀渀搀 ⼀⨀⨀ 䄀搀搀椀琀椀漀渀愀氀 䌀愀琀攀最漀爀礀 䈀氀漀挀欀猀 ⨀⨀⼀ഀ
਍ഀ
਍ऀ攀渀搀 ⼀⨀ 椀昀 猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀 ⨀⼀ഀ
਍ऀഀ
਍ऀ䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开猀甀戀樀攀挀琀ഀ
਍ऀ䤀一吀伀 䀀挀开戀椀猀愀挀猀甀戀樀攀挀琀挀漀搀攀ഀ
਍      ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开猀甀戀樀攀挀琀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍攀渀搀ഀ
਍ഀ
਍挀氀漀猀攀 挀甀爀猀漀爀开猀甀戀樀攀挀琀ഀ
਍搀攀愀氀氀漀挀愀琀攀 挀甀爀猀漀爀开猀甀戀樀攀挀琀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀  漀甀琀瀀甀琀 䄀甀搀椀攀渀挀攀 䌀漀搀攀  㰀䄀甀搀椀攀渀挀攀䌀漀搀攀㸀 㰀戀　㜀㌀㸀             ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀ 䴀漀搀椀昀椀攀搀 㔀⼀㈀　　㌀ ⴀ 䌀吀ⴀ 䴀漀搀椀昀椀攀搀 琀漀 椀渀挀漀爀瀀漀爀愀琀攀 洀甀氀琀椀瀀氀攀 愀甀搀椀攀渀挀攀 挀漀搀攀猀 甀猀椀渀最 戀漀漀欀愀甀搀椀攀渀挀攀 琀愀戀氀攀 ⨀⼀ഀ
਍䐀䔀䌀䰀䄀刀䔀 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀 䤀一匀䔀一匀䤀吀䤀嘀䔀 䌀唀刀匀伀刀ഀ
਍䘀伀刀ഀ
਍猀攀氀攀挀琀 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀 ⠀㌀⤀Ⰰ愀甀搀椀攀渀挀攀挀漀搀攀⤀ ഀ
਍昀爀漀洀 戀漀漀欀愀甀搀椀攀渀挀攀 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀 ഀ
਍漀爀搀攀爀 戀礀 猀漀爀琀漀爀搀攀爀ഀ
਍䘀伀刀 刀䔀䄀䐀 伀一䰀夀ഀ
਍ഀ
਍伀倀䔀一 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀ഀ
਍ഀ
਍䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀ഀ
਍䤀一吀伀 䀀椀开愀甀搀椀攀渀挀攀挀漀搀攀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍猀攀氀攀挀琀 䀀椀开爀漀眀渀甀洀戀攀爀㴀　ഀ
਍椀昀 䀀椀开愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 ⴀ㄀ ഀ
਍戀攀最椀渀ഀ
਍ऀ攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开眀愀爀渀椀渀最Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ ✀一漀 䄀甀搀椀攀渀挀攀 䌀漀搀攀✀ഀ
਍攀渀搀ഀ
਍ഀ
਍眀栀椀氀攀 ⠀䀀椀开愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㄀ ⤀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开爀漀眀渀甀洀戀攀爀 㴀 䀀椀开爀漀眀渀甀洀戀攀爀 ⬀ ㄀ഀ
਍ऀ䤀䘀 ⠀䀀椀开愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀㰀㸀ⴀ㈀⤀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀഀ
਍ഀ
਍ऀ椀昀 ⠀䀀椀开爀漀眀渀甀洀戀攀爀 㸀㴀 ㄀⤀ ⼀⨀ 䈀攀最椀渀 挀漀搀攀 瀀爀漀挀攀猀猀椀渀最 ⴀ 伀甀琀瀀甀琀 愀甀搀椀攀渀挀攀 挀漀搀攀⨀⼀ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ⼀⨀ 伀甀琀瀀甀琀 㰀戀　㜀㌀㸀  愀甀搀椀攀渀挀攀 挀漀搀攀⨀⼀ഀ
਍ऀ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ऀ椀昀 ⠀䀀椀开愀甀搀椀攀渀挀攀挀漀搀攀 㰀㄀　⤀ഀ
਍ऀऀ戀攀最椀渀ഀ
਍ऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㜀㌀㸀✀ ⬀ ✀　✀ ⬀ 挀漀渀瘀攀爀琀⠀瘀愀爀挀栀愀爀⠀㈀㔀⤀Ⰰ䀀椀开愀甀搀椀攀渀挀攀挀漀搀攀⤀ ⬀ ✀㰀⼀戀　㜀㌀㸀✀ഀ
਍ऀऀ攀渀搀ഀ
਍ऀ攀氀猀攀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ ഀ
਍ऀऀऀ猀攀氀攀挀琀 ✀㰀戀　㜀㌀㸀✀ ⬀ 挀漀渀瘀攀爀琀⠀瘀愀爀挀栀愀爀⠀㈀㔀⤀Ⰰ䀀椀开愀甀搀椀攀渀挀攀挀漀搀攀⤀ ⬀ ✀㰀⼀戀　㜀㌀㸀✀ഀ
਍ऀ攀渀搀ഀ
਍ഀ
਍ഀ
਍ऀ攀渀搀 ⼀⨀挀漀搀攀 瀀爀漀挀攀猀猀椀渀最 ⨀⼀ഀ
਍ഀ
਍ऀ攀渀搀 ⼀⨀ 椀昀 愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀 ⨀⼀ഀ
਍ऀഀ
਍ऀ䘀䔀吀䌀䠀 一䔀堀吀 䘀刀伀䴀 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀ഀ
਍ऀ䤀一吀伀 䀀椀开愀甀搀椀攀渀挀攀挀漀搀攀ഀ
਍      ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开愀甀搀椀攀渀挀攀挀甀爀猀漀爀猀琀愀琀甀猀 㴀 䀀䀀䘀䔀吀䌀䠀开匀吀䄀吀唀匀ഀ
਍攀渀搀ഀ
਍ഀ
਍挀氀漀猀攀 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀ഀ
਍搀攀愀氀氀漀挀愀琀攀 挀甀爀猀漀爀开戀漀漀欀愀甀搀椀攀渀挀攀ഀ
਍ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 戀㄀㤀　 䤀渀琀攀爀攀猀琀 䄀最攀猀              ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍猀攀氀攀挀琀 䀀椀开瀀愀最攀挀漀甀渀琀 㴀 瀀愀最攀挀漀甀渀琀 昀爀漀洀 瀀爀椀渀琀椀渀最 眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍愀渀搀 瀀爀椀渀琀椀渀最欀攀礀㴀㄀ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开愀最攀氀漀眀 㴀 愀最攀氀漀眀Ⰰ  䀀椀开愀最攀栀椀最栀㴀愀最攀栀椀最栀Ⰰ 䀀椀开愀最攀氀漀眀甀瀀椀渀搀㴀愀最攀氀漀眀甀瀀椀渀搀Ⰰ䀀椀开愀最攀栀椀最栀甀瀀椀渀搀㴀愀最攀栀椀最栀甀瀀椀渀搀ഀ
਍昀爀漀洀 戀漀漀欀搀攀琀愀椀氀ഀ
਍眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀ഀ
਍ഀ
਍⼀⨀⨀ 䄀最攀 䰀漀眀 愀渀搀 䄀最攀 䰀漀眀 唀瀀 椀渀搀椀挀愀琀漀爀 愀爀攀 洀甀琀甀愀氀氀礀 攀砀挀氀甀猀椀瘀攀 ⨀⨀⼀ഀ
਍椀昀 䀀椀开愀最攀氀漀眀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀氀漀眀 㸀 　 愀渀搀 䀀椀开愀最攀氀漀眀甀瀀椀渀搀 㴀 ㄀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开愀最攀氀漀眀甀瀀椀渀搀㴀　ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀ 䄀最攀 䠀椀最栀 愀渀搀 䄀最攀 䠀椀最栀 唀瀀 椀渀搀椀挀愀琀漀爀 愀爀攀 洀甀琀甀愀氀氀礀 攀砀挀氀甀猀椀瘀攀 ⨀⨀⼀ഀ
਍椀昀 䀀椀开愀最攀栀椀最栀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀栀椀最栀 㸀 　 愀渀搀 䀀椀开愀最攀栀椀最栀甀瀀椀渀搀 㴀 ㄀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开愀最攀栀椀最栀甀瀀椀渀搀㴀　ഀ
਍攀渀搀ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀ 䔀砀愀洀瀀氀攀㨀  ✀昀爀漀洀 ㌀ 琀漀 㜀✀ ⨀⨀⨀⼀ഀ
਍椀昀 䀀椀开愀最攀氀漀眀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀氀漀眀 㸀 　 愀渀搀 䀀椀开愀最攀栀椀最栀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀栀椀最栀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀㄀㤀　㸀昀爀漀洀 ✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开愀最攀氀漀眀⤀ ⬀ ✀ 琀漀 ✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开愀最攀栀椀最栀⤀ ⬀ ✀㰀⼀戀㄀㤀　㸀✀ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀ 䔀砀愀洀瀀氀攀㨀  ✀甀瀀 琀漀 㜀✀ ⨀⨀⨀⼀ഀ
਍椀昀 䀀椀开愀最攀氀漀眀甀瀀椀渀搀㴀㄀ 愀渀搀 䀀椀开愀最攀栀椀最栀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀栀椀最栀 㸀 　ഀ
਍戀攀最椀渀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀㄀㤀　㸀甀瀀 琀漀 ✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开愀最攀栀椀最栀⤀ ⬀ ✀㰀⼀戀㄀㤀　㸀✀ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀ 䔀砀愀洀瀀氀攀㨀  ✀㌀ 甀瀀眀愀爀搀猀✀ ⨀⨀⨀⼀ഀ
਍椀昀  䀀椀开愀最攀氀漀眀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀氀漀眀 㸀 　 愀渀搀 䀀椀开愀最攀栀椀最栀甀瀀椀渀搀㴀㄀ഀ
਍戀攀最椀渀ഀ
਍ऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ഀ
਍ऀ猀攀氀攀挀琀 ✀㰀戀㄀㤀　㸀昀爀漀洀 ✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开愀最攀氀漀眀⤀ ⬀ ✀㰀⼀戀㄀㤀　㸀✀ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀ 䔀砀愀洀瀀氀攀㨀  䄀最攀 䰀漀眀 漀渀氀礀 ⴀ 渀漀 甀瀀眀愀爀搀猀 ⴀ ✀㌀✀ ⨀⨀⨀⼀ഀ
਍椀昀 䀀椀开愀最攀栀椀最栀甀瀀椀渀搀㴀　 漀爀 䀀椀开愀最攀栀椀最栀甀瀀椀渀搀 椀猀 渀甀氀氀 ഀ
਍ऀ椀昀 䀀椀开愀最攀氀漀眀 椀猀 渀漀琀 渀甀氀氀 愀渀搀 䀀椀开愀最攀氀漀眀 㸀 　ऀഀ
਍ऀऀ椀昀 䀀椀开愀最攀栀椀最栀 椀猀 渀甀氀氀 漀爀 䀀椀开愀最攀栀椀最栀㴀　ഀ
਍ऀऀ戀攀最椀渀ഀ
਍ऀऀऀ椀渀猀攀爀琀 椀渀琀漀 攀氀漀漀渀椀砀昀攀攀搀 ⠀昀攀攀搀琀攀砀琀⤀ഀ
਍ऀऀऀ猀攀氀攀挀琀 ✀㰀戀㄀㤀　㸀✀ ⬀ 挀漀渀瘀攀爀琀 ⠀瘀愀爀挀栀愀爀⠀㄀　⤀Ⰰ䀀椀开愀最攀氀漀眀⤀ ⬀ ✀㰀⼀戀㄀㤀　㸀✀ഀ
਍ഀ
਍ऀऀ攀渀搀ഀ
਍ഀ
਍ഀ
਍ഀ
਍ ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 䐀攀猀挀爀椀瀀琀椀瘀攀 䌀漀渀琀攀渀琀          ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 搀㄀　　 䄀渀渀漀琀愀琀椀漀渀 ⴀ 䈀爀椀攀昀 䐀攀猀挀爀椀瀀琀椀漀渀             ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍攀砀攀挀 䀀椀开爀攀琀甀爀渀挀漀搀攀 㴀 攀氀漀开漀甀琀瀀甀琀开挀漀洀洀攀渀琀开渀攀眀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ✀䈀䐀✀Ⰰ✀㰀搀㄀　　㸀㰀℀嬀䌀䐀䄀吀䄀嬀✀Ⰰ✀崀崀㸀㰀⼀搀㄀　　㸀✀Ⰰ 　ഀ
਍ഀ
਍椀昀 䀀椀开爀攀琀甀爀渀挀漀搀攀㴀ⴀ㄀ഀ
਍戀攀最椀渀ഀ
਍ऀ爀漀氀氀戀愀挀欀 琀爀愀渀ഀ
਍ऀ⼀⨀攀砀攀挀 攀氀漀瀀爀漀挀攀猀猀攀爀爀漀爀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ䀀䀀攀爀爀漀爀Ⰰ✀䔀刀刀伀刀✀Ⰰ✀匀儀䰀 䔀爀爀漀爀✀⨀⼀ഀ
਍ऀ爀攀琀甀爀渀 ⴀ㄀  ⼀⨀⨀ 䘀愀琀愀氀 匀儀䰀 䔀爀爀漀爀 ⨀⨀⼀ഀ
਍攀渀搀ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 䴀愀椀渀 䐀攀猀挀爀椀瀀琀椀漀渀 猀攀渀琀 愀猀 伀琀栀攀爀 吀攀砀琀 挀漀洀瀀漀猀椀琀攀           ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀ 䤀昀 搀攀猀挀爀椀瀀琀椀漀渀 椀猀 洀椀猀猀椀渀最Ⰰ 琀爀礀 猀攀渀搀 匀攀爀椀攀猀 䐀攀猀挀爀椀瀀琀椀漀渀 ⨀⨀⼀ഀ
਍猀攀氀攀挀琀 䀀椀开搀攀猀挀挀漀甀渀琀㴀　ഀ
਍ഀ
਍猀攀氀攀挀琀 䀀椀开搀攀猀挀挀漀甀渀琀㴀挀漀甀渀琀 ⠀⨀⤀ 昀爀漀洀 戀漀漀欀挀漀洀洀攀渀琀猀 ഀ
਍眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀 愀渀搀 ഀ
਍挀漀洀洀攀渀琀琀礀瀀攀挀漀搀攀㴀㌀ 愀渀搀 挀漀洀洀攀渀琀琀礀瀀攀猀甀戀挀漀搀攀㴀㠀ഀ
਍ഀ
਍椀昀 䀀椀开搀攀猀挀挀漀甀渀琀㴀　 漀爀 䀀椀开搀攀猀挀挀漀甀渀琀 椀猀 渀甀氀氀ഀ
਍戀攀最椀渀ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开搀攀猀挀挀漀甀渀琀㴀　ഀ
਍ऀ猀攀氀攀挀琀 䀀椀开搀攀猀挀挀漀甀渀琀㴀挀漀甀渀琀 ⠀⨀⤀ 昀爀漀洀 戀漀漀欀挀漀洀洀攀渀琀猀 ഀ
਍ऀ眀栀攀爀攀 戀漀漀欀欀攀礀㴀䀀椀开戀漀漀欀欀攀礀 愀渀搀 挀漀洀洀攀渀琀琀礀瀀攀挀漀搀攀㴀㌀ 愀渀搀 挀漀洀洀攀渀琀琀礀瀀攀猀甀戀挀漀搀攀㴀㈀㤀ഀ
਍ऀ椀昀 䀀椀开搀攀猀挀挀漀甀渀琀 㸀 　ഀ
਍ऀ戀攀最椀渀ഀ
਍ഀ
਍ऀऀ⼀⨀攀砀攀挀 攀氀漀漀渀椀砀瘀愀氀椀搀愀琀椀漀渀开猀瀀 䀀椀开眀愀爀渀椀渀最Ⰰ 䀀椀开戀漀漀欀欀攀礀Ⰰ ✀䐀攀猀挀爀椀瀀琀椀漀渀 洀椀猀猀椀渀最㨀 匀攀渀搀椀渀最 匀攀爀椀攀猀 䐀攀猀挀✀ഀ
਍ऀऀ⨀⼀ഀ
਍ऀऀ攀砀攀挀 䀀椀开爀攀琀甀爀渀挀漀搀攀 㴀 攀氀漀开漀渀椀砀开漀琀栀攀爀琀攀砀琀开渀攀眀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ✀　㄀✀Ⰰ✀匀刀䐀匀䌀✀ഀ
਍ऀऀ椀昀 䀀椀开爀攀琀甀爀渀挀漀搀攀㴀ⴀ㄀ഀ
਍ऀऀ戀攀最椀渀ഀ
਍ऀऀऀ爀漀氀氀戀愀挀欀 琀爀愀渀ഀ
਍ऀऀऀ⼀⨀攀砀攀挀 攀氀漀瀀爀漀挀攀猀猀攀爀爀漀爀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ䀀䀀攀爀爀漀爀Ⰰ✀䔀刀刀伀刀✀Ⰰ✀匀儀䰀 䔀爀爀漀爀✀⨀⼀ഀ
਍ऀऀऀ爀攀琀甀爀渀 ⴀ㄀  ⼀⨀⨀ 䘀愀琀愀氀 匀儀䰀 䔀爀爀漀爀 ⨀⨀⼀ഀ
਍ऀऀ攀渀搀ഀ
਍ഀ
਍ऀ攀渀搀ഀ
਍攀渀搀ഀ
਍攀氀猀攀ഀ
਍戀攀最椀渀ഀ
਍ഀ
਍ऀ攀砀攀挀 䀀椀开爀攀琀甀爀渀挀漀搀攀 㴀 攀氀漀开漀渀椀砀开漀琀栀攀爀琀攀砀琀开渀攀眀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ✀　㄀✀Ⰰ✀䐀✀ഀ
਍ऀ椀昀 䀀椀开爀攀琀甀爀渀挀漀搀攀㴀ⴀ㄀ഀ
਍ऀ戀攀最椀渀ഀ
਍ऀऀ爀漀氀氀戀愀挀欀 琀爀愀渀ഀ
਍ऀऀ⼀⨀攀砀攀挀 攀氀漀瀀爀漀挀攀猀猀攀爀爀漀爀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ䀀䀀攀爀爀漀爀Ⰰ✀䔀刀刀伀刀✀Ⰰ✀匀儀䰀 䔀爀爀漀爀✀⨀⼀ഀ
਍ऀऀ爀攀琀甀爀渀 ⴀ㄀  ⼀⨀⨀ 䘀愀琀愀氀 匀儀䰀 䔀爀爀漀爀 ⨀⨀⼀ഀ
਍ऀ攀渀搀ഀ
਍ഀ
਍攀渀搀ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍⼀⨀⨀ 伀甀琀瀀甀琀 䈀爀椀攀昀 ⠀匀栀漀爀琀⤀ 䐀攀猀挀爀椀瀀琀椀漀渀 猀攀渀琀 愀猀 伀琀栀攀爀 吀攀砀琀 挀漀洀瀀漀猀椀琀攀           ⨀⨀⼀ഀ
਍⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀ
਍ഀ
਍攀砀攀挀 䀀椀开爀攀琀甀爀渀挀漀搀攀 㴀 攀氀漀开漀渀椀砀开漀琀栀攀爀琀攀砀琀开渀攀眀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ✀　㈀✀Ⰰ✀䈀䐀✀ഀ
਍椀昀 䀀椀开爀攀琀甀爀渀挀漀搀攀㴀ⴀ㄀ഀ
਍戀攀最椀渀ഀ
਍ऀ爀漀氀氀戀愀挀欀 琀爀愀渀ഀ
਍ऀ⼀⨀攀砀攀挀 攀氀漀瀀爀漀挀攀猀猀攀爀爀漀爀开猀瀀 䀀椀开戀漀漀欀欀攀礀Ⰰ䀀䀀攀爀爀漀爀Ⰰ✀䔀刀刀伀刀✀Ⰰ✀匀儀䰀 䔀爀爀漀爀✀⨀⼀ഀ
਍ऀ爀攀琀甀爀渀 ⴀ㄀  ⼀⨀⨀ 䘀愀琀愀氀 匀儀䰀 䔀爀爀漀爀 ⨀⨀⼀ഀ
਍攀渀搀ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍⼀⨀⨀⨀䌀漀洀洀攀渀琀 吀礀瀀攀猀 渀漀琀 挀甀爀爀攀渀琀氀礀 猀甀瀀瀀漀爀琀攀搀 椀渀 伀渀椀砀ഀ
਍䄀䌀伀䴀ऀ⠀攀⤀ 䄀甀琀栀漀爀 䌀漀洀洀攀渀琀猀ഀ
਍ഀ
AFB	(e) Audience For Book਍ഀ
PCOM	(e) Publisher Comments਍ഀ
SET	(e) Setting਍ഀ
P 	(e) Publicity਍ഀ
SLH	(e) Sales Handle਍ഀ
PTI	(e) Pub Date Tie In਍ഀ
CB	(e) Catalog Bullets਍ഀ
***/਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output OtherText              	**/਍ഀ
/* Includes OtherText header, d102 TextTypeCode, d104 Text */਍ഀ
/* Can include in future d103 TextFormat */਍ഀ
/*****************************************/਍ഀ
਍ഀ
/* 04 - Table of Contents */਍ഀ
਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'04','TOC'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q1  Quote 1 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q1'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* CT - 2/6/03 Added quotes 2 and 3 and the 5 new quote fields to output*/਍ഀ
਍ഀ
/* 08 Q2  Quote 2 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q2'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q3  Quote 3 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q3'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q4  Quote 4 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q4'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q5  Quote 5 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q5'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q6  Quote 6 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q6'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q7  Quote 7 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q7'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 08 Q8  Quote 8 */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'08','Q8'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
਍ഀ
/* 2/6/03 CT - Added citations */਍ഀ
਍ഀ
exec @i_returncode = elo_onix_citation_new_sp @i_bookkey਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/* 13 - Author Bio */਍ഀ
਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'13','AI'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/* 23 EX  Excerpt */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'23','EX'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 31 BC Catalog Body Copy */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'31','BC'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/* 17 FC Inside Flap Copy */਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'17','FC'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/* 18 BPC Back Panel Copy */਍ഀ
਍ഀ
exec @i_returncode = elo_onix_othertext_new_sp @i_bookkey,'18','BPC'਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output e110 ReviewQuote - Repeats three times    **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q1','<e110><![CDATA[',']]></e110>', 0਍ഀ
--exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q1','<e110>','</e110>', 1਍ഀ
਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q2','<e110><![CDATA[',']]></e110>', 0਍ഀ
--exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q2','<e110>','</e110>', 1਍ഀ
਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q3','<e110><![CDATA[',']]></e110>', 0਍ഀ
--exec @i_returncode = elo_output_comment_new_sp @i_bookkey,'Q3','<e110><![CDATA[',']]></e110>', 0਍ഀ
਍ഀ
if @i_returncode=-1਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
/** Modified 11/13/02 - CT - Added second printing of Imprint Name to accomodate Bowker **/਍ഀ
/** b079 Imprint Name **/਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b079><![CDATA[' + oe.orgentrydesc + ']]></b079>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output Imprint Composite              **/਍ഀ
/** Add functionality here for publisher specific Imrpint Code if needed **/਍ഀ
/** Create a new b242 entry called 'Publisher Supplied Imprint Code'  **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '<imprint>'਍ഀ
਍ഀ
/** Output Name Code Type - 02 Proprietary **/਍ഀ
insert into eloonixfeed (feedtext) select '<b241>02</b241>'਍ഀ
਍ഀ
/** Output Name Code Type NAME - Sending Eloquence Uniqe Key **/਍ഀ
insert into eloonixfeed (feedtext) select '<b242>Eloquence Unique Code</b242>'਍ഀ
਍ഀ
਍ഀ
/** Now output the Code b243 - using Orgentrykey **/਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b243>' + convert (varchar (25),oe.orgentrykey) + '</b243>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey਍ഀ
਍ഀ
/** b079 Imprint Name **/਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b079><![CDATA[' + oe.orgentrydesc + ']]></b079>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=3 and oe.orgentrykey=bo.orgentrykey਍ഀ
਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '</imprint>'਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output b081 PublisherName              **/਍ഀ
/*****************************************/਍ഀ
਍ഀ
/** FOLLOWING COMPOSITE MAY BE USED IN FUTURE ਍ഀ
insert into eloonixfeed (feedtext) select '<publisher>'਍ഀ
** Output Publisher Role Type Code - 01 Publisher **਍ഀ
insert into eloonixfeed (feedtext) select '<b241>01</b241>'਍ഀ
** Output Name Code Type - 02 Proprietary **਍ഀ
insert into eloonixfeed (feedtext) select '<b241>02</b241>'਍ഀ
** Output Name Code Type NAME - Sending Eloquence Uniqe Key **਍ഀ
insert into eloonixfeed (feedtext) select '<b242>Eloquence Unique Code</b242>'਍ഀ
** Now output the Code b243 - using Orgentrykey **਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b243>' + convert (varchar (25),oe.orgentrykey) + '</b243>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey਍ഀ
** b081 Publisher Name **਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b081><![CDATA[' + oe.orgentrydesc + ']]></b081>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey਍ഀ
insert into eloonixfeed (feedtext) select '</publisher>'਍ഀ
***/਍ഀ
਍ഀ
/** Output Publisher Name sans composite **/਍ഀ
਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<b081><![CDATA[' + oe.orgentrydesc + ']]></b081>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=2 and oe.orgentrykey=bo.orgentrykey਍ഀ
਍ഀ
਍ഀ
਍ഀ
/*****************************************/਍ഀ
/** Output b003 PublicationDate         **/਍ഀ
/*****************************************/਍ഀ
select @d_pubdate=NULL਍ഀ
select @c_bisacstatuscode = ' '਍ഀ
਍ഀ
/* 8/27/02 - CT - Ignore pubdate if bisac status = Cancelled, Postponed,਍ഀ
 or No longer Our Publication */਍ഀ
਍ഀ
select @c_bisacstatuscode=g.bisacdatacode਍ഀ
from bookdetail bd,gentables g਍ഀ
where bd.bookkey= @i_bookkey and g.tableid=314 ਍ഀ
and g.datacode=bd.bisacstatuscode਍ഀ
਍ഀ
if @c_bisacstatuscode NOT in ('NL','PC','PP')  ਍ഀ
Begin਍ഀ
	select @d_pubdate = activedate from bookdates ਍ഀ
	where bookkey=@i_bookkey  and printingkey=1 and datetypecode=8਍ഀ
਍ഀ
	if @d_pubdate is NOT NULL਍ഀ
	begin਍ഀ
		/* Call the Date conversion function, ਍ഀ
		then retrieve the resuling date from eloconverteddate */਍ഀ
		exec eloformatdateYYYYMMDD_sp @d_pubdate਍ഀ
		select @c_pubdate=converteddate from eloconverteddate਍ഀ
	਍ഀ
		insert into eloonixfeed (feedtext)਍ഀ
		select '<b003>' + @c_pubdate + '</b003>'਍ഀ
	end਍ഀ
	else /*** Check for Estimated Pub Date ***/਍ഀ
	begin਍ഀ
		select @d_pubdate = estdate from bookdates ਍ഀ
		where bookkey=@i_bookkey and printingkey=1 and datetypecode=8਍ഀ
		if @d_pubdate is NOT NULL਍ഀ
		begin਍ഀ
			/* Call the Date conversion function, ਍ഀ
			then retrieve the resuling date from eloconverteddate */਍ഀ
			exec eloformatdateYYYYMMDD_sp @d_pubdate਍ഀ
			select @c_pubdate=converteddate from eloconverteddate਍ഀ
	਍ഀ
			insert into eloonixfeed (feedtext)਍ഀ
			select '<b003>' + @c_pubdate + '</b003>'਍ഀ
		end਍ഀ
		else ਍ഀ
		/*** Actual or Estimated Pub Date does not exist, Try Pub Month/Year from Printing. Pub Month/Year is set in Java Import਍ഀ
	    	to Pub Month + Pub Year, with day set to '01'. i.e. 03/01/2001 ***/਍ഀ
		/** Ignore Pub Month/Year = 01/01/1900 which is a default date */਍ഀ
		begin਍ഀ
			select @d_pubdate=pubmonth from printing਍ഀ
      			where bookkey=@i_bookkey and printingkey=1 ਍ഀ
			if @d_pubdate is NOT NULL and @d_pubdate > '01/01/1900'਍ഀ
			begin਍ഀ
				/* Call the Date conversion function, ਍ഀ
				then retrieve the resuling date from eloconverteddate */਍ഀ
				exec eloformatdateYYYYMMDD_sp @d_pubdate਍ഀ
				select @c_pubdate=converteddate from eloconverteddate਍ഀ
	਍ഀ
				insert into eloonixfeed (feedtext)਍ഀ
				select '<b003>' + @c_pubdate + '</b003>'਍ഀ
			end਍ഀ
			else /** No Possibility for pub date exists - send Validation error **/਍ഀ
				begin਍ഀ
				select @i_validationerrorind = 1਍ഀ
				exec eloonixvalidation_sp @i_error, @i_bookkey, 'Pub Date and Pub Month missing'਍ഀ
			end਍ഀ
਍ഀ
		end਍ഀ
	end /** End Else Check Est Pub DatePub Year **/਍ഀ
end/** End Else if NOT Cancelled, Postponed, or No longer our Pub **/਍ഀ
਍ഀ
਍ഀ
/*******************************************************/਍ഀ
/*    Output Measure Composite                         */਍ഀ
/*******************************************************/਍ഀ
select @d_measuredweight =  bookweight from booksimon where bookkey = @i_bookkey਍ഀ
਍ഀ
if @d_measuredweight is NOT null and @d_measuredweight <> 0.0਍ഀ
begin਍ഀ
਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<measure>'਍ഀ
਍ഀ
      /** specify measure type (08 for weight)**/਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<c093>' + @c_measurecode + '</c093>'਍ഀ
਍ഀ
	/** actual product weight(in pounds) **/਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<c094>' + convert(varchar(10),@d_measuredweight) + '</c094>'਍ഀ
਍ഀ
	/** specify units ( LBS) **/਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '<c095>LB</c095>'਍ഀ
਍ഀ
	insert into eloonixfeed (feedtext) ਍ഀ
	select '</measure>'਍ഀ
਍ഀ
end਍ഀ
਍ഀ
/***************************************/਍ഀ
/** Output SupplyDetail Data		  **/਍ഀ
/***************************************/਍ഀ
਍ഀ
਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '<supplydetail>'਍ഀ
਍ഀ
/***************************************/਍ഀ
/** Output j137 Supplier Name - Use Company Name  **/਍ഀ
/***************************************/਍ഀ
insert into eloonixfeed (feedtext)਍ഀ
select '<j137><![CDATA[' + oe.orgentrydesc + ']]></j137>'਍ഀ
from orgentry oe,bookorgentry bo where bo.bookkey=@i_bookkey਍ഀ
and bo.orglevelkey=1 and oe.orgentrykey=bo.orgentrykey਍ഀ
਍ഀ
਍ഀ
/***************************************/਍ഀ
/** Output j141 AvailabilityCode - 		  **/਍ഀ
/***************************************/਍ഀ
਍ഀ
select @c_onixstatuscode = ''਍ഀ
select @c_bisacstatuscode=''਍ഀ
਍ഀ
select @c_bisacstatuscode=g.bisacdatacode਍ഀ
from bookdetail bd,gentables g਍ഀ
where bd.bookkey= @i_bookkey and g.tableid=314 ਍ഀ
and g.datacode=bd.bisacstatuscode਍ഀ
if @@error <>0਍ഀ
begin਍ഀ
	rollback tran਍ഀ
	/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
	return -1  /** Fatal SQL Error **/਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/** We will no longer provide any information regarding Bisac Status **/਍ഀ
/** The trading partners can handle the transaction without it DSL 2/28/02**/਍ഀ
/*if @c_bisacstatuscode is null or @c_bisacstatuscode = ''਍ഀ
begin਍ഀ
	select @i_validationerrorind = 1਍ഀ
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'BISAC Status missing'਍ഀ
end਍ഀ
*/਍ഀ
਍ഀ
/**  Convert Bisac Status Code to ONIX Status Codes **/਍ഀ
਍ഀ
	select @c_onixstatuscode = ਍ഀ
	case @c_bisacstatuscode਍ഀ
	when 'ACT' then 'IP' /*Active-Available*/਍ഀ
	when 'NL' then 'RF' /* No Longer Our Publication */਍ഀ
	when 'NOP' then 'RF' /* Not Our Publication */਍ഀ
	when 'NYP' then 'NP' /* Not Yet Published */਍ഀ
	when 'OD' then 'MD' /* On Demand */਍ഀ
	when 'OP' then 'OP' /* Out of Print*/਍ഀ
	when 'OS' then 'TU' /* Temporarily out of stock */਍ഀ
	when 'OSI' then 'OI' /* Out of stock indefinately */਍ഀ
	when 'PC' then 'AB' /* Publication Canceled */਍ഀ
	else 'NP' /* Set to NYP */਍ഀ
	end਍ഀ
਍ഀ
insert into eloonixfeed (feedtext) select '<j141>' + @c_onixstatuscode ਍ഀ
	+ '</j141>'਍ഀ
਍ഀ
਍ഀ
/***************************************/਍ഀ
/** j142 Output Availability Date       **/਍ഀ
/** if the status us Not Yet Published or Uncertain, send Pub Date **/਍ഀ
/** as availability date if it exists **/਍ഀ
/***************************************/਍ഀ
਍ഀ
if @c_pubdate is not null and @c_pubdate <> ''਍ഀ
begin਍ഀ
	/** if the status us Not Yet Published or Uncertain, send Pub Date਍ഀ
		as availability date if it exists **/਍ഀ
	if @c_onixstatuscode = 'NP' or @c_onixstatuscode = 'CS' ਍ഀ
	begin਍ഀ
		insert into eloonixfeed (feedtext)਍ഀ
		select '<j142>' + @c_pubdate + '</j142>'਍ഀ
	end਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/**************************************************************/਍ഀ
/**  output carton qty  <PackQuantity> <j145>             **/਍ഀ
/*************************************************************/਍ഀ
select @i_packqty = cartonqty1਍ഀ
from bindingspecs਍ഀ
where bookkey=@i_bookkey and printingkey = 1਍ഀ
਍ഀ
if  @i_packqty is not null and @i_packqty > 0 ਍ഀ
	begin਍ഀ
		insert into eloonixfeed(feedtext)਍ഀ
		select '<j145>' + convert(varchar(25),@i_packqty) + '</j145>'਍ഀ
	end਍ഀ
਍ഀ
਍ഀ
਍ഀ
/******************************************/਍ഀ
/** Output Price Group - for US Retail ***/਍ഀ
/****************************************/਍ഀ
/* begin price composite */਍ഀ
਍ഀ
/** Modified 10/8/2002 by DSL to output Estimate price if Final not available **/਍ഀ
਍ഀ
select @d_usretail=0਍ഀ
select @d_estusretail=0਍ഀ
਍ഀ
select ਍ഀ
@d_usretail=convert (decimal (10,2),finalprice),਍ഀ
@d_estusretail=convert (decimal (10,2),budgetprice)  ਍ഀ
from bookprice਍ഀ
where bookkey=@i_bookkey and pricetypecode=8਍ഀ
and currencytypecode=6਍ഀ
਍ഀ
if @d_usretail=0 or @d_usretail is null  /* Final price not found, use budget */਍ഀ
begin਍ഀ
	if @d_estusretail > 0 and @d_estusretail is not null਍ഀ
	begin਍ഀ
		select @d_usretail=@d_estusretail਍ഀ
	end਍ഀ
end਍ഀ
਍ഀ
if @d_usretail=0 or @d_usretail is null /* Retail Price Not Found - Try for Suggested List Price */਍ഀ
begin਍ഀ
	select @d_usretail=convert (decimal (10,2),finalprice),਍ഀ
	@d_estusretail=convert (decimal (10,2),budgetprice)  ਍ഀ
	from bookprice਍ഀ
	where bookkey=@i_bookkey and pricetypecode=11਍ഀ
	and currencytypecode=6਍ഀ
਍ഀ
	if @d_usretail=0 or @d_usretail is null  /* Final price not found, use budget */਍ഀ
	begin਍ഀ
		if @d_estusretail > 0 and @d_estusretail is not null਍ഀ
		begin਍ഀ
			select @d_usretail=@d_estusretail਍ഀ
		end਍ഀ
	end਍ഀ
end਍ഀ
਍ഀ
਍ഀ
/** j148 = Price Type Code - 01 = Retail, j151 = price amount **/਍ഀ
if @d_usretail>0਍ഀ
begin਍ഀ
਍ഀ
/** Modified to send the Composite instead of j151 - 10/29/01 - DSL **/਍ഀ
	/*** j151 is price field only - no longer using this. ***/਍ഀ
	/** insert into eloonixfeed (feedtext) select '<j151>' + ਍ഀ
		convert (varchar (10),@d_usretail) + '</j151>' **/਍ഀ
	਍ഀ
	/** Modified 10/2002 to send Discount Code in Price Composite */਍ഀ
	/**************************************************************/਍ഀ
	/**  output discount code  <DiscountGroupCode> <j149>        **/਍ഀ
	/**************************************************************/਍ഀ
	select @c_discountcode = '';਍ഀ
	select @c_discountcode=g.datadesc਍ഀ
	from bookdetail bd,gentables g਍ഀ
	where bd.bookkey= @i_bookkey and g.tableid=459 ਍ഀ
	and g.datacode=bd.discountcode਍ഀ
	if @@error <>0਍ഀ
	begin਍ഀ
		rollback tran਍ഀ
		/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/਍ഀ
		return -1  /** Fatal SQL Error **/਍ഀ
	end਍ഀ
	਍ഀ
	insert into eloonixfeed (feedtext) select '<price>'਍ഀ
	insert into eloonixfeed (feedtext) select '<j148>01</j148>'਍ഀ
	if  @c_discountcode is not null and @c_discountcode <> '' ਍ഀ
	begin਍ഀ
	exec @c_discountcode = xml_escape_element_value @c_discountcode਍ഀ
		insert into eloonixfeed(feedtext)਍ഀ
		select '<j149>' + @c_discountcode + '</j149>'਍ഀ
	end਍ഀ
	insert into eloonixfeed (feedtext) select '<j151>' + ਍ഀ
		convert (varchar (10),@d_usretail) + '</j151>'਍ഀ
	insert into eloonixfeed (feedtext) select '<j152>USD</j152>'਍ഀ
	/**NOTE: Add CurrencyCode Here for UK/Canadian in future**/਍ഀ
਍ഀ
	/* J161 - Price effective Date - Call the Date conversion function, ਍ഀ
	then retrieve the resuling date from eloconverteddate */਍ഀ
	select @d_effectivedate=getdate()਍ഀ
	exec eloformatdateYYYYMMDD_sp @d_effectivedate਍ഀ
	select @c_effectivedate=converteddate from eloconverteddate਍ഀ
	਍ഀ
	insert into eloonixfeed (feedtext)਍ഀ
	select '<j161>' + @c_effectivedate + '</j161>'਍ഀ
਍ഀ
਍ഀ
	insert into eloonixfeed (feedtext) select '</price>'਍ഀ
	/****** END of Composite  ***/਍ഀ
end਍ഀ
else /** No Price found - output Validation Error **/਍ഀ
begin਍ഀ
	select @i_validationerrorind = 1਍ഀ
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Retail Price missing'਍ഀ
end਍ഀ
਍ഀ
/***************************************/਍ഀ
/** Output Supply Detail Ending Line  **/਍ഀ
/***************************************/਍ഀ
insert into eloonixfeed (feedtext) select '</supplydetail>'਍ഀ
਍ഀ
/***************************************/਍ഀ
/** Output Product Group Ending Line  **/਍ഀ
/***************************************/਍ഀ
insert into eloonixfeed (feedtext) ਍ഀ
	select '</product>'਍ഀ
਍ഀ
if @i_validationerrorind = 1਍ഀ
begin਍ഀ
	exec eloonixvalidation_sp @i_error, @i_bookkey, 'Rolling back transaction!'਍ഀ
	rollback tran਍ഀ
end਍ഀ
else਍ഀ
begin਍ഀ
	commit tran਍ഀ
end਍ഀ
਍ഀ
return 0਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER OFF ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
