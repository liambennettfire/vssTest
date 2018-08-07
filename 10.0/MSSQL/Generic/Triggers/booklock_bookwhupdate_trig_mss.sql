SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from sysobjects where id = object_id('dbo.wh_booklock_trig') and (type = 'P' or type = 'TR'))
	drop trigger dbo.wh_booklock_trig
GO

CREATE TRIGGER WH_BOOKLOCK_TRIG on BOOKLOCK
 FOR  DELETE
    
AS
  DECLARE @v_bookkey       int
  DECLARE @err_msg  varchar(100)
  DECLARE @v_lastuserid    varchar(30)
  DECLARE @i_count int
  DECLARE @v_locktypecode int

select @v_bookkey = d.bookkey, @v_lastuserid = d.userid, @v_locktypecode = d.locktypecode  from deleted d

If @v_bookkey IS NOT NULL
   BEGIN
      IF @@error != 0
         BEGIN
	    ROLLBACK TRANSACTION
	    select @err_msg = 'Could not select from booklock table (trigger).'
	    print @err_msg
         END
      ELSE
         BEGIN
            select @i_count =count(*)   
                from bookwhupdate
	        where bookkey = @v_bookkey

            if @i_count = 0 AND @v_locktypecode = 1
               begin
                 insert into bookwhupdate
                    (bookkey,lastuserid,lastmaintdate)
                 values
                    (@v_bookkey,@v_lastuserid,getdate())

	         IF @@error != 0
                    BEGIN
		       ROLLBACK TRANSACTION
		       select @err_msg ='Could not update bookwupdate table (trigger).'
		       print @err_msg
                    END

              end
        END
   END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO
