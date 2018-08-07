/* vista-in-init.sql **/
/** This SQL will be run prior to bcp'ing the nightly data file **/
/** into the feed tables **/


print 'Dropping and recreating feedin_titles'
go
drop table feedin_titles
go

CREATE TABLE dbo.feedin_titles
(isbn                   VARCHAR(10) NULL,
bisacstatuscode         VARCHAR(10) NULL,
retailprice             VARCHAR(20) NULL,
canadianprice           VARCHAR(20) NULL,
nextretailprice         VARCHAR(20) NULL,
nextcanadianprice       VARCHAR(20) NULL,
categorycode            VARCHAR(12) NULL,
pubdate                 VARCHAR(12) NULL,
usnextpricedate		VARCHAR(12) NULL,
canadanextpricedate	VARCHAR(12) NULL,
reldate                 VARCHAR(12) NULL,
cartonqty               VARCHAR(10) NULL,
canadianrestriction	VARCHAR(10) NULL,
projectisbn             VARCHAR(15) NULL,
qtyavailable            VARCHAR(15) NULL,
nextisbn		varchar(10) null,
vistadivision		varchar (15) NULL,
backorderqty		varchar (15) NULL,
vistaimprint		varchar (15) NULL,
openqty			varchar (10) NULL,
dummyfield		varchar(10)  NULL)

GRANT ALL on dbo.feedin_titles TO public

go
