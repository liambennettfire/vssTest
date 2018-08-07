/** CREATE UOC WEBSITE              **/


/** Select all nyp or active books **/

truncate table webbookkeys

insert into webbookkeys
select distinct bookkey
		from bookdetail
			where bisacstatuscode in  (1,4)
go
			
/**********CREATE TITLE FILE TITLE.SGM **********/

execute webbookout_sp
go

/**********CREATE SERIES FILES series.idx,series.htm and individual series file.htm **********/
/*PASS ONLY CUTOFF DATE, this date will have to be verified for each run*/

execute webseriesout_sp '01/01/2006'
GO

/**********CREATE SUBJECT FILES subject.idx,subject.htm and individual subject file.htm **********/
/*PASS ONLY CUTOFF DATE, this date will have to be verified for each run*/

execute websubjout_sp '01/01/2006'
GO

/**********CREATE CATALOG FILES individual catalog file .html **********/
/*PASS ONLY CUTOFF DATE, this date will have to be verified for each run*/

execute webvirtcatout_sp '01/01/2006'

GO
exit