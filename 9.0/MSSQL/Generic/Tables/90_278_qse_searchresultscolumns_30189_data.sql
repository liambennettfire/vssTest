-- make sure the order of the columns (sortorder) is in synch with the order of the controls in the code 
-- set websortorder = 0 so that they default to not visible

-- Printing Search
-- Product Number

-- create a spot for productnumber to the left of title
update qse_searchresultscolumns
   set websortorder = websortorder + 1
 where searchtypecode = 28
   and searchitemcode = 14
   and websortorder >= 2
go

-- make productnumber visible by default and place it to the left of title
insert into qse_searchresultscolumns (searchtypecode,searchitemcode,usageclasscode,columnnumber,
objectname,columnlabel,defaultwidth,tablename,columnname,displayind,keycolumnind,defaultsortorder,
websortorder,webhorizontalalign)
values (28,14,0,13,'Product Number','Product Number',130,'taqprojectprinting_view','productnumber',1,0,13,2,'left')
go
    
-- create a spot for productnumber to the left of title for existing views
update qse_searchresultsviewlayout 
set columnorder = columnorder + 1
where resultsviewkey in (select resultsviewkey from qse_searchresultsview where searchtypecode = 28)
   and columnorder >= 2
go
    
-- add new columns to all existing printing results views - as visible
insert into qse_searchresultsviewlayout (resultsviewkey,columnnumber,columnorder,columnwidth,lastuserid,lastmaintdate)
select srv.resultsviewkey,src.columnnumber,src.websortorder,src.defaultwidth,'INITDATA',getdate()
  from qse_searchresultscolumns src, qse_searchresultsview srv
 where src.searchitemcode = srv.itemtypecode
   and src.searchtypecode = srv.searchtypecode 
   and src.searchtypecode = 28
   and src.searchitemcode = 14 
   and src.columnnumber in (13)
go   

