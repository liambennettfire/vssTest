-- Drop this procedure if it already exists
PRINT 'deletetitle_datawh'
GO
IF object_id('deletetitle_datawh ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_datawh 
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes from all the datawarehouse tables based on bookkey/printingkey      */
/*********************************************************************************************/ 

CREATE PROCEDURE deletetitle_datawh 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT
AS

DECLARE	@v_estkey INT,
			@v_estversion INT,
			@err_msg varchar(255),
			@v_bookkey INT,
			@v_printingkey INT

SELECT	@v_estkey = 0,
			@v_estversion = 0,			
			@v_bookkey = 0,
			@v_printingkey = 0
			
DECLARE delete_whest cursor for /*each whest row*/

	SELECT distinct a.bookkey,a.printingkey,a.estkey, a.estversion
		FROM whest a
   	WHERE a.bookkey=@delete_title_bookkey
			AND a.printingkey = @delete_title_printingkey;
					
	
OPEN delete_whest

BEGIN

	DELETE FROM whauthor
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whauthor for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitleclass
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitleclass for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitlecomments
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitlecomments for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitlefiles
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitlefiles for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitleinfo
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitleinfo for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitlepersonnel
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitlepersonnel for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whtitleprevworks
				WHERE bookkey = @delete_title_bookkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whtitleprevworks for bookkey' + convert(char(10),@delete_title_bookkey)
		print @err_msg
		goto finished
	end 
	
	
	DELETE FROM whfinalcostest
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whfinalcostest for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whprinting
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whprinting for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	
	DELETE FROM whprintingkeydates
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whprintingkeydates for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whschedule1
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whschedule1 for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whschedule2
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whschedule2 for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whschedule3
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whschedule3 for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whschedule4
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whschedule4 for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 
	
	DELETE FROM whschedule5
				WHERE bookkey = @delete_title_bookkey
					AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whschedule5 for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 

	FETCH delete_whest INTO @v_bookkey,@v_printingkey, @v_estkey, @v_estversion

	if @@fetch_status = -1
	begin
		/*select @err_msg = 'ERROR: No rows selected into delete whest cursor. Cannot continue.'
		print @err_msg*/
		CLOSE delete_gposection 
		DEALLOCATE delete_gposection 
		return 
	end
		
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DELETE FROM whestcost
			WHERE estkey = @v_estkey AND
						estversion = @v_estversion ;

		if @@error != 0 
			begin
			select @err_msg = 'Error deleting from whestcost for estkey' + convert(char(10),@v_estkey) +
				' and for estversion' + convert(char(10),@v_estversion)
			print @err_msg
			goto finished
		end 
	
		FETCH delete_whest INTO @v_bookkey,@v_printingkey, @v_estkey, @v_estversion

		if @@fetch_status = -2
		begin
			select @err_msg = 'ERROR: No rows selected into delete whest cursor. Cannot continue.'
			print @err_msg
			CLOSE delete_gposection 
			DEALLOCATE delete_gposection 
			return 
		end

	end
	
	DELETE FROM whest
			WHERE bookkey = @delete_title_bookkey
				AND printingkey =@delete_title_printingkey ;

	if @@error != 0 
	begin
		select @err_msg = 'Error deleting from whest for bookkey' + convert(char(10),@delete_title_bookkey) +
			' and for printingkey' + convert(char(10),@delete_title_printingkey)
		print @err_msg
		goto finished
	end 

end

finished: 
CLOSE delete_whest
DEALLOCATE delete_whest
return


