-- Drop this procedure if it already exists
PRINT 'deletetitle_deassign_onorder'
GO
IF object_id('deletetitle_deassign_onorder') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_deassign_onorder
END 
GO

/************************************************************************************/ 
/*This procedure deletes from the matrequestpo table and updates the matpomatcost table*/
/*************************************************************************************/ 


CREATE PROCEDURE deletetitle_deassign_onorder 
	@delete_title_pokey INT,
	@delete_title_materialkey INT,
  	@delete_title_rawmaterialkey INT,
	@v_qtyallocated_po INT,
	@illus_paperchgcode1 INT,
  	@illus_paperchgcode2 INT,
	@textpaperchgcode1 INT,
	@textpaperchgcode2 INT,
	@error_code INT OUTPUT,
	@error_desc VARCHAR(2000) OUTPUT

AS

/* initialize variables  */
DECLARE	
	@v_matpocost_count INT,
	@v_matpocost_qtyavailable INT,
	@v_matpocost_qtyallocated INT,
	@v_matpocost_ordercomplete varchar(1),
	@v_matpo_ponumber varchar(10),
	@v_zero_allocation INT,
	@err_msg varchar(255),
    @count_temp INT,
    @v_calc_qtyallocated INT,
    @v_calc_qtyavailable INT


SELECT	
	@v_matpocost_count = 0,
	@v_matpocost_qtyavailable = 0,
	@v_matpocost_qtyallocated = 0,
	@v_matpocost_ordercomplete = '',
	@v_matpo_ponumber = ' ',
	@v_zero_allocation = 0,
	@error_desc = '',
    @error_code = 0
    
    /*select @err_msg = 'executing deassign_title_onorder for pokey ' + convert(char(10), @delete_title_pokey)
	print @err_msg*/ 	

SELECT @v_matpocost_qtyavailable = a.qtyavailable,
		@v_matpocost_qtyallocated = a.qtyallocated,
		@v_matpocost_ordercomplete = a.ordercomplete,
		@v_matpo_ponumber = b.ponumber  
  FROM matpomatcost a, matpo b  
 WHERE (a.pokey = b.pokey) AND
       (b.pokey = @delete_title_pokey) AND
       (a.rawmaterialkey = @delete_title_rawmaterialkey) AND
       (a.chgcodecode in (@illus_paperchgcode1,@illus_paperchgcode2) OR
        a.chgcodecode in (@textpaperchgcode1,@textpaperchgcode2))

if @@error != 0 
begin 
	select @err_msg = 'Error selecting from matpomatcost for pokey ' + convert(char(10), @delete_title_pokey)
    print @err_msg 
	return 
end 



/*select @err_msg = 'deassign_title_onorder for count ' + convert(char(10), @count_temp)
print @err_msg 

select @err_msg = 'deassign_title_onorder for pokey ' + convert(char(10), @delete_title_pokey)
print @err_msg 

select @err_msg = 'deassign_title_onorder for @v_matpocost_qtyavailable ' + convert(char(10),@v_matpocost_qtyavailable)
print @err_msg 

select @err_msg = 'deassign_title_onorder for @v_matpocost_qtyallocated ' + convert(char(10),@v_matpocost_qtyallocated)
print @err_msg

select @err_msg = 'deassign_title_onorder for @v_matpo_ponumber ' + convert(char(10),@v_matpo_ponumber)
print @err_msg

select @err_msg = 'deassign_title_onorder for @v_matpocost_ordercomplete  ' + @v_matpocost_ordercomplete
print @err_msg*/


