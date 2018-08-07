SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elo832outbook_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elo832outbook_sp]
GO


CREATE proc dbo.elo832outbook_sp @i_bookkey int,  @c_version varchar (6), @c_modifieddate varchar (10), @c_BCT10 char (2)
as

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @d_initprocessdate datetime 
DECLARE @c_initprocessdate varchar (25)
DECLARE @d_lastprocessdate datetime 
DECLARE @c_lastprocessdate varchar (25)
DECLARE @c_recordtype char (3)

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
DECLARE @c_sendersan char (15)
DECLARE @c_suppliertype char (2)

DECLARE @c_author832name1 varchar (255)
DECLARE @c_author832name2 varchar (255)
DECLARE @c_author832name3 varchar (255)
DECLARE @c_author832name4 varchar (255)

DECLARE @i_editioncode int
DECLARE @c_editionbisaccode varchar (10)


DECLARE @c_mediabisaccode varchar (25)
DECLARE @c_formatbisaccode varchar (25)
DECLARE @i_pagecount smallint
DECLARE @c_trimsizewidth varchar (20)
DECLARE @c_trimsizelength varchar (20)
DECLARE @c_cartonqty varchar (20)
DECLARE @c_usretailprice varchar (20)
DECLARE @d_usretailprice decimal (10,2)
DECLARE @c_bisaccategorymajorcode1 varchar (100)
DECLARE @c_bisaccategoryminorcode1 varchar (100)
DECLARE @c_bisaccategoryminorcode2 varchar (100)
DECLARE @c_bisaccategoryminorcode3 varchar (100)
DECLARE @c_pubdateYYYYMMDD varchar(8)
DECLARE @c_pubdateMMDDYY varchar(6)
DECLARE @c_pubdateYYMMDD varchar(6)
DECLARE @c_todayYYMMDD varchar(6)
DECLARE @c_todayYYYYMMDD varchar(8)
DECLARE @c_todayMMDDYY varchar(6)
DECLARE @c_pubdatecentury varchar(8)
DECLARE @c_bisacstatuscode varchar (25)
DECLARE @i_cartonqty int
DECLARE @C_message varchar (25)

DECLARE @c_authorlastname1 varchar (100)
DECLARE @c_authorfirstname1 varchar (100)
DECLARE @c_authortype1 varchar (100)
DECLARE @c_authorlastname2 varchar (100)
DECLARE @c_authorfirstname2 varchar (100)
DECLARE @c_authortype2 varchar (100)
DECLARE @c_authorlastname3 varchar (100)
DECLARE @c_authorfirstname3 varchar (100)
DECLARE @c_authortype3 varchar (100)
DECLARE @c_authorlastname4 varchar (100)
DECLARE @c_authorfirstname4 varchar (100)
DECLARE @c_authortype4 varchar (100)

DECLARE @i_authorcount int
DECLARE @i_illustratorcount int
DECLARE @i_year int
DECLARE @i_month int
DECLARE @i_day int
DECLARE @c_month char(2)
DECLARE @c_day char(2)
DECLARE @c_year char(2)
DECLARE @c_century char(2)

DECLARE @c_dummy varchar (25)
DECLARE @i_subjectcursorstatus int
DECLARE @i_rownumber int

DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_validationerrorind int
DECLARE @c_tempmessage varchar (255)

/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 2

begin tran

/** Initialize the Validation Error to zero (False) **/
/** This will be set to '1' if any validation fails, and the transaction will be rolled back **/
/** for this bookkey.  Processing will continue to the next bookkey **/

select @i_validationerrorind = 0



/**********************************************************/
/**                                                      **/
/** Select the row from the eloflatfeed table            **/
/**                                                      **/  
/**********************************************************/

