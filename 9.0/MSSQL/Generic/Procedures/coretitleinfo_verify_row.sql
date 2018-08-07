/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.CoreTitleInfo_Verify_Row') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP PROC dbo.CoreTitleInfo_Verify_Row
  END
GO

CREATE PROCEDURE CoreTitleInfo_Verify_Row
@bookkey int, @printingkey int, @bookkey_only int OUTPUT
AS

DECLARE @v_maxprintingkey INT
DECLARE @v_count INT

BEGIN
 IF @bookkey is null
   return

 IF @bookkey_only = 1
    BEGIN
	/* no printingkey on the table being updated */
	SELECT @v_count = count(*)
	FROM coretitleinfo
	WHERE bookkey = @bookkey

	IF @v_count = 0
		/* Insert coretitleinfo row with 0 printingkey */
		INSERT INTO coretitleinfo (bookkey,printingkey)
           	VALUES (@bookkey,0)
    END

  ELSE
    BEGIN
	/* printing level table being updated */
	SELECT @v_count = count(*)
	FROM coretitleinfo
	WHERE bookkey = @bookkey AND printingkey = @printingkey

	IF @v_count = 0
	  BEGIN
		/* look for row with printingkey = 0 because it may have been inserted already */
		SELECT @v_count = count(*)
		FROM coretitleinfo
		WHERE bookkey = @bookkey AND printingkey = 0

		IF @v_count = 0
		  BEGIN
			/* if any rows exist for this bookkey, use max printing to populate the new row */
			SELECT @v_maxprintingkey = max(printingkey)
			FROM coretitleinfo
			WHERE bookkey = @bookkey
				
			IF @v_maxprintingkey > 0
			  BEGIN
				/* Insert coretitleinfo row and copy BOOK level fields from last printing */
				INSERT INTO coretitleinfo 
				 (bookkey,
				 printingkey,
				 productnumber,
				 title,
				 titleprefix,
				 shorttitle,
				 authorname,
				 illustratorname,
				 mediatypecode,
				 mediatypesubcode,
				 formatname,
				 editioncode,
				 editiondesc,
				 bisacstatuscode,
				 bisacstatusdesc,
				 titlestatuscode,
				 titletypecode,
				 seriescode,
				 seriesdesc,
				 imprintkey,
				 imprintname,
				 tmmheaderorg1key,
				 tmmheaderorg1desc,
				 tmmheaderorg2key,
				 tmmheaderorg2desc,
				 orgentryfilter,
				 formatchildcode,
				 childformatdesc,
				 linklevelcode,
				 standardind,
				 publishtowebind,
				 sendtoeloind,
				 ageinfo,
				 tmmprice,
				 finalpriceind,
				 workkey,
				 titleprefixupper,
				 productnumberx,
             isbn,
             isbnx,
             ean,
             eanx,
             upc,
             upcx,
             altproductnumber,
             altproductnumberx,
             titleverifycode,
             verifelobasic,
             verifbna,
             verifbooknet,
             titleverifydesc,
             itemtypecode,
             usageclasscode)
				SELECT bookkey,
				 @printingkey,
				 productnumber,
				 title,
				 titleprefix,
				 shorttitle,
				 authorname,
				 illustratorname,
				 mediatypecode,
				 mediatypesubcode,
				 formatname,
				 editioncode,
				 editiondesc,
				 bisacstatuscode,
				 bisacstatusdesc,
				 titlestatuscode,
				 titletypecode,
				 seriescode,
				 seriesdesc,
				 imprintkey,
				 imprintname,
				 tmmheaderorg1key,
				 tmmheaderorg1desc,
				 tmmheaderorg2key,
				 tmmheaderorg2desc,
				 orgentryfilter,
				 formatchildcode,
				 childformatdesc,
				 linklevelcode,
				 standardind,
				 publishtowebind,
				 sendtoeloind,
				 ageinfo,
				 tmmprice,
				 finalpriceind,
				 workkey,
				 titleprefixupper,
				 productnumberx,
             isbn,
             isbnx,
             ean,
             eanx,
             upc,
             upcx,
             altproductnumber,
             altproductnumberx,
             titleverifycode,
             verifelobasic,
             verifbna,
             verifbooknet,
             titleverifydesc,
             itemtypecode,
             usageclasscode             
				FROM coretitleinfo
				WHERE bookkey = @bookkey AND printingkey = @v_maxprintingkey
			  END
			ELSE
			  BEGIN
				/* Insert coretitleinfo row */
				INSERT INTO coretitleinfo (bookkey, printingkey)
            		VALUES (@bookkey, @printingkey)
			  END
		  END
		
		ELSE IF @v_count > 0
		  BEGIN
			/* update printingkey */
			UPDATE coretitleinfo
			SET printingkey = @printingkey
			WHERE bookkey = @bookkey AND printingkey = 0
		  END
	  END
    END

    SELECT @v_count = count(*)
      FROM titlechangedinfo
     WHERE bookkey = @bookkey
 
    IF @v_count > 0 BEGIN
      UPDATE titlechangedinfo
         SET lastchangedate = getdate()
       WHERE bookkey = @bookkey
    END
    ELSE BEGIN
      INSERT INTO titlechangedinfo (bookkey,lastchangedate)
           VALUES (@bookkey,getdate())
    END

END
GO