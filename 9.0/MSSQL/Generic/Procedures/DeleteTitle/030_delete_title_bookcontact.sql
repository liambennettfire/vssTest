-- Drop this procedure if it already exists
PRINT 'deletetitle_bookcontact'
GO
IF object_id('deletetitle_bookcontact ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_bookcontact
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes from bookcontact based on bookkey/printingkey                       */
/*and bookcontactrole based on bookcontactkey                                                */
/*********************************************************************************************/ 

CREATE PROCEDURE deletetitle_bookcontact 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT,
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	
	@v_bookcontactkey	INT,
	@err_msg  varchar(255)

SELECT 	
	@v_bookcontactkey = 0,
	@error_code = 0,
	@error_desc = ''

/*each bookcontact row*/
DECLARE  delete_bookcontact cursor 
FOR SELECT distinct a.bookcontactkey
		FROM bookcontact a
		   WHERE a.bookkey=@delete_title_bookkey
				AND a.printingkey = @delete_title_printingkey
					
	
OPEN delete_bookcontact

FETCH delete_bookcontact INTO @v_bookcontactkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete bookcontact cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_bookcontact 
	DEALLOCATE delete_bookcontact 
	return 
end

WHILE @@FETCH_STATUS = 0
BEGIN

	DELETE FROM bookcontactrole WHERE bookcontactkey = @v_bookcontactkey 
	if @@error != 0 begin
		select @err_msg = 'Error deleting from bookcontactrole for bookcontactkey' + convert(char(10),@v_bookcontactkey) 
		print @err_msg
		goto finished
	end
  
    FETCH delete_bookcontact INTO @v_bookcontactkey

END

DELETE FROM bookcontact WHERE bookkey = @delete_title_bookkey AND printingkey =@delete_title_printingkey ;

if @@error != 0 begin
	select @err_msg = 'Error deleting from bookcontact for bookkey' + convert(char(10),@delete_title_bookkey) +
		' and for printingkey' + convert(char(10),@delete_title_printingkey)
	print @err_msg
	goto finished
end

CLOSE delete_bookcontact
DEALLOCATE delete_bookcontact
return

finished: 
CLOSE delete_bookcontact
DEALLOCATE delete_bookcontact
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return