select
@c_isbn10=isbn10,
@c_titlewithprefix=titlewithprefix,
@c_subtitle=subtitle,
@c_publishername=publishername,
@c_imprintname=imprintname,
@c_bisacstatuscode=bisacstatuscode,
@c_authorlastname1=authorlastname1,
@c_authorfirstname1=authorfirstname1,
@c_authortype1=authortype1,
@c_authorlastname2=authorlastname2,
@c_authorfirstname2=authorfirstname2,
@c_authortype2=authortype2,
@c_authorlastname3=authorlastname3,
@c_authorfirstname3=authorfirstname3,
@c_authortype3=authortype3,
@c_authorlastname4=authorlastname4,
@c_authorfirstname4=authorfirstname4,
@c_authortype4=authortype4,
@c_bisaccategorymajorcode1=bisaccategorymajorcode1,
@c_bisaccategoryminorcode1=bisaccategoryminorcode1,
@c_bisaccategoryminorcode2=bisaccategoryminorcode2,
@c_bisaccategoryminorcode3=bisaccategoryminorcode3,
@c_pubdateYYYYMMDD=pubdateYYYYMMDD,
@c_mediabisaccode=mediabisaccode,
@c_formatbisaccode=formatbisaccode,
@i_pagecount=pagecount,
@i_cartonqty=cartonqty,
@c_trimsizewidth=trimsizewidth ,
@c_trimsizelength=trimsizelength ,
@d_usretailprice=	usretailprice
from eloflatfeed 
where bookkey= @i_bookkey



/*******************************************/
/* Output Line Item Envelope (LIN Segment) */
/*******************************************/

if @c_bisaccategorymajorcode1 is null
begin
	/* Initialize to blank if null */
	select @c_bisaccategorymajorcode1 = ''
end

insert into elo832feed (feedtext) select
'LIN^^IB^' +
@c_isbn10 +
'^B7^' +
@c_publishername +
'^IM^' +
@c_imprintname +
'^^^^^^^^^ZZ^' +
@c_bisaccategorymajorcode1 + '~'

/* Added G53 segmentt for Anderson News - This may be required for others as well */
/* G53 allows for ADd\Change\Delete information to be transmitted */

	/*select @d_initprocessdate = substring(convert(varchar (25),initprocessdate),1,12), 
	@d_lastprocessdate = substring(convert(varchar (25),lastprocessdate),1,12) from elobookkeys where bookkey = @i_bookkey
	*/
	select @d_initprocessdate = initprocessdate from elobookkeys where bookkey = @i_bookkey
	select @d_lastprocessdate = lastprocessdate from elobookkeys where bookkey = @i_bookkey

	exec eloformatdateYYYYMMDD_sp @d_initprocessdate
	select @c_initprocessdate=converteddate from eloconverteddate
	
 	exec eloformatdateYYYYMMDD_sp @d_lastprocessdate
	select @c_lastprocessdate=converteddate from eloconverteddate

/* do not process records that are not in the appropriate date range for delta files */

	if @c_lastprocessdate <= @c_modifieddate
	begin
		rollback tran
		return 0
	end
/******** G53 SEgment - only use when BCT10 = '00' **********/
if (@c_BCT10 = '00')
begin
	if @c_initprocessdate >= @c_modifieddate
	begin
		select @c_recordtype = '003' /* add */
	end
	else
	begin
		select @c_recordtype = '001' /* change */
	end

	if @c_bisacstatuscode in ('OP','OSI','OS','PC','DC')
	begin
		select @c_recordtype = '002' /* delete */
	end
	
	insert into elo832feed (feedtext) select
	'G53^' + @c_recordtype + '~'

end /* end G53 segment for BCT10 = 00 */

/******************************************************************/
/*											*/
/*   3/13/03 - CT - Date Fields Modified to fit the 4010 Standard */
/*			for dates - CCYYMMDD					*/
/******************************************************************/


