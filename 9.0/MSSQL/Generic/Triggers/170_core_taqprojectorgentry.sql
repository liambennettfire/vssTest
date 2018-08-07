IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_taqprojectorgentry') AND type = 'TR')
	DROP TRIGGER dbo.core_taqprojectorgentry
GO

CREATE TRIGGER core_taqprojectorgentry ON taqprojectorgentry
FOR INSERT, UPDATE AS

DECLARE @v_taqprojectkey INT,
	@v_orglevelkey INT,
	@v_orgentrykey INT,
	@v_projecthdrlevel1 INT,
	@v_projecthdrlevel2 INT,
	@v_counter INT,
	@v_orgentrydesc VARCHAR(40),
	@v_orgentryfilter VARCHAR(40),
	@err_msg VARCHAR(100)

/* Check at which organizational level this client stores Project Header Display Level 1 */
SELECT @v_projecthdrlevel1 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 26	/* TAQ Project Header Level One */
/* NOTE: not checking for errors here - TAQ Project Header1 filterorglevel record must exist */

/* Check at which organizational level this client stores Project Header Display Level 1 */
SELECT @v_projecthdrlevel2 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 27	/* TAQ Project Header Level Two */
/* NOTE: not checking for errors here - TAQ Project Header2 filterorglevel record must exist */

SELECT @v_taqprojectkey = i.taqprojectkey, @v_orglevelkey = i.orglevelkey
FROM inserted i

/*** TMM HEADER ORGLEVEL 1 ***/
IF @v_orglevelkey = @v_projecthdrlevel1
BEGIN
	EXECUTE CoreProjectInfo_Row_Refresh @v_taqprojectkey
END

/*** TMM HEADER ORGLEVEL 2 ***/
IF @v_orglevelkey = @v_projecthdrlevel2
BEGIN
	EXECUTE CoreProjectInfo_Row_Refresh @v_taqprojectkey
END

GO
