IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.associatedtitles_salesdata') AND type = 'TR')
	DROP TRIGGER dbo.associatedtitles_salesdata
GO

CREATE TRIGGER associatedtitles_salesdata ON associatedtitles
FOR INSERT, UPDATE AS
IF UPDATE (salesunitgross) OR 
	UPDATE (salesunitnet) OR
	UPDATE (bookpos) OR 
	UPDATE (lifetodatepointofsale) OR 
	UPDATE (yeartodatepointofsale) OR 
	UPDATE (previousyearpointofsale)

BEGIN
  DECLARE @v_copy_salesdata_option	TINYINT,
    @v_bookkey INT,
    @v_assobookkey INT,
    @v_salesunitgross INT,
    @v_salesunitnet INT,
    @v_bookpos  INT,
    @v_ltdpos INT,
    @v_ytdpos INT,
    @v_pypos  INT

  SELECT @v_copy_salesdata_option = optionvalue 
  FROM clientoptions 
  WHERE optionid = 92

  IF @v_copy_salesdata_option = 0
    RETURN

  DECLARE assotitles_cur CURSOR FOR
    SELECT i.bookkey, i.associatetitlebookkey, i.salesunitgross, i.salesunitnet, 
    i.bookpos, i.lifetodatepointofsale, i.yeartodatepointofsale, i.previousyearpointofsale
    FROM inserted i 

  OPEN assotitles_cur

  FETCH NEXT FROM assotitles_cur 
  INTO @v_bookkey, @v_assobookkey, @v_salesunitgross, @v_salesunitnet, @v_bookpos, @v_ltdpos, @v_ytdpos, @v_pypos

  WHILE (@@FETCH_STATUS=0)  /*LOOP*/
  BEGIN

    IF @v_assobookkey > 0
    BEGIN
      UPDATE associatedtitles
      SET salesunitgross = @v_salesunitgross, salesunitnet = @v_salesunitnet, bookpos = @v_bookpos, 
        lifetodatepointofsale = @v_ltdpos, yeartodatepointofsale = @v_ytdpos, previousyearpointofsale = @v_pypos
      WHERE associatetitlebookkey = @v_assobookkey 
    END

    FETCH NEXT FROM assotitles_cur 
    INTO @v_bookkey, @v_assobookkey, @v_salesunitgross, @v_salesunitnet, @v_bookpos, @v_ltdpos, @v_ytdpos, @v_pypos

  END

  CLOSE assotitles_cur
  DEALLOCATE assotitles_cur
	
END
GO
