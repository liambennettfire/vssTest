DECLARE 
  @v_qsiconfigobjectkey INT,
  @v_windowid INT 
  
BEGIN  
  SELECT @v_windowid = windowid 
  FROM qsiwindows  
  WHERE windowname = 'DeletePrinting'

  SELECT @v_qsiconfigobjectkey =  configobjectkey 
  FROM qsiconfigobjects 
  WHERE configobjectid = 'linkDeleteProject' AND 
		windowid = @v_windowid
		  
  UPDATE qsiconfigobjects SET defaultvisibleind = 1 WHERE configobjectkey = @v_qsiconfigobjectkey	  
  UPDATE qsiconfigdetail SET visibleind = 1 WHERE configobjectkey = @v_qsiconfigobjectkey	
		
END
go
		