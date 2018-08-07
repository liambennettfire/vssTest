
DECLARE @v_maxDataCode INT 
SET @v_maxDataCode = (SELECT MAX(dataCode) FROM gentables WHERE tableId = 519)

INSERT INTO gentables(tableid,datacode,deletestatus,tablemnemonic,datadesc,datadescshort,lastuserid,lastmaintdate)
VALUES(519,@v_maxDataCode+1,'N','ContactRelationship','Ignore for Website Only','Ignore for Website','qsiadmin',GETDATE())