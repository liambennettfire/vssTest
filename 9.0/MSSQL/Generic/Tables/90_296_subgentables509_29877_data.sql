
insert into subgentables (
tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,alldivisionsind,
externalcode,datadescshort,lastuserid,lastmaintdate,numericdesc1,numericdesc2,bisacdatacode,
subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,	
eloquencefieldtag,alternatedesc1,alternatedesc2,subgen3ind,qsicode,subgen4ind)
values (
509,25,1,'Purchase Order Reports','N',NULL,1,'RPTMENU',NULL,NULL,NULL,'INIT',getdate(),NULL,NULL,NULL,0,0,
NULL,NULL,0,0,NULL,NULL,NULL,0,1,0)
go

insert into sub2gentables (
tableid,datacode,datasubcode,datasub2code,datadesc,deletestatus,applid,sortorder,tablemnemonic,
alldivisionsind,externalcode,datadescshort,lastuserid,lastmaintdate,numericdesc1,numericdesc2,bisacdatacode,
sub2gen1ind,sub2gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
values (
509,25,1,1,'Purchase Order','N',NULL,	1,'RPTMENU',NULL,NULL,NULL,'INIT',getdate(),NULL,1,NULL,0,0,NULL,NULL,0,0,NULL,NULL,NULL,1)
go