if @c_version = '003060'
begin /* Version 3060 - Dates formatted as MMDDYY***CC */
	/***************************************************/
	/* Output DTM Segment Pubdate (043)                */
	/* Formatted as MMDDYY with the century            */
	/* added as additional field at end of DTM Segment */
	/***************************************************/

	if @c_pubdateYYYYMMDD is not null and @c_pubdateYYYYMMDD <> ''
	begin
		select @c_pubdateMMDDYY = 
		substring (@c_pubdateYYYYMMDD,5,4) + 
		substring (@c_pubdateYYYYMMDD,3,2)

		select @c_pubdatecentury = substring (@c_pubdateYYYYMMDD,1,2)

		insert into elo832feed (feedtext) select 
		'DTM^043^' + @c_pubdateMMDDYY + '^^^' + @c_pubdatecentury + '~'
	end
	else
	begin
		if @c_bisacstatuscode in ('PC','DC') /* insert pubdate = 000000^^^20 for PC and DC titles */
		begin
			insert into elo832feed (feedtext) select 
			'DTM^043^000000^^^' + @c_pubdatecentury + '~'
		end
		else
		begin
			select @c_message = 'no pubdate'
			print @c_isbn10 
			print  @c_message
			select @i_validationerrorind = 1 /* must have pubdate */
		end
	end

	/*******************************************/
	/* Output DTM Segment Available date (018)        */
	/*******************************************/

	if @c_pubdateYYYYMMDD is not null and @c_pubdateYYYYMMDD <> ''
	begin
		if @c_bisacstatuscode in ('NYP','ACT','OP', 'NL')
		begin
			/* Use the formatted fields from the previous Segment **/
			insert into elo832feed (feedtext) select 
			'DTM^018^' + @c_pubdateMMDDYY + '^^^' + @c_pubdatecentury + '~'
		end
	end


	/****************************************************/
	/* Output DTM Segment Last Change date (167)        */
	/****************************************************/
	select @c_todayYYYYMMDD = convert (char (8),getdate(),112) 

	/* Extract Century and build MMDDYY format */
	select @c_century = substring (@c_todayYYYYMMDD,1,2)
	select @c_todayMMDDYY = 
	substring (@c_todayYYYYMMDD,5,2) + 
	substring (@c_todayYYYYMMDD,7,2) + 
	substring (@c_todayYYYYMMDD,3,2)


	/* Output for approporiate Bisac Status codes **/
	if @c_bisacstatuscode in ('ACT','OP', 'NL')
	begin
		insert into elo832feed (feedtext) select 
		'DTM^167^' + @c_todayMMDDYY + '^^^' + @c_century + '~'
	end /*Bisac Status */

	/*******************************************/
	/* Output DTM Segment Out of Print Date (ZZZ)        */
	/*******************************************/

	/* Output for approporiate Bisac Status codes **/
	/** Use formatted date from previous segment **/

	if @c_bisacstatuscode in ('OP', 'NL')
	begin
		insert into elo832feed (feedtext) select 
		'DTM^ZZZ^' + @c_todayMMDDYY + '^^^' + @c_century + '~'
	end /* Bisac Status */

end /* end of version 3060 dates */

if @c_version = '004010' /* Version 4010 - Dates formatted as CCYYMMDD*/
Begin

	/***************************************************/
	/* Output DTM Segment Pubdate (043)                */
	/* Formatted as CCYYMMDD (4010 standard)           */
	/***************************************************/

	if @c_pubdateYYYYMMDD is not null and @c_pubdateYYYYMMDD <> ''
	begin
		select @c_pubdateYYMMDD = 
			substring (@c_pubdateYYYYMMDD,3,2) +
			substring (@c_pubdateYYYYMMDD,5,4) 

		select @c_pubdatecentury = substring (@c_pubdateYYYYMMDD,1,2)

		insert into elo832feed (feedtext) select 
		'DTM^043^'+ @c_pubdatecentury + @c_pubdateYYMMDD   + '~'
	end
	else
	begin
		if @c_bisacstatuscode in ('PC','DC') /* insert pubdate = 20000000 for PC and DC titles */
		begin
			insert into elo832feed (feedtext) select 
			'DTM^043^20000000' + '~'

		end
		else
		begin
			select @i_validationerrorind = 1 /* must have pubdate */
		end
	end


	/*******************************************/
	/* Output DTM Segment Available date (018)     CCYYMMDD   */
	/*******************************************/

	if @c_pubdateYYYYMMDD is not null and @c_pubdateYYYYMMDD <> ''
	begin
		if @c_bisacstatuscode in ('NYP','ACT','OP', 'NL')
		begin
			/* Use the formatted fields from the previous Segment **/
			insert into elo832feed (feedtext) select 
			'DTM^018^' + @c_pubdatecentury  + @c_pubdateYYMMDD  + '~'
		end
	end


	/****************************************************/
	/* Output DTM Segment Last Change date (167)        */
	/****************************************************/
	select @c_todayYYYYMMDD = convert (char (8),getdate(),112) 

	/* Extract Century and build YYMMDD format */
	select @c_century = substring (@c_todayYYYYMMDD,1,2)
	select @c_todayYYMMDD = 
	substring (@c_todayYYYYMMDD,3,2) + 
	substring (@c_todayYYYYMMDD,5,2) + 
	substring (@c_todayYYYYMMDD,7,2)


	/* Output for approporiate Bisac Status codes **/
	if @c_bisacstatuscode in ('ACT','OP', 'NL')
	begin
		insert into elo832feed (feedtext) select 
		'DTM^167^' + @c_century  + @c_todayYYMMDD  + '~'
	end /*Bisac Status */

	/*******************************************/
	/* Output DTM Segment Out of Print Date (ZZZ)        */
	/*******************************************/

	/* Output for approporiate Bisac Status codes **/
	/** Use formatted date from previous segment **/

	if @c_bisacstatuscode in ('OP', 'NL')
	begin
		insert into elo832feed (feedtext) select 
		'DTM^ZZZ^' + @c_century + @c_todayYYMMDD  + '~'
	end /* Bisac Status */

