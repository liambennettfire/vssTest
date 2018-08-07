-- add new columns to all existing title results views - as not visible
insert into qse_searchresultsviewlayout (resultsviewkey,columnnumber,columnorder,columnwidth,lastuserid,lastmaintdate)
select srv.resultsviewkey,src.columnnumber,src.websortorder,src.defaultwidth,'INITDATA',getdate()
  from qse_searchresultscolumns src, qse_searchresultsview srv
 where src.searchitemcode = srv.itemtypecode
   and src.searchtypecode = srv.searchtypecode 
   and src.searchtypecode = 6
   and src.searchitemcode = 1 
   and src.columnnumber in (40)