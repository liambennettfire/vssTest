IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.maintsalesdatetype') AND type = 'TR')
	DROP TRIGGER dbo.maintsalesdatetype
GO

CREATE TRIGGER maintsalesdatetype ON BOOKDATES
FOR INSERT, UPDATE AS 

DECLARE	@v_dateind  INT
DECLARE	@v_count	INT
DECLARE	@v_bookkey	INT
DECLARE	@v_printingkey	INT
DECLARE	@v_datetypecode	INT 
DECLARE	@v_userid	VARCHAR (30)
DECLARE	@v_datetypeold	INT
DECLARE	@v_totalcount	INT
DECLARE	@err_msg		VARCHAR(100)
	
SELECT @v_bookkey = i.bookkey,
	@v_printingkey = i.printingkey,
	@v_datetypecode = i.datetypecode,
	@v_userid = i.lastuserid,
	@v_datetypeold = d.datetypecode
FROM inserted i full outer join 
	deleted d on i.bookkey=d.bookkey
	and i.printingkey=d.printingkey
	
IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from bookdates table (datetype trigger).'
	print @err_msg
  END
ELSE
  BEGIN
   
	/**** Continue only if it's 1st printing  ****/
	IF @v_printingkey = 1 
	   BEGIN
		/**** check if  row is a salesconference date ****/
		SELECT @v_dateind = date1ind	
			FROM DATETYPE
				WHERE datetypecode = @v_datetypecode
				
		IF @v_dateind = 1 BEGIN
		  SELECT @v_totalcount = COUNT(*)
		    FROM SALESCONFERENCEMAT
		   WHERE bookkey = @v_bookkey AND
				 salesmaterialcode IN (SELECT datetypecode FROM datetype WHERE date1ind = 1) 
		
		   IF @v_totalcount = 2 OR @v_totalcount > 2 
		      RETURN
		END

		IF @v_dateind = 1 /* salesconference date */
		  BEGIN
		        /** Make sure that the salesconferencemat table only has salesconference date rows for this title **/
				/** Dates that are not salesconference dates will be deleted here **/
				DELETE FROM SALESCONFERENCEMAT
					WHERE bookkey = @v_bookkey AND
							salesmaterialcode IN (SELECT datetypecode FROM datetype
							WHERE date1ind = 0 OR date1ind IS NULL) 

				/** Check the total rowcount on salesconferencemat table for this title **/
				SELECT @v_totalcount = count(*) 
					FROM SALESCONFERENCEMAT
					WHERE bookkey = @v_bookkey  

			/** Continue only if there are less than 2 rows on the salesconferencemat table for this title **/
				IF @v_totalcount < 2 
				   BEGIN
					/** If the old datetypecode is null (INSERT), set it to zero for consistency of processing **/
					IF @v_datetypeold IS NULL 	
					  BEGIN
						select @v_datetypeold = 0
					END
		
			/** Check if the OLD datetype already exists on the salesconferencemat table */
				  	SELECT @v_count = count(*)
						FROM SALESCONFERENCEMAT
							WHERE bookkey = @v_bookkey AND
								salesmaterialcode = @v_datetypeold 
		
					IF  @v_count > 0 /* the old salesconf date already exists on salesconferencemat table */
					  BEGIN
						UPDATE SALESCONFERENCEMAT
							SET salesmaterialcode = @v_datetypecode
								WHERE bookkey = @v_bookkey AND
									salesmaterialcode = @v_datetypeold 
					  END 
			           ELSE  /* the old salesconf date doesn't exist on salesconferencemat table */
				  	  BEGIN
				/** Check if the NEW datetype already exists on the salesconferencemat table */
						select @v_count = 0
						SELECT @v_count = count(*)
							FROM SALESCONFERENCEMAT
								WHERE bookkey = @v_bookkey AND
									salesmaterialcode = @v_datetypecode

						IF  @v_count = 0 
						  BEGIN 
						/*** If the NEW datetype doesn't exist on salesconferencemat table, insert it **/
							insert into SALESCONFERENCEMAT  /* default distributioncode to 0 for now*/
								(bookkey,salesmaterialcode,distributiongrpcode,lastuserid,lastmaintdate)
							values (@v_bookkey,@v_datetypecode,0,@v_userid,getdate())
					   	END
				   	END

	     			END  /* v_totalcount < 2 */

	 		 END	/* v_dateind = 1 */

		    END  /* v_printingkey = 1 */
  END

