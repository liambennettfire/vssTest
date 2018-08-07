-- for printing start with most of the same search criteria as projects
	INSERT INTO qse_searchtypecriteria
	  (searchtypecode,searchcriteriakey,tablename,columnname,subgencolumnname,subgen2columnname,
	   secondtablename,secondcolumnname,bestcolumnname)
	SELECT DISTINCT 28,searchcriteriakey,tablename,columnname,subgencolumnname,subgen2columnname,
		   secondtablename,secondcolumnname,bestcolumnname
	  FROM qse_searchtypecriteria
	 WHERE searchtypecode = 7
	   and searchcriteriakey not in (13,70,75,76,77,78,79,80,81,82,83,84,85,93,127,135,202,203)
	   and searchcriteriakey not in (select searchcriteriakey from qse_searchcriteria where misckey is not NULL)
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
SELECT searchtypecode, 277, 'temp_globalcontact', 'searchname' 
	FROM qse_searchtypecriteria WHERE searchcriteriakey = 157
go

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
VALUES(28, 278, 'taqprojectprinting_view', 'printingnum')
go