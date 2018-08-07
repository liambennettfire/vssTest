IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.updateprodnum') AND type = 'TR')
	DROP TRIGGER dbo.updateprodnum
GO

CREATE TRIGGER updateprodnum ON isbn  
FOR UPDATE AS

DECLARE @columnname VARCHAR(50), 
	@newprodnum VARCHAR(50),
	@oldprodnum VARCHAR(50),
	@newisbn VARCHAR(13),
	@oldisbn VARCHAR(13),
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
	SELECT @newprodnum = ''
	SELECT @oldprodnum = ''

	IF @columnname = 'isbn'
		SELECT @oldprodnum = d.isbn,
			@newprodnum = i.isbn,
			@lastuserid = i.lastuserid,
			@bookkey = d.bookkey
		FROM inserted i, deleted d
		WHERE i.isbnkey = d.isbnkey

	ELSE IF @columnname = 'upc'
		SELECT @oldprodnum = d.upc,
			@newprodnum = i.upc,
			@lastuserid = i.lastuserid,
			@bookkey = d.bookkey
		FROM inserted i, deleted d
		WHERE i.isbnkey = d.isbnkey

	ELSE IF @columnname = 'itemnumber'
		SELECT @oldprodnum = d.itemnumber,
			@newprodnum = i.itemnumber,
			@lastuserid = i.lastuserid,
			@bookkey = d.bookkey
		FROM inserted i, deleted d
		WHERE i.isbnkey = d.isbnkey

	IF @@error <> 0
	  BEGIN
		ROLLBACK TRANSACTION
		select @err_msg = 'Could not select from isbn table (trigger).'
		print @err_msg
	  END

	IF @oldprodnum IS NULL
		SELECT @oldprodnum = ''
	IF @newprodnum IS NULL
		SELECT @newprodnum = ''

      IF @newprodnum <> @oldprodnum
        BEGIN
		UPDATE productnumber
		SET productnumber = @newprodnum,
			lastuserid = @lastuserid,
			lastmaintdate = getdate()
            WHERE bookkey = @bookkey AND productnumlockey = 1

            IF @@error != 0
              BEGIN
	           ROLLBACK TRANSACTION
	           select @err_msg = 'Could not update productnumber table (trigger).'
	           print @err_msg
              END
	  END

	/**** Update ISBN on coretitleinfo. ****/
	/**** The above productnumber table update takes care of PRODUCTNUMBER update on coretitleinfo. ****/
	SELECT @newisbn = i.isbn, @oldisbn = d.isbn
	FROM inserted i, deleted d
	WHERE i.isbnkey = d.isbnkey

	IF @oldisbn IS NULL
		SELECT @oldisbn = ''
	IF @newisbn IS NULL
		SELECT @newisbn = ''

	IF @newisbn <> @oldisbn
	  BEGIN
		/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
		EXECUTE CoreTitleInfo_Verify_Row @bookkey, 0, 1

		UPDATE coretitleinfo
		SET isbn = @newisbn, isbnx = REPLACE(@newisbn, '-', '')
		WHERE bookkey = @bookkey

            IF @@error != 0
              BEGIN
	           ROLLBACK TRANSACTION
	           select @err_msg = 'Could not update ISBN on coretitleinfo table (trigger).'
	           print @err_msg
              END
	  END

  END
GO

