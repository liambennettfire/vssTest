SET NOCOUNT ON

DECLARE @v_count INT
DECLARE @v_count_book INT
DECLARE @v_count2 INT
DECLARE @v_bookkey	INT
DECLARE @v_printingkey INT
DECLARE @v_newkey INT
DECLARE @v_gpokey INT
DECLARE @v_vendorname VARCHAR(100)
DECLARE @v_ponumber VARCHAR(30)
DECLARE @v_changenumber INT
DECLARE @v_title VARCHAR(255)
DECLARE @v_gpostatus VARCHAR(1)
DECLARE @v_gpolastuserid VARCHAR(30)
DECLARE @v_taqprojecttype INT
DECLARE @v_taqprojecttitle VARCHAR(255) 
DECLARE @v_printingnum INT
DECLARE @v_itemtypecode INT
DECLARE @v_usageclasscode INT
DECLARE @v_usageclasscode_proforma INT
DECLARE @v_usageclasscode_final INT
DECLARE @v_printing_for_po_reports INT
DECLARE @v_po_reports_for_printing INT
DECLARE @v_taqprojectstatuscode	INT
DECLARE @v_templateind	TINYINT
DECLARE @v_lockorigdateind TINYINT
DECLARE @v_lastuserid VARCHAR(30)
DECLARE @v_lastmaintdate DATETIME
DECLARE @v_workkey INT
DECLARE @v_taqprojectformatkey	INT
DECLARE @v_taqprojectrelationshipkey INT
DECLARE @v_primaryformatind INT
DECLARE @NumberRecords	INT
DECLARE @RowCount	INT
DECLARE @v_filterorglevelkey INT
DECLARE @v_productnumberkey INT
DECLARE @v_po_number INT
DECLARE @v_printing_taqprojectkey INT
DECLARE @v_gpodate DATETIME
DECLARE @v_daterequired DATETIME
DECLARE @v_warehousedate DATETIME
DECLARE @v_boundbookdate DATETIME
DECLARE @v_taqtaskkey INT
DECLARE @v_datetypecode INT
DECLARE @v_taqprojectkey INT
DECLARE @v_vendor_role INT
DECLARE @v_globalcontactkey INT
DECLARE @v_sortorder INT
DECLARE @v_taqprojectcontactkey INT
DECLARE @v_taqprojectcontactrolekey INT
DECLARE @v_count_distributionpo INT
DECLARE @v_vendorid VARCHAR(10)
DECLARE @v_vendorkey INT
DECLARE @v_count_distribution INT
DECLARE @v_count3 INT
DECLARE @v_cover_due	VARCHAR(100)
DECLARE @v_jacket_due	VARCHAR(100)
DECLARE @v_misc_due VARCHAR(100)
DECLARE @v_cover_due_parse VARCHAR(20)
DECLARE @v_jacket_due_parse VARCHAR(20)
DECLARE @v_misc_due_parse VARCHAR(20)
DECLARE @v_cover_due_date	DATETIME
DECLARE @v_jacket_due_date	DATETIME
DECLARE @v_misc_due_date  DATETIME
DECLARE @v_pos INT
DECLARE @v_count_gpo INT
DECLARE @v_count_components INT
DECLARE @v_comptype INT
DECLARE @v_compdesc_single VARCHAR(50)
DECLARE @v_compdesc VARCHAR(2000)
DECLARE @v_commonform_cnt INT



BEGIN

  SET @v_lastuserid = 'CONVERTED'
  SET @v_lastmaintdate = getdate()
  SELECT @v_taqprojecttype = datacode FROM gentables where tableid = 521 AND qsicode = 9  -- Converted PO
  SELECT @v_printing_for_po_reports = datacode FROM gentables WHERE tableid = 582 and qsicode = 29 --Printing (for PO Reports)
  SELECT @v_po_reports_for_printing = datacode FROM gentables WHERE tableid = 582 and qsicode = 30 --PO Reports (for Printings)
  SELECT @v_vendor_role = datacode FROM gentables where tableid = 285 and qsicode = 15 --vendor
  SET @v_itemtypecode = 15 --Purchase Orders
  SET @v_usageclasscode_proforma = 2 --Proforma PO Report
  SET @v_usageclasscode_final = 3 --Final PO Report
 
