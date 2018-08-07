IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.inserttitlesethistory') AND type = 'TR')
	DROP TRIGGER dbo.inserttitlesethistory
GO


CREATE TRIGGER inserttitlesethistory ON bookfamily  
FOR INSERT AS 

DECLARE @lastuserid VARCHAR(30), 
	@setbookkey INT, 
   @titlebookkey INT,
   @lastmaintdate datetime,
   @relationcode INT,
   @v_count INT,
   @err_msg VARCHAR(80)
	

/*** Get current bookkey and userid ***/
SELECT @setbookkey = i.parentbookkey,
   @titlebookkey = i.childbookkey,
	@lastuserid = i.lastuserid,
   @lastmaintdate = i.lastmaintdate,
   @relationcode  = i.relationcode
FROM inserted i

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

	IF @v_count = 0
	BEGIN
		INSERT INTO titlesethistory (setbookkey, titlebookkey, titleaddeddate, titleaddedby, titleremoveddate,titleremovedby,note)
		VALUES (@setbookkey, @titlebookkey, @lastmaintdate, @lastuserid, NULL,NULL,NULL)
	
	  IF @@error != 0
		BEGIN
		  ROLLBACK TRANSACTION
		  select @err_msg = 'Could not insert into titlesethistory table (trigger).'
		  print @err_msg
		END
   END
   ELSE
   BEGIN
		update titlesethistory 
        set titleremoveddate = NULL,
            titleremovedby = NULL,
            note = NULL,
            titleaddeddate=@lastmaintdate,
            titleaddedby=@lastuserid
      WHERE setbookkey = @setbookkey AND
            titlebookkey = @titlebookkey
		
		
		IF @@error != 0
		BEGIN
		  ROLLBACK TRANSACTION
		  select @err_msg = 'Could not update titlesethistory table (trigger).'
		  print @err_msg
		END
   END 
end


GO
