IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.maintainpublicationdatetype') AND type = 'TR')
	DROP TRIGGER dbo.maintainpublicationdatetype
GO

CREATE TRIGGER maintainpublicationdatetype ON taqprojecttask FOR INSERT, UPDATE
AS 
IF UPDATE (datetypecode) OR 	UPDATE (actualind) OR 	UPDATE (activedate) 
BEGIN

--check if updates are not coming from bookdates trigger
if object_id( 'tempdb..#dont_fire_bookdates' ) is not null begin
  return
end


DECLARE	@v_count	INT
DECLARE	@v_bookkey	INT
DECLARE	@v_printingkey	INT
DECLARE	@v_datetypecode	INT 
DECLARE	@v_userid	VARCHAR (30)
DECLARE @v_estdate datetime
DECLARE @v_activedate datetime
DECLARE @v_originaldate datetime
DECLARE @v_original_pub_date datetime
DECLARE @v_actualind INT
DECLARE	@err_msg		VARCHAR(100)
DECLARE @v_new_key	INT
	
SELECT @v_bookkey = i.bookkey,
	@v_printingkey = i.printingkey,
	@v_datetypecode = i.datetypecode,
    @v_activedate = i.activedate, 
    @v_originaldate = i.originaldate,
    @v_actualind = i.actualind,
	@v_userid = i.lastuserid
FROM inserted i full outer join 
	deleted d on i.bookkey=d.bookkey
	and i.printingkey=d.printingkey
	

 if (@v_bookkey is null OR @v_printingkey is null OR @v_datetypecode is null) begin
  return
end
   
	--Continue only if it's ebook go-live 
	IF @v_datetypecode = 436 	
     BEGIN
		-- check if  there is a row for Publication Date 
		SELECT @v_count = count(*)	
			FROM taqprojecttask
           WHERE bookkey = @v_bookkey
                AND printingkey = @v_printingkey
                AND datetypecode = 8

         -- Row for publication date 
		IF  @v_count > 0   BEGIN
				SELECT @v_original_pub_date = originaldate
				  FROM taqprojecttask
				WHERE bookkey = @v_bookkey
					 AND printingkey = @v_printingkey
					 AND datetypecode = 8
	
				IF @v_original_pub_date IS NULL 	
	
					UPDATE taqprojecttask
							SET activedate = @v_activedate, 
								actualind = @v_actualind,
								originaldate = @v_activedate,
								lastuserid = @v_userid,
								lastmaintdate = getdate()
					 WHERE bookkey = @v_bookkey 
						AND printingkey = @v_printingkey
						AND datetypecode = 8
					
				ELSE
					
						UPDATE taqprojecttask
							SET activedate = @v_activedate, 
									actualind = @v_actualind,
									lastuserid = @v_userid,
									lastmaintdate = getdate()
						 WHERE bookkey = @v_bookkey 
							AND printingkey = @v_printingkey
							AND datetypecode = 8
					 
	
	
				IF @@error != 0
				BEGIN
				  ROLLBACK TRANSACTION
				  select @err_msg = 'Could not update Publication Date on taqprojecttask table (maintainpublicationdatetype trigger).'
				  print @err_msg
				END
			END 

             -- check if  there is a row for On Sale Date 
		SELECT @v_count = count(*)	
			FROM taqprojecttask
           WHERE bookkey = @v_bookkey
                AND printingkey = @v_printingkey
                AND datetypecode = 20003

         -- Row for On Sale Date
		IF  @v_count > 0   BEGIN
				SELECT @v_original_pub_date = originaldate
				  FROM taqprojecttask
				WHERE bookkey = @v_bookkey
					 AND printingkey = @v_printingkey
					 AND datetypecode = 20003
	
				IF @v_original_pub_date IS NULL 	
	
					UPDATE taqprojecttask
							SET activedate = @v_activedate, 
								actualind = @v_actualind,
								originaldate = @v_activedate,
								lastuserid = @v_userid,
								lastmaintdate = getdate()
					 WHERE bookkey = @v_bookkey 
						AND printingkey = @v_printingkey
						AND datetypecode = 20003
					
				ELSE
					
						UPDATE taqprojecttask
							SET activedate = @v_activedate, 
									actualind = @v_actualind,
									lastuserid = @v_userid,
									lastmaintdate = getdate()
						 WHERE bookkey = @v_bookkey 
							AND printingkey = @v_printingkey
							AND datetypecode = 20003
					 
	
	
				IF @@error != 0
				BEGIN
				  ROLLBACK TRANSACTION
				  select @err_msg = 'Could not update On Sale Date on taqprojecttask table (maintainpublicationdatetype trigger).'
				  print @err_msg
				END
			END 
   END  -- datetypecode = 436
  END