end /* end Version 4010 dates*/

/*******************************************/
/* Output CTB Returnable Segment           */
/*******************************************/

/* Output Returnable and Strippable for Mass Market Titles only */
/* All others are returnable and Full Copies Only */
if @c_formatbisaccode='MM'
begin
	insert into elo832feed (feedtext) select 'CTB^OR^S' + '~'
end
else
begin
	insert into elo832feed (feedtext) select 'CTB^OR^Y' + '~'
end

/*******************************************/
/* Output PID A01,A02 Authors              */
/*******************************************/

/* First format the author names - replace spaces with & for 832 compliance */
/* 3/27/02 - Replaced '+' with space for 832 compliance */

if @c_authorfirstname1 is not null and @c_authorfirstname1 <> ''
begin /* Add First Name to Last Name */
	select @c_author832name1 = replace (@c_authorlastname1,' ','&') +
				   ' ' + replace (@c_authorfirstname1,' ','&') + '~'
end
else /* Last Name Only Available */
begin 
	select @c_author832name1 = replace (@c_authorlastname1,' ','&') + '~'
end

if @c_authorfirstname2 is not null and @c_authorfirstname2 <> ''
begin /* Add First Name to Last Name */
	select @c_author832name2 = replace (@c_authorlastname2,' ','&') +
				   ' ' + replace (@c_authorfirstname2,' ','&') + '~'
end
else /* Last Name Only Available */
begin 
	select @c_author832name2 = replace (@c_authorlastname2,' ','&') + '~'
end

if @c_authorfirstname3 is not null and @c_authorfirstname3 <> ''
begin /* Add First Name to Last Name */
	select @c_author832name3 = replace (@c_authorlastname3,' ','&') +
				   ' ' + replace (@c_authorfirstname3,' ','&') + '~'
end
else /* Last Name Only Available */
begin 
	select @c_author832name3 = replace (@c_authorlastname3,' ','&') + '~'
end

if @c_authorfirstname4 is not null and @c_authorfirstname4 <> ''
begin /* Add First Name to Last Name */
	select @c_author832name4 = replace (@c_authorlastname4,' ','&') +
				   ' ' + replace (@c_authorfirstname4,' ','&') + '~'
end
else /* Last Name Only Available */
begin 
	select @c_author832name4 = replace (@c_authorlastname4,' ','&') + '~'
end

select @i_authorcount=0
select @i_illustratorcount=0
/* 3/25/03 - CT removed segment terminators after author names because it is already added to name above */
if @c_author832name1 is not null 
   and @c_author832name1 <> ''
   and upper (@c_authortype1)<> 'ILLUSTRATOR'
begin
	select @i_authorcount = @i_authorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^A0'+
	convert(char (1),@i_authorcount)+'^'+@c_author832name1 
end 

if @c_author832name2 is not null 
   and @c_author832name2 <> ''
   and upper (@c_authortype2)<> 'ILLUSTRATOR'
begin
	select @i_authorcount = @i_authorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^A0'+
	convert(char (1),@i_authorcount)+'^'+@c_author832name2 
end 

if @c_author832name3 is not null 
   and @c_author832name3 <> ''
   and upper (@c_authortype3)<> 'ILLUSTRATOR'
begin
	select @i_authorcount = @i_authorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^A0'+
	convert(char (1),@i_authorcount)+'^'+@c_author832name3 
end 

if @c_author832name4 is not null 
   and @c_author832name4 <> ''
   and upper (@c_authortype4)<> 'ILLUSTRATOR'
begin
	select @i_authorcount = @i_authorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^A0'+
	convert(char (1),@i_authorcount)+'^'+@c_author832name4 
end 	
 

if @c_author832name1 is not null 
   and @c_author832name1 <> ''
   and upper (@c_authortype1)= 'ILLUSTRATOR'
begin
	select @i_illustratorcount = @i_illustratorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^I0'+
	convert(char (1),@i_illustratorcount)+'^'+@c_author832name1 
end 

