/* Ran on GENMSDEV. Refer to SIR # 2693  */

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.bookprice_sendtoelo_112004') AND (type = 'P' or type = 'RF'))
BEGIN
 DROP PROC dbo.bookprice_sendtoelo_112004
END

GO

CREATE PROCEDURE dbo.bookprice_sendtoelo_112004 AS
BEGIN
	DECLARE @v_bookkey 	  INT,
		@v_printingkey	  INT,
		@v_sendtoelo	  INT,
		@v_lastuserid	  CHAR(30),
		@v_count	  INT,
		@v_currentdate    DATETIME,
		@v_edipartnerkey  INT

	DECLARE bookprice_cur CURSOR FOR
		SELECT DISTINCT bookkey
		FROM bookprice 
		WHERE effectivedate = '1/1/2004'

	SET @v_printingkey = 1
	SET @v_lastuserid = 'QSIDBA'
	SET @v_sendtoelo = 1
	SET @v_currentdate = GETDATE()

	OPEN bookprice_cur
	FETCH NEXT FROM bookprice_cur INTO @v_bookkey

	WHILE (@@FETCH_STATUS = 0)
  	  BEGIN
		UPDATE book
		SET sendtoeloind = 1
		WHERE bookkey = @v_bookkey

		SELECT @v_count = COUNT(*)
		FROM bookwhupdate
		WHERE bookkey = @v_bookkey
		
		IF (@v_count > 0)
			UPDATE bookwhupdate
			SET lastuserid = @v_lastuserid, lastmaintdate = @v_currentdate
			WHERE bookkey = @v_bookkey
		ELSE
			INSERT INTO bookwhupdate VALUES (
			@v_bookkey, @v_lastuserid, @v_currentdate)

		/* --------------- Do Eloquence --------------- */
                /* For each edi partner for this title, we must set the */
                /* bookedistatus. Then we need to also set the partner. */
		DECLARE c_edipartner CURSOR FOR
                	SELECT edipartnerkey
	                FROM bookedipartner
        	        WHERE bookkey = @v_bookkey AND
                	      printingkey = @v_printingkey
	        	FOR UPDATE

		OPEN c_edipartner
                FETCH NEXT FROM c_edipartner INTO @v_edipartnerkey
                WHILE (@@FETCH_STATUS = 0)
                  BEGIN
                	SELECT @v_count = COUNT(*)
                        FROM bookedistatus
                        WHERE bookkey = @v_bookkey AND
                              printingkey = @v_printingkey AND
                              edipartnerkey = @v_edipartnerkey

                        IF (@v_count > 0)
                          /* If there is an eloquence entry for the title then */
                          /* update the row for this title.                    */
			  BEGIN
				UPDATE bookedistatus
                                SET edistatuscode = 3, 
                                     lastuserid = @v_lastuserid,  
                                     lastmaintdate = @v_currentdate
                               	WHERE bookkey = @v_bookkey AND
                                     printingkey = @v_printingkey AND
                                     edipartnerkey = @v_edipartnerkey
                          END
                        ELSE
                          /* If there is NOT an eloquence entry for the title  */
                          /* then insert the row for this title.               */
                          BEGIN
                          	INSERT INTO bookedistatus (
                                	edipartnerkey, bookkey, printingkey, edistatuscode, 
	                                 lastuserid, lastmaintdate, previousedistatuscode)
				VALUES (
                                 @v_edipartnerkey, @v_bookkey, 1, 3, @v_lastuserid, @v_currentdate, 0)
			  END

			UPDATE bookedipartner 
                        SET sendtoeloquenceind = 1,
                            lastuserid = @v_lastuserid,  
                            lastmaintdate = @v_currentdate
                        WHERE CURRENT OF c_edipartner
                          
                	FETCH NEXT FROM c_edipartner INTO @v_edipartnerkey
                  END /* WHILE (@@FETCH_STATUS >= 0) on c_edipartner */
		CLOSE c_edipartner
                DEALLOCATE c_edipartner

		/* Insert only ONE 'Send To Eloquence' titlehistory row for each title */
		/* instead of for each partner */
		SELECT @v_count = count(*)
		FROM titlehistory
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey AND
			columnkey = 104 AND
			(DATEDIFF(DAY, lastmaintdate, @v_currentdate)=0 AND
			 DATEDIFF(MONTH, lastmaintdate, @v_currentdate)=0 AND
			 DATEDIFF(YEAR, lastmaintdate, @v_currentdate)=0) AND
			floatvalue IS NULL AND
			recentchangeind IS NULL AND
			authorchangecode IS NULL AND
			lastuserid = @v_lastuserid AND
			changecomment IS NULL AND
			currentstringvalue = @v_sendtoelo AND
			fielddesc = 'Send To Eloquence'
		
		IF (@v_count = 0)
			INSERT INTO titlehistory VALUES (
				@v_bookkey, @v_printingkey, 104, @v_currentdate, 
				NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
				NULL, @v_sendtoelo, 'Send To Eloquence')
		
		FETCH NEXT FROM bookprice_cur INTO @v_bookkey

	  END  /*LOOP bookprice_cur */

	CLOSE bookprice_cur 
	DEALLOCATE bookprice_cur
END
GO

/**** Execute the bookprice sendtoelo stored procedure *****/
EXEC bookprice_sendtoelo_112004
GO