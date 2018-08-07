set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER TRIGGER [maintainbestdate] ON [dbo].[bookdates]  
FOR INSERT, UPDATE AS
IF UPDATE(activedate) OR UPDATE(estdate) 

DECLARE
  @v_bookkey INT,
  @v_printingkey INT,
  @v_datetypecode INT,
  @v_estdate DATETIME,
  @v_activedate DATETIME,	
  @v_actualind  TINYINT,
  @v_bestdate DATETIME,
  @err_msg VARCHAR(100),
  @v_userid VARCHAR(30),
  @v_new_key int

SELECT @v_activedate = i.activedate,
  @v_estdate = i.estdate,
  @v_bestdate = COALESCE(i.activedate, i.estdate),
  @v_bookkey = i.bookkey,
  @v_printingkey = i.printingkey,
  @v_datetypecode = i.datetypecode,
  @v_userid = i.lastuserid
FROM inserted i
WHERE i.datetypecode <> 387 

DECLARE @v_currentdate		datetime
DECLARE @v_bbdatelocked		int
DECLARE @v_count			int
DECLARE @v_updatetype		char(1)
DECLARE @i_status_prod      int
DECLARE @useWebScheduling   int
DECLARE @v_useProdBBD int

IF @v_bookkey is null
   RETURN

IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from bookdates table (trigger).'
	print @err_msg
  END
ELSE
  BEGIN
/* 10-25-02 cursor error when more than 1 person updating bookdates so will not use for now*/
/**	DECLARE cur_prodbbdate INSENSITIVE CURSOR
	FOR
		SELECT bookkey
			FROM bookdates
			WHERE bookkey = @v_bookkey AND
					printingkey = 1 AND
					datetypecode = 387 
	FOR READ ONLY
  **/
  	
	/**** Set bestdate with activedate when filled, otherwise with estdate ****/
--THIS IS DONE ON PB AS WELL. It's cousing data change between retrieve and update error
--on PB and MS 2005
--if @v_datetypecode <> 387 begin

      IF @v_activedate IS NOT NULL
        SET @v_actualind = 1
      ELSE
        SET @v_actualind = 0
        
      UPDATE bookdates 
      SET bestdate = @v_bestdate, actualind = @v_actualind
      WHERE bookkey = @v_bookkey AND
        printingkey = @v_printingkey AND
        datetypecode = @v_datetypecode 

      IF @@error != 0
      BEGIN
	     ROLLBACK TRANSACTION
	     select @err_msg = 'Could not update bookdates table (trigger).'
	     print @err_msg
      END
--end
			
	--check client option id = 72 (Use Web Title Scheduling) -if optionvalue = 0 use TMM scheduling 
    SELECT @useWebScheduling = optionvalue
    FROM clientoptions
    WHERE optionid = 72

    SELECT @v_useProdBBD = optionvalue
    FROM clientoptions
    WHERE optionid = 6
            
	/**** Update Production Bound Book Date for first printing ****/
	IF @v_printingkey = 1 AND @v_datetypecode = 30 AND @v_useProdBBD = 1
	  begin
		/*** Check if Production Bound Book Date is filled in for this title ***/
		
	/** REMOVE CURSOR SINCE CAUSING ERROR
		OPEN cur_prodbbdate
		FETCH NEXT FROM cur_prodbbdate INTO @v_count 
			  
		select @i_status_prod = @@FETCH_STATUS
		IF @i_status_prod != 0
		**/
		select @v_count = 0
		SELECT @v_count = count(*)
		FROM bookdates
		WHERE bookkey = @v_bookkey AND
			printingkey = 1 AND
			datetypecode = 387 
        
		IF @v_count = 0 
		 begin
			select @v_updatetype = 'I' /*Production BBD doesn't exist - Insert */
		 end	
		ELSE
		 begin
			select @v_updatetype = 'U';	/*Procuction BBD already exists - Update */
		END 
		/**close cur_prodbbdate
		deallocate  cur_prodbbdate 
		**/
		/* If Production Bound Book Date doesn't exist for 1st printing, always insert */
		IF @v_updatetype = 'I' 
		  begin
			  INSERT INTO BOOKDATES(bookkey, printingkey, datetypecode, bestdate)
			  VALUES(@v_bookkey, 1, 387, @v_bestdate)

        if ( @useWebScheduling = 1)
          BEGIN
            EXECUTE dbo.get_next_key 'QSIDBA', @v_new_key OUTPUT
			
			      INSERT INTO taqprojecttask (taqtaskkey, bookkey, printingkey, datetypecode, activedate)
			      VALUES (@v_new_key, @v_bookkey, 1, 387, @v_bestdate)
			    END
		  end
		ELSE
		  begin
			/*** Check if Bound Book Date is locked on first printing for this title ****/
         select @v_bbdatelocked = 0
         EXEC Is_BBD_Locked @v_bookkey, @v_printingkey, @v_datetypecode, @v_userid, @v_bbdatelocked OUTPUT
			
			/* Check if the current date is entered - if NULL, update regardless of locked status(?) */
			SELECT @v_currentdate= bestdate
			FROM bookdates
			WHERE bookkey = @v_bookkey AND
					printingkey = 1 AND
					datetypecode = 387 
					
			IF @v_bbdatelocked = 1 OR @v_currentdate = NULL 
			  begin
				UPDATE BOOKDATES
				SET bestdate = @v_bestdate
				WHERE bookkey = @v_bookkey AND
					printingkey = 1 AND
					datetypecode = 387 
			  END
		 END			
	END
END	



