-- make sure the order of the columns (sortorder) is in synch with the order of the controls in the code 
-- set websortorder = 0 so that they default to not visible

-- Printing Search
-- Sub Title
insert into qse_searchresultscolumns (searchtypecode,searchitemcode,usageclasscode,columnnumber,
objectname,columnlabel,defaultwidth,tablename,columnname,displayind,keycolumnind,defaultsortorder,
websortorder,webhorizontalalign)
values (28,14,0,14,'Sub Title','Sub Title',null,'taqprojectprinting_view','subtitle',1,0,14,0,'left')
go

-- add new columns to all existing title results views - as not visible
insert into qse_searchresultsviewlayout (resultsviewkey,columnnumber,columnorder,columnwidth,lastuserid,lastmaintdate)
select srv.resultsviewkey,src.columnnumber,src.websortorder,src.defaultwidth,'INITDATA',getdate()
  from qse_searchresultscolumns src, qse_searchresultsview srv
 where src.searchitemcode = srv.itemtypecode
   and src.searchtypecode = srv.searchtypecode 
   and src.searchtypecode = 28
   and src.searchitemcode = 14 
   and src.columnnumber in (14)
