set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROC [dbo].[YUPFeedTitleInfo] AS

DECLARE @date DATETIME
DECLARE @count INT
DECLARE @bookkey  INT
DECLARE @isbn10  VARCHAR(10)
DECLARE @ean13 VARCHAR(13)
DECLARE @retailprice VARCHAR(20)
DECLARE @bisacstatuscode VARCHAR(10)
DECLARE @discount VARCHAR(10)
DECLARE @discountcode VARCHAR(10)
DECLARE @cartonqty INT 
DECLARE @qtyavailable VARCHAR(20)
DECLARE @bookweight FLOAT
DECLARE @bisacstatus INT
DECLARE @territorycode INT
DECLARE @convchar VARCHAR(100)

BEGIN TRAN 

SELECT @date = GETDATE()

INSERT INTO feederror (batchnumber, processdate, errordesc, detailtype) VALUES ('3', @date, 'Feed Summary: Updates', 0)
INSERT INTO feederror (batchnumber, processdate, errordesc, detailtype) VALUES ('3', @date, 'Feed Summary: Rejected', 0)

DECLARE feed_titles_YUP INSENSITIVE CURSOR FOR
	SELECT LEFT(t.isbn, 10), RTRIM(t.isbn13), RTRIM(t.status), RTRIM(t.retailprice),
		CONVERT(INT, t.cartonqty), RTRIM(bookweightgross), RTRIM(t.qtyavailable), UPPER(RTRIM(t.discount))
		FROM yupbookmaster t, isbn i
		WHERE i.ean13 = RTRIM(t.isbn13) AND LEN(RTRIM(t.isbn13)) = 13
	FOR READ ONLY

OPEN feed_titles_YUP 

