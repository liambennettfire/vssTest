IF EXISTS (SELECT * FROM clientoptions WHERE optionid=120)
	UPDATE clientoptions SET optionvalue = 1 WHERE optionid = 120
	
GO	