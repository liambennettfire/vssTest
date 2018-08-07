-- Drop this procedure if it already exists
PRINT 'deletetitle_deassign_onhand'
GO
IF object_id('deletetitle_deassign_onhand') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_deassign_onhand
END 
GO

/************************************************************************************ 
This procedure deletes from the matrequestlot table and updates the printerlot table
*************************************************************************************/ 


CREATE PROCEDURE deletetitle_deassign_onhand @delete_title_materialkey INT,@error_code INT OUTPUT,@error_desc VARCHAR(2000) OUTPUT
AS


/* initialize variables */
DECLARE	@printerlot_count INT,
	@printerlot_onhandavailable INT,
	@printerlot_onhandallocated INT,
	@lotkey INT,
	@qtyallocated INT,
	@err_msg varchar(255)

SELECT	
    @printerlot_count = 0,
	@printerlot_onhandavailable = 0,
	@printerlot_onhandallocated = 0,
	@lotkey = 0,
	@qtyallocated = 0,
	@error_desc = '',
    @error_code = 0

/*each matrequestlot row*/
DECLARE delete_matrequestlot_cursor CURSOR
FOR  SELECT m.lotkey,
	       m.qtyallocated
          FROM matrequestlot m 
         WHERE m.materialkey = @delete_title_materialkey
OPEN delete_matrequestlot_cursor

FETCH delete_matrequestlot_cursor INTO @lotkey, @qtyallocated

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete matrequest lot cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_matrequestlot_cursor 
	DEALLOCATE delete_matrequestlot_cursor 
	return 
end

WHILE @@FETCH_STATUS = 0 BEGIN   /* cursor processing */

	SELECT @printerlot_onhandavailable=printerlot.onhandavailable,@printerlot_onhandallocated=printerlot.onhandallocated  
	  FROM printerlot  
	 WHERE printerlot.lotkey = @lotkey

	if @@error != 0 begin 
		select @err_msg = 'Error selecting from printerlot for lotkey ' + convert(char(10), @lotkey)
        print @err_msg 
		goto finished 
	end 

	if @@rowcount > 0 begin
		IF @printerlot_onhandavailable = NULL BEGIN
			select @printerlot_onhandavailable = 0
		END 
	
		IF @printerlot_onhandallocated = NULL BEGIN
			select @printerlot_onhandallocated = 0
		END
		
		UPDATE printerlot 
			SET onhandavailable = @printerlot_onhandavailable + @qtyallocated,
			    onhandallocated = @printerlot_onhandallocated -  @qtyallocated
			WHERE printerlot.lotkey = @lotkey AND
		        	printerlot.onhandavailable = @printerlot_onhandavailable AND
				printerlot.onhandallocated = @printerlot_onhandallocated

		if @@error != 0 begin 
			select @err_msg = 'Error updating printerlot table for lotkey' + convert(char(10), @lotkey)
            print @err_msg 
			goto finished 
		end 
	
		/* delete matrequestlot record  */

		DELETE FROM matrequestlot WHERE materialkey = @delete_title_materialkey AND lotkey = @lotkey

		if @@error != 0 begin 
			select @err_msg =  'Error deleting from matrequestlot table for materialkey '  
					+ convert(char(10), @delete_title_materialkey) + ' and lotkey ' + convert(char(10), @lotkey) 
            print @err_msg 
			goto finished 
		end 

		goto getnextrow
	end
	else begin
		goto getnextrow

	end /* end of one cursor row  */	

	getnextrow: 
	/* reset all variables */ 
	 
	FETCH delete_matrequestlot_cursor INTO @lotkey, @qtyallocated
 
 
	if @@fetch_status = -2 begin 
		select @err_msg = 'ERROR:  during fetch of matrequestlot.' 
		print @err_msg 
		goto finished 
	end 
end /* end of cursor processing */
	

finished: 
CLOSE delete_matrequestlot_cursor 
DEALLOCATE delete_matrequestlot_cursor
return 





