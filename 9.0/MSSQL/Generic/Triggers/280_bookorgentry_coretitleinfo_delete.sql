IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookorgentry_del') AND type = 'TR')
	DROP TRIGGER dbo.core_bookorgentry_del
GO

CREATE TRIGGER core_bookorgentry_del ON bookorgentry
FOR DELETE AS

DECLARE @v_bookkey INT,
	@v_orglevelkey INT,
	@v_orgentrykey INT,
	@v_lowestlevel INT,
	@v_imprintlevel INT,
	@v_tmmhdrlevel1 INT,
	@v_tmmhdrlevel2 INT,
    @v_publisherlevel INT,
	@v_counter INT,
    @v_bookorgentrycount INT,
	@v_orgentryfilter VARCHAR(40),
	@err_msg VARCHAR(100)

/* Check at which organizational level this client stores Imprint */
SELECT @v_imprintlevel = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 15  /* Imprint */
/* NOTE: not checking for errors here - IMPRINT filterorglevel record must exist */

/* Check at which organizational level this client stores Publisher */
SELECT @v_publisherlevel = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 18  /* Publisher */
/* NOTE: not checking for errors here - IMPRINT filterorglevel record must exist */

/* Check at which organizational level this client stores TMM Header Display Level 1 */
SELECT @v_tmmhdrlevel1 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 16	/* Title Header Level One */
/* NOTE: not checking for errors here - TMM Header1 filterorglevel record must exist */

/* Check at which organizational level this client stores TMM Header Display Level 1 */
SELECT @v_tmmhdrlevel2 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 17	/* Title Header Level Two */
/* NOTE: not checking for errors here - TMM Header2 filterorglevel record must exist */

SELECT @v_bookkey = d.bookkey, @v_orglevelkey = d.orglevelkey
FROM deleted d

SELECT @v_bookorgentrycount = COUNT(*) 
FROM bookorgentry WHERE bookkey = @v_bookkey

/* Get the lowest orglevel for this bookkey */
SELECT @v_lowestlevel = COALESCE(max(orglevelkey), 0 )
FROM bookorgentry
WHERE bookkey = @v_bookkey

/*** IMPRINT ***/
IF @v_orglevelkey = @v_imprintlevel
  BEGIN
	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	UPDATE coretitleinfo
	SET imprintkey = NULL, imprintname = NULL
	WHERE bookkey = @v_bookkey
  END

/*** PUBLISHER ***/
IF @v_orglevelkey = @v_publisherlevel
  BEGIN
	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	UPDATE coretitleinfo
	SET publisherkey = NULL, publisherdesc = NULL
	WHERE bookkey = @v_bookkey
  END

/*** TMM HEADER ORGLEVEL 1 ***/
IF @v_orglevelkey = @v_tmmhdrlevel1
  BEGIN
	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	UPDATE coretitleinfo
	SET tmmheaderorg1key = NULL, tmmheaderorg1desc = NULL
	WHERE bookkey = @v_bookkey
  END

/*** TMM HEADER ORGLEVEL 2 ***/
IF @v_orglevelkey = @v_tmmhdrlevel2
  BEGIN
	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	UPDATE coretitleinfo
	SET tmmheaderorg2key = NULL, tmmheaderorg2desc = NULL
	WHERE bookkey = @v_bookkey
  END

/*** Set orgentryfilter only once - when modifying the lowest orglevel ***/
IF @v_bookorgentrycount = @v_lowestlevel
  BEGIN
	DECLARE bookorgentry_cur CURSOR FOR
	  SELECT bo.orglevelkey, bo.orgentrykey
	  FROM bookorgentry bo
	  WHERE bo.bookkey = @v_bookkey
	  ORDER BY bo.orglevelkey
	
	OPEN bookorgentry_cur
	
	FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey
	
	SET @v_counter = 1
	
	WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		IF @v_counter = 1 
		  SET @v_orgentryfilter = '(' + LTRIM(STR(@v_orgentrykey))
	    ELSE IF @v_counter > 0  	
		  SET @v_orgentryfilter = @v_orgentryfilter + ',' + LTRIM(STR(@v_orgentrykey))
	    ELSE 
		  SET @v_orgentryfilter = NULL

		FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey
	
		SET @v_counter = @v_counter + 1
	  END
	
	IF @v_orgentryfilter IS NOT NULL
	  BEGIN
		SET @v_orgentryfilter = @v_orgentryfilter + ')'
	
		UPDATE coretitleinfo
		SET orgentryfilter = @v_orgentryfilter
		WHERE bookkey = @v_bookkey
	  END
    ELSE 
      BEGIN
        UPDATE coretitleinfo
		SET orgentryfilter = NULL
		WHERE bookkey = @v_bookkey
      END
	
	CLOSE bookorgentry_cur
	DEALLOCATE bookorgentry_cur
  END

GO

