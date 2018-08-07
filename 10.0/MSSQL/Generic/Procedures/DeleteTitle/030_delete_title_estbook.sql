-- Drop this procedure if it already exists
PRINT 'deletetitle_estbook'
GO
IF object_id('deletetitle_estbook ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_estbook 
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes from estbook based on bookkey/printingkey                           */
/*and all the related estbook tables based on estkey                                         */
/*********************************************************************************************/ 



CREATE PROCEDURE deletetitle_estbook 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT,
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS



DECLARE	
	@v_estkey INT,
	@err_msg varchar(255)
	
SELECT 
	@error_code = 0,
	@error_desc = ''


DECLARE delete_estbook CURSOR for  /* each estversion row */
	SELECT distinct a.estkey
	  FROM estbook a
     WHERE a.bookkey = @delete_title_bookkey AND
          a.printingkey = @delete_title_printingkey

OPEN delete_estbook

FETCH delete_estbook INTO @v_estkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete estbook cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_estbook 
	DEALLOCATE delete_estbook 
	return 
end

WHILE @@FETCH_STATUS = 0
BEGIN

	DELETE FROM estversion WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estversion for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end

	DELETE FROM estnonpocost WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estnonpocost for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estmessage WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estmessage for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estcomp WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estcomp for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estcost WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estcost for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estcameraspecs WHERE estkey = @v_estkey ;
	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from estcameraspecs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estmaterialspecs WHERE estkey = @v_estkey ;
	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from estmaterialspecs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estmaterialspecsigs WHERE estkey = @v_estkey ;
	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from estmaterialspecsigs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estmiscspecs WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estmiscspecs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estplspecs WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estplspecs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estspecs WHERE estkey = @v_estkey ;
	if @@error != 0 begin
		select @err_msg = 'Error deleting from estspecs for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	DELETE FROM estbookorgentry WHERE estkey = @v_estkey ;
	if @@error != 0 		begin
		select @err_msg = 'Error deleting from estbookorgentry for estkey' + convert(char(10),@v_estkey) 
		print @err_msg
		goto finished
	end
		
	FETCH delete_estbook INTO @v_estkey
	--if @@fetch_status = -2 	begin
	--	select @err_msg = 'ERROR: No rows selected into delete estbook cursor. Cannot continue.'
	--	print @err_msg
	--	CLOSE delete_estbook 
	--	DEALLOCATE delete_estbook
	--	return 
	--end
end
		
DELETE FROM estbook WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey ;
if @@error != 0 begin
	select @err_msg = 'Error deleting from estbook for bookkey' + convert(char(10),@delete_title_bookkey) +
		' and for printingkey' + convert(char(10),@delete_title_printingkey)
	print @err_msg
	goto finished
end

CLOSE delete_estbook
DEALLOCATE delete_estbook
return

finished: 
CLOSE delete_estbook
DEALLOCATE delete_estbook
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return

