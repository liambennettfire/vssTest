/** This SQL Outputs  B&N Printing Titles For Today**/
delete from bnpubprintingfeedkeys

insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from printing
where lastmaintdate>=convert(varchar,getdate(),101) /*up to the hour*/

insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from titlehistory
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert specs-- bindingspecs tables*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from bindingspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert compspec*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from compspec
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert coverspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from coverspecs
where lastmaintdate>=convert(varchar,getdate(),101)
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert endpapers*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from endpapers
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert jacketspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from jacketspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert mediainsertspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from mediainsertspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert transparencyspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from transparencyspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert textspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from textspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/*******other specs tables*/

/* insert assemblypecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from assemblyspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert audiocassettespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from audiocassettespecs
where lastmaintdate>=convert(varchar,getdate(),101)
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert audiospecs -- no lastmaintdate
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from audiospecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and bookkey not in (select distinct bookkey from bnpubprintingfeedkeys)
*/

/* insert bundlespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from bundlespecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert cameraspec*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cameraspec
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert cardspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cardspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert casespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from casespecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert cdromspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cdromspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert coverinsertspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from coverinsertspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert diskettespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from diskettespecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert documentationspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from documentationspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert electpackagingspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from electpackagingspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert errataspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from errataspecs
where lastmaintdate>=convert(varchar,getdate(),101)
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert labelspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from labelspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert laserdiscspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from laserdiscspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert materialspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from materialspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/


/* insert misccompspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from misccompspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert nonbookspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from nonbookspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert posterspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from posterspecs
where lastmaintdate>=convert(varchar,getdate(),101)
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert printpackagingspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from printpackagingspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert secondcoverspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from secondcoverspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert stickerspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from stickerspecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* DELETES */

delete from bnpubprintingfeedkeys where bookkey in (
select bookkey from book where standardind='Y')


/* delete ones not in master list*/
delete from bnpubprintingfeedkeys where bookkey not in (
select distinct bookkey from booksubjectcategory 
where categorycode =1 and categorytableid=431 )

/*delete MJ fine or sterling titles 
2-10-05 crm 2440 remove this delete

delete from bnpubprintingfeedkeys where bookkey in (
select distinct bookkey from bookmisc
where misckey = 1 and longvalue in(5,8))
*/

/*delete from exclude table*/

delete from bnpubprintingfeedkeys 
where exists(select bnpubprintingfeedexclude.bookkey,bnpubprintingfeedexclude.printingkey
from bnpubprintingfeedexclude 
where bnpubprintingfeedkeys.bookkey=bnpubprintingfeedexclude.bookkey and bnpubprintingfeedkeys.printingkey=bnpubprintingfeedexclude.printingkey)
/*run printing info*/

exec feed_out_printing_info

/*run component printing info*/
exec feed_out_printing_comp_info

/*run qtybreakdown info*/
exec feed_out_printing_qtybkdwn_info

/*run coordinators info*/
exec feed_out_printing_coord_info


/*DTS for each*/
dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingFeedIncr

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingCompFeedIncr

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingQtyBkwFeedIncr

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingCoordFeedIncr

/******************FULL****************************/

/** This SQL Outputs  B&N Printing Titles ALL**/

delete from bnpubprintingfeedkeys

insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from printing

insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from titlehistory
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys)


/* insert specs-- bindingspecs tables*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from bindingspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys)

/* insert compspec*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from compspec
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert coverspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from coverspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 


/* insert endpapers*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from endpapers
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys)

/* insert jacketspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from jacketspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert mediainsertspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from mediainsertspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys)


/* insert transparencyspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from transparencyspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys)

/* insert textspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from textspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/*******other specs tables*/

/* insert assemblypecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from assemblyspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert audiocassettespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from audiocassettespecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert audiospecs -- no lastmaintdate
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from audiospecs
where lastmaintdate>=convert(varchar,getdate(),101) 
and bookkey not in (select distinct bookkey from bnpubprintingfeedkeys)
*/

/* insert bundlespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from bundlespecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert cameraspec*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cameraspec
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys)

/* insert cardspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cardspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert casespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from casespecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert cdromspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from cdromspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert coverinsertspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from coverinsertspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert diskettespecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from diskettespecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 


/* insert documentationspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from documentationspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert electpackagingspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from electpackagingspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert errataspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from errataspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert labelspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from labelspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert laserdiscspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from laserdiscspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) /*up to the hour*/

/* insert materialspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from materialspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedk

/* insert misccompspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from misccompspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert nonbookspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from nonbookspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert posterspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from posterspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert printpackagingspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from printpackagingspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert secondcoverspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from secondcoverspecs
where  not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* insert stickerspecs*/
insert into bnpubprintingfeedkeys (bookkey,printingkey)
select distinct bookkey ,printingkey
from stickerspecs
where not exists (select bookkey,printingkey from bnpubprintingfeedkeys) 

/* DELETES */

delete from bnpubprintingfeedkeys where bookkey in (
select bookkey from book where standardind='Y')


/* delete ones not in master list*/
delete from bnpubprintingfeedkeys where bookkey not in (
select distinct bookkey from booksubjectcategory 
where categorycode =1 and categorytableid=431 )

/*delete MJ fine or sterling titles
2-10-05 crm 2440 remove this delete

delete from bnpubprintingfeedkeys where bookkey in (
select distinct bookkey from bookmisc
where misckey = 1 and longvalue in(5,8))
*/

/*delete from exclude table*/

delete from bnpubprintingfeedkeys 
where exists(select bnpubprintingfeedexclude.bookkey,bnpubprintingfeedexclude.printingkey
from bnpubprintingfeedexclude 
where bnpubprintingfeedkeys.bookkey=bnpubprintingfeedexclude.bookkey and bnpubprintingfeedkeys.printingkey=bnpubprintingfeedexclude.printingkey)


/*run printing info*/

exec feed_out_printing_info

/*run component printing info*/
exec feed_out_printing_comp_info

/*run qtybreakdown info*/
exec feed_out_printing_qtybkdwn_info

/*run coordinators info*/
exec feed_out_printing_coord_info


/*DTS for each*/
dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingFeedFull

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingCompFeedFull

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingQtyBkwFeedFull

dtsrun /SWBCOSPDB /Uqsidba /Pqsidba /NBNPrintingCoordFeedFull
