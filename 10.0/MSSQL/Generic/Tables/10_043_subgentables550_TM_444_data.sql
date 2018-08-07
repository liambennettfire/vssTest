DECLARE @tableid INT,
		@datacode INT,
		@datasubcode INT,
		@qsicode INT

SET @tableid = 550

SELECT @datacode = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 5

SELECT @datasubcode = COALESCE(MAX(datasubcode), 0)
FROM subgentables
WHERE tableid = 550
  AND datacode = @datacode

SET @datasubcode = COALESCE(@datasubcode, 0) + 1

SET @qsicode = 85

IF NOT EXISTS(SELECT 1 FROM subgentables WHERE tableid = @tableid AND datacode = @datacode AND datasubcode = @datasubcode)
BEGIN
	INSERT INTO subgentables 
		(tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
		numericdesc1,numericdesc2,bisacdatacode,subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
		eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
	VALUES (@tableid,@datacode,@datasubcode,'User Table','N',NULL,1,'SearchItem',NULL,'User Table','QSIDBA',getdate(),
		NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@qsicode)
END