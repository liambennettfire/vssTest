delete From qse_searchcriteria where searchcriteriakey in (295,296)

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, allowrangeind)
VALUES
  (295, 'Age Range', 7, 7, 1)
go

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, allowrangeind)
VALUES
  (296, 'Grade Range', 7, 7, 1)
go