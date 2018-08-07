truncate table rtf2htmlbookkeys

/* update changes of Table of Content and UR Copy
6-1-04 add Rich Title(29) and Subtitle (30)*/

/* get all rows not currently on bookcommenthtml
10-29-04 CRM 02045 modified.. titles that previously inserted here was not
inserting any new comment rows because was only using bookkey to distinguish*/

insert into rtf2htmlbookkeys (bookkey,printingkey,commenttypecode,commenttypesubcode)
select b.bookkey,b.printingkey,b.commenttypecode,b.commenttypesubcode 
from bookcommentrtf b
where not exists (select  bh.bookkey,bh.printingkey,bh.commenttypecode,bh.commenttypesubcode
from bookcommenthtml bh
where b.printingkey=bh.printingkey
and b.bookkey=bh.bookkey and b.commenttypecode=bh.commenttypecode
and b.commenttypesubcode = bh.commenttypesubcode
and bh.commenttypecode = 1 and bh.commenttypesubcode in (8,24,29,30))
and b.commenttypecode = 1 and b.commenttypesubcode in (8,24,29,30)
go

/* get all rows with lastmaintdate on bookcommenthtml less than lastmaintdate on bookcommentrtf*/

insert into rtf2htmlbookkeys (bookkey,printingkey,commenttypecode,commenttypesubcode)
select b.bookkey,b.printingkey,b.commenttypecode,b.commenttypesubcode 
	from bookcommentrtf b, bookcommenthtml b2
		where b.bookkey = b2.bookkey 
		  and b.printingkey = b2.printingkey
		  and b.commenttypecode = b2.commenttypecode
		  and b.commenttypesubcode = b2.commenttypesubcode
		  and b.commenttypecode = 1 
		  and b.commenttypesubcode in (8,24,29,30) 
		  and b2.lastmaintdate < b.lastmaintdate

go

/** Execute the Bookcommenthtml stored procedure */
/* Send zero for 'allbooksind' parameter to export rows specified
in rtf2htmlbookkeys - this may be used for incremental updates
Send one for 'allbooksind' parameter to build complete bookcommenthtml table */
exec bookcommenthtml_sp 0
go

select count (*) from bookcommenthtml
select count(*) from rtf2htmlbookkeys