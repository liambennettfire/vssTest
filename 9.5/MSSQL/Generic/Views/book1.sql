SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[book1]
GO


CREATE VIEW book1 
	(bookkey,
	title,
	sku,
	isbn,
	isbn10,
	standardind,
	creationdate,
	cycle,
	mediatypecode,
	mediatypesubcode,
	lastuserid,
	lastmaintdate,
	specsrecind,
	nextprintingnbr,
	ttlcd,
	scaleorgentrykey,
	productnumber,
	reuseisbnind,
	authorname,
   ean,
   editioncode) 
AS SELECT 
	BOOK.BOOKKEY, 
	BOOK.TITLE, 
	BOOK.SKU, 
	ISBN.ISBN, 
	ISBN.ISBN10, 
	BOOK.STANDARDIND, 
	BOOK.CREATIONDATE, 
	BOOK.CYCLE, 
	BOOKDETAIL.MEDIATYPECODE, 
	BOOKDETAIL.MEDIATYPESUBCODE, 
	BOOK.LASTUSERID, 
	BOOK.LASTMAINTDATE, 
	BOOK.SPECSRECIND, 
	BOOK.NEXTPRINTINGNBR, 
	ISBN.TTLCD, 			
	BOOK.SCALEORGENTRYKEY, 
	PRODUCTNUMBER.PRODUCTNUMBER,
	BOOK.REUSEISBNIND,
		'                               ',
   ISBN.EAN,
   BOOKDETAIL.EDITIONCODE
FROM BOOK, BOOKDETAIL, ISBN, PRODUCTNUMBER 
WHERE ( BOOK.BOOKKEY = BOOKDETAIL.BOOKKEY ) AND 
		( BOOKDETAIL.BOOKKEY = ISBN.BOOKKEY ) AND
		( BOOK.BOOKKEY = PRODUCTNUMBER.BOOKKEY ) 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[book1]  TO [public]
GO
