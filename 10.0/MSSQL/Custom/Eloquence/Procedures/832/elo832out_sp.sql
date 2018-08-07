SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elo832out_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elo832out_sp]
GO
create proc dbo.elo832out_sp @c_version varchar (6), @c_modifieddate varchar (10), @c_partnertype char (3) as

/**  3/13/03 - Added @c_version to allow for conversion to Version 4010 when needed (4010 used CCYYMMDD format for dates )*/ 
/**   @c_version is used to populate GS08 and passed is also to elo832outbook  **/

/* 4/23/03 - Added functionality to provide add\change\delete information in the G53 segment of LIN envelope. This */
/* will be an option determined by trading partner info in elotradingpartner table */
 
/** This stored procedure is dependant upon the successful completion **/
/** of the eloflatout_sp procedure as it uses the resulting eloflatfeed table contents **/
/** to generate the 832 **/

DECLARE @i_bookkey int
DECLARE @c_currentdate varchar (10)
DECLARE @d_currentdate datetime
DECLARE @i_book_cursor_status int
DECLARE @i_output_832_book int
DECLARE @c_publishername varchar (100)
DECLARE @c_imprintname varchar (100)
DECLARE @c_isbn10 varchar (25)
DECLARE @c_segmentcount varchar (25)
DECLARE @c_lincount varchar (25)
DECLARE @c_controlnumber varchar (25)
DECLARE @c_todayYYMMDD char (6)
DECLARE @c_todayHHMM varchar (5)
DECLARE @c_sendersan char (15)
DECLARE @c_receiversan char (15)
DECLARE @c_ediaddress char (15)

DECLARE @c_applicationref char (10)
DECLARE @c_enterprisepassword char (10)
DECLARE @c_suppliertype char (2)
DECLARE @c_BCT10 char (2)





/* Truncate the output table in preparation for new feed */
truncate table elo832feed


/* The 832 Feed will use all rows existing in eloflatfeed table */
/* rather than going to the PSS5 tables directly, therefore the cursor */
/* will select from the eloflatfeed table */
DECLARE cursor_book INSENSITIVE CURSOR
FOR
select distinct (bookkey), publishername,imprintname,isbn10 from eloflatfeed
order by publishername,imprintname,isbn10
FOR READ ONLY

OPEN cursor_book

print 'Total Number of Books Exporting for 832: ' + convert (char(10),@@CURSOR_ROWS)

/***************************************************************/
/** Prepare variables for outputting X12 Envelope             **/
/** NOTE THE USE OF THE ELO832CONTROL TABLE                   **/
/** VALUES SUCH AS THE SenderSAN and ReceiverSAN              **/
/** can be set prior to executing this SP. Alternatively, the **/
/** fields can be set to a recognizable string and POST PROCESSED **/
/*  on the elo832feed tab after the SP runs and before the    **/
/** BCP from elo832feed runs                                  **/
/** (i.e. Update elo832feed set feedtext =                                **/
/** replace (feedtext,'RECEIVERSAN___','12345678_______' where seqnum=1   **/
/** This will allow this 832 transaction to be resent to different Receivers by modifying **/
/** the receiver san and bcp'ing multiple times rather than haveing to run the SP **/
/** multiple times                                            **/
/***************************************************************/

/** Generate the Control Number **/

update elo832control set 
controlnumber = controlnumber + 1, 
lastuserid='ELO832SP',
lastmaintdate=getdate()

/** Select Envelope variables from the control table **/
/** Make sure SenderSan and Receiversan are right padded with spaces **/
/** to 15 characters total **note - CT - These fields are now being trimmed of spaces, per Atilla's */
/** instructions. We will need to determine what is correct                                     **/


/** CT - 3/18/03 - need to left pad control number with zero's */

select 
@c_controlnumber = replace (convert(varchar (9),str(controlnumber,9,0)), ' ', '0' ),
@c_sendersan = sendersan,
@c_receiversan = receiversan,
@c_applicationref = applicationref,
@c_enterprisepassword = enterprisepassword
from elo832control



/*** Generate Todays Date and Time  ***/
/** Use convert function with style 12 for YYMMDD **/ 
/** Use convert style 8 for HH:MM - then replace : with blank**/
/** 4/03 - CT - Trim leading/trailing spaces from HH:MM */

select @c_todayYYMMDD = convert (char (6),getdate(),12) 

select @c_todayHHMM = convert (char (5),getdate(),8)

