
/****** Object:  Trigger dbo.insertpohistory    Script Date: 5/22/2000 4:22:19 PM ******/
/****** Object:  Trigger dbo.insertpohistory    Script Date: 7/28/97 5:14:31 PM ******/
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'insertpohistory')
	BEGIN
		DROP  Trigger insertpohistory
	END
GO

CREATE TRIGGER insertpohistory
ON pohistory
FOR INSERT
AS
BEGIN
DELETE pocancellation
FROM pocancellation,inserted
WHERE (pocancellation.bookkey=inserted.bookkey) AND
(pocancellation.printingkey=inserted.printingkey)
END

