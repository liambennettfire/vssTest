/* CRM# 1127 KB 12/22/04 Funtionality to update titlehistory has been moved to this */
/* new trigger sendtoelostatus from trigger sendtoelo                               */
/* 12/21/04 - KB - CRM# 1127 Ran on GENMSDEV  */

PRINT 'TRIGGER : dbo.sendtoelostatus'
GO

IF exists (select * from dbo.sysobjects where id = Object_id('dbo.sendtoelostatus') and (type = 'P' or type = 'TR'))
BEGIN
 DROP TRIGGER dbo.sendtoelostatus
END

GO

CREATE TRIGGER sendtoelostatus ON bookedistatus
FOR INSERT, UPDATE AS

DECLARE @v_bookkey 	INT,
	@v_err_msg	CHAR(200),
	@v_count	INT,
	@v_lastuserid	CHAR(30),
	@v_printingkey	INT,
   @v_edistatuscode INT,
   @v_edipartnerkey INT
	
SELECT @v_bookkey = i.bookkey, @v_edistatuscode = i.edistatuscode,
	@v_printingkey = i.printingkey, @v_lastuserid = i.lastuserid,
	@v_edipartnerkey = i.edipartnerkey
FROM inserted i
				

BEGIN
	/* Insert only ONE 'Send To Eloquence' titlehistory row for each title */
	/* instead of for each partner - use edipartnerkey of 1 */
	IF @v_edipartnerkey <> 1 BEGIN
        	RETURN
	END

	IF (@v_edistatuscode = 1)
	BEGIN
		SELECT @v_count = count(*)
		FROM titlehistory
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey AND
			columnkey = 104 AND
			(DATEDIFF(DAY, lastmaintdate, getdate())=0 AND
			 DATEDIFF(MONTH, lastmaintdate, getdate())=0 AND
			 DATEDIFF(YEAR, lastmaintdate, getdate())=0  AND
			 DATEDIFF(HOUR, lastmaintdate, getdate())=0 AND
			 DATEDIFF(MINUTE, lastmaintdate, getdate())=0) AND
			floatvalue IS NULL AND
			recentchangeind IS NULL AND
			authorchangecode IS NULL AND
			lastuserid = @v_lastuserid AND
			changecomment IS NULL AND
			currentstringvalue = 1 AND
			fielddesc = 'Send To Eloquence'
		
		IF (@v_count = 0)
                BEGIN

			INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
		            	recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                	VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
				NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
				NULL, 1, 'Send To Eloquence')
                END
	END
	IF (@v_edistatuscode = 3)
	BEGIN
		SELECT @v_count = count(*)
		FROM titlehistory
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey AND
			columnkey = 104 AND
			(DATEDIFF(DAY, lastmaintdate, getdate())=0 AND
			 DATEDIFF(MONTH, lastmaintdate, getdate())=0 AND
			 DATEDIFF(YEAR, lastmaintdate, getdate())=0  AND
			 DATEDIFF(HOUR, lastmaintdate, getdate())=0 AND
			 DATEDIFF(MINUTE, lastmaintdate, getdate())=0) AND
			floatvalue IS NULL AND
			recentchangeind IS NULL AND
			authorchangecode IS NULL AND
			lastuserid = @v_lastuserid AND
			changecomment IS NULL AND
			currentstringvalue = 1 AND
			fielddesc = 'Resend To Eloquence'
		
		IF (@v_count = 0) 
                BEGIN
			INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
			            recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                        VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
				NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
				NULL, 1, 'Resend To Eloquence')
                END
                ELSE
                BEGIN
			-- just set lastuserid and lastmaintdate
			UPDATE titlehistory
      			   SET lastuserid = @v_lastuserid,
                               lastmaintdate = GETDATE()
 			 WHERE bookkey = @v_bookkey AND
			       printingkey = @v_printingkey AND
			       columnkey = 104 AND
			       (DATEDIFF(DAY, lastmaintdate, getdate())=0 AND
			        DATEDIFF(MONTH, lastmaintdate, getdate())=0 AND
			        DATEDIFF(YEAR, lastmaintdate, getdate())=0  AND
			        DATEDIFF(HOUR, lastmaintdate, getdate())=0 AND
			        DATEDIFF(MINUTE, lastmaintdate, getdate())=0) AND
			       floatvalue IS NULL AND
			       recentchangeind IS NULL AND
			       authorchangecode IS NULL AND
			       lastuserid = @v_lastuserid AND
			       changecomment IS NULL AND
			       currentstringvalue = 1 AND
			       fielddesc = 'Resend To Eloquence'
               END
	END
	IF (@v_edistatuscode = 6)
	BEGIN
		INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
		            recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
			NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
			NULL, 1, 'Title Deleted From Eloquence')
	END
	IF (@v_edistatuscode = 7)
	BEGIN
		INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
		            recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
			NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
			NULL, 1, 'Title Deactivated From Eloquence')
	END
	IF (@v_edistatuscode = 8)
	BEGIN
		INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
		            recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
			NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
			NULL, 1, 'Never Send Title To Eloquence')
	END

        -- Send to eloquence was cleared out for some reason
	IF (@v_edistatuscode = 0)
	BEGIN
		INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,floatvalue,stringvalue,
		            recentchangeind,authorchangecode,lastuserid,changecomment,currentstringvalue,fielddesc)
                VALUES (@v_bookkey, @v_printingkey, 104, GETDATE(), 
			NULL, '(Not Present)', NULL, NULL, @v_lastuserid,
			NULL, 1, 'No Status')
	END

END

GO