--  DROP TABLE #gposection

  CREATE TABLE #gposection (
	RowID int IDENTITY (1,1),
	GpoKey	INT,
	Key1 INT,
	Key2 INT)
      
      
   INSERT INTO #gposection (GpoKey,Key1,Key2)
    SELECT DISTINCT gpokey,key1,key2
     FROM gposection
    WHERE sectiontype in (2,3)
    ORDER by gpokey,key1,key2
    
   SET @NumberRecords	= @@ROWCOUNT
   SET @RowCount = 1

   --print '@NumberRecords'
   --print @NumberRecords

   WHILE @RowCount <= @NumberRecords
   BEGIN
   
    SELECT @v_gpokey = gpokey, @v_bookkey = key1, @v_printingkey =  key2
      FROM #gposection
     WHERE ROWID = @RowCount
     
    SET @v_commonform_cnt = 0 
    SELECT @v_commonform_cnt = COUNT(*)
      FROM gposection
     WHERE gpokey = @v_gpokey AND sectiontype NOT IN (2,3)
     
    SET @v_count_gpo = 0
    SELECT @v_count_gpo = COUNT(*)
      FROM gpo
     WHERE gpokey = @v_gpokey
   
    IF @v_commonform_cnt = 0 and @v_count_gpo > 0 BEGIN 

	   -- print '@v_gpokey'
		  --print @v_gpokey
	   -- print '@v_bookkey'
		  --print @v_bookkey
		  --print '@v_printingkey'
		  --print @v_printingkey
	     
	    
		SELECT @v_vendorname = COALESCE(vendorname,''), @v_ponumber = COALESCE(ltrim(rtrim(gponumber)),''), 
			   @v_changenumber = COALESCE(gpochangenum,0),@v_gpostatus = gpostatus,
			   @v_gpolastuserid = lastuserid, @v_gpodate = gpodate, @v_daterequired = daterequired, @v_warehousedate = warehousedate,
			   @v_boundbookdate = boundbookdate, @v_vendorkey = COALESCE(vendorkey,'')
		  FROM gpo
		 WHERE gpokey = @v_gpokey
	     
	     
		SELECT @v_count_book = COUNT(*)
		  FROM book
		   WHERE bookkey = @v_bookkey

		--print '@v_count_book'
		--print @v_count_book


		-- HNA Customize to exlude Distribution POs based on orglevel
		IF @v_count_book = 1 BEGIN
		  SELECT @v_count_distribution = COUNT(*)
			FROM bookorgentry
		   WHERE orglevelkey = 2
			 AND orgentrykey = 3
			 AND bookkey = @v_bookkey
	      
	      
		  --IF @v_count_distribution = 1 BEGIN
		  --  print 'PO Number: ' + @v_ponumber + ' not converted because it is a distribution PO'
		  --END
		END
	    
	    
		SELECT @v_count3 = 0
		SELECT @v_count3 = COUNT(*)
		  FROM taqproject
		 WHERE taqprojectkey = @v_gpokey
		 
		--print '@v_count_distribution'
		--print @v_count_distribution

		  IF @v_count_book = 1 AND @v_count_distribution = 0 AND @v_count3 = 0 BEGIN
		  	
		
		--print '@v_vendorname'
		--print @v_vendorname
		--print '@v_ponumber'
		--print @v_ponumber
		
	     
			SELECT @v_count = count(key1)
			  FROM gposection
			 WHERE gpokey = @v_gpokey AND key1 <> @v_bookkey
		 	        
			IF @v_count = 0 BEGIN
			    -- only one printing related to PO
  				SELECT @v_title = title
				  FROM book
				 WHERE bookkey = @v_bookkey
				 
				SELECT @v_printingnum  = COALESCE(printingnum,0)
				  FROM printing
				 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

	--print '@v_title'
	--print @v_title
	             SELECT @v_count_components = COUNT(*)
				   FROM gposection
				  WHERE gpokey = @v_gpokey AND key1 = @v_bookkey AND key2 = @v_printingkey
				 
				 IF @v_count_components = 1 BEGIN
				  SET @v_compdesc = ''
				  SELECT @v_compdesc_single = description FROM gposection WHERE gpokey = @v_gpokey AND key1 = @v_bookkey AND key2 = @v_printingkey
				  SELECT @v_compdesc = @v_compdesc_single
				 END
				 ELSE IF  @v_count_components > 1 BEGIN
					 SET @v_compdesc = ''
				     
					 DECLARE component_cursor CURSOR FOR
						SELECT key3 
						  FROM gposection
						 WHERE gpokey = @v_gpokey AND key1 = @v_bookkey AND key2 = @v_printingkey
			
					 OPEN component_cursor
					 FETCH component_cursor INTO @v_comptype
			         
					 WHILE @@FETCH_STATUS = 0 BEGIN
						IF @v_compdesc IS NULL OR @v_compdesc = '' 		 
							SELECT @v_compdesc = description FROM gposection WHERE gpokey = @v_gpokey AND key1 = @v_bookkey AND key2 = @v_printingkey
							   AND key3 = @v_comptype
						ELSE BEGIN
							SELECT @v_compdesc_single = description FROM gposection WHERE gpokey = @v_gpokey AND key1 = @v_bookkey AND key2 = @v_printingkey
								AND key3 = @v_comptype
							SELECT @v_compdesc = @v_compdesc + '/' + @v_compdesc_single
						END
						
						FETCH component_cursor INTO @v_comptype
					 END
					 CLOSE component_cursor
					 DEALLOCATE component_cursor
				 END	
				 
				 		
				--IF 	@v_title IS NOT NULL BEGIN		
				--	SET @v_taqprojecttitle = @v_vendorname + ' ' + @v_ponumber + ' ' + convert(varchar,@v_changenumber) + ' ' + @v_title
				--END
				--ELSE BEGIN
				--	SET @v_taqprojecttitle = @v_vendorname + ' ' + @v_ponumber + ' ' + convert(varchar,@v_changenumber)
				--END
				IF 	@v_title IS NOT NULL BEGIN	
				    IF @v_printingnum > 0 
						SET @v_taqprojecttitle = @v_ponumber + '-' + convert(varchar,@v_changenumber) + ' ' + @v_title + ' #' + convert(varchar, @v_printingnum)
					ELSE
						SET @v_taqprojecttitle = @v_ponumber + '-' + convert(varchar,@v_changenumber) + ' ' + @v_title 
						
					IF @v_compdesc IS NOT NULL AND @v_compdesc <> ''
						SET @v_taqprojecttitle =  @v_taqprojecttitle + ' ' + @v_compdesc
				END
				ELSE BEGIN
					SET @v_taqprojecttitle = @v_ponumber + '-' + convert(varchar,@v_changenumber)
					
					IF @v_compdesc IS NOT NULL AND @v_compdesc <> ''
						SET @v_taqprojecttitle =  @v_taqprojecttitle + ' ' + @v_compdesc
				END
			END
			ELSE BEGIN
				 -- more than one related printing
				--SET @v_taqprojecttitle = @v_vendorname + ' ' + @v_ponumber + ' ' + convert(varchar,@v_changenumber)
				SET @v_taqprojecttitle = @v_ponumber + ' ' + convert(varchar,@v_changenumber)
			END
			
			SET @v_taqprojecttype = @v_taqprojecttype
			
			IF @v_gpostatus = 'P' OR @v_gpostatus = 'F' BEGIN
				SELECT @v_taqprojectstatuscode = datacode FROM gentables where tableid = 522 AND qsicode = 13 --Sent to Vendor
			END
			ELSE IF @v_gpostatus = 'A' BEGIN
				SELECT @v_taqprojectstatuscode = datacode FROM gentables where tableid = 522 AND qsicode = 11 -- Amended
			END
			ELSE IF @v_gpostatus = 'V' BEGIN
				SELECT @v_taqprojectstatuscode = datacode FROM gentables where tableid = 522 AND qsicode = 10 -- Void
			END
			ELSE BEGIN
				SET @v_taqprojectstatuscode = 0
			END
			
			SET @v_lastuserid = 'CONVERTED ' + @v_gpolastuserid
			
			IF @v_gpostatus = 'P' OR @v_gpostatus = 'V' OR @v_gpostatus = 'A' BEGIN
				SET @v_usageclasscode = @v_usageclasscode_proforma
			END
			ELSE IF @v_gpostatus = 'F' BEGIN
				SET @v_usageclasscode = @v_usageclasscode_final
			END
			
			--taqproject row
			INSERT INTO taqproject 
			 (taqprojectkey, taqprojectownerkey, taqprojecttitle,taqprojecttype,taqprojectstatuscode,templateind, lockorigdateind, lastuserid,
			 lastmaintdate,usageclasscode,searchitemcode)
			 VALUES(@v_gpokey,0,@v_taqprojecttitle,@v_taqprojecttype,@v_taqprojectstatuscode,0,0,@v_lastuserid,
				@v_lastmaintdate,@v_usageclasscode,@v_itemtypecode)
				
			-- taqprojectrelationship row
			SET @v_count2 = 0
			
			SELECT @v_count2 = COUNT(*)
			  FROM taqprojectprinting_view
			 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
			
			IF @v_count2 = 1 BEGIN
				SELECT @v_taqprojectkey = taqprojectkey
				  FROM taqprojectprinting_view
				 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
									
				 
				EXEC dbo.get_next_key 'QSIDBA', @v_taqprojectrelationshipkey OUT
				
				INSERT INTO taqprojectrelationship (taqprojectrelationshipkey,taqprojectkey1,taqprojectkey2,relationshipcode1,
				  relationshipcode2,lastuserid,lastmaintdate)
				VALUES(@v_taqprojectrelationshipkey,@v_taqprojectkey,@v_gpokey,@v_printing_for_po_reports,@v_po_reports_for_printing,
				  @v_lastuserid,@v_lastmaintdate)
			END
			
			--- taqproductnumbers
			-- PO Number
			IF @v_ponumber IS NOT NULL AND @v_ponumber <> '' BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_productnumberkey OUT
				
				SELECT @v_po_number = datacode FROM gentables WHERE tableid = 594 and qsicode = 7 --PO Number
				
				INSERT INTO taqproductnumbers(productnumberkey,taqprojectkey,elementkey,productidcode,prefixcode,productnumber,lastuserid,lastmaintdate)
					VALUES(@v_productnumberkey,@v_gpokey,NULL,@v_po_number,NULL,@v_ponumber,@v_lastuserid,@v_lastmaintdate)
			
			END
			
			-- PO Amendment #
			IF @v_changenumber IS NOT NULL AND @v_changenumber > 0 BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_productnumberkey OUT
				
				SELECT @v_po_number = datacode FROM gentables WHERE tableid = 594 and qsicode = 13 --PO Amendent #
				
				INSERT INTO taqproductnumbers(productnumberkey,taqprojectkey,elementkey,productidcode,prefixcode,productnumber,lastuserid,lastmaintdate)
					VALUES(@v_productnumberkey,@v_gpokey,NULL,@v_po_number,NULL,@v_changenumber,@v_lastuserid,@v_lastmaintdate)
			END
			
			
			-- Taqprojectorgentry
			SELECT @v_printing_taqprojectkey = MIN(taqprojectkey) 
			  FROM taqprojectprinting_view
			 WHERE bookkey = @v_bookkey 
			   AND printingkey = @v_printingkey
			   
			   
			SELECT @v_filterorglevelkey = max(orglevelkey)
			  FROM taqprojectorgentry
			 WHERE taqprojectkey = @v_printing_taqprojectkey
	         
	        
			INSERT INTO taqprojectorgentry (taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
			  SELECT @v_gpokey, orgentrykey, orglevelkey, @v_lastuserid, getdate()
				FROM taqprojectorgentry
			   WHERE taqprojectkey = @v_printing_taqprojectkey
				 AND orglevelkey <= @v_filterorglevelkey
				 
				 
			-- TAQPROJECTTASKS
			IF @v_gpodate  IS NOT NULL BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
				
				select @v_datetypecode = datetypecode FROM datetype where lower(description) = 'po date'
				
				--print 'po date'
				--print '@v_datetypecode'
				--print @v_datetypecode
	        
				INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
				VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,1,@v_gpodate,1,@v_lastuserid, getdate())
			END 
	        
	        
			IF @v_daterequired  IS NOT NULL BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
				
				select @v_datetypecode = datetypecode FROM datetype where lower(description) = 'date required'
				
				--print 'date required'
				--print '@v_datetypecode'
				--print @v_datetypecode
	        
				INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
				VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,1,@v_daterequired,1,@v_lastuserid, getdate())
			END 
	        
			IF @v_warehousedate IS NOT NULL BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
				
				select @v_datetypecode = datetypecode FROM datetype where lower(description) = 'warehouse date'
				
				--print 'warehouse date'
				--print '@v_datetypecode'
				--print @v_datetypecode
	        
				INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
				VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,1,@v_warehousedate ,1,@v_lastuserid, getdate())
			END 
	         
	         
			IF @v_boundbookdate IS NOT NULL BEGIN
				EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
				
				select @v_datetypecode = datetypecode FROM datetype where lower(description) = 'bound book date'
				
				--print 'bound book date'
				--print '@v_datetypecode'
				--print @v_datetypecode
	        
				INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
				VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,1,@v_boundbookdate ,1,@v_lastuserid, getdate())
			END 
	        
			SET @v_cover_due = ''
			SET @v_jacket_due = ''
			SET @v_misc_due = ''
	        
	        
			SELECT @v_cover_due = jacketcoverdue, @v_jacket_due = jacketdue, @v_misc_due = miscdue
			  FROM component 
			 WHERE pokey = @v_gpokey
			   AND compkey = 2
	         
			-- Cover Due  
			IF @v_cover_due IS NOT NULL AND @v_cover_due <> '' BEGIN
				IF ISDATE(@v_cover_due) = 1 BEGIN
					select @v_cover_due_date = CASE WHEN ISDATE(@v_cover_due) = 1
						THEN CASE WHEN CAST(@v_cover_due AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
							THEN @v_cover_due
									ELSE NULL
							END
						ELSE NULL
						END
					
					IF @v_cover_due_date IS NOT NULL BEGIN	
						EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
						
						select @v_datetypecode = datetypecode FROM datetype where qsicode = 25 --Cover due
												        
						INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
						 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_cover_due_date,1,@v_lastuserid, getdate())
					END
				END
				ELSE BEGIN --IF ISDATE(@v_cover_due) <> 1
				   --print '@v_cover_due'
				   --print @v_cover_due
				   SET @v_pos = CHARINDEX('-',@v_cover_due)
				   IF @v_pos > 0 BEGIN
					   SET @v_cover_due_parse = SUBSTRING(@v_cover_due,1,(CHARINDEX('-',@v_cover_due)-1))
					   --print '@v_cover_due_parse'
					   --print @v_cover_due_parse
					   
					   IF ISDATE(@v_cover_due_parse) = 1 BEGIN
						select @v_cover_due_date = CASE WHEN ISDATE(@v_cover_due_parse) = 1
							THEN CASE WHEN CAST(@v_cover_due_parse AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
								THEN @v_cover_due_parse
										ELSE NULL
								END
							ELSE NULL
							END
						
						IF @v_cover_due_date IS NOT NULL BEGIN	
							EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
							select @v_datetypecode = datetypecode FROM datetype where qsicode = 25 --Cover due
													        
							INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
							 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_cover_due_date,1,@v_lastuserid, getdate())
						END
					  END --IF ISDATE(@v_cover_due_parse) = 1 
					  ELSE BEGIN --IF ISDATE(@v_cover_due_parse) <> 1 
					   
						   EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
						   select @v_datetypecode = datetypecode FROM datetype where qsicode = 25 --Cover due
													        
						   INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
							VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_cover_due)
					  END --IF ISDATE(@v_cover_due_parse) <> 1 
					END  --@v_pos > 0
					ELSE BEGIN
						 EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
						 select @v_datetypecode = datetypecode FROM datetype where qsicode = 25 --Cover due
													        
						 INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
							VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_cover_due)
					
					END --@v_pos = 0
				END --IF ISDATE(@v_cover_due) <> 1
			END --IF @v_cover_due IS NOT NULL AND @v_cover_due <> '' 
			
			-- Jacket Due
			IF @v_jacket_due IS NOT NULL AND @v_jacket_due <> '' BEGIN
				IF ISDATE(@v_jacket_due) = 1 BEGIN
					select @v_jacket_due_date = CASE WHEN ISDATE(@v_jacket_due) = 1
						THEN CASE WHEN CAST(@v_jacket_due AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
							THEN @v_jacket_due
							ELSE NULL
						END
						ELSE NULL
					END
					
					IF @v_jacket_due_date IS NOT NULL BEGIN	
						EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
						
						select @v_datetypecode = datetypecode FROM datetype where qsicode = 26 --Jacket due
												        
						INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
						 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_jacket_due_date ,1,@v_lastuserid, getdate())
					END
				END
				ELSE BEGIN --IF ISDATE(@v_jacket_due) <> 1
				--print '@v_jacket_due'
				--print @v_jacket_due
				   SET @v_pos = CHARINDEX('-',@v_jacket_due)
				   IF @v_pos > 0 BEGIN
					   SET @v_jacket_due_parse = SUBSTRING(@v_jacket_due,1,(CHARINDEX('-',@v_jacket_due)-1))
					   --print '@v_jacket_due_parse'
					   --print @v_jacket_due_parse
					   
					   IF ISDATE(@v_jacket_due_parse) = 1 BEGIN
						select @v_jacket_due_date = CASE WHEN ISDATE(@v_jacket_due_parse) = 1
							THEN CASE WHEN CAST(@v_jacket_due_parse AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
								THEN @v_jacket_due_parse
								ELSE NULL
							END
							ELSE NULL
							END
						
						IF @v_jacket_due_date IS NOT NULL BEGIN	
							EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
							select @v_datetypecode = datetypecode FROM datetype where qsicode = 26 --Jacket due
													        
							INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
							 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_jacket_due_date,1,@v_lastuserid, getdate())
						END
					  END --IF ISDATE(@v_jacket_due_parse) = 1 
					  ELSE BEGIN --IF ISDATE(@v_jacket_due_parse) <> 1 
					   
						   EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
						   select @v_datetypecode = datetypecode FROM datetype where qsicode = 26 --JAcket due
													        
						   INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
							VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_jacket_due)
					  END --IF ISDATE(@v_jacket_due_parse) <> 1 
					END --@v_pos > 0
					ELSE BEGIN
						EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
								
					   select @v_datetypecode = datetypecode FROM datetype where qsicode = 26 --JAcket due
												        
						INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
								VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_jacket_due)
					
					END --@v_pos < 0
				END --IF ISDATE(@v_jacket_due) <> 1
			END --IF @v_jacket_due IS NOT NULL AND @v_jacket_due <> ''
			
			-- Misc Due
			IF @v_misc_due IS NOT NULL AND @v_misc_due <> '' BEGIN
				IF ISDATE(@v_misc_due) = 1 BEGIN
					select @v_misc_due_date = CASE WHEN ISDATE(@v_misc_due) = 1
						THEN CASE WHEN CAST(@v_misc_due AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
							THEN @v_misc_due
							ELSE NULL
						END
						ELSE NULL
					END
					
					IF @v_misc_due_date IS NOT NULL BEGIN	
						EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
						
						select @v_datetypecode = datetypecode FROM datetype where qsicode = 27 -- Misc Due
												        
						INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
						 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_misc_due_date ,1,@v_lastuserid, getdate())
					END
				END
				ELSE BEGIN --IF ISDATE(@v_misc_due) <> 1
				--print '@v_misc_due'
				--print @v_misc_due
				   SET @v_pos = CHARINDEX('-',@v_misc_due)
				   IF @v_pos > 0 BEGIN
					   SET @v_misc_due_parse = SUBSTRING(@v_misc_due,1,(CHARINDEX('-',@v_misc_due)-1))
					   --print '@v_misc_due_parse'
					   --print @v_misc_due_parse
					   
					   IF ISDATE(@v_misc_due_parse) = 1 BEGIN
						select @v_misc_due_date = CASE WHEN ISDATE(@v_misc_due_parse) = 1
							THEN CASE WHEN CAST(@v_misc_due_parse AS DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
								THEN @v_misc_due_parse
										ELSE NULL
								END
							ELSE NULL
							END
						
						IF @v_misc_due_parse IS NOT NULL BEGIN	
							EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
							select @v_datetypecode = datetypecode FROM datetype where qsicode = 27 --Misc due
													        
							INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
							 VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,@v_misc_due_parse,1,@v_lastuserid, getdate())
						END
					  END --IF ISDATE(@v_misc_due_parse) = 1 
					  ELSE BEGIN --IF ISDATE(@v_jacket_due_parse) <> 1 
					   
						   EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
						   select @v_datetypecode = datetypecode FROM datetype where qsicode = 27 --Misc due
													        
						   INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
							VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_misc_due)
					  END --IF ISDATE(@v_misc_due_parse) <> 1 
					END --@v_pos > 0
					ELSE BEGIN
						EXEC dbo.get_next_key 'QSIDBA', @v_taqtaskkey OUT
							
						select @v_datetypecode = datetypecode FROM datetype where qsicode = 27 --Misc due
													        
						INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate,taqtasknote)
							VALUES (@v_taqtaskkey,@v_gpokey,@v_datetypecode,0,NULL,0,@v_lastuserid, getdate(),@v_misc_due)
					
					END  --@v_pos < 0
				END --IF ISDATE(@v_misc_due) <> 1
			END  --IF @v_misc_due IS NOT NULL AND @v_misc_due <> ''
	         
	         
			--TAQPROJECTCONTACT
			-- For HNA conversion will be based on conversionkey from globalcontact matching vendorkey on vendor table
			IF @v_vendorkey > 0 BEGIN
			  
				SELECT @v_globalcontactkey = globalcontactkey
				  FROM globalcontact
				 WHERE conversionkey = @v_vendorkey
		    		     
				EXEC dbo.get_next_key 'QSIDBA', @v_taqprojectcontactkey OUT
		    		    
				SELECT @v_sortorder = COALESCE(sortorder,0)
				  FROM taqprojectcontact
				 WHERE taqprojectkey = @v_gpokey
		    		     
				SELECT @v_sortorder = @v_sortorder + 1
		    		
				INSERT INTO taqprojectcontact(taqprojectcontactkey,taqprojectkey,globalcontactkey,keyind,sortorder,lastuserid,lastmaintdate)
				  VALUES(@v_taqprojectcontactkey,@v_gpokey,@v_globalcontactkey,1,@v_sortorder,@v_lastuserid, getdate())
		    		      
		    		      
				EXEC dbo.get_next_key 'QSIDBA', @v_taqprojectcontactrolekey OUT
		    		    
				INSERT INTO taqprojectcontactrole
				  (taqprojectcontactrolekey,taqprojectcontactkey,taqprojectkey,rolecode,activeind,lastuserid,lastmaintdate)
					 VALUES(@v_taqprojectcontactrolekey,@v_taqprojectcontactkey,@v_gpokey,@v_vendor_role,1,@v_lastuserid, getdate())
			END
			ELSE BEGIN
			  print 'Vendor Key is not populated for: ' +  CONVERT(VARCHAR(20),@v_gpokey) + ' for PO Number: ' + @v_ponumber
			END
		END		--IF @v_count_book = 1 AND @v_count_distribution = 0 AND @v_count3 = 0 
	END --@v_count_gpo > 0

	SET @RowCount = @RowCount + 1
   END
   
   DROP TABLE #gposection
END -- main loop