--insert missing qsiconfigobjects rows for qutl_get_configuration to get all relevant helpUrl's
DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_windowid INT,
  @v_configobjectid VARCHAR(100),
  @v_configobjectdesc VARCHAR(100),
  @v_defaultlabeldesc VARCHAR(100),
  @v_itemtypecode INT
     
BEGIN  
  DECLARE cr_QsiConfigRows CURSOR FOR
  SELECT windowid, windowname, windowtitle
  FROM qsiwindows
  WHERE (lower(windowname) like '%search%' or 
	     lower(windowname) like '%task%' or 
	     lower(windowname) like '%pl%' or 
	     lower(windowname) like '%territory%' or 
	     lower(windowname) like '%newcontact%' or 
	     lower(windowname) like '%asset%') 
	     and applicationind = 14 
		 and windowid not in (SELECT windowid FROM qsiconfigobjects 
								WHERE windowid in (SELECT windowid FROM qsiwindows 
													WHERE (lower(windowname) like '%search%' or 
														   lower(windowname) like '%task%' or 
														   lower(windowname) like '%pl%' or 
														   lower(windowname) like '%territory%' or 
														   lower(windowname) like '%newcontact%' or 
														   lower(windowname) like '%asset%') 
														   and applicationind = 14))
  
  OPEN cr_QsiConfigRows
  FETCH NEXT FROM cr_QsiConfigRows
  INTO @v_windowid, @v_configobjectid, @v_configobjectdesc
  
  WHILE @@FETCH_STATUS = 0 BEGIN
  	 
    exec dbo.get_next_key 'FBT',@v_max_key out
    
	INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate)
    VALUES 
      (@v_max_key, @v_windowid, @v_configobjectid, @v_configobjectdesc, @v_configobjectdesc, 
      'QSIADMIN', getdate())
      
  FETCH NEXT FROM cr_QsiConfigRows
  INTO @v_windowid, @v_configobjectid, @v_configobjectdesc
  
  END
  
  CLOSE cr_QsiConfigRows
  DEALLOCATE cr_QsiConfigRows
END
go  