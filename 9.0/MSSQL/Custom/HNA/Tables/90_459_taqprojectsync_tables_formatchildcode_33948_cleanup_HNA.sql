set nocount on
go

DECLARE
	@v_plstage INT,
	@v_plversion INT,
	@v_projectkey	INT,
	@v_error  INT,
    @v_errordesc  VARCHAR(2000)
	
	
BEGIN
	DECLARE specitems_cur CURSOR FOR
		SELECT c.taqprojectkey,c.taqversionkey,c.plstagecode
		  FROM taqversionspecitems i,taqversionspeccategory c,taqprojecttitle t
		 WHERE i.itemcode = 1 -- Other Format
		   AND i.itemdetailcode > 0 
		   AND c.itemcategorycode = 1 -- Summary component
		   AND i.taqversionspecategorykey = c.taqversionspecategorykey
		   AND t.taqprojectkey = c.taqprojectkey
		   and t.bookkey not in (select bookkey from booksimon)
		   ORDER BY t.taqprojectkey 
	 
	 
	 OPEN specitems_cur 

	 FETCH NEXT FROM specitems_cur INTO @v_projectkey, @v_plversion, @v_plstage

	 WHILE (@@FETCH_STATUS <> -1)
	 BEGIN
		
		print 'taqprojectkey'
		print  @v_projectkey  
		print 'taqplversion'
		print @v_plversion
		
	    EXEC qpl_sync_specitems2tables_by_projectkey @v_projectkey,@v_plversion,
			'FB_UPDATE_33948',@v_error OUT, @v_errordesc OUT

		IF @v_error = -1 BEGIN
			SET @v_errordesc = 'Error returned from qpl_sync_specitems2tables: ' + @v_errordesc
			print @v_errordesc
		END

		FETCH NEXT FROM specitems_cur INTO @v_projectkey, @v_plversion, @v_plstage
	END
	
	CLOSE specitems_cur
	DEALLOCATE specitems_cur

END
go

set nocount off
go