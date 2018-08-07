INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (28,14,0,11,'Media','Media','dbo','get_gentables_desc(312,taqprojectprinting_view.mediatypecode,''long'') mediadesc',1,0,11,null,11,'left')
go


INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (28,14,0,12,'Format','Format','dbo','get_subgentables_desc(312,taqprojectprinting_view.mediatypecode,taqprojectprinting_view.mediatypesubcode,''long'') formatname',1,0,12,null,12,'left')
go