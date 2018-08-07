IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.insertprodnum') AND type = 'TR')
	DROP TRIGGER dbo.insertprodnum
GO

CREATE TRIGGER insertprodnum ON isbn  
FOR INSERT AS 

DECLARE @columnname VARCHAR(50), 
	@newprodnum VARCHAR(50),
	@newisbn VARCHAR(13),
	@lastuserid VARCHAR(30), 
	@bookkey INT, 
	@err_msg VARCHAR(100)


/*** Get the table and column to be used as main numbering scheme - productnumlockey 1 ***/
SELECT @columnname = Lower(columnname)
FROM productnumlocation p
WHERE p.productnumlockey = 1

IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from productnumlocation table.'
	print @err_msg
  END
ELSE
  BEGIN
	IF @columnname = 'isbn'
	  BEGIN
		SELECT @newprodnum = i.isbn, 
			@lastuserid = i.lastuserid, 
			@bookkey = i.bookkey
		FROM inserted i
	  END
	ELSE IF @columnname = 'upc'
	  BEGIN
		SELECT @newprodnum = i.upc,
			@lastuserid = i.lastuserid,
			@bookkey = i.bookkey
		FROM inserted i
        END
      ELSE IF @columnname = 'itemnumber'
	  BEGIN
		SELECT @newprodnum = i.itemnumber,
			@lastuserid = i.lastuserid,
			@bookkey = i.bookkey
		FROM inserted i
	  END
	ELSE
        BEGIN
		SELECT @newprodnum = null,
			@lastuserid = i.lastuserid,
			@bookkey = i.bookkey
		FROM inserted i
        END

	INSERT INTO productnumber (bookkey, productnumlockey, productnumber, lastuserid, lastmaintdate)
	VALUES (@bookkey, 1, @newprodnum, @lastuserid, getdate())

      IF @@error != 0
      BEGIN
	     ROLLBACK TRANSACTION
	     select @err_msg = 'Could not insert into productnumber table (trigger).'
	     print @err_msg
      END

	/**** Update ISBN on coretitleinfo. ****/
	/**** The above insert into productnumber table takes care of PRODUCTNUMBER update on coretitleinfo. ****/
	SELECT @newisbn = i.isbn
	FROM inserted i

	/** Make sure row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @bookkey, 0, 1

	UPDATE coretitleinfo
	SET isbn = @newisbn, isbnx = REPLACE(@newisbn, '-', '')
	WHERE bookkey = @bookkey
  END
GO
