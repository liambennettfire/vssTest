IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_booksimon') AND type = 'TR')
	DROP TRIGGER dbo.core_booksimon
GO

CREATE TRIGGER core_booksimon ON booksimon
FOR INSERT, UPDATE AS
IF UPDATE (formatchildcode)
BEGIN
	DECLARE @v_bookkey INT,
		@v_formatchildcode INT,
		@v_childformatdesc VARCHAR(40)
	
	SELECT @v_bookkey = i.bookkey, @v_formatchildcode = i.formatchildcode
	FROM inserted i

	if @v_bookkey is null begin
		return
	end

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	/** Get Children's Format description from gentables **/
	EXECUTE gentables_longdesc 300, @v_formatchildcode, @v_childformatdesc OUTPUT

	UPDATE coretitleinfo
	SET formatchildcode = @v_formatchildcode, childformatdesc = @v_childformatdesc
	WHERE bookkey = @v_bookkey
END
GO
