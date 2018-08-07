DECLARE
	@v_windowid_title INT,
	@v_windowid_project INT,
	@v_availobjectid VARCHAR(50),
	@v_availobjectname VARCHAR(50),
	@v_searchcriteriakey INT,
	@sortNum INT,
	@availSecurityObjectsKey INT
	
SELECT @v_windowid_project = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'PLVersionDetails'	
SELECT @sortNum = ( SELECT max(sortorder) FROM securityobjectsavailable WHERE windowid = @v_windowid_project) 

  IF ( @sortNum is null ) SELECT @sortNum = 0


-- PL Production Costs By Prtg
SET @v_availobjectid = 'PLVerProductionCostsByPrtg'
SET @v_availobjectname = 'GenerateCosts'
SET @v_searchcriteriakey = NULL

IF EXISTS (SELECT * FROM securityobjectsavailable WHERE windowid = @v_windowid_project AND LTRIM(RTRIM(LOWER(availobjectid))) = LTRIM(RTRIM(LOWER(@v_availobjectid))) AND LTRIM(RTRIM(LOWER(availobjectname))) = LTRIM(RTRIM(LOWER(@v_availobjectname)))) BEGIN
	UPDATE securityobjectsavailable SET criteriakey = @v_searchcriteriakey, availobjectcodetableid = NULL, allowadmintochoosevalueind = NULL, defaultaccesscode = NULL,  availobjectwholerowind = 0, availobjectdesc = 'Generate Costs'
	WHERE windowid = @v_windowid_project AND 
		  LTRIM(RTRIM(LOWER(availobjectid))) = LTRIM(RTRIM(LOWER(@v_availobjectid))) AND 
		  LTRIM(RTRIM(LOWER(availobjectname))) = LTRIM(RTRIM(LOWER(@v_availobjectname)))
		  
END
ELSE BEGIN
    SET @sortNum = @sortNum + 1
    exec get_next_key 'qsidba', @availSecurityObjectsKey output
    
    INSERT INTO securityobjectsavailable 
	    (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, 
		 menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, availobjectwholerowind,
         availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
    VALUES 
	    (@availSecurityObjectsKey, @v_windowid_project, @v_availobjectid, @v_availobjectname, 'Generate Costs', @sortNum, 
		  null, null, null, 'QSIADMIN', getdate(), null, 0, 
		  NULL, NULL, NULL) 
END

GO