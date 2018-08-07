/* cispubymm-in-init.sql **/
/** This SQL will be run prior to bcp'ing the nightly data file **/
/** into the feed tables **/


print 'truncating feedin_titles'
go

truncate table feedin_titles
go

