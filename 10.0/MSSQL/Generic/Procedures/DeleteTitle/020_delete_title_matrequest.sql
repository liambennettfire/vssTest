-- Drop this procedure if it already exists
PRINT 'deletetitle_matrequest'
GO
IF object_id('deletetitle_matrequest ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_matrequest 
END 
GO

/*************************************************************************************/ 
/*This procedure writes to the matrequestold table and calls the stored procedures   */
/*to deassign on hand and on order inventory                                         */
/*************************************************************************************/ 

CREATE PROCEDURE deletetitle_matrequest 
	@delete_title_materialkey INT, 
	@illus_paperchgcode1 INT,
	@illuspaperchgcode2 INT,
	@text_paperchgcode1 INT,
	@textpaperchgcode2 INT,
	@error_code INT OUTPUT,
	@error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	@v_rawmaterialkey INT,
			@v_printer INT,
			@v_rmc varchar(10),
			@v_stocktypecode INT,
			@v_rollsize INT,
			@v_sheetsize INT,
			@v_basisweight INT,
			@v_color INT,
			@v_opacity INT,
			@v_requeststatus char(1),
			@v_requestdate datetime,
			@v_requireddate datetime,
			@v_ldcind varchar(10),
			@v_qtyrequested INT,
			@v_qtyonhandallocated INT,
			@v_requireddayind varchar(1),
			@v_matsuppliercode INT,
			@v_qtyallocated INT,
			@v_qtyallocated_po INT,
			@v_paperbulk INT,
			@v_ldcdate datetime,
			@v_lot_count INT,
			@v_po_count INT,
			@v_pokey INT,
			@err_msg varchar(70),
			@return_code INT,
			@count_temp INT


SELECT	@v_rawmaterialkey = 0,
		@v_printer = 0,
		@v_rmc = '',
		@v_stocktypecode = 0,
		@v_rollsize = 0,
		@v_sheetsize = 0,
		@v_basisweight = 0,
		@v_color = 0,
		@v_opacity = 0,
		@v_requeststatus = '',
		@v_ldcind = '',
		@v_qtyrequested = 0,
		@v_qtyonhandallocated = 0,
		@v_requireddayind = '',
		@v_matsuppliercode = 0,
		@v_qtyallocated = 0,
		@v_qtyallocated_po = 0,
		@v_paperbulk = 0,
		@v_lot_count = 0,
		@v_po_count = 0,
		@v_pokey = 0,
		@return_code = 0,
        @count_temp = 0,
        @error_desc = '',
        @error_code = 0

/*select @err_msg = 'In delete title matrequest for materialkey' + convert(char(10),@delete_title_materialkey )
print @err_msg*/
/* each matrequestpo row  */
DECLARE delete_matrequestpo CURSOR FOR 
	SELECT distinct pokey
	  FROM matrequestpo
	 WHERE materialkey = @delete_title_materialkey 
	
OPEN delete_matrequestpo

FETCH delete_matrequestpo INTO @v_pokey

/*SELECT @@FETCH_STATUS 'Fetch Status'*/
SELECT @@FETCH_STATUS 'Fetch Status1'

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete matrequestpo cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_matrequestpo 
	DEALLOCATE delete_matrequestpo 
	return 
end

WHILE @@FETCH_STATUS = 0 begin

	SELECT @v_rawmaterialkey = a.rawmaterialkey,@v_printer = a.printer,@v_rmc = a.rmc,
		   @v_stocktypecode = a.stocktypecode,@v_rollsize = a.rollsize,@v_sheetsize = a.sheetsize,   
    	   @v_basisweight = a.basisweight,@v_paperbulk = a.paperbulk,@v_color = a.color,
		   @v_opacity = a.opacity,@v_requeststatus = a.requeststatus,@v_requestdate = a.requestdate,   
     	   @v_requireddate = a.requireddate,@v_ldcind = a.ldcind,@v_ldcdate = a.ldcdate,
		   @v_qtyrequested = a.qtyrequested,@v_qtyonhandallocated = a.qtyonhandallocated,
		   @v_requireddayind = a.requireddayind,@v_matsuppliercode = a.matsuppliercode
	  FROM matrequest a 
     WHERE a.materialkey = @delete_title_materialkey

	if @@error != 0 	begin
		select @err_msg = 'Error selecting from matrequest for materialkey' + convert(char(10),@delete_title_materialkey )
		print @err_msg
		goto finished
	end 

	IF @v_qtyonhandallocated IS NULL 	begin
		select @v_qtyonhandallocated = 0
	END 

	IF @v_qtyrequested IS NULL 	begin
		select @v_qtyrequested = 0
	END

	IF @v_qtyonhandallocated > 0 	begin
		EXEC deletetitle_deassign_onhand @delete_title_materialkey,@error_code,@error_desc 
    
		IF @error_code != 0 begin
			select @err_msg = 'Return code of less than 0 returned from deletetitle_deassign_onhand' + 
				+ ' for materialkey ' + convert(char(10),@delete_title_materialkey )
       		print @err_msg 
			goto finished 
		end
	end

	IF @v_qtyonhandallocated < @v_qtyrequested begin	
	
		SELECT @v_qtyallocated_po = h.qtyallocated  
		  FROM matrequest k, matrequestpo h 
	 	 WHERE ( k.materialkey = h.materialkey ) and  
			   (k.materialkey = @delete_title_materialkey )  AND
			   ( h.pokey = @v_pokey  ) 

		if @@error != 0 begin
			select @err_msg = 'Error selecting from matrequest and matrequestpo for materialkey' + convert(char(10),@delete_title_materialkey )
			print @err_msg
			goto finished
		end 
	

		IF @v_qtyallocated_po IS NULL begin
			select v_qtyallocated_po = 0
		end
		
		/* check to see if these values exist on the temp. table - if they do then don't execute deassign onorder procedure*/
		SELECT @count_temp = count(*)
  		  FROM #matpo t
		 WHERE (t.pokey = @v_pokey) AND
  			   (t.rawmaterialkey = @v_rawmaterialkey) 

		if @@error != 0 begin 
			select @err_msg = 'Error selecting from #matpo for pokey ' + convert(char(10), @v_pokey)
		    print @err_msg 
			goto finished 
		end 

		/*select @err_msg = 'count ' +convert(char(10),@count_temp)
		print @err_msg*/

		IF @count_temp = 0 begin

			/*select @err_msg = 'going to exec deassign onorder' +convert(char(10),@count_temp)
			print @err_msg*/

			EXEC deletetitle_deassign_onorder @v_pokey ,@delete_title_materialkey,@v_rawmaterialkey,@v_qtyallocated_po,
					@illus_paperchgcode1 ,@illuspaperchgcode2 ,@text_paperchgcode1 ,@textpaperchgcode2,@error_code,@error_desc

			IF @error_code != 0 begin
				select @err_msg = 'Return code of less than 0 returned from deletetitle_deassign_onorder' + 
					+ ' for materialkey ' + convert(char(10),@delete_title_materialkey )
  				print @err_msg 
				goto finished 
			end 
		end

	end
				
	goto getnextrow

	getnextrow: 
	/* reset all variables */ 
	 
	FETCH delete_matrequestpo INTO @v_pokey
 
	--if @@fetch_status = -2
	--begin 
	--	select @err_msg = 'ERROR:  during fetch of matrequestpo.' 
	--	print @err_msg 
	--	goto finished 
	--end 
	--SELECT @@FETCH_STATUS 'Fetch Status2'
end /* end cursor processing */

/* copy request onto matrequestold  */
INSERT matrequestold
	( materialkey,rawmaterialkey,rmc,printer,stocktypecode,rollsize,sheetsize,   
     basisweight,paperbulk,color,opacity,requeststatus,requestdate,   
     requireddate,ldcind,ldcdate,qtyrequested,qtyonhandallocated,   
		requireddayind,matsuppliercode)
VALUES 	(@delete_title_materialkey,@v_rawmaterialkey,@v_rmc,@v_printer,@v_stocktypecode,@v_rollsize,@v_sheetsize,   
        @v_basisweight,@v_paperbulk,@v_color,@v_opacity,@v_requeststatus,@v_requestdate,   
        @v_requireddate,@v_ldcind,@v_ldcdate,@v_qtyrequested,@v_qtyonhandallocated,
      	 @v_requireddayind,@v_matsuppliercode) 

if @@error != 0 
begin
	select @err_msg = 'Error inserting into matrequestold for materialkey' + convert(char(10),@delete_title_materialkey )
	print @err_msg
	goto finished
end 

CLOSE delete_matrequestpo 
DEALLOCATE delete_matrequestpo
return

finished: 
CLOSE delete_matrequestpo 
DEALLOCATE delete_matrequestpo
SELECT @error_code = -1
SELECT @error_desc = @err_msg
return




