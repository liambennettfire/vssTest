/** CREATE UOC WEBSITE SUBJECT             **/


/** Select all nyp or active books **/
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

/**********CREATE SUBJECT FILES subject.idx,subject.htm and individual subject file.htm **********/
/*PASS ONLY CUTOFF DATE, this date will have to be verified for each run*/

Print 'Executing Web Subject Out Stored Proc'
go

set nocount on
go

DECLARE @d_cutoffdate datetime

/* set cutoff date  can hardcode if need be' 
example  execute websubjout_sp '01/01/2004' */


/*9-30-04 UOC change subject and series files, added
extra parameters (cutoffdate,file location,userid and password) to procedure call*/

select @d_cutoffdate = getdate() -120

execute websubjout_sp  @d_cutoffdate,'c:\','qsidba','qsidba'

GO
exit