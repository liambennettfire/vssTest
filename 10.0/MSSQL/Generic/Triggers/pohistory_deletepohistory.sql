IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'deletepohistory')
	BEGIN
		DROP  Trigger deletepohistory
	END
GO


create TRIGGER deletepohistory ON pohistory
FOR DELETE
AS
BEGIN
INSERT INTO pocancellation (bookkey, printingkey,
sku,ponumber,datecancelled,lastuserid,isbn10,pokey,interfaceseqnum,productnumber)
SELECT deleted.bookkey, printingkey, sku, ponumber,
	getdate(), deleted.lastuserid, isbn10, pokey,interfaceseqnum,productnumber
FROM deleted, isbn
WHERE deleted.bookkey=isbn.bookkey
END

