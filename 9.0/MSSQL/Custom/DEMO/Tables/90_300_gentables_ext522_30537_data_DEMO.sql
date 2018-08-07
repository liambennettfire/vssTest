IF NOT EXISTS (select * from gentables_ext where tableid = 522 and datacode = (SELECT datacode FROM gentables where tableid = 522 and qsicode = 4)) BEGIN    
	INSERT INTO gentables_ext 
	(tableid,datacode,onixcode,onixcodedefault,onixversion,lastuserid,lastmaintdate)
	SELECT tableid, datacode, null, 0, null,'FB_INSERT',getdate()
	FROM gentables where tableid = 522 and qsicode = 4 
END
GO