-- Creating a backup table
IF OBJECT_ID('dbo.qsiconfigdetail_backup', 'U') IS NOT NULL BEGIN
  DROP TABLE dbo.qsiconfigdetail_backup
END  
  
SELECT *
INTO qsiconfigdetail_backup 
FROM qsiconfigdetail 

DECLARE   
	@v_configobjectkey INT,
	@v_qsiwindowviewkey INT, 
	@v_usageclasscode INT,
	@v_configobjecttype INT,
	@v_configdetailkey INT
  
  DECLARE crQsiConfigDetail CURSOR FOR
	select DISTINCT c1.configobjectkey, c1.qsiwindowviewkey, c1.usageclasscode, co.configobjecttype from qsiconfigdetail c1 INNER JOIN qsiconfigdetail c2 
	ON c1.qsiwindowviewkey = c2.qsiwindowviewkey AND c1.usageclasscode = c2.usageclasscode AND c1.configobjectkey = c2.configobjectkey AND c1.visibleind = c2.visibleind
	AND c1.configdetailkey <> c2.configdetailkey 
	INNER JOIN qsiconfigobjects co ON c1.configobjectkey = co.configobjectkey 
	AND c2.configobjectkey =  co.configobjectkey 
	AND c1.qsiwindowviewkey IS NOT NULL
	AND co.configobjecttype in (3,4,5)
	
  OPEN crQsiConfigDetail 

  FETCH NEXT FROM crQsiConfigDetail INTO @v_configobjectkey, @v_qsiwindowviewkey, @v_usageclasscode,@v_configobjecttype

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    SELECT TOP(1) @v_configdetailkey = configdetailkey FROM qsiconfigdetail WHERE configobjectkey = @v_configobjectkey AND qsiwindowviewkey = @v_qsiwindowviewkey AND usageclasscode = @v_usageclasscode
    
    IF @v_configdetailkey > 0 BEGIN
		DELETE FROM qsiconfigdetail 
		WHERE configobjectkey = @v_configobjectkey AND qsiwindowviewkey = @v_qsiwindowviewkey AND usageclasscode = @v_usageclasscode
		AND configdetailkey <> @v_configdetailkey
    END
	
    FETCH NEXT FROM crQsiConfigDetail INTO @v_configobjectkey, @v_qsiwindowviewkey, @v_usageclasscode,@v_configobjecttype
  END /* WHILE FECTHING */

  CLOSE crQsiConfigDetail 
  DEALLOCATE crQsiConfigDetail	
  
GO  