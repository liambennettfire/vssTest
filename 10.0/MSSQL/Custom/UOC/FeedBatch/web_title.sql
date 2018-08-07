/** CREATE UOC WEBSITE              **/


/** Select all nyp or active books **/
/*6-8-04 make sure no blank isbn titles get in*/
/*8-1-04 display different format of a title in one control tag not separate
         control tag... need to only put one row into the webbookkeys table*/

truncate table webbookkeys

insert into webbookkeys
select distinct b.bookkey
		from bookdetail b, isbn i, book b2
			where b.bookkey=i.bookkey and bisacstatuscode in  (1,4)
				and b.bookkey = b2.bookkey
				and datalength(isbn)>0
				and b2.bookkey=b2.workkey  /*insert parentkey first*/

go

/*9-30-04  get the lowest bookkey in the set from bookcustom.customint09 that is not the parent*/

insert into webbookkeys
select min(b.bookkey)
		from bookdetail b, isbn i, book b2, bookcustom bc
			where b.bookkey=i.bookkey and bisacstatuscode in  (1,4)
				and b.bookkey = b2.bookkey and b.bookkey=bc.bookkey
				and datalength(isbn)>0
				and b2.bookkey<>b2.workkey  /*insert childkey when parent not already present*/
				and b2.workkey not in (select bookkey from webbookkeys)
				group by customint09

go
			
/**********CREATE TITLE FILE TITLE.SGM **********/

Print 'Executing Web Title Out Stored Proc'
go

set nocount on
go

execute webbookout_sp
go

exit