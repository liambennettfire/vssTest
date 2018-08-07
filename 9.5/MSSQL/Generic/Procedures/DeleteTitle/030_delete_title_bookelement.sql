-- Drop this procedure if it already exists
PRINT 'deletetitle_bookelement'
GO
IF object_id('deletetitle_bookelement ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_bookelement 
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes from bookelement based on bookkey/printingkey                       */
/*and all the related element tables based on elementkey                                     */
/*********************************************************************************************/ 

CREATE PROCEDURE deletetitle_bookelement 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT,
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	@v_elementkey	INT,
		@err_msg  varchar(255)

SELECT @v_elementkey = 0
SELECT @error_code = 0
SELECT @error_desc = ''

/*each bookcomments row*/
DECLARE  delete_bookelement cursor FOR 
	SELECT distinct a.elementkey
	  FROM bookelement a
	 WHERE a.bookkey=@delete_title_bookkey AND a.printingkey = @delete_title_printingkey
	
OPEN delete_bookelement

FETCH delete_bookelement INTO @v_elementkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete bookelement cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_bookelement 
	DEALLOCATE delete_bookelement 
	return 
end

WHILE @@FETCH_STATUS = 0
BEGIN

	DELETE FROM element
			WHERE elementkey = @v_elementkey 

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from element for elementkey' + convert(char(10),@v_elementkey) 
		print @err_msg
		goto finished
	end

	/*DBMS_OUTPUT.PUT_LINE('Delete from element');*/

	DELETE FROM elementauthor WHERE elementkey = @v_elementkey 
	if @@error != 0 begin
		select @err_msg = 'Error deleting from elementauthor for elementkey' + convert(char(10),@v_elementkey) 
		print @err_msg
		goto finished
	end

	DELETE FROM elementcategory WHERE elementkey = @v_elementkey 
	if @@error != 0 begin
		select @err_msg = 'Error deleting from elementcategory for elementkey' + convert(char(10),@v_elementkey) 
		print @err_msg
		goto finished
	end


	DELETE FROM elementcomments WHERE elementkey = @v_elementkey 
	if @@error != 0 begin
		select @err_msg = 'Error deleting from elementcomments for elementkey' + convert(char(10),@v_elementkey) 
		print @err_msg
		goto finished
	end

	DELETE FROM task WHERE elementkey = @v_elementkey 
	if @@error != 0 begin
		select @err_msg = 'Error deleting from task for elementkey' + convert(char(10),@v_elementkey) 
		print @err_msg
		goto finished
	end

	FETCH delete_bookelement INTO @v_elementkey
	if @@fetch_status = -2 begin
		select @err_msg = 'ERROR: No rows selected into delete bookelement cursor. Cannot continue.'
		print @err_msg
		CLOSE delete_bookelement 
		DEALLOCATE delete_bookelement 
		return 
	end
			 

END

DELETE FROM bookelement WHERE bookkey = @delete_title_bookkey AND printingkey =@delete_title_printingkey ;

if @@error != 0 begin
	select @err_msg = 'Error deleting from bookelement for bookkey' + convert(char(10),@delete_title_bookkey) +
		' and for printingkey' + convert(char(10),@delete_title_printingkey)
	print @err_msg
	goto finished
end

CLOSE delete_bookelement
DEALLOCATE delete_bookelement
return

finished: 
CLOSE delete_bookelement
DEALLOCATE delete_bookelement
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return


