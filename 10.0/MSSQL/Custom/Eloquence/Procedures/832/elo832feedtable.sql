create table elo832feed (seqnum int IDENTITY(1,1),feedtext text null)
create unique index elo832feed_p1 on elo832feed (seqnum)
grant all on elo832feed to public

drop table elo832control
go
create table elo832control (controlnumber int null, 
sendersan char (15),
receiversan char (15),
applicationref char (10),
enterprisepassword char (10),
suppliertype char(2),
lastuserid varchar (30), 
lastmaintdate datetime)

grant all on elo832control to public
insert into elo832control 
(
controlnumber,
sendersan,
receiversan,
applicationref,
enterprisepassword,
suppliertype,
lastuserid,
lastmaintdate
)
values 
(
1000,
'????????       ',
'????????       ',
'          ', /* 10 chars */
'          ', /* 10 chars */
'AG',
'DSL',
getdate()
)

delete from elo832control
/** FOR PUBNET ***/
insert into elo832control 
(
controlnumber,
sendersan,
receiversan,
applicationref,
enterprisepassword,
suppliertype,
lastuserid,
lastmaintdate
)
values 
(
1000,
'????????       ',
'DBTEST         ', /** Use DBLOAD for production **/
'832LD     ', /* 10 chars*/
'          ', /* 10 chars */
'AG',
'DSL',
getdate()
)

sp_help book