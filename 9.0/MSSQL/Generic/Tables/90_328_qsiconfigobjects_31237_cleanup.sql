DECLARE 
	@v_qsiconfigobjectkey INT,
	@v_configobjectid VARCHAR(100),
	@v_new_configobjectid VARCHAR(100),
	@v_sectioncontrolname VARCHAR(4000),
	@v_new_sectioncontrolname VARCHAR(4000),
	@v_count INT
	
	
BEGIN

    SELECT @v_count = COUNT(*)
      FROM qsiconfigobjects 
      WHERE windowid in (select windowid from qsiwindows where lower(windowname) = 'posummary') 
        and sectioncontrolname like '%ProjectsMisc%'
        
    IF @v_count > 0 BEGIN

		DECLARE cur_qsiconfigobjects CURSOR FOR
		 SELECT configobjectkey, configobjectid, sectioncontrolname 
		   FROM qsiconfigobjects 
		  WHERE windowid in (select windowid from qsiwindows where lower(windowname) = 'posummary') 
			and sectioncontrolname like '%ProjectsMisc%'
		ORDER BY configobjectkey ASC
		
		
		
		OPEN cur_qsiconfigobjects
  
		FETCH NEXT FROM cur_qsiconfigobjects INTO @v_qsiconfigobjectkey,@v_configobjectid, @v_sectioncontrolname

		WHILE (@@FETCH_STATUS <> -1) BEGIN
		
		    SET @v_new_configobjectid = REPLACE(@v_configobjectid, 'Project', 'PurchaseOrders')

		    SET @v_new_sectioncontrolname = REPLACE(@v_sectioncontrolname, 'Projects', 'PurchaseOrders')
		    
		    
		    UPDATE qsiconfigobjects
		       SET configobjectid = @v_new_configobjectid,
		           sectioncontrolname = @v_new_sectioncontrolname
		     WHERE configobjectkey = @v_qsiconfigobjectkey
		       AND configobjectid = @v_configobjectid
		       AND sectioncontrolname = @v_sectioncontrolname

			FETCH NEXT FROM cur_qsiconfigobjects INTO @v_qsiconfigobjectkey,@v_configobjectid, @v_sectioncontrolname
	    END
	    
	    CLOSE cur_qsiconfigobjects 
		DEALLOCATE cur_qsiconfigobjects
	END

END
go