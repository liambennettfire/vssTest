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
		SELECT distinct c.taqprojectkey,c.taqversionkey,c.plstagecode
		  FROM taqversionspeccategory c
		  INNER JOIN dbo.rpt_taqversionspecitems_view2 tv on c.taqprojectkey=tv.taqprojectkey and tv.itemcategorycode=1 and tv.itemcode=8
		  INNER JOIN dbo.taqversionspecitems t on tv.taqversionspecitemkey = t.taqversionspecitemkey
		  INNER JOIN taqprojectprinting_view tp  ON tp.taqprojectkey = c.taqprojectkey
		  INNER JOIN printing p on p.bookkey=tp.bookkey and p.printingkey=tp.printingkey
		  WHERE ((p.tmmactualtrimlength IS NULL AND (tv.description2 IS not NULL AND tv.description2 <> '') ) 
			AND (p.trimsizelength IS NULL AND (tv.description2 IS not NULL AND tv.description2 <> '') ) 
			AND (p.esttrimsizelength IS NULL AND (tv.description2 IS not NULL AND tv.description2 <> '') ))
		 ORDER BY c.taqprojectkey
	 
	 
	 OPEN specitems_cur 

	 FETCH NEXT FROM specitems_cur INTO @v_projectkey, @v_plversion, @v_plstage

	 WHILE (@@FETCH_STATUS <> -1)
	 BEGIN
		
		print 'taqprojectkey'
		print  @v_projectkey  
		print 'taqplversion'
		print @v_plversion
		
	    EXEC qpl_sync_specitems2tables_by_projectkey @v_projectkey,@v_plversion,
			'FB_UPDATE_33872',@v_error OUT, @v_errordesc OUT

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