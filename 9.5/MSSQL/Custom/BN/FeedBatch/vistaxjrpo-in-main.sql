/* vistaxjrpop-in-main.sql **/
/** This SQL will be run after the bcp of the nightly data file **/
/** into the feed tables **/

/************************** BARNES & NOBLE CHANGE  !!!!!!  *************************************/
/** delete all records owned by B&N based on Publisher orgentry                              ***/
/**  Changed by AA 2/22/2005  CRM 2496 -- 1-7-05 remove 3 isbns for now                      ***/
/***********************************************************************************************/

delete from feedin_xjrpop
where isbn in (select isbn10 from isbn where bookkey in 
(select bookkey from bookorgentry where orgentrykey=323))
and isbn not in ('0883659603','1586630962','1586631888')

/***********************************************************************************************/


Print 'Alter table - add bookkey'
go
set nocount on
go

alter table feedin_xjrpop add bookkey int null
go

print 'Set the bookkey on feedin_xjrpop by joining to the ISBN table'
go
update feedin_xjrpop
set bookkey =i.bookkey 
from isbn i
where i.isbn10=feedin_xjrpop.isbn
go

update feedin_xjrpop
set vistacomment = replace(vistacomment,'|','')
go

Print 'Executing Feed In XJRPO Stored Proced'
go
set nocount on
go


execute feed_in_xjrpop
go

Print 'Following is output from FEEDERROR table...'
go

select * from feederror where batchnumber='5' and processdate >= convert (char,getdate(), 101)
go