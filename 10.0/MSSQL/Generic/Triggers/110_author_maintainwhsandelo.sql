IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'maintainwhsandelo ')
	DROP TRIGGER maintainwhsandelo
GO

/* author_trigger_sir_1519_mssq.sql */
/******************************************************/
/*                                                    */
/*  Rod Hamann                                        */
/*  03-06-2003                                        */
/*  PSS5 SIR 1519                                     */
/*  Tested on: GENMSDEV                               */
/*                                                    */
/*                   MSSQL VERSION                    */
/*                                                    */
/*  This trigger is designed to set the appropriate   */
/*  values in the DB for ALL titles associated with   */
/*  an author when ever author information is changed.*/
/*                                                    */
/******************************************************/

CREATE TRIGGER maintainwhsandelo ON author  
FOR INSERT, UPDATE AS 
/************************************************/
/*                                              */
/*  When author information is changed then we  */
/*  should set the flags for datawarehousing &  */
/*  eloquence exports for all of the author's   */
/*  titles.                                     */
/*                                              */
/************************************************/
/* 9/26/13 - KW - Took out the update to bookedistatus and bookedipartner.
This is now done from qcontact_update_globalcontacthistory procedure, called from qutl_dbchange_request. */

DECLARE @v_authorkey        int,
        @v_currentdate      datetime,
        @v_bookkey          int,
        @v_count            int,
        @v_err_msg          char(200),
        @v_lastuserid       char(30)

/*  Get the author that is being updated. */
SELECT @v_authorkey = inserted.authorkey,
       @v_lastuserid = inserted.lastuserid
  FROM inserted

IF (@@error != 0)
   BEGIN
      ROLLBACK TRANSACTION
      select @v_err_msg = 'Could not select from author table (trigger).'
      print @v_err_msg
   END
ELSE
   BEGIN
      /* Get every book key associated with this author */
      DECLARE c_book CURSOR FOR
       SELECT bookkey
         FROM bookauthor
        WHERE authorkey = @v_authorkey
	  FOR READ ONLY

      OPEN c_book 
      FETCH c_book INTO @v_bookkey
      WHILE (@@FETCH_STATUS >= 0)
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
               BEGIN /* We have a valid date */
                  /* ------------- Do Datawarehousing ------------ */
                  SELECT @v_count = COUNT(*)
                    FROM bookwhupdate
                   WHERE bookkey = @v_bookkey

                  IF (@v_count > 0)
                     /* If there is a datawarehouse entry for the title   */
                     /* then update the row for this title with the date. */
                     BEGIN
                        UPDATE bookwhupdate 
                           SET lastuserid = @v_lastuserid,
                               lastmaintdate = @v_currentdate
                         WHERE bookkey = @v_bookkey
                     END
                  ELSE
                     /* If there is NOT a datawarehouse entry for the     */
                     /* title then add it for this title with the date.   */
                     BEGIN
                        INSERT INTO bookwhupdate VALUES (
                           @v_bookkey, @v_lastuserid, @v_currentdate)
                     END

               END  /* We have a valid date */
            FETCH c_book INTO @v_bookkey
         END /* WHILE (@@FETCH_STATUS >= 0) on c_book */

      CLOSE c_book
      DEALLOCATE c_book
   END