select @c_todayHHMM = replace (@c_todayHHMM,':','')

select @c_todayHHMM = LTRIM(RTRIM(@c_todayHHMM))



/***************************************************************/
/** Output Transmission Envelope Header (ISA and GS segments) **/
/** FOR EXAMPLES SEE BISG.ORG X12 30 Enveloping Segments Example **/
/** in the EDI Cookbook                                       **/
/***************************************************************/
/* CT - The *ZZ* that preceeds receiversan (ISA07)needs to be *12* for ADMK sample file, *01* for Anderson News . We should  
add this field to the control table??*/

insert into elo832feed (feedtext) select 
'ISA^00^' + @c_applicationref + '^00^' + @c_enterprisepassword + '^ZZ^' + @c_sendersan + '^01^'+ @c_receiversan +
'^' + @c_todayYYMMDD + '^' + @c_todayHHMM + '^U^00200^' + @c_controlnumber + '^0^P^>~' 


/***************************************************************/
/** Output Transmission Envelope Header - GS segments         **/
/***************************************************************/

insert into elo832feed (feedtext) 
select 'GS^SC^' + RTRIM(@c_sendersan) + '^' + RTRIM(@c_receiversan) + '^' + @c_todayYYMMDD +
'^' + @c_todayHHMM + '^' + @c_controlnumber + '^X^' + @c_version + '~'

FETCH NEXT FROM cursor_book
INTO @i_bookkey, @c_publishername, @c_imprintname, @c_isbn10

select @i_book_cursor_status = @@FETCH_STATUS

/***************************************************************/
/** Output ST segment                                         **/
/***************************************************************/

insert into elo832feed (feedtext) select 'ST^832^' + @c_controlnumber + '~'

/***************************************************************/
/** Output BCT segments                                       **/
/***************************************************************/

/* 04/11/03 - CT Changed BCT02 to 'Simon&Schuster'. In future this value should be companyname */
/*						and should be pulled from the customer table' */

/* 4/23/03 - Need Add call to ? table to determine value for BCT10 */
/*	 - 00 means use G53 to convery add\change\delete status for each title. */
/*     - 05 means replace - which means this data replaces any data that you have for this title */

select @c_BCT10 = '05' /* default to 'replace' */
if (@c_partnertype = 'G53') /* use G53 segment */
begin
	select @c_BCT10 = '00'
end
																					

insert into elo832feed (feedtext) select 'BCT^RC^' + 'Simon & Schuster' + '^^^^^^^^' + @c_BCT10 + '~'


while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
	
	exec @i_output_832_book=elo832outbook_sp @i_bookkey, @c_version, @c_modifieddate, @c_BCT10
	end

	FETCH NEXT FROM cursor_book
	INTO @i_bookkey, @c_publishername, @c_imprintname, @c_isbn10
        select @i_book_cursor_status = @@FETCH_STATUS
end



close cursor_book
deallocate cursor_book

/** Output Final 832 Ending **/

/***********************************************************************/
/** Output CTT segment  - which is a count of all books (LIN SEGMENTS **/
/***********************************************************************/

select @c_lincount = convert (varchar (10), count (*)) from elo832feed where feedtext like 'LIN%'

insert into elo832feed (feedtext) select 'CTT^' + @c_lincount + '~'

/*************************************************************************/
/** Output SE segment  - which includes the 832controlnumber and a count **/
/* of all Segments inluding ST and SE                                    **/
/** but EXCLUDING the ISA and GS Segments                                **/
/**************************************************************************/

/** NOTE: We are adding one to the count because the count should include **/
/** the SE segment which we are now outputing and therefore is not on the **/
/** database.								  **/

select @c_segmentcount = convert (varchar (10), count (*) + 1) from elo832feed 
where feedtext not like 'ISA%' and feedtext not like 'GS%'

insert into elo832feed (feedtext) select 'SE^'  + @c_segmentcount + '^' + @c_controlnumber + '~'

/**************************************************************************/
/** Output GE segment  - which includes the 832controlnumber and a count **/
/* of all ST Segments which is always one                                **/
/**************************************************************************/

insert into elo832feed (feedtext) select 'GE^1^' + @c_controlnumber + '~'

/**************************************************************************/
/** Output IEA segment  - which includes the 832controlnumber and a count **/
/* of all GS Segments which is always one                                **/
/**************************************************************************/

insert into elo832feed (feedtext) select 'IEA^1^' + @c_controlnumber + '~'

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

