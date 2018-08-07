/* cispubtmm-in-main.sql **/
/** This SQL will be run after the bcp of the nightly data file **/
/** into the feed tables **/

Print 'Executing Feed In Stored Procedure'
go
set nocount on
go
execute feed_in_title_info
go

Print 'Following is output from FEEDERROR table...'
go
select * from feederror where batchnumber ='3' and processdate >= convert (char,getdate(), 101)
	order by batchnumber,isbn
go