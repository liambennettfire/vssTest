/* vistaxjrpo-in-init.sql **/
/** This SQL will be run prior to bcp'ing the nightly data file **/
/** into the feed tables **/

print 'Dropping and recreating feedin_xjrpop'
go

drop table feedin_xjrpop
go

/**  10-13-04 xjrpop feed table **/

CREATE TABLE dbo.feedin_xjrpop
(isbn		VARCHAR(10) NULL,
ponumber	VARCHAR(10) NULL,
jobno		VARCHAR(10) NULL,
ordqty	VARCHAR(10) NULL,
recqty	VARCHAR(10) NULL,
dateord	VARCHAR(20) NULL,
datedue	VARCHAR(20) NULL,
cmpflag	CHAR(1) NULL,
datecomp	VARCHAR(20) NULL,
lastdelref	VARCHAR(10) NULL,
lastdelno	CHAR(1) NULL,
smref		VARCHAR(10) NULL,
daterevsd	VARCHAR(20) NULL,
datecnfrmd	VARCHAR(20) NULL,
pmode		varchar(20) NULL,
vistacomment	varchar(4000)	NULL)
go

GRANT ALL on dbo.feedin_xjrpop TO public
go 