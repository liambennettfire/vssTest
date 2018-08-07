-- Drop this procedure if it already exists
PRINT 'deletetitle_materialspecs'
GO
IF object_id('deletetitle_materialspecs ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_materialspecs 
END 
GO

/*************************************************************************************/ 
/*This procedure deletes from materialspecs and calls deassign_matrequest_title      */
/*procedure if any papers have been assigned                                         */ 
/*************************************************************************************/ 


CREATE PROCEDURE  deletetitle_materialspecs 
		@delete_title_bookkey INT,
		@delete_title_printingkey INT,
		@illus_chgcode1 INT,
		@illus_chgcode2 INT,
		@text_chgcode1 INT,
        @text_chgcode2 INT,
		@mms_option char(1),
		@error_code INT OUTPUT,
		@error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	
	@v_matrequest_count INT,
	@v_matrequest_status char(1),
	@v_materialkey INT,
	@res INT,
	@err_msg varchar(255)

SELECT   
	@v_matrequest_count = 0,
	@v_matrequest_status = '',
	@v_materialkey = 0,
	@res = 0,
	@error_code = 0,
	@error_desc = ''
			
/*each materialspecs row*/
DECLARE delete_materialspecs cursor FOR 
	SELECT distinct a.materialkey
	  FROM  materialspecs a
	 WHERE a.bookkey = @delete_title_bookkey
	   AND a.printingkey = @delete_title_printingkey
					
	
OPEN delete_materialspecs

FETCH delete_materialspecs INTO @v_materialkey

if @@fetch_status = -1 begin
		/*select @err_msg = 'ERROR: No rows selected into delete materialspecs cursor. Cannot continue.'
		print @err_msg*/
		CLOSE delete_materialspecs 
		DEALLOCATE delete_materialspecs 
		return 
end

WHILE @@FETCH_STATUS = 0 BEGIN
	IF @mms_option = 'Y' begin

		SELECT @v_matrequest_count  = count(*)
		  FROM matrequest b
         WHERE b.materialkey = @v_materialkey

		if @@error != 0 begin
			select @err_msg = 'Error selecting from matrequest for materialkey' + convert(char(10),@v_materialkey)
			print @err_msg
			goto finished
		end 

		if @v_matrequest_count is null begin
			select @v_matrequest_count = 0
		end
			
		if @v_matrequest_count > 0 begin
			
			SELECT @v_matrequest_status = b.requeststatus
			  FROM matrequest b
        	 WHERE b.materialkey = @v_materialkey

			if @@error != 0 begin
				select @err_msg = 'Error selecting from matrequest for materialkey' + convert(char(10),@v_materialkey)
				print @err_msg
				goto finished
			end 
			
			if @v_matrequest_status IS NULL begin
			   select @v_matrequest_status = ''
			END 

			if @v_matrequest_status = 'A' begin
				EXEC deletetitle_matrequest @v_materialkey,@illus_chgcode2,@illus_chgcode2,
						@text_chgcode1,@text_chgcode2,@error_code,@err_msg 
				if @error_code != 0 begin 
					select @err_msg = 'Return code of less than 0 returned from deletetitle_matrequest' +
						' for materialkey ' + convert(char(10),@v_materialkey)
					print @err_msg
					goto finished
				end 
			end
			
			DELETE FROM  matrequest WHERE materialkey = @v_materialkey
			if @@error != 0 begin
				select @err_msg = 'Error selecting from matrequest for materialkey' + convert(char(10),@v_materialkey)
				print @err_msg
				goto finished
			end 
		end
	
		DELETE FROM  materialspecs 	WHERE materialkey = @v_materialkey
		if @@error != 0 begin
			select @err_msg = 'Error deleteing from materialspecs for materialkey' + convert(char(10),@v_materialkey)
			print @err_msg
			goto finished
		end 

		goto getnextrow

		getnextrow:
	
		FETCH delete_materialspecs INTO @v_materialkey
 	--	if @@fetch_status = -2 begin 
		--	select @err_msg = 'ERROR:  during fetch of delete of materialspecs cursor.' 
		--	print @err_msg 
		--	goto finished 
		--end 
	end
end

CLOSE delete_materialspecs
DEALLOCATE delete_materialspecs
return	

finished: 
CLOSE delete_materialspecs
DEALLOCATE delete_materialspecs
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return




