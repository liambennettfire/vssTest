DECLARE
   @v_listkey INT,
   @v_itemtype INT,   
   @v_usageclass INT,
   @v_count INT
   
 SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44


INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,1,'Projectkey','Projectkey','coreprojectinfo','projectkey',0,1,0,null,0,'left')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,2,'Template','Template','coreprojectinfo','templateind',0,0,1,null,1,'center')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,3,'Name','Name','coreprojectinfo','projecttitle',1,0,2,null,2,'left')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,4,'Status','Status','coreprojectinfo','projectstatusdesc',1,0,3,null,3,'left')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,5,'Type','Type','coreprojectinfo','projecttypedesc',1,0,4,null,4,'left')

--INSERT INTO qse_searchresultscolumns
--  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
--   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
--VALUES
--  (30,16,0,6,'Media/Format','Media/Format','taqversionformat','(dbo.get_gentables_desc(312, mediatypecode, ''long'') + ''/'' + dbo.get_subgentables_desc(312, mediatypecode, mediatypesubcode, ''long'')) mediaformatdesc',1,0,5,null,5,'left')
--go

--INSERT INTO qse_searchresultscolumns
--  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
--   columnname,columnvaluesql,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
--VALUES
--  (30,@v_itemtype,0,6,'Media/Format','Media/Format','taqversionformat','mediaformatdesc','dbo.get_gentables_desc(312, mediatypecode, ''long'') + ''/'' + dbo.get_subgentables_desc(312, mediatypecode, mediatypesubcode, ''long'')',1,0,5,null,5,'left')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,columnvaluesql,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,6,'Media/Format','Media/Format','taqversionformat','mediaformatdesc','(SELECT COALESCE(dbo.get_gentables_desc(312, mediatypecode, ''long'') + ''/'' + dbo.get_subgentables_desc(312, mediatypecode, mediatypesubcode, ''long''), '''') FROM taqversionformat WHERE coreprojectinfo.projectkey = taqversionformat.taqprojectkey)',1,0,5,null,5,'left')


INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,7,'Key Participants','Key Participants','coreprojectinfo','projectparticipants',0,0,6,null,6,'left')

INSERT INTO qse_searchresultscolumns
  (searchtypecode,searchitemcode,usageclasscode,columnnumber,objectname,columnlabel,tablename,
   columnname,displayind,keycolumnind,defaultsortorder,defaultwidth,websortorder,webhorizontalalign)
VALUES
  (30,@v_itemtype,0,8,'Usage Class','Usage Class','coreprojectinfo','usageclasscodedesc',0,0,7,null,7,'left')
go
