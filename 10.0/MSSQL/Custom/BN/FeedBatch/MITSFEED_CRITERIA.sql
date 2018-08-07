/** This SQL Outputs  B&N Titles For Today**/
delete from bnmitstitlefeedbookkeys

insert into bnmitstitlefeedbookkeys (bookkey)
/* 8-24-04 uncomment when okayed
select distinct t.bookkey from booksubjectcategory b, titlehistory t
where categorycode =1 and categorytableid=431 */
select  distinct t.bookkey from bookorgentry b, titlehistory t
where b.orgentrykey=323 and b.orglevelkey=1
and printingkey=1 and b.bookkey=t.bookkey
and t.lastmaintdate>=convert(varchar,getdate(),101) /*up to the hour*/

/* insert any other titles which have a MITS Class assigned */
/* do not insert dups already entered **/
insert into bnmitstitlefeedbookkeys (bookkey)
select t.bookkey from bookmisc b, titlehistory t
where misckey=1 
and printingkey=1 and b.bookkey=t.bookkey
and t.lastmaintdate>=convert(varchar,getdate(),101)  /*up to the hour*/
and longvalue is not null 
and longvalue > 0
and t.bookkey not in 
(select bookkey from  bnmitstitlefeedbookkeys)

/* 7-20-04 insert titles from   booksubjectcategory changes */
insert into bnmitstitlefeedbookkeys (bookkey)
select distinct bookkey from booksubjectcategory
where categorytableid=437
and lastmaintdate>=convert(varchar,getdate(),101)  
and bookkey not in 
(select bookkey from  bnmitstitlefeedbookkeys)


/*7-20-04 remove templates for now*/
delete from bnmitstitlefeedbookkeys where bookkey in (
select bookkey from book where standardind='Y')

exec feed_out_title_info

/** post processing **/
/*7-20-04  put back per doug
8-24-04 do all deletes in procedure need total rowcount*/
/*delete from bnmitstitlefeed where isbn10 is null
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where isbn10 = ''
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where titlewithprefix is null

delete from bnmitstitlefeed where titlewithprefix = ''
*/

/* Eliminate Merchkeys temporarily until complete feed back complete 7-20-04 put back per doug*/
/*delete from bnmitstitlefeed where merchkey=0
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where merchkey is null
and titlewithprefix not like 'Total Records%'
*/

/** Run Author Out ****/
exec feed_out_author_info


/*FUll RUN*/
/** This SQL Outputs ALL B&N Titles **/
delete from bnmitstitlefeedbookkeys

insert into bnmitstitlefeedbookkeys (bookkey)
select bookkey from bookorgentry where orglevelkey=1
and orgentrykey=323
/*changed 8-23-04 to below put back orig 8-24-04 till this okayed
select distinct bookkey from booksubjectcategory where categorytableid=431 and
categorycode =1*/

/* insert any other titles which have a MITS Class assigned */
/* do not insert dups already entered **/
insert into bnmitstitlefeedbookkeys (bookkey)
select bookkey from bookmisc 
where misckey=1 
and longvalue is not null 
and longvalue > 0
and bookkey not in 
(select bookkey from  bnmitstitlefeedbookkeys)

/*7-20-04 remove templates for now*/
delete from bnmitstitlefeedbookkeys where bookkey in (
select bookkey from book where standardind='Y')

exec feed_out_title_info

/** post processing **/
/*7-20-04  put back per doug
8-24-04 any deletes must be done in procedure becuase need
total rowcount*/
/*delete from bnmitstitlefeed where isbn10 is null
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where isbn10 = ''
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where titlewithprefix is null

delete from bnmitstitlefeed where titlewithprefix = ''
*/

/* Eliminate Merchkeys temporarily until complete feed back complete 7-20-04 put back per doug*/
/*delete from bnmitstitlefeed where merchkey=0
and titlewithprefix not like 'Total Records%'

delete from bnmitstitlefeed where merchkey is null
and titlewithprefix not like 'Total Records%'
*/

/** Run Author Out ****/
exec feed_out_author_info
