IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'MAINTSALESDATETYPEDEL')
	DROP TRIGGER MAINTSALESDATETYPEDEL
GO

CREATE TRIGGER MAINTSALESDATETYPEDEL ON BOOKDATES
FOR DELETE AS 

DECLARE	@v_dateind    	INT
DECLARE	@v_count	INT
DECLARE	@v_bookkey2	INT
DECLARE	@v_printingkey2	INT
DECLARE	@v_datetypecode2	INT 

DECLARE @err_msg varchar(100)	

 SELECT @v_bookkey2 = d.bookkey,
   	    @v_printingkey2 = d.printingkey,
	    @v_datetypecode2 = d.datetypecode
	      FROM deleted d 
			
IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from bookdates table (datetype trigger).'
	print @err_msg
  END
ELSE
  BEGIN
   
	/**** Continue only if it's 1st printing  ****/
	IF @v_printingkey2 = 1 
	   BEGIN
		/**** check if  row is a salesconference date ****/
		SELECT @v_dateind = date1ind	
			FROM DATETYPE
				WHERE datetypecode = @v_datetypecode2

		IF @v_dateind = 1 /* salesconference date */
		  BEGIN
			IF @v_datetypecode2 >0 	
			  BEGIN
				select @v_count = 0
				SELECT @v_count = count(*)
					FROM SALESCONFERENCEMAT
						WHERE bookkey = @v_bookkey2 AND
							salesmaterialcode = @v_datetypecode2

				IF  @v_count > 0 
				  BEGIN 
					delete from SALESCONFERENCEMAT
						WHERE  bookkey = @v_bookkey2 AND
							salesmaterialcode = @v_datetypecode2
				  END
			END
	    	END
	END 
END

