IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_orgentry') AND type = 'TR')
	DROP TRIGGER dbo.core_orgentry
GO

CREATE TRIGGER core_orgentry ON orgentry
FOR INSERT, UPDATE AS
IF UPDATE (orgentrydesc)
BEGIN
	DECLARE @v_orglevelkey INT,
		@v_orgentrykey INT,
		@v_imprintlevel INT,
		@v_tmmhdrlevel1 INT,
		@v_tmmhdrlevel2 INT,
		@v_orgentrydesc VARCHAR(40),
		@err_msg VARCHAR(100),
      @v_count 	INT

	/* Check at which organizational level this client stores Imprint */
	SELECT @v_imprintlevel = filterorglevelkey
	FROM filterorglevel
	WHERE filterkey = 15  /* Imprint */
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

	/*** Get modified orgentry row's values ****/
	SELECT @v_orglevelkey = i.orglevelkey, @v_orgentrykey = i.orgentrykey, @v_orgentrydesc = i.orgentrydesc
	FROM inserted i

	SELECT @v_count = 0
	/*** IMPRINT ***/
	IF @v_orglevelkey = @v_imprintlevel
	  BEGIN
      SELECT @v_count = count(*)
        FROM coretitleinfo
       WHERE imprintkey = @v_orgentrykey

      IF @v_count > 0 BEGIN
			UPDATE coretitleinfo
			SET imprintname = @v_orgentrydesc
			WHERE imprintkey = @v_orgentrykey
      END
	  END

   SELECT @v_count = 0
	/*** TMM HEADER ORGLEVEL 1 ***/
	IF @v_orglevelkey = @v_tmmhdrlevel1
	  BEGIN
      
      SELECT @v_count = count(*)
        FROM coretitleinfo
       WHERE tmmheaderorg1key = @v_orgentrykey
      
      IF @v_count > 0 BEGIN
			UPDATE coretitleinfo
			SET tmmheaderorg1desc = @v_orgentrydesc
			WHERE tmmheaderorg1key = @v_orgentrykey
      END
	  END

   SELECT @v_count = 0
	/*** TMM HEADER ORGLEVEL 2 ***/
	IF @v_orglevelkey = @v_tmmhdrlevel2
	  BEGIN
      SELECT @v_count = count(*)
        FROM coretitleinfo
       WHERE tmmheaderorg2key = @v_orgentrykey

      IF @v_count > 0 BEGIN
			UPDATE coretitleinfo
			SET tmmheaderorg2desc = @v_orgentrydesc
			WHERE tmmheaderorg2key = @v_orgentrykey
      END
	  END
END
GO
