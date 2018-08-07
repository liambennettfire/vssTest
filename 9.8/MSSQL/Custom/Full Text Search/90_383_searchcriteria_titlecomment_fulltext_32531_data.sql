-- qse_searchcriteria
delete from qse_searchcriteria
where searchcriteriakey = 297
go
INSERT INTO qse_searchcriteria
  (searchcriteriakey, [description], datatypecode, defaultoperator, fulltextsearchind, detailcriteriaind)
VALUES
  (297, 'Words Within', 1, 1, 1, 1)
go
delete from qse_searchcriteria
where searchcriteriakey = 298
go
INSERT INTO qse_searchcriteria
  (searchcriteriakey, [description], datatypecode, defaultoperator, parentcriteriaind)
VALUES
  (298, 'TITLE COMMENTS (SEARCH WITHIN)', 0, 1, 1)
go

-- qse_searchtypecriteria
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (6, 297, 'bookcomments', 'commenttext')
go
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname,subgencolumnname)
VALUES
  (6, 190, 'bookcomments', 'commenttypecode','commenttypesubcode')
go
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (6, 298, null, null)
go

-- qse_searchcriteriadetail
INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (298, 190, 1)
go
INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (298, 297, 2)
go
