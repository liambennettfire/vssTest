/* vistapo-in-init.sql **/
/** This SQL will be run prior to bcp'ing the nightly data file **/
/** into the feed tables **/

print 'Dropping and recreating feedin_closedpo'
go

drop table feedin_closedpo
go

/**  7-11-03  add closedpo feed table **/

CREATE TABLE dbo.feedin_closedpo
(isbn		VARCHAR(10) NULL,
ponumber	VARCHAR(10) NULL,
jobno		VARCHAR(10) NULL,
ordqty	VARCHAR(10) NULL,
recqty	VARCHAR(10) NULL,
dateord	VARCHAR(20) NULL,
datedue	VARCHAR(20) NULL,
cmpflag	varCHAR(10) NULL,
datecomp	VARCHAR(20) NULL,
lastdelref	VARCHAR(20) NULL,
lastdelno	varCHAR(10) NULL,
smref		VARCHAR(20) NULL,
pomode		VARCHAR(100) NULL,
c_text		VARCHAR(100) NULL)
go

GRANT ALL on dbo.feedin_closedpo TO public
go 