IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_season') AND type = 'TR')
	DROP TRIGGER dbo.core_season
GO

CREATE TRIGGER core_season ON season
FOR INSERT, UPDATE AS
IF UPDATE (seasondesc)
BEGIN
	DECLARE @v_seasonkey INT,
		@v_seasondesc VARCHAR(80),
		@err_msg VARCHAR(100)

	/*** Get modified season row's values ****/
	SELECT @v_seasonkey = i.seasonkey, @v_seasondesc = i.seasondesc
	FROM inserted i

	UPDATE coretitleinfo
	SET seasondesc = @v_seasondesc
	WHERE bestseasonkey = @v_seasonkey
END
GO
