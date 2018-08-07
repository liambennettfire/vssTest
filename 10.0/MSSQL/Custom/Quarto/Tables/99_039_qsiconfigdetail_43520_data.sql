DECLARE 
    @v_count  INT,
    @v_newkey   INT,
	@v_windowid INT,
	@v_qsiwindowviewkey INT,    
    @v_datacode_Contract INT,
    @v_datasubcode INT,
    @v_configobjectkey INT,
    @v_position INT 
	
BEGIN
	
	SELECT @v_datacode_Contract = dbo.qutl_get_gentables_datacode(550, 10, NULL)	
	
	SELECT @v_datasubcode = datasubcode 
	FROM subgentables
	WHERE tableid = 550 AND datacode = @v_datacode_Contract AND qsicode = 63
	
	SELECT TOP(1)  @v_qsiwindowviewkey = qsiwindowviewkey 
	FROM qsiwindowview 
	WHERE itemtypecode = @v_datacode_Contract AND usageclasscode = @v_datasubcode AND defaultind = 1
	
    SELECT @v_configobjectkey = configobjectkey
    FROM qsiconfigobjects 
    WHERE configobjectid = 'shContractVerification'   
 
    SELECT @v_count = COUNT(*)
    FROM qsiconfigdetail
    WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @v_datasubcode AND qsiwindowviewkey = @v_qsiwindowviewkey
    
    IF @v_count = 0 BEGIN
    
	  SELECT @v_windowid = windowid 
	  FROM qsiwindows 
	  WHERE lower(windowname) = 'ContractSummary'	
	
	  SELECT @v_position = MAX(COALESCE(position, 0)) + 1
	  FROM qsiconfigobjects
	  WHERE windowid = @v_windowid
	    AND itemtypecode = @v_datacode_Contract
	        
	  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT    
		
	  INSERT INTO qsiconfigdetail
		(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
		lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
	  VALUES
		(@v_newkey, @v_configobjectkey, @v_datasubcode, 'Verification Status', 1, 0,
		'QSIDBA', getdate(), @v_qsiwindowviewkey, 0, @v_position)      
    
    END
    ELSE BEGIN
	   UPDATE qsiconfigdetail
	   SET visibleind = 1 
	   WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @v_datasubcode AND qsiwindowviewkey = @v_qsiwindowviewkey 
    END
     
END
go
 	 	