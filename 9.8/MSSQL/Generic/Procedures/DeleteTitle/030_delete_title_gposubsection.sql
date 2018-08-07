-- Drop this procedure if it already exists
PRINT 'deletetitle_gposubsection'
GO
IF object_id('deletetitle_gposubsection ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_gposubsection 
END 
GO

/*************************************************************************************/ 
/*This procedure deletes from gpo and related tables based on gposubsction keys      */
/*************************************************************************************/ 



CREATE PROCEDURE deletetitle_gposubsection 
			@delete_title_bookkey INT,
			@delete_title_printingkey INT,
			@error_code INT OUTPUT,
			@error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	
	@gpo_gpokey INT,
	@gpo_gponumber varchar(10),
	@gpo_gpostatus char(1),
	@gposubsection_key1 INT,
	@gposubsection_key2 INT,
	@gposubsectionkey INT,
	@err_msg varchar(255)

SELECT   
	@gpo_gpokey = 0,
	@gpo_gponumber = '',
	@gpo_gpostatus = '',
	@gposubsection_key1 = 0,
	@gposubsection_key2 = 0,
	@gposubsectionkey = 0,
	@error_code = 0,
	@error_desc = ''

DECLARE delete_gposubsection cursor for          /*each gposubsection row*/
	SELECT distinct a.gpokey,a.gponumber,a.gpostatus,b.key1,b.key2,b.subsectionkey
	  FROM gpo a, gposubsection b
	 WHERE a.gpokey = b.gpokey
       AND (b.subsectiontype in (2,3) )
	   AND b.key1=@delete_title_bookkey
	   AND b.key2 = @delete_title_printingkey;

OPEN delete_gposubsection

FETCH delete_gposubsection INTO @gpo_gpokey,@gpo_gponumber, @gpo_gpostatus, @gposubsection_key1, @gposubsection_key2,@gposubsectionkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete gposubsection cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_gposubsection 
	DEALLOCATE delete_gposubsection 
	return 0
end
		
	
WHILE @@FETCH_STATUS = 0 BEGIN
	DELETE FROM gpo WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gpo for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gposection WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gposection for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gposubsection WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gposubsection for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gpocost WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 
	begin
		select @err_msg = 'Error selecting from gpocost for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gpoinstructions WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gpoinstructions for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gpoimport WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gpoimport for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gpoimportvendors WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gpoimportvendors for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM gposhiptovendor WHERE gpokey = @gpo_gpokey ;
	if @@error != 0 begin
		select @err_msg = 'Error selecting from gposhiptovendor for gpokey' + convert(char(10),@gpo_gpokey)
		print @err_msg
		goto finished
	end 
	
	FETCH delete_gposubsection INTO @gpo_gpokey,@gpo_gponumber, @gpo_gpostatus, @gposubsection_key1, @gposubsection_key2,@gposubsectionkey
 --	if @@fetch_status = -2 begin 
	--	select @err_msg = 'ERROR:  during fetch of delete of gposubsection cursor.' 
	--	print @err_msg 
	--	goto finished 
	--end 
	
END

CLOSE delete_gposubsection
DEALLOCATE delete_gposubsection
return

finished: 
CLOSE delete_gposubsection
DEALLOCATE delete_gposubsection
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return