if @c_author832name2 is not null 
   and @c_author832name2 = ''
   and upper (@c_authortype2)= 'ILLUSTRATOR'
begin
	select @i_illustratorcount = @i_illustratorcount + 1

	insert into elo832feed (feedtext) select 'PID^S^^BI^I0'+
	convert(char (1),@i_illustratorcount)+'^'+@c_author832name2 
end 

if @c_author832name3 is not null 
   and @c_author832name3 <> ''
   and upper (@c_authortype3)= 'ILLUSTRATOR'
begin
	select @i_illustratorcount = @i_illustratorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^I0'+
	convert(char (1),@i_illustratorcount)+'^'+@c_author832name3 
end 

if @c_author832name4 is not null 
   and @c_author832name4 <> ''
   and upper (@c_authortype4)= 'ILLUSTRATOR'
begin
	select @i_illustratorcount = @i_illustratorcount + 1
	insert into elo832feed (feedtext) select 'PID^S^^BI^I0'+
convert(char (1),@i_illustratorcount)+'^'+@c_author832name4 
end 	

if @i_authorcount = 0 and @i_illustratorcount = 0
begin
		select @c_message = ' no author'
		print @c_isbn10 
		print  @c_message 
		select @i_validationerrorind = 1 /* must have author */
end

/*******************************************/
/* Output PID TI01 Title                   */
/*******************************************/


/* 4/5/03 - CT- commented out code to break title (and subtitle) line into 80 character or less segments. */
/* we will now output title (subtitle) in single line */


/*  Total line can be no more than 80 characters, so we will */
/*  substring title at 65 character which is 80 chars minus  */
/*  the PID tag of 15 chars **/

/*insert into elo832feed (feedtext) select 'PID^S^^BI^TI01^'+
substring (@c_titlewithprefix,1,65) + '~'

/* Check for remaining title and output if needed */
if len (@c_titlewithprefix) > 65
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^TI02^'+
	substring (@c_titlewithprefix,66,65) + '~'
end
*/
insert into elo832feed (feedtext) select 'PID^S^^BI^TI01^'+@c_titlewithprefix + '~'

if len (@c_titlewithprefix) = 0
begin
	select @c_message = ' no title'
	print @c_isbn10
	print @c_message
	select @i_validationerrorind = 1 /* must have title */
end


/*******************************************/
/* Output PID ST01 Subtitle                */
/*******************************************/

/* we will now allow a totle of 95 characters per line , so below does not apply*/
/*  Total line can be no more than 80 characters, so we will */
/*  substring title at 65 character which is 80 chars minus  */
/*  the PID tag of 15 chars. Max size of Subtitle is 255    **/

if @c_subtitle is not null and @c_subtitle <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^ST01^'+
	substring (@c_subtitle,1,80) + '~'

	/* Check for remaining subtitle and output if needed */
	if len (@c_subtitle) > 80
	begin
		insert into elo832feed (feedtext) select 'PID^S^^BI^ST02^'+
		substring (@c_subtitle,81,80) + '~'
	end

	/* Check for remaining subtitle and output if needed */
	if len (@c_subtitle) > 160
	begin
		insert into elo832feed (feedtext) select 'PID^S^^BI^ST03^'+
		substring (@c_subtitle,161,80) + '~'
	end

	/* Check for remaining subtitle and output if needed */
	if len (@c_subtitle) > 240
	begin
		insert into elo832feed (feedtext) select 'PID^S^^BI^ST04^'+
		substring (@c_subtitle,241,15) + '~'
	end
	
end /** If Subtitle is not null or blank **/

/*******************************************/
/* Output PID IM  Bisac Media              */
/*******************************************/

if @c_mediabisaccode is not null and @c_mediabisaccode <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^IM^'+ @c_mediabisaccode + '~'
end


else
begin
	select @c_message = ' no media'
	print @c_isbn10
	print @c_message
	select @i_validationerrorind = 1 /* must have media */
end

/*******************************************/
/* Output PID FBP  Bisac Format            */
/*******************************************/

if @c_formatbisaccode is not null and @c_formatbisaccode <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^FBP^'+ @c_formatbisaccode + '~'
end

else
begin
	select @c_message = 'no format'
	print @c_isbn10 
	print @c_message
	select @i_validationerrorind = 1 /* must have format */
end

/*******************************************/
/* Output PID SA  Bisac Status             */
/*******************************************/

if @c_bisacstatuscode is not null and @c_bisacstatuscode <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^SA^'+ @c_bisacstatuscode + '~'
end

