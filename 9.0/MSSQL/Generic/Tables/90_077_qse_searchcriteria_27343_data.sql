INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, allowrangeind, querystring)
VALUES
  (280, 'Last Updated On', 3, 4, 1, 'LastMaintDt')
go  
  
UPDATE qse_searchcriteria
SET querystring = 'ProjStat'
WHERE searchcriteriakey = 71
go

UPDATE qse_searchcriteria
SET querystring = 'Tmplt'
WHERE searchcriteriakey = 143
go

UPDATE qse_searchcriteria
SET querystring = 'TmpltStr'
WHERE searchcriteriakey = 151
go

UPDATE qse_searchcriteria
SET querystring = 'UsageClass'
WHERE searchcriteriakey = 120
go

UPDATE qse_searchcriteria
SET querystring = 'PubDate'
WHERE searchcriteriakey = 241
go

UPDATE qse_searchcriteria
SET querystring = 'EloCust'
WHERE searchcriteriakey = 89
go

UPDATE qse_searchcriteria
SET querystring = 'MetadataAsset'
WHERE searchcriteriakey = 240
go

UPDATE qse_searchcriteria
SET querystring = 'VerType'
WHERE searchcriteriakey = 199
go

UPDATE qse_searchcriteria
SET querystring = 'VerStat'
WHERE searchcriteriakey = 200
go

UPDATE qse_searchcriteria
SET querystring = 'CSApprvl'
WHERE searchcriteriakey = 184
go
