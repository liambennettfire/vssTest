IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'bookdetail_set_elopartnerstatus')
	DROP TRIGGER bookdetail_set_elopartnerstatus
GO

CREATE TRIGGER bookdetail_set_elopartnerstatus ON bookdetail
FOR UPDATE AS 

DECLARE @v_bookkey          int,
        @v_csapprovalold    int,
        @v_csapprovalnew    int,
        @v_userid           varchar(100),
        @v_error_desc       varchar(2000),
        @v_error_code       int

SET NOCOUNT ON;

IF UPDATE(csapprovalcode) 
BEGIN
  /*  Get the bookkey that is being inserted or updated. */
  SELECT 
    @v_bookkey = inserted.bookkey, 
    @v_csapprovalnew = coalesce(csapprovalcode,0), 
    @v_userid = lastuserid 
  FROM 
    inserted

  SELECT 
    @v_csapprovalold = coalesce(csapprovalcode,0) 
  FROM 
    deleted 
  WHERE 
    bookkey = @v_bookkey 

  IF (@@error != 0)
    BEGIN
      ROLLBACK TRANSACTION
      select @v_error_desc = 'Could not select from bookdetail table (bookdetail_set_elopartnerstatus trigger).'
      print @v_error_desc
    END
  ELSE
    BEGIN
      -- If Eloquence approval status changed from  "Approved" to "Selectively Approved"
      IF @v_csapprovalold = 1 AND @v_csapprovalnew = 4
      BEGIN
        UPDATE taqprojectelementpartner SET resendind = 0, lastuserid = @v_userid, lastmaintdate = getdate() WHERE bookkey = @v_bookkey
        exec qtitle_set_cspartnerstatuses_on_title @v_bookkey, @v_userid, @v_error_code output, @v_error_desc output

        IF @v_error_code = -1 BEGIN
          print @v_error_desc
          return
        END 
      END
    END
END
