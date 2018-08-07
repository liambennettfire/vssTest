IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_elocustomer') AND type = 'TR')
  DROP TRIGGER dbo.book_elocustomer
GO

CREATE TRIGGER book_elocustomer ON book
FOR INSERT AS

DECLARE @v_bookkey INT,
	@v_elocustomerkey INT,
	@v_defaultelocustomerkey INT,
	@v_elodefaultcompanylevel INT,
	@v_count INT,
        @v_clientdefaultid INT,
	@err_msg VARCHAR(100),
        @v_userid VARCHAR(30),
        @o_error_code INT,
        @o_error_desc VARCHAR(2000),
        @v_customershortname VARCHAR(30)

SET @v_clientdefaultid = 1
SET @v_defaultelocustomerkey = 0

/* Check at which organizational level this client stores Eloquence Default Customer Org Level */
SELECT @v_elodefaultcompanylevel = filterorglevelkey
  FROM filterorglevel
 WHERE filterkey = 28  /* Eloquence Default Customer Org Level */
/* NOTE: not checking for errors here - Eloquence Default Customer Org Level filterorglevel record must exist */

SELECT @v_bookkey = i.bookkey, @v_userid = i.lastuserid
  FROM inserted i

-- go get default elocustomerkey
SELECT @v_count = count(*)
  FROM bookorgentry bo, orgentry o
 WHERE bo.orgentrykey = o.orgentrykey and
       bo.bookkey = @v_bookkey and
       bo.orglevelkey = @v_elodefaultcompanylevel

IF @@error != 0 BEGIN
  ROLLBACK TRANSACTION
  SELECT @err_msg = 'Could not get count from bookorgentry table (book_elocustomer trigger).'
  PRINT @err_msg
  RETURN
END

-- NOTE: Only continue on if the bookorgentry record exists. If it does not exist at this time,
-- the elocustomerkey will set when the bookorgentry records are added (trigger on bookorgentry).  
IF @v_count > 0 BEGIN
  SELECT @v_defaultelocustomerkey = o.elocustomerkey
    FROM bookorgentry bo, orgentry o
   WHERE bo.orgentrykey = o.orgentrykey and
         bo.bookkey = @v_bookkey and
         bo.orglevelkey = @v_elodefaultcompanylevel

  IF @@error != 0 BEGIN
    ROLLBACK TRANSACTION
    SELECT @err_msg = 'Could not select from bookorgentry table (book_elocustomer trigger).'
    PRINT @err_msg
    RETURN
  END

  IF @v_defaultelocustomerkey is null OR @v_defaultelocustomerkey <= 0 BEGIN
    -- get default from clientdefaults table
    SELECT @v_defaultelocustomerkey = cd.clientdefaultvalue
      FROM clientdefaults cd
     WHERE cd.clientdefaultid = @v_clientdefaultid 

    IF @@error != 0 BEGIN
      ROLLBACK TRANSACTION
      SELECT @err_msg = 'Could not select from clientdefaults table (book_elocustomer trigger).'
      PRINT @err_msg
      RETURN
    END
  END

  UPDATE book
     SET elocustomerkey = @v_defaultelocustomerkey
   WHERE bookkey = @v_bookkey 

  IF @@error != 0 BEGIN
    ROLLBACK TRANSACTION
    SELECT @err_msg = 'Could not update book table (book_elocustomer trigger).'
    PRINT @err_msg
    RETURN
  END

  -- Title History
  SELECT @v_customershortname = c.customershortname
    FROM customer c
   WHERE c.customerkey = @v_defaultelocustomerkey

  IF @@error != 0 BEGIN
    ROLLBACK TRANSACTION
    SELECT @err_msg = 'Could not select from customer table (book_elocustomer trigger).'
    PRINT @err_msg
    RETURN
  END

  -- qtitle_update_titlehistory (@i_tablename,@i_columnname,@i_bookkey,@i_printingkey, @i_datetypecode,@i_currentstringvalue, 
  --                             @i_transtype,@i_userid,@i_historyorder,@i_fielddescdetail,@o_error_code,@o_error_desc)

  EXECUTE qtitle_update_titlehistory 'book', 'elocustomerkey', @v_bookkey, 0, 0, @v_customershortname, 'update', 
                                   @v_userid, 0, '', @o_error_code, @o_error_desc 
END

GO
