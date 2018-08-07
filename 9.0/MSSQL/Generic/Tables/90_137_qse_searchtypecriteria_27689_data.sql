INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES(30, 156, 'coreprojectinfo', 'projecttitle')
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES(30, 133, 'coreprojectinfo', 'projectstatus')
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname, secondtablename, secondcolumnname)
VALUES(30, 137, 'taqprojecttask', 'activedate', 'taqprojecttask', 'reviseddate')
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname, subgencolumnname)
VALUES(30, 282, 'taqversionformat', 'mediatypecode', 'mediatypesubcode')
go

-- (dbo.get_gentables_desc(312, mediatypecode, ''long'') + ''/'' + dbo.get_subgentables_desc(312, mediatypecode, mediatypesubcode, ''long'')) 