BEGIN

	/*select @err_msg = 'updating matpomatcost' 
	print @err_msg*/

	IF @v_matpocost_qtyavailable IS NULL begin
	   select @v_matpocost_qtyavailable = 0
	end

	IF @v_matpocost_qtyallocated IS NULL begin
		select @v_matpocost_qtyallocated = 0
	END 

	IF @v_matpocost_ordercomplete IS NULL begin
		select @v_matpocost_ordercomplete = 'N'
	end

	/*select @err_msg = 'deassign_title_onorder for @v_matpocost_ordercomplete  ' + @v_matpocost_ordercomplete
	print @err_msg*/
	
	IF @v_matpocost_ordercomplete = 'Y' begin

		select @v_calc_qtyavailable = @v_matpocost_qtyavailable +  @v_matpocost_qtyallocated

		UPDATE matpomatcost
		   SET qtyallocated = @v_zero_allocation, qtyavailable = @v_calc_qtyavailable
		  FROM matpomatcost m, matpo p
		 WHERE (m.pokey = @delete_title_pokey) AND
		   	   (m.pokey =p.pokey and p.postatus in ('F','I')) AND
		  	   (m.rawmaterialkey = @delete_title_rawmaterialkey) AND
			   (m.chgcodecode in (@illus_paperchgcode1,@illus_paperchgcode2) OR
			     m.chgcodecode in (@textpaperchgcode1,@textpaperchgcode2)) AND
			    m.qtyallocated = @v_matpocost_qtyallocated AND
			    m.qtyavailable = @v_matpocost_qtyavailable		

			
		if @@error <> 0 begin 
			select @err_msg = 'Error updating matpomatcost table for pokey' + convert(char(10), @delete_title_pokey)
			print @err_msg
			SET @error_code = -1
			SET @error_desc = @err_msg 
			return
		end 	
	end  /* end of update  */

	IF @v_matpocost_ordercomplete = 'N' begin
		select @v_calc_qtyallocated = @v_matpocost_qtyallocated - @v_matpocost_qtyallocated

   		select @v_calc_qtyavailable = @v_matpocost_qtyavailable +  @v_matpocost_qtyallocated

		UPDATE matpomatcost
		   SET qtyallocated = @v_calc_qtyallocated,
			   qtyavailable = @v_calc_qtyavailable
          FROM matpomatcost m, matpo p
		 WHERE (m.pokey = @delete_title_pokey) AND
			   (m.pokey = p.pokey and 
			    p.postatus in ('F','I')) AND
			   (m.rawmaterialkey = @delete_title_rawmaterialkey) AND
			   (m.chgcodecode in (@illus_paperchgcode1,@illus_paperchgcode2) OR
			    m.chgcodecode in (@textpaperchgcode1,@textpaperchgcode2)) AND
			    m.qtyallocated = @v_matpocost_qtyallocated AND
			    m.qtyavailable = @v_matpocost_qtyavailable	

	
		if @@error <> 0 begin 
			select @err_msg = 'Error updating matpomatcost table for pokey' + convert(char(10), @delete_title_pokey)
			print @err_msg 
			SET @error_code = -1
			SET @error_desc = @err_msg
			return
		end 	
	end
	
	/* insert values into temporary table */
	CREATE TABLE #matpo (pokey int, rawmaterialkey int)
	
	INSERT #matpo (pokey, rawmaterialkey)
	VALUES        (@delete_title_pokey,@delete_title_rawmaterialkey) 

	if @@error <> 0 begin 
		select @err_msg = 'Error inserting into temp table for pokey' + convert(char(10), @delete_title_pokey) 
                  + 'for rawmaterialkey' + convert(char(10), @delete_title_rawmaterialkey)
		print @err_msg 
		return
	end 	
END 

/* delete matrequestpo record  */
DELETE FROM matrequestpo
 WHERE (materialkey = @delete_title_materialkey) AND
       (pokey = @delete_title_pokey)

if @@error != 0 begin 
	select @err_msg = 'Error deleting from matrequestpo table for materialkey '  
			+ convert(char(10), @delete_title_materialkey) + ' and pokey ' + convert(char(10), @delete_title_pokey) 
    print @err_msg 
    SET @error_code = -1
	SET @error_desc = @err_msg
	return
end 

