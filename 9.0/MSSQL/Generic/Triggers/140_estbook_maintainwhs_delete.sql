/*  PV - When estimate information is changed then we  */
/*  should set the flags for datawarehousing  */
/* Refer to SIR # 2612 */

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'estbook_maintainwhs_del')
	DROP TRIGGER estbook_maintainwhs_del
GO

CREATE TRIGGER estbook_maintainwhs_del ON estbook
FOR DELETE AS 

DECLARE @v_estkey        int,
        @v_currentdate   datetime,
        @v_count         int,
	@v_err_msg       char(200),
        @v_lastuserid    char(30)

/*  Get the estimate that is being updated. */
SELECT @v_estkey = deleted.estkey,
       @v_lastuserid = deleted.lastuserid
FROM deleted

IF (@@error != 0)
  BEGIN
	ROLLBACK TRANSACTION
	select @v_err_msg = 'Could not select from estbook table (trigger).'
	print @v_err_msg
  END
ELSE
  BEGIN
  IF @@rowcount > 0
	  BEGIN
		/* Get the system date */
			  SELECT @v_currentdate = GETDATE()
			  IF (@@error != 0)
				 BEGIN /* We DO NOT have a valid date */
					ROLLBACK TRANSACTION
						 select @v_err_msg = 'Could not obtain system date (trigger).'
						 print @v_err_msg
				 END /* We DO NOT have a valid date */
		ELSE
				 BEGIN
			/* ------------- Do Datawarehousing ------------ */
						 SELECT @v_count = COUNT(*)
						 FROM estwhupdate
						 WHERE estkey = @v_estkey
	
			IF (@v_count > 0)
							/* If there is a datawarehouse entry for the estimate   */
							/* then update the row for this estimate with the date. */
							BEGIN
								UPDATE estwhupdate 
				SET lastuserid = @v_lastuserid,
										lastmaintdate = @v_currentdate
									WHERE estkey = @v_estkey
							END
			ELSE
							/* If there is NOT a datawarehouse entry for the     */
			  /* estimate then add it for this estimate with the date.   */
			  BEGIN
				INSERT INTO estwhupdate VALUES (
										@v_estkey, @v_lastuserid, @v_currentdate)
							END
	 
		  END
	END
  END


