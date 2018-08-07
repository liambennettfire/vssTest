INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, allowmultiplerowsind, parentcriteriaind)
VALUES
  (284, 'RELATED TITLE/PRINTING', 0, 1, 1, 1)
go


INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind)
VALUES
  (285, 'Title', 1, 3, 1)
go

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator,  detailcriteriaind)
VALUES
  (286, 'Printing Number', 1, 3, 1)
go

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind)
VALUES
  (287, 'Author Name', 1, 3, 1)
go

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, detailcriteriaind,allowrangeind,allowbestind)
VALUES
  (288, 'Pub Date', 3, 7, 1,1,1)
go

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, gentableid, detailcriteriaind)
VALUES
  (289, 'Season', 4, 1, 329, 1)
go

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (284, 285, 1)
go

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (284, 286, 2)
go

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (284, 287, 3)
go

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (284, 288, 4)
go

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (284, 289, 5)
go



