/* vista-in-main.sql **/
/** This SQL will be run after the bcp of the nightly data file **/
/** into the feed tables **/

/************************** BARNES & NOBLE CHANGE  !!!!!!  *************************************/
/** delete all records owned by B&N based on Publisher orgentry                              ***/
/**  Changed by DSL 7/15/2004  -- 1-7-05 remove 3 isbns for now                                                               ***/
/***********************************************************************************************/

delete from feedin_titles
where isbn in (select isbn10 from isbn where bookkey in 
(select bookkey from bookorgentry where orgentrykey=323))
and isbn not in ('0883659603','1586630962','1586631888')

/***********************************************************************************************/

print 'Set the External Code for all ISBN prefixes to Prefix without dashes'
go
update gentables set externalcode=rtrim (substring (datadesc,1,1) + substring (datadesc,3,10))
where tableid=138
go


/******* Set the prices to the 'Next' prices if available ****/
update feedin_titles set retailprice=nextretailprice where nextretailprice is not null
go

update feedin_titles set canadianprice=nextcanadianprice where nextcanadianprice is not null
go

/******* Bisac Status Changes  **/

print 'Set the inbound BisacStatusCode of TOS to OS which is the correct Status for Temporarily Out of Stock'
go
update feedin_titles set bisacstatuscode='OS' where bisacstatuscode='TOS'
go

print 'Set all OP,OSI, PC titles for NON STERLING DIVISIONS to No Longer Our Publication'
print '************************************************************************'
print '******  MAKE SURE ANY NEW STERLING DIVISIONS ARE ADDED TO THIS SQL *****'
print '************************************************************************'
go
update feedin_titles set bisacstatuscode = 'NL'
where bisacstatuscode in ('OP','OSI','PP','PC') and vistadivision not in ('ST','AL','HE','CH')
go

/*******************************************************************************/
/*** Modified 2/5/2004 by DSL to set OPE titles to a new Bisac Status of OPE, **/
/**  rather then active, we will continue to set the OPE Indicator            **/
/*******************************************************************************/
print 'Set all OPE Titles to Bisac Status of active and set the corresponding Indicator or true'
print 'First alter the table to add the new indicator'
alter table feedin_titles add opexhaustedind int null
go
/*** Changed 2/5/2004 **/
/**
update feedin_titles set bisacstatuscode='ACT',opexhaustedind=1 
where bisacstatuscode='OPE'
**/


/** new SQL 2/5/2004  **/
update feedin_titles set opexhaustedind=1 where bisacstatuscode='OPE'
go

print 'Set opexhaustedind for all other titles to False'
go
update feedin_titles set opexhaustedind = 0 where opexhaustedind is null
go

print 'Set the Canadian Restriction of "Y" to "NCR" which equals No Canadian Rights'
go
update feedin_titles set canadianrestriction='NCR' where canadianrestriction='Y'
go


Print 'Executing Feed In Stored Proced'
go
set nocount on
go
execute feed_in_title_info
go
Print 'Following is output from FEEDERROR table...'
go
select * from feederror where batchnumber='3' and processdate >= convert (char,getdate(), 101)
go

/*10-15-04 */
Print 'Alter table - add bookkey'
go
set nocount on
go

alter table feedin_titles add bookkey int null
go

print 'Set the bookkey on feedin_titles by joining to the ISBN table'
go
update feedin_titles
set bookkey =i.bookkey 
from isbn i
where i.isbn10=feedin_titles.isbn
go