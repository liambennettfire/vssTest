
IF NOT EXISTS(SELECT * FROM clientdefaults WHERE clientdefaultid = 82) BEGIN
	INSERT INTO clientdefaults
	  (clientdefaultid, clientdefaultname, clientdefaultcomment, clientdefaultvalue, lastuserid, lastmaintdate)
	VALUES
	  (82, 'Contact Comment Type Code', 'This will be the datacode for the Contact Note Types (tableid 528) to be used on contact searches', NULL, 'QSIDBA', getdate())
END  