IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookverification') AND type = 'TR')
	DROP TRIGGER dbo.core_bookverification
GO

CREATE  TRIGGER core_bookverification ON bookverification
FOR INSERT, UPDATE AS
IF UPDATE (titleverifystatuscode) 
BEGIN
	DECLARE @v_bookkey 		INT,
		@v_titleverifycode 	SMALLINT, 
		@v_titleverifydesc 	varchar(40)
	
	SELECT @v_bookkey =i.bookkey,
	       @v_titleverifycode=i.titleverifystatuscode
	FROM inserted i

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	/*** Fill in description fields ***/
	exec gentables_longdesc 513,@v_titleverifycode,@v_titleverifydesc OUTPUT

	UPDATE coretitleinfo
	SET titleverifydesc=@v_titleverifydesc ,
	    titleverifycode=@v_titleverifycode 
	WHERE bookkey = @v_bookkey
END