FETCH NEXT FROM feed_titles_YUP INTO @isbn10, @ean13, @bisacstatuscode, @retailprice, @cartonqty, @bookweight, @qtyavailable, @discount

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @bookkey = b.bookkey FROM isbn i, book b
		WHERE i.bookkey = b.bookkey AND (b.reuseisbnind IS NULL or reuseisbnind = 0) AND ean13 = @ean13
	
	IF @bookkey IS NULL --Title not found in TMM
		UPDATE feederror SET detailtype = (detailtype + 1) WHERE batchnumber='3' AND processdate >= @date AND errordesc LIKE 'Feed Summary: Rejected%'
	ELSE
	BEGIN
		SELECT @count = COUNT(bookkey) FROM bookdetail WHERE bookkey = @bookkey
		IF @count = 0
			INSERT INTO bookdetail (bookkey, lastuserid, lastmaintdate) VALUES (@bookkey, 'BOOKMASTERFEED', @date)
		
		--BISAC Status:
		SELECT @bisacstatus = datacode FROM gentables WHERE UPPER(externalcode )= UPPER(@bisacstatuscode) AND tableid=314 

		IF @bisacstatus IS NULL
			INSERT INTO feederror (isbn, batchnumber, processdate, errordesc) 
				VALUES (@isbn10, '3', @date, 'BISAC STATUS NOT ON GENTABLES; BISAC STATUS NOT UPDATED ' + @bisacstatuscode)
		ELSE
		BEGIN --BISAC Status		
			UPDATE feederror SET detailtype = (detailtype + 1) WHERE batchnumber='3' AND processdate >= @date AND errordesc LIKE 'Feed Summary: Updates%'
			EXEC dbo.titlehistory_insert 'BISACSTATUSCODE', 'BOOKDETAIL', @bookkey, 0, '', @bisacstatus, 1
			UPDATE bookdetail SET bisacstatuscode = @bisacstatus, lastuserid='BOOKMASTERFEED', 
				lastmaintdate = CASE WHEN bisacstatuscode=@bisacstatus THEN lastmaintdate ELSE @date END 
				WHERE bookkey = @bookkey
		END

		--Discount
		SELECT @discountcode = datacode FROM gentables WHERE UPPER(externalcode)=@discount AND tableid=459 
	
		IF @discountcode IS NULL
		 	INSERT INTO feederror (isbn, batchnumber, processdate, errordesc)
				VALUES (@isbn10, '3', @date, 'DISCOUNT CODE NOT ON GENTABLES; DISCOUNT NOT UPDATED '+ @discount)
		ELSE
		BEGIN --Discount Code
			EXEC dbo.titlehistory_insert 'DISCOUNTCODE','BOOKDETAIL', @bookkey, 0, '', @discountcode, 1
			UPDATE bookdetail SET discountcode = @discountcode, lastuserid = 'BOOKMASTERFEED', 
				lastmaintdate = CASE WHEN discountcode = @discountcode THEN lastmaintdate ELSE @date END 
				WHERE bookkey = @bookkey
		END

		IF @territorycode > 0 
		BEGIN --Territory
			EXEC dbo.titlehistory_insert 'TERRITORIESCODE', 'BOOK', @bookkey, 0, '', @territorycode, 1
			UPDATE book SET territoriescode = @territorycode, lastuserid = 'BOOKMASTERFEED', 
				lastmaintdate = CASE WHEN territoriescode = @territorycode THEN lastmaintdate ELSE @date END 
				WHERE bookkey = @bookkey
		END

		-- Carton Qty:
		if @cartonqty >1
		BEGIN
			EXEC dbo.titlehistory_insert 'CARTONQTY1', 'BINDINGSPECS', @bookkey, 1, '', @cartonqty, 1
	
			SELECT @count = COUNT(bookkey) FROM bindingspecs WHERE bookkey = @bookkey AND printingkey=1
			IF @count > 0
				UPDATE bindingspecs SET cartonqty1 = @cartonqty, lastuserid='BOOKMASTERFEED', 
					lastmaintdate = CASE WHEN cartonqty1 = @cartonqty THEN lastmaintdate ELSE @date END
					WHERE bookkey = @bookkey AND printingkey = 1
			ELSE
				INSERT INTO bindingspecs (bookkey, printingkey, vendorkey, cartonqty1, lastuserid, lastmaintdate)
					VALUES (@bookkey, 1, 0, @cartonqty, 'BOOKMASTERFEED', @date)
		END

		--Bookweight:
		IF LEN(@bookweight) > 0 AND @bookweight <> .00000
		BEGIN
			SELECT @convchar = CONVERT(CHAR, @bookweight)
			EXEC dbo.titlehistory_insert 'BOOKWEIGHT', 'PRINTING', @bookkey, 0, '', @convchar, 1

			SELECT @count = COUNT(bookkey) FROM printing WHERE bookkey = @bookkey
			IF @count > 0
				UPDATE printing SET bookweight = @bookweight, lastuserid='BOOKMASTERFEED', 
					lastmaintdate = CASE WHEN bookweight = @bookweight THEN lastmaintdate ELSE @date END
					WHERE bookkey = @bookkey
			ELSE
				INSERT INTO printing (bookkey, bookweight, lastmaintdate, lastuserid) VALUES (@bookkey, @bookweight, @date, 'BOOKMASTERFEED')
		END

		--Quantity available:
		SELECT @count = COUNT(bookkey) FROM bookcustom WHERE bookkey = @bookkey
		IF @count > 0 
			UPDATE bookcustom SET customint01 = @qtyavailable, lastuserid='BOOKMASTERFEED', 
				lastmaintdate = CASE WHEN customint01 = @qtyavailable THEN lastmaintdate ELSE @date END
				WHERE bookkey = @bookkey
		ELSE
			INSERT INTO bookcustom (bookkey, customint01, lastmaintdate, lastuserid) VALUES (@bookkey, @qtyavailable, @date, 'BOOKMASTERFEED')
			
		--Retail Price:
		IF LEN(@retailprice) > 0 AND @retailprice <> '0.0000'
		BEGIN
			SELECT @convchar = CONVERT(float, @retailprice)
			EXEC dbo.titlehistory_insert 'FINALPRICE', 'BOOKPRICE', @bookkey, 0, '8', @convchar, 1
			
			SELECT @count = COUNT(bookkey) FROM bookprice WHERE bookkey=@bookkey AND currencytypecode=6 AND pricetypecode=8
			IF @count > 0
				UPDATE bookprice SET finalprice = @retailprice, lastuserid='BOOKMASTERFEED', 
					lastmaintdate = CASE WHEN finalprice = @retailprice THEN lastmaintdate ELSE @date END
					WHERE bookkey=@bookkey AND currencytypecode=6 AND pricetypecode=8
			ELSE
				BEGIN
					UPDATE keys SET generickey = generickey + 1, lastuserid = 'QSIADMIN', lastmaintdate = GETDATE()
					INSERT INTO bookprice  (pricekey, bookkey, pricetypecode, currencytypecode, activeind, finalprice, effectivedate, lastuserid, lastmaintdate)
						SELECT generickey, @bookkey, 8, 6, 1, @retailprice, @date, 'BOOKMASTERFEED', @date FROM keys
				END
		END
	END --IF @bookkey IS NULL
	
	FETCH NEXT FROM feed_titles_YUP INTO @isbn10, @ean13, @bisacstatuscode, @retailprice, @cartonqty, @bookweight, @qtyavailable, @discount
END --WHILE (@@FETCH_STATUS = 0)

INSERT INTO feederror (batchnumber, processdate, errordesc)  VALUES ('3', @date, 'Titles Completed' + CONVERT(CHAR, GETDATE()))

CLOSE feed_titles_YUP
DEALLOCATE feed_titles_YUP

COMMIT TRAN
