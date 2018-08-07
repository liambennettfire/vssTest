IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.updatetitlesethistory') AND type = 'TR')
	DROP TRIGGER dbo.updatetitlesethistory
GO


CREATE TRIGGER updatetitlesethistory ON bookfamily  
FOR DELETE AS 

DECLARE @lastuserid VARCHAR(30), 
	@setbookkey INT, 
   @titlebookkey INT,
   @lastmaintdate datetime,
   @relationcode INT,
   @v_count INT,
   @err_msg VARCHAR(80),
   @v_note VARCHAR(255)
	

/*** Get current bookkey and userid ***/
SELECT @setbookkey = d.parentbookkey,
   @titlebookkey = d.childbookkey,
	@lastuserid = d.lastuserid,
   @lastmaintdate = d.lastmaintdate,
   @relationcode  = d.relationcode
FROM deleted d

IF @relationcode = 20001 
begin
  IF @lastuserid is null
     begin
       SELECT @lastuserid = userid
         FROM booklock
        WHERE bookkey =  @titlebookkey
     end

	IF @lastuserid is null
     begin
       set @lastuserid = 'QSIDBA'
     end


  IF @lastmaintdate is null
     begin
       set @lastmaintdate = getdate()
     end

	SELECT @v_count = count(*)
     FROM titlesethistory
    WHERE setbookkey = @setbookkey AND
          titlebookkey = @titlebookkey

	IF @v_count = 1
	BEGIN

      SET @v_note = 'Title removed from set'

		update titlesethistory 
        set titleremoveddate = @lastmaintdate,
            titleremovedby = @lastuserid,
            note = @v_note
      WHERE setbookkey = @setbookkey AND
            titlebookkey = @titlebookkey
				
		IF @@error != 0
		BEGIN
		  ROLLBACK TRANSACTION
		  select @err_msg = 'Could not update titlesethistory table (delete trigger).'
		  print @err_msg
		END
   END 
end


GO

