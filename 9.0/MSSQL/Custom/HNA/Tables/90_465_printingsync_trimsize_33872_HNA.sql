set nocount on
go

DECLARE
	@v_bookkey INT,
	@v_printingkey INT,
	@v_userid VARCHAR(30)
	
	
BEGIN
	DECLARE printing_cur CURSOR FOR
	SELECT p.bookkey,p.printingkey
	  FROM printing p INNER JOIN dbo.taqprojectprinting_view tp on p.bookkey=tp.bookkey and p.printingkey=tp.printingkey
		INNER JOIN dbo.rpt_taqversionspecitems_view2 tv on tp.taqprojectkey=tv.taqprojectkey and tv.itemcategorycode=1 and tv.itemcode=8
		INNER JOIN dbo.taqversionspecitems t on tv.taqversionspecitemkey = t.taqversionspecitemkey
	 WHERE coalesce(p.tmmactualtrimlength,'') <> coalesce(tv.description2,'') 
	   AND coalesce(tv.description2,'') = '' 
	   AND coalesce(p.tmmactualtrimlength,'') <> ''
	   AND p.printingkey = 1
	ORDER BY p.bookkey 
	 
	 
	 OPEN printing_cur 

	 FETCH NEXT FROM printing_cur INTO @v_bookkey, @v_printingkey

	 WHILE (@@FETCH_STATUS <> -1)
	 BEGIN
		
		print 'bookkey'
		print  @v_bookkey  
		print 'printingkey'
		print @v_printingkey
		
		SET @v_userid = 'FB_CLEANUP_33872'
		
	    EXEC qpl_sync_tables2specitems @v_bookkey, @v_printingkey, 'printing', @v_userid
	
		FETCH NEXT FROM printing_cur INTO @v_bookkey, @v_printingkey
	END
	
	CLOSE printing_cur
	DEALLOCATE printing_cur
	
	
	DECLARE printing_cur CURSOR FOR
	SELECT p.bookkey,p.printingkey
	  FROM printing p INNER JOIN dbo.taqprojectprinting_view tp on p.bookkey=tp.bookkey and p.printingkey=tp.printingkey
		INNER JOIN dbo.rpt_taqversionspecitems_view2 tv on tp.taqprojectkey=tv.taqprojectkey and tv.itemcategorycode=1 and tv.itemcode=8
		INNER JOIN dbo.taqversionspecitems t on tv.taqversionspecitemkey = t.taqversionspecitemkey
	 WHERE coalesce(p.tmmactualtrimlength,'') <> coalesce(tv.description2,'') 
	   AND coalesce(tv.description2,'') = '' 
	   AND coalesce(p.trimsizelength,'') <> ''
	   AND p.printingkey> 1
	ORDER BY p.bookkey 
	 
	 
	 OPEN printing_cur 

	 FETCH NEXT FROM printing_cur INTO @v_bookkey, @v_printingkey

	 WHILE (@@FETCH_STATUS <> -1)
	 BEGIN
		
		print 'bookkey'
		print  @v_bookkey  
		print 'printingkey'
		print @v_printingkey
		
		SET @v_userid = 'FB_CLEANUP_33872'
		
	    EXEC qpl_sync_tables2specitems @v_bookkey, @v_printingkey, 'printing', @v_userid
	
		FETCH NEXT FROM printing_cur INTO @v_bookkey, @v_printingkey
	END
	
	CLOSE printing_cur
	DEALLOCATE printing_cur

END
go

set nocount off
go