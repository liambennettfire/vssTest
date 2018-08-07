IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_printing') AND type = 'TR')
	DROP TRIGGER dbo.core_printing
GO

CREATE TRIGGER core_printing ON printing
FOR INSERT, UPDATE AS
IF UPDATE (issuenumber) OR 
	UPDATE (jobnumberalpha) OR
	UPDATE (pubmonthcode) OR 
	UPDATE (pubmonth) OR 
	UPDATE (seasonkey) OR 
	UPDATE (estseasonkey)

BEGIN
	DECLARE @v_bookkey INT,
		@v_printingkey INT,
		@v_issuenumber INT,
		@v_jobnumberalpha CHAR(7),
		@v_pubmonthcode INT,
		@v_pubmonthname VARCHAR(10),
		@v_pubmonth DATETIME,
		@v_seasonkey INT,
		@v_estseasonkey INT,
		@v_bestseasonkey INT,
		@v_seasondesc VARCHAR(40)
	
	SELECT @v_bookkey = i.bookkey, @v_printingkey = i.printingkey, @v_issuenumber = i.issuenumber, @v_jobnumberalpha = i.jobnumberalpha,
		@v_pubmonthcode = i.pubmonthcode, @v_pubmonth = i.pubmonth, @v_seasonkey = i.seasonkey,
		@v_estseasonkey = i.estseasonkey
	FROM inserted i

	/*** Make sure coretitleinfo row exists for this bookkey, printingkey ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, @v_printingkey, 0

	/* Convert month code into string */
	SELECT @v_pubmonthname =
	CASE @v_pubmonthcode
	  WHEN 1 THEN 'January'
	  WHEN 2 THEN 'February'
	  WHEN 3 THEN 'March'
	  WHEN 4 THEN 'April'
	  WHEN 5 THEN 'May'
	  WHEN 6 THEN 'June'
	  WHEN 7 THEN 'July'
	  WHEN 8 THEN 'August'
	  WHEN 9 THEN 'September'
	  WHEN 10 THEN 'October'
	  WHEN 11 THEN 'November'
	  WHEN 12 THEN 'December'
	END

	/*** Fill in SEASON information ***/
	SET @v_bestseasonkey = @v_seasonkey
	/* If Season is missing, use estimated season */
	IF @v_bestseasonkey IS NULL OR @v_bestseasonkey = 0 
		SET @v_bestseasonkey = @v_estseasonkey

	/* Only if season or estimated season is filled in, get description and update core table */
	IF @v_bestseasonkey IS NOT NULL AND @v_bestseasonkey <> 0 			
	BEGIN
		DECLARE season_cur CURSOR FOR
		SELECT seasondesc
		FROM season
		WHERE seasonkey = @v_bestseasonkey

		OPEN season_cur
		FETCH NEXT FROM season_cur INTO @v_seasondesc 
 
		IF @@FETCH_STATUS <> 0  /* error */
		   SET @v_seasondesc = ''

		CLOSE season_cur 			
		DEALLOCATE season_cur
	END

	UPDATE coretitleinfo
	SET issuenumber = @v_issuenumber, jobnumberalpha = @v_jobnumberalpha, pubmonth = @v_pubmonthname, pubyear = YEAR(@v_pubmonth),
		seasonkey = @v_seasonkey, estseasonkey = @v_estseasonkey, 
		bestseasonkey = @v_bestseasonkey, seasondesc = @v_seasondesc
	WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
END
GO