/*******************************************/
/* Output PID PA  Pagecount                */
/*******************************************/

if @i_pagecount is not null and @i_pagecount > 0
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^PA^'+ 
	convert (varchar (5), @i_pagecount) + '~'
end

/*******************************************/
/* Output PID ED  Edition                  */
/*******************************************/


select @i_editioncode = editioncode from bookdetail where bookkey=@i_bookkey
if @i_editioncode is not null and @i_editioncode > 0
begin
	select @c_editionbisaccode=bisacdatacode from gentables where tableid=200 
	and datacode=@i_editioncode

end

if @c_editionbisaccode is not null and @c_editionbisaccode <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^ED^'+ @c_editionbisaccode + '~'
end


/*******************************************/
/* Output PID AD  Audience Code            */
/* Set to Juvenile or Trade based on Bisac */
/* Subject Code- Juvenile = JUV and        */
/* JNF (Juvenile Non-Fiction)              */
/*******************************************/

if  substring (@c_bisaccategorymajorcode1,1,3) = 'JUV' or 
    substring (@c_bisaccategorymajorcode1,1,3) = 'JNF'
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^AD^JUV' + '~'
end
else
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^AD^TRA' + '~'
end



/*******************************************/
/* Output PID S1,S2,S3  Bisac category     */
/*******************************************/

if @c_bisaccategoryminorcode1 is not null and @c_bisaccategoryminorcode1 <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^S1^'+ @c_bisaccategoryminorcode1 + '~'
end

if @c_bisaccategoryminorcode2 is not null and @c_bisaccategoryminorcode2 <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^S2^'+ @c_bisaccategoryminorcode2 + '~'
end

if @c_bisaccategoryminorcode3 is not null and @c_bisaccategoryminorcode3 <> ''
begin
	insert into elo832feed (feedtext) select 'PID^S^^BI^S3^'+ @c_bisaccategoryminorcode3 + '~'
end

/*******************************************/
/* Output PO4 - Carton Qty and Trim Size   */
/*******************************************/

if @c_trimsizewidth is null or @c_trimsizewidth = ''
begin
	/* Initialize to blank if null */
	select @c_trimsizewidth = ''
end

if @c_trimsizelength is null or @c_trimsizelength = ''
begin
	/* Initialize to blank if null */
	select @c_trimsizelength = ''
end



if @i_cartonqty is null or @i_cartonqty = 0
begin
	select @c_cartonqty = '0'
end
else
begin
	select @c_cartonqty = convert (varchar (5),@i_cartonqty)
end

/* do not include the 'IN' dimension info if no trim size data is available */

if @c_trimsizewidth = '' and @c_trimsizelength = ''
	insert into elo832feed (feedtext) select 'PO4^' + @c_cartonqty + '~'
else
	insert into elo832feed (feedtext) select 'PO4^' + @c_cartonqty +
	'^^^^^^^^^' + @c_trimsizewidth + '^' + @c_trimsizelength + '^^IN' + '~'


/********************************************************/
/* Output CTP Price                                     */
/* If there are no cents, output as whole number        */
/* i.e. 13.95 is outputted as is, 14.00 is output as 14 */
/* with the '.00' stripped off                          */
/********************************************************/

if @d_usretailprice is not null and @d_usretailprice > 0
begin
	select @c_usretailprice=convert (varchar (10),@d_usretailprice)

	if substring (@c_usretailprice,len (@c_usretailprice)-2,3)='.00'
	begin
		select @c_usretailprice=substring (@c_usretailprice,1,len (@c_usretailprice)-2)
	end
	
	insert into elo832feed (feedtext) select 'CTP^TR^MSR^' + @c_usretailprice + '~'
end
else
begin
	select @c_message = 'no price'
	print @c_isbn10 
	print @c_message
	select @i_validationerrorind = 1 /* must have price */
end

/*******************************************/
/* Output CUR Currency                     */
/*******************************************/

insert into elo832feed (feedtext) select 'CUR^MF^USD' + '~'

/*******************************************/
/* Output N1 segment                       */
/*******************************************/
select 
@c_sendersan = sendersan,
@c_suppliertype = suppliertype
from elo832control

insert into elo832feed (feedtext) select 'N1^' + RTRIM(@c_suppliertype) + '^' +
RTRIM(@c_publishername) + '^15^' + RTRIM(@c_sendersan) + '~'

/** Wrap Up **/
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

