DECLARE
	@v_itemtype_Journals INT,
	@v_usageclass_Journals INT,
	@v_usageclass_Content_Units INT,
	@v_usageclass_Issues INT,
	@v_usageclass_Volume INT,
	@v_configobjectkey INT,
	@v_count INT,
	@v_usageclasscode INT,
	@v_qsiwindowviewkey INT
	
	SET @v_count = 0
	
	SELECT @v_configobjectkey = configobjectkey
	FROM qsiconfigobjects 
	WHERE itemtypecode = 6 AND configobjectid = 'JournalsTabgroup1'
	
	IF @v_configobjectkey > 0 BEGIN
		SELECT @v_itemtype_Journals = dbo.qutl_get_gentables_datacode(550, 6, NULL)
			
		SELECT @v_usageclass_Journals = datasubcode
		FROM subgentables 
		WHERE tableid = 550 AND datacode = @v_itemtype_Journals  AND qsicode = 4

		SELECT @v_usageclass_Content_Units = datasubcode
		FROM subgentables 
		WHERE tableid = 550  AND datacode = @v_itemtype_Journals AND qsicode = 6	

		SELECT @v_usageclass_Issues = datasubcode
		FROM subgentables 
		WHERE tableid = 550  AND datacode = @v_itemtype_Journals AND qsicode = 5	

		SELECT @v_usageclass_Volume = datasubcode
		FROM subgentables 
		WHERE tableid = 550  AND datacode = @v_itemtype_Journals AND qsicode = 8	

	  DECLARE crQsiwindowview CURSOR FOR
		SELECT qsiwindowviewkey, usageclasscode from qsiwindowview 
		WHERE itemtypecode = @v_itemtype_Journals
		and defaultind = 1
	  
	  OPEN crQsiwindowview 

	  FETCH NEXT FROM crQsiwindowview INTO @v_qsiwindowviewkey, @v_usageclasscode

	  WHILE (@@FETCH_STATUS <> -1) BEGIN
		SET @v_count = 0
		
		SELECT @v_count = COUNT(*)
		FROM qsiconfigdetail
		WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @v_usageclasscode 
		
		IF @v_count > 0 BEGIN
			UPDATE qsiconfigdetail SET position  = 3 
			WHERE configobjectkey =  @v_configobjectkey AND usageclasscode = @v_usageclasscode AND qsiwindowviewkey = @v_qsiwindowviewkey
		END
	    
		FETCH NEXT FROM crQsiwindowview INTO @v_qsiwindowviewkey, @v_usageclasscode
	  END /* WHILE FETCHING */

	  CLOSE crQsiwindowview 
	  DEALLOCATE crQsiwindowview 
  
  END