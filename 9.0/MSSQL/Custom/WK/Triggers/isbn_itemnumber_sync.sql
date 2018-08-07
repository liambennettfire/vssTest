if exists (select * from dbo.sysobjects where id = object_id(N'dbo.isbn_itemnumber_sync') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop Trigger dbo.isbn_itemnumber_sync
GO

CREATE TRIGGER dbo.isbn_itemnumber_sync ON [dbo].[isbn]
FOR INSERT, UPDATE AS
IF UPDATE (isbn) OR Update(itemnumber)
BEGIN
	DECLARE @v_isbn varchar(13),
                  @v_bookkey int,
                  @err_msg VARCHAR(100),
                  @v_userid VARCHAR(30),
                  @o_error_code INT,
				  @o_error_desc VARCHAR(2000),
				  @itemnumber varchar(20)

	SELECT @v_isbn=i.isbn,@v_bookkey=i.bookkey,@v_userid = i.lastuserid, @itemnumber = i.itemnumber
      FROM inserted i

	--Only update if isbn is populated by the user. 
	If (@v_isbn is not null and len(@v_isbn)> 0)
		BEGIN
			UPDATE isbn
			SET itemnumber = @v_isbn
			WHERE bookkey = @v_bookkey
			
			 IF @@error != 0
			  BEGIN
				 ROLLBACK TRANSACTION
				 SET @err_msg = 'Could not update itemnumber on isbn table (trigger).'
				 PRINT @err_msg
				  RETURN
			  END
		
		END

	
	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	If (@v_isbn is not null and len(@v_isbn)> 0)
		BEGIN
			UPDATE coretitleinfo
			SET itemnumber= @v_isbn, 
			altproductnumber = @v_isbn, 
			altproductnumberx = REPLACE(@v_isbn, '-', '')
			WHERE bookkey = @v_bookkey 
			
			IF @@error != 0
			  BEGIN
				 ROLLBACK TRANSACTION
				 SET @err_msg = 'Could not update itemnumber on coretitleinfo table (trigger).'
				 PRINT @err_msg
				  RETURN
			  END
		END

	

	-- qtitle_update_titlehistory (@i_tablename,@i_columnname,@i_bookkey,@i_printingkey, @i_datetypecode,@i_currentstringvalue, 
	  --                             @i_transtype,@i_userid,@i_historyorder,@i_fielddescdetail,@o_error_code,@o_error_desc)

	--If (@itemnumber is null or @itemnumber = '') begin
		if (@v_isbn is not null and len(@v_isbn)> 0) begin	
		EXECUTE qtitle_update_titlehistory 'isbn', 'itemnumber', @v_bookkey, 0, 0, @v_isbn, 'update', 
                                   @v_userid, 0, '', @o_error_code, @o_error_desc 
     end
END 
go
-- this trigger must be last because there are other triggers that will 
-- overwrite the itemnumber with null if they run after this one
sp_settriggerorder 'isbn_itemnumber_sync','LAST','INSERT'
GO
sp_settriggerorder 'isbn_itemnumber_sync','LAST','UPDATE'
GO
