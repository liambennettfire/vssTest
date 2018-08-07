IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.maintainadvancepmtrevestdate') AND type = 'TR')
	DROP TRIGGER dbo.maintainadvancepmtrevestdate
GO

CREATE TRIGGER maintainadvancepmtrevestdate ON bookdates
FOR INSERT, UPDATE AS
IF UPDATE (bestdate)

DECLARE @bookkey		INT,
	@printingkey	INT,
	@datetypecode	INT,
	@bestdate		DATETIME,
	@calcbestdate	DATETIME,
	@contractkey	INT,
	@datacode		INT,
	@monthadv		INT,
	@dayadv		INT,	
	@err_msg		VARCHAR(100)

SELECT @bestdate = COALESCE(i.activedate, i.estdate),
	@bookkey = i.bookkey,
	@printingkey = i.printingkey,
	@datetypecode = i.datetypecode
FROM inserted i

IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from bookdates table (trigger).'
	print @err_msg
  END
ELSE
  BEGIN

	IF @printingkey = 1
	  BEGIN

		DECLARE curBDates CURSOR FOR
		SELECT c.contractkey, c.dateoffsetcode
		FROM bookdates b, contractadvance c, gentables g
		WHERE b.bookkey = c.bookkey AND
			b.datetypecode = c.datetypecode AND
			c.dateoffsetcode = g.datacode AND
			b.bookkey = @bookkey AND
			b.datetypecode = @datetypecode AND
			g.tableid = 466	/*** Advance Date Offset ***/ 

		OPEN curBDates 

		FETCH curBDates INTO @contractkey, @datacode

		WHILE @@FETCH_STATUS = 0
		  BEGIN
			SELECT @monthadv = numericdesc1, @dayadv = numericdesc2
			FROM gentables
			WHERE tableid = 466 AND datacode = @datacode 
        
			SET @calcbestdate = @bestdate

			IF @monthadv IS NOT NULL
			  SET @calcbestdate = DATEADD(month, @monthadv, @bestdate)
			ELSE IF @dayadv IS NOT NULL
			  SET @calcbestdate = DATEADD(day ,@dayadv, @bestdate)
  
			UPDATE contractadvance
			SET advancepmtrevestdate = @calcbestdate 
			WHERE contractkey = @contractkey AND
				datetypecode = @datetypecode AND
				dateoffsetcode = @datacode

			FETCH curBDates INTO @contractkey, @datacode
		  END

		  CLOSE curBDates
		  DEALLOCATE curBDates

	  END

	IF @@error != 0
	  BEGIN
		ROLLBACK TRANSACTION
		select @err_msg = 'Could not update bookdates table (trigger).'
		print @err_msg
	  END

  END

