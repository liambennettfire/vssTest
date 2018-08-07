/* Ran on GENMSDEV. Refer to SIR # 1799 */
/* 11/12/03 - PV - Ran on GENMSDEV, GENMS2DEV, NUPRESS */
/* Refer to SIR # 2519 */
/* CRM# 1127 KB 12/22/04 Funtionality to update titlehistory has been moved to the */
/* new trigger sendtoelostatus. Also book should be updated with the value of      */
/* sendtoeloquenceind on bookedipartner - not just when it is set to 1             */
/* RAN ON GENMSDEV  */

PRINT 'TRIGGER : dbo.sendtoelo'
GO

IF exists (select * from dbo.sysobjects where id = Object_id('dbo.sendtoelo') and (type = 'P' or type = 'TR'))
BEGIN
 DROP TRIGGER dbo.sendtoelo
END

GO

CREATE TRIGGER sendtoelo ON bookedipartner
FOR INSERT, UPDATE AS

DECLARE @v_bookkey 	INT,
	@v_sendtoelo	INT,
	@v_err_msg	CHAR(200),
	@v_count	INT,
	@v_lastuserid	CHAR(30),
	@v_printingkey	INT,
   @v_edistatuscode INT,
   @v_edipartnerkey INT
	
SELECT @v_bookkey = i.bookkey, @v_sendtoelo = i.sendtoeloquenceind,
	@v_printingkey = i.printingkey, @v_lastuserid = i.lastuserid,
	@v_edipartnerkey = i.edipartnerkey
FROM inserted i
				
/*IF (@v_sendtoelo = 1)
	UPDATE book
	SET sendtoeloind = 1
	WHERE bookkey = @v_bookkey */

UPDATE book
  SET sendtoeloind = @v_sendtoelo
WHERE bookkey = @v_bookkey
  

SELECT @v_count = COUNT(*)
FROM bookwhupdate
WHERE bookkey = @v_bookkey
		
IF (@v_count > 0)
	UPDATE bookwhupdate
	SET lastuserid = @v_lastuserid, lastmaintdate = GETDATE()
	WHERE bookkey = @v_bookkey
ELSE
	INSERT INTO bookwhupdate VALUES (
	@v_bookkey, @v_lastuserid, GETDATE())


GO