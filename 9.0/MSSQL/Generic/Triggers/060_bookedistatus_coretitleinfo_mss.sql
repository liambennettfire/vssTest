IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookedistatus') AND type = 'TR')
	DROP TRIGGER dbo.core_bookedistatus
GO

CREATE TRIGGER core_bookedistatus ON bookedistatus
FOR INSERT, UPDATE AS
IF UPDATE (edistatuscode) 

BEGIN
	DECLARE @v_bookkey INT,
		@v_printingkey INT,
		@v_edipartnerkey INT,
		@v_edistatuscode INT
	
	SELECT @v_bookkey = i.bookkey, @v_printingkey = i.printingkey, @v_edipartnerkey = i.edipartnerkey,
	       @v_edistatuscode = i.edistatuscode
	FROM inserted i

	/*** Only Maintain edistatuscode on core for edipartnerkey = 1 ***/
	IF @v_edipartnerkey <> 1 BEGIN
  	  RETURN
	END

	/*** Make sure coretitleinfo row exists for this bookkey, printingkey ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, @v_printingkey, 0

	UPDATE coretitleinfo
	   SET edistatuscode = @v_edistatuscode
	 WHERE bookkey = @v_bookkey AND
               printingkey = @v_printingkey

END
GO
