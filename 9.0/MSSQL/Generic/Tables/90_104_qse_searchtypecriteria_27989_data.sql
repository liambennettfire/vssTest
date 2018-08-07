delete from qse_searchtypecriteria where searchtypecode = 29
go

-- for purchase orders start with most of the same search criteria as projects
	INSERT INTO qse_searchtypecriteria
	  (searchtypecode,searchcriteriakey,tablename,columnname,subgencolumnname,subgen2columnname,
	   secondtablename,secondcolumnname,bestcolumnname)
	SELECT DISTINCT 29,searchcriteriakey,tablename,columnname,subgencolumnname,subgen2columnname,
		   secondtablename,secondcolumnname,bestcolumnname
	  FROM qse_searchtypecriteria
	 WHERE searchtypecode = 7
	   and searchcriteriakey not in (13,70,75,76,77,78,79,80,81,82,83,84,85,93,127,135,157,158,159,160,177,179,180,181,202,203)
	   and searchcriteriakey not in (select searchcriteriakey from qse_searchcriteria where misckey is not NULL)
go

-- PO Number
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES(29, 281, 'taqproductnumbers', 'productnumber')
go

-- Related Title/Printing
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey)
VALUES
  (29, 284)
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (29, 285, 'purchaseorderstitlesview', 'title')
go

-- Printing Number
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (29, 286, 'purchaseorderstitlesview', 'printingnum')
go

-- Author Last Name
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (29, 287, 'purchaseorderstitlesview', 'authorname')
go

-- Pub Date
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (29, 288, 'purchaseorderstitlesview', 'pubdate')
go

-- Season
INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES
  (29, 289, 'purchaseorderstitlesview', 'seasonkey')
go