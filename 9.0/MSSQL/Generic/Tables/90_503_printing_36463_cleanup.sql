DECLARE @v_taqprojectkey INT
DECLARE @v_bookkey	INT
DECLARE @v_printingkey INT
DECLARE @v_bookweight DECIMAL(15,4)
DECLARE @v_printing_bookweight DECIMAL(15,4)
DECLARE @v_historyvalue VARCHAR(255)
DECLARE @o_error_code INT
DECLARE @o_error_desc VARCHAR(2000)
DECLARE @v_count INT

BEGIN
	SELECT @v_count = COUNT(*) FROM qsiconfigspecsync WHERE tablename = 'printing' AND columnname = 'bookweight'
    
    IF @v_count = 0 RETURN

	DECLARE taqproject_cur CURSOR FOR
		SELECT taqversionspecitems_view.taqprojectkey, decimalvalue, printing.bookkey,printing.printingkey, bookweight 
		  FROM taqversionspecitems_view, taqprojecttitle, printing
		  WHERE speccategorydescription = (SELECT datadesc FROM gentables WHERE tableid = 616 AND qsicode = 1) --'Summary' 
		    AND itemcode = (SELECT datasubcode FROM subgentables 
				WHERE datacode = (select datacode from gentables where tableid = 616 AND qsicode = 1) 
				  AND datadesc = 'Book Weight')
		    AND decimalvalue IS NOT NULL
		    AND taqprojecttitle.taqprojectkey = taqversionspecitems_view.taqprojectkey
		    AND printing.bookkey = taqprojecttitle.bookkey
		    AND printing.printingkey = taqprojecttitle.printingkey
		    AND printing.bookweight is null
		    ORDER BY taqversionspecitems_view.taqprojectkey DESC
		    
	 OPEN taqproject_cur

	 FETCH NEXT FROM taqproject_cur INTO @v_taqprojectkey,@v_bookweight,@v_bookkey,@v_printingkey,@v_printing_bookweight

	 WHILE (@@FETCH_STATUS = 0) BEGIN
	    IF @v_printing_bookweight IS NULL BEGIN
			UPDATE printing  
			   SET bookweight = @v_bookweight,
			       lastuserid = 'FB_36463_UPDATE',
			       lastmaintdate = GETDATE()
			 WHERE bookkey = @v_bookkey
			   AND printingkey = @v_printingkey
			   
			SET @o_error_code = 0
			SET @o_error_desc = ''
			   
			SET @v_historyvalue = CAST(@v_bookweight AS VARCHAR(50))
			
			EXEC dbo.qtitle_update_titlehistory 'printing','bookweight',@v_bookkey,@v_printingkey,0,@v_historyvalue,
			  'UPDATE','FB_36463_UPDATE',NULL,NULL,@o_error_code OUTPUT,@o_error_desc OUTPUT

		END
		FETCH NEXT FROM taqproject_cur INTO @v_taqprojectkey,@v_bookweight,@v_bookkey,@v_printingkey,@v_printing_bookweight
	 END
	 
	 CLOSE taqproject_cur 
	 DEALLOCATE taqproject_cur
END 
Go