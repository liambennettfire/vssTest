-- Home Default View
DECLARE
	@v_qsiwindowviewkey INT,
	@v_option_value INT,
	@v_windowid INT,
	@v_configobjectkey_printings INT,
	@v_configobjectkey_pos INT
	
	
	
BEGIN
	SELECT @v_qsiwindowviewkey = COALESCE(qsiwindowviewkey,0)
	  FROM qsiwindowview
	 WHERE qsiwindowviewname = 'Home Default View'
	 
	SELECT @v_option_value = COALESCE(optionvalue,0)  
	  FROM clientoptions
	 WHERE optionid = 117 -- Production on the Web
	 
	SELECT @v_windowid = COALESCE(windowid,0)
	  FROM qsiwindows
	 WHERE windowname = 'Home'
	 
	SELECT @v_configobjectkey_printings = COALESCE(configobjectkey,0)   
	  FROM qsiconfigobjects
	 WHERE configobjectid = 'shPrintings'
		 
	SELECT @v_configobjectkey_pos = COALESCE(configobjectkey,0)   
	  FROM qsiconfigobjects
	 WHERE configobjectid = 'shPurchaseOrders'
	 
	IF @v_qsiwindowviewkey > 0 BEGIN
		IF @v_option_value = 0 BEGIN
			IF @v_qsiwindowviewkey > 0 AND @v_windowid > 0 BEGIN
				IF @v_configobjectkey_printings > 0 BEGIN
					UPDATE qsiconfigdetail 
					   SET visibleind = 0
					 WHERE configobjectkey in (SELECT configobjectkey from qsiconfigobjects
					                           WHERE windowid = @v_windowid
					                           AND configobjectkey = @v_configobjectkey_printings
					                           AND defaultvisibleind = 1)

					UPDATE qsiconfigobjects 
					   SET defaultvisibleind = 0
					 WHERE windowid = @v_windowid
					   AND configobjectkey = @v_configobjectkey_printings
					   AND defaultvisibleind = 1					   
				END
				
				IF @v_configobjectkey_pos > 0 BEGIN
					UPDATE qsiconfigdetail 
					   SET visibleind = 0
					 WHERE configobjectkey in (SELECT configobjectkey from qsiconfigobjects
					                           WHERE windowid = @v_windowid
					                           AND configobjectkey = @v_configobjectkey_pos
					                           AND defaultvisibleind = 1)

					UPDATE qsiconfigobjects 
					   SET defaultvisibleind = 0
					 WHERE windowid = @v_windowid
					   AND configobjectkey = @v_configobjectkey_pos
					   AND defaultvisibleind = 1
				END
			END
		END
		IF @v_option_value = 1 BEGIN
			IF @v_qsiwindowviewkey > 0 AND @v_windowid > 0 BEGIN
				IF @v_configobjectkey_printings > 0 BEGIN
					UPDATE qsiconfigdetail 
					   SET visibleind = 1
					 WHERE configobjectkey in (SELECT configobjectkey from qsiconfigobjects
					                           WHERE windowid = @v_windowid
					                           AND configobjectkey = @v_configobjectkey_printings
					                           AND defaultvisibleind = 0)

					UPDATE qsiconfigobjects 
					   SET defaultvisibleind = 1
					 WHERE windowid = @v_windowid
					   AND configobjectkey = @v_configobjectkey_printings
					   AND defaultvisibleind = 0
				END
				
				IF @v_configobjectkey_pos > 0 BEGIN
					UPDATE qsiconfigdetail 
					   SET visibleind = 1
					 WHERE configobjectkey in (SELECT configobjectkey from qsiconfigobjects
					                           WHERE windowid = @v_windowid
					                           AND configobjectkey = @v_configobjectkey_pos
					                           AND defaultvisibleind = 0)

					UPDATE qsiconfigobjects 
					   SET defaultvisibleind = 1
					 WHERE windowid = @v_windowid
					   AND configobjectkey = @v_configobjectkey_pos
					   AND defaultvisibleind = 0
				END
			END
		END
	END

END