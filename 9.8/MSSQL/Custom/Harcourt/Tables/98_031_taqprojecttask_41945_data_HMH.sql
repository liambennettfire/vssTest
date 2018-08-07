/*

Case: 41945 KeyDates Element for all titles 2052 Houghton Mifflin Harcourt : HMH Marketing Enhancements Jan 2017

HMH has requested that we use the same process we used for case 39878 but for all titles and not just for templates. 
	Note that this has already been run for the templates. So they should be excluded from this sql.

From 39878:
AK - 10/31/16 - For all title templates, check to see if key dates element exists. If not create it. 
	For any tasks on the title template that is not already attached to an element (no taqelementkey), attach them to the key dates element.

*/


DECLARE 
	@v_taqtaskkey INT,
	@v_taqelementtypecode INT,
	@v_taqelementdesc VARCHAR(255),
	@v_bookkey INT,
	@v_printingkey INT,
	@v_taqelementkey INT,
	@v_taqelementnumber INT,
	@v_error_code INT,
	@v_error_desc varchar(2000),
	@v_error  INT,
    @v_rowcount INT
	
	SET @v_error_code = 0
    SET @v_error_desc = ''
    SET @v_taqelementkey = 0
	SET @v_taqelementtypecode = 0
	
	SELECT @v_taqelementtypecode = datacode, @v_taqelementdesc = datadesc 
	FROM gentables 
	WHERE tableid = 287 and datadesc = 'Key Dates'	
	
	IF @v_taqelementtypecode = 0 BEGIN
		RETURN
	END
	
	UPDATE gentables
	SET deletestatus = 'N'
	WHERE tableid = 287 and datadesc = 'Key Dates'	

    DECLARE cur_taqprojectelement CURSOR FOR
	  SELECT DISTINCT b.bookkey, p.printingkey 
	  FROM book b 
	  INNER JOIN printing p ON b.bookkey = p.bookkey
	  WHERE b.bookkey NOT IN (
								SELECT te.bookkey 
								FROM taqprojectelement te 
								WHERE ISNULL(te.bookkey,0) > 0 AND 
								  te.taqelementtypecode = @v_taqelementtypecode) 
	  AND UPPER(b.standardind) = 'N' 
	  AND b.usageclasscode = 1	

    OPEN cur_taqprojectelement
             
    FETCH NEXT FROM cur_taqprojectelement INTO @v_bookkey, @v_printingkey
             
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_taqelementkey OUT
      
	  IF @v_taqelementkey IS NOT NULL
	   BEGIN
	   
			/* Get the maximum element number currently on taqprojectelement table */
			EXEC qproject_get_max_element_number @v_bookkey, @v_printingkey, @v_taqelementtypecode,
			  0, @v_taqelementnumber OUTPUT,
			  @v_error_code OUTPUT, @v_error_desc OUTPUT
		      
			IF @v_taqelementnumber IS NOT NULL
			  SET @v_taqelementnumber = @v_taqelementnumber + 1
			ELSE
			  SET @v_taqelementnumber = 1		      
		        		    
			/***** ADD new row to TAQPROJECTELEMENT table ****/
			INSERT INTO taqprojectelement
			  (taqelementkey,
			  taqprojectkey,
			  bookkey,
			  printingkey,
			  taqelementtypecode,
			  taqelementtypesubcode,
			  taqelementnumber,
			  taqelementdesc,
			  sortorder,
			  lastuserid,
			  lastmaintdate)
			VALUES
			  (@v_taqelementkey,
			  NULL,
			  @v_bookkey,
			  @v_printingkey,
			  @v_taqelementtypecode,
			  0,
			  @v_taqelementnumber,
			  @v_taqelementdesc,
			  @v_taqelementnumber,
			  'Case 41945',
			  getdate())
		      
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			  SET @v_error_code = 1
			  PRINT 'Error inserting to taqprojectelement table (bookkey=' + CAST(@v_bookkey AS VARCHAR) +
					', printingkey=' + CAST(@v_printingkey AS VARCHAR) +
					', taqelementkey=' + CAST(@v_taqelementkey AS VARCHAR)
			END  
		 END
		   
		  ELSE  --@v_taqelementkey not generated (NULL)
		   BEGIN
			  PRINT 'Could not generate new taqelementkey (taqprojectelement table)'
		   END
                    
      FETCH NEXT FROM cur_taqprojectelement INTO @v_bookkey, @v_printingkey
    END
             
    CLOSE cur_taqprojectelement
    DEALLOCATE cur_taqprojectelement
    	

    DECLARE cur_taqprojecttask CURSOR FOR
	 SELECT taqtaskkey, t.bookkey, t.printingkey 
	 FROM taqprojecttask t 
		INNER JOIN book b ON t.bookkey = b.bookkey 
		INNER JOIN printing p ON p.bookkey = b.bookkey AND p.printingkey = t.printingkey
	 WHERE UPPER(b.standardind) = 'N' AND COALESCE(taqelementkey, 0) = 0 AND b.usageclasscode = 1
                    

    OPEN cur_taqprojecttask
             
    FETCH NEXT FROM cur_taqprojecttask INTO @v_taqtaskkey, @v_bookkey, @v_printingkey
             
    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF EXISTS(SELECT 1 FROM taqprojectelement WHERE taqelementtypecode = @v_taqelementtypecode) BEGIN
		SELECT TOP(1) @v_taqelementkey = taqelementkey 
		FROM taqprojectelement
		WHERE taqelementtypecode = @v_taqelementtypecode AND 
		      bookkey = @v_bookkey AND
		      printingkey = @v_printingkey
		ORDER BY taqelementkey DESC
		
		UPDATE taqprojecttask 
		SET taqelementkey = @v_taqelementkey, lastuserid = 'CASE 41945', lastmaintdate = GETDATE() 
		WHERE taqtaskkey = @v_taqtaskkey            
      END
                    
      FETCH NEXT FROM cur_taqprojecttask INTO @v_taqtaskkey, @v_bookkey, @v_printingkey
    END
             
    CLOSE cur_taqprojecttask
    DEALLOCATE cur_taqprojecttask
    
    GO



