/* cispub-out-main.sql **/
/** This SQL will run the feed out procedure then bcp to data file **/

/*
print 'update bookcustom column code 6-- reset to all ready to null then update to ready
all that have required fields'
*/

update bookcustom
set customcode09 = null
where customcode09 = 2 
go

/*insert of missing bookcustom*/

insert into bookcustom (bookkey,lastuserid,lastmaintdate)
select distinct b.bookkey,'FEEDOUT_UOC',getdate() from book b
where not exists (select b2.bookkey from
bookcustom b2 where b.bookkey=b2.bookkey)
go

/*update pofeeddate.tentativefeeddate to now*/
update pofeeddate
set tentativefeeddate = getdate()
where feeddatekey=7
go

/*required fields isbn10,format, discount, title, price, bisacstatus
chris add back  active titles 1,4 nyp,10 Not Yet Scheduled (Status 5)*/

update bookcustom 
set customcode09 = 2
where bookkey  in (
select distinct i.bookkey from isbn i,bookdetail be,book bk,booksubjectcategory bs,
bookprice bp, bookauthor ba, titlehistory t
where i.bookkey= bk.bookkey and i.bookkey = be.bookkey
	and i.bookkey =  bs.bookkey and i.bookkey = bp.bookkey
	and i.bookkey = ba.bookkey
	and datalength(isbn10) = 10
	and mediatypecode >0 and mediatypesubcode >0
	and discountcode > 0 
	and pricetypecode = 8 and currencytypecode = 6 /*price*/
	and datalength(bk.title) > 0
	and be.bisacstatuscode in (1,4,10) 
	and i.bookkey=t.bookkey and t.printingkey=1
	and t.lastmaintdate>= (select feeddate from pofeeddate where
		feeddatekey=7)
	and t.lastmaintdate< (select tentativefeeddate from pofeeddate
		where feeddatekey=7))

go	

/* set any not 2 to not ready 1*/
update bookcustom
set customcode09 = 1
where customcode09 is null or customcode09=0
go


/*truncating tables before start*/

delete from feedout_titles
go
delete from feedout_authors
go
delete from feedout_majorsubj
go

Print 'Executing Feed Out Stored Proc, author'
go

set nocount on
go

execute feed_out_author_info
go

Print 'Executing Feed Out Stored Proc, major subjects'
go

set nocount on
go

execute feed_out_majsub_info
go

Print 'Executing Feed Out Stored Proc, title'
go

set nocount on
go

execute feed_out_title_info
go

Print 'Following is output from FEEDERROR table...'
go
select * from feederror where batchnumber ='1' and processdate >= convert (char,getdate(), 101)
	order by batchnumber
go