IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.deleteprodnum') AND type = 'TR')
	DROP TRIGGER dbo.deleteprodnum
GO

CREATE TRIGGER deleteprodnum ON isbn
FOR DELETE AS
BEGIN
	DELETE productnumber
	FROM productnumber,deleted
	WHERE productnumber.bookkey = deleted.bookkey
END
GO