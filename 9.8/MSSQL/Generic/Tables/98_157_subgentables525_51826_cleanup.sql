DECLARE
  @v_count INT,
  @v_datasubcode INT,
  @v_datadesc VARCHAR(40),
  @v_datadescshort VARCHAR(20),
  @v_datacode INT


BEGIN

    SELECT @v_count = COUNT(*) FROM gentables WHERE tableid = 525 and datadesc = 'Freight Terms'

	IF @v_count = 1  BEGIN
		SELECT @v_datacode = datacode FROM gentables WHERE tableid = 525 and datadesc = 'Freight Terms'

		UPDATE subgentables SET lockbyqsiind = 0, lastuserid = 'FB_51826_UPDATE', lastmaintdate = getdate()
		WHERE tableid = 525 and datacode = @v_datacode AND lockbyqsiind = 1
	END

	SET @v_count = 0

	SELECT @v_count = COUNT(*) FROM gentables WHERE tableid = 525 and datadesc = 'Import Country'

	IF @v_count = 1  BEGIN
		SELECT @v_datacode = datacode FROM gentables WHERE tableid = 525 and datadesc = 'Import Country'

		UPDATE subgentables SET lockbyqsiind = 0, lastuserid = 'FB_51826_UPDATE', lastmaintdate = getdate()
		WHERE tableid = 525 and datacode = @v_datacode AND lockbyqsiind = 1
	END

END

GO