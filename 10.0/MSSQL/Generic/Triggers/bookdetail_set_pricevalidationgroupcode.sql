IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'bookdetail_set_pricevalidationgroupcode')
	DROP TRIGGER bookdetail_set_pricevalidationgroupcode
GO

CREATE TRIGGER bookdetail_set_pricevalidationgroupcode ON bookdetail
FOR INSERT, UPDATE AS 

DECLARE @v_bookkey        					int,
              @v_pricevalidationgroupcode   int,
              @v_count           					int,
	          @v_err_msg     					varchar(2000),
              @v_error_desc						varchar(2000),
              @v_error_code					int

/*  Get the bookkey that is being inserted or updated. */
SELECT @v_bookkey = inserted.bookkey
FROM inserted

IF (@@error != 0)
  BEGIN
	ROLLBACK TRANSACTION
	select @v_err_msg = 'Could not select from bookdetail table (bookdetail_set_pricevalidationgroupcode trigger).'
	print @v_err_msg
  END
ELSE
  BEGIN
   IF @@rowcount > 0
	  BEGIN
         SELECT @v_count = count(*)
            FROM bookdetail
          WHERE bookkey = @v_bookkey
		
		IF (@v_count > 0)
             BEGIN
                 exec qtitle_set_price_validation_group @v_bookkey,@v_error_code OUTPUT,@v_error_desc OUTPUT

                 IF @v_error_code = -1 BEGIN
                  SET @v_err_msg = @v_error_desc
				print @v_err_msg
				return
			 END 
  			END
	END
  END



