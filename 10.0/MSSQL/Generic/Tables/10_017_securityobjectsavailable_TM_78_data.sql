DECLARE
	@v_windowid_title INT,
	@v_availobjectid VARCHAR(50),
	@v_availobjectdesc VARCHAR(50),
	@v_availablesecurityobjectskey INT

SELECT @v_windowid_title = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'productsummary'

-- Production Spec Section
SET @v_availobjectid = 'shProdSpecs'
SET @v_availobjectdesc = 'Specifications - ALL'

IF NOT EXISTS (SELECT * FROM securityobjectsavailable WHERE windowid = @v_windowid_title AND LTRIM(RTRIM(LOWER(availobjectid))) = LTRIM(RTRIM(LOWER(@v_availobjectid))) AND LTRIM(RTRIM(LOWER(availobjectdesc))) = LTRIM(RTRIM(LOWER(@v_availobjectdesc)))) BEGIN
    exec get_next_key 'qsidba', @v_availablesecurityobjectskey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind,defaultaccesscode,criteriakey)
    values ( @v_availablesecurityobjectskey, @v_windowid_title, @v_availobjectid, null, @v_availobjectdesc, 1, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null, null, null) 
END

-- Citations Section
SET @v_availobjectid = 'shTitleCitations'
SET @v_availobjectdesc = 'Citations - ALL'

IF NOT EXISTS (SELECT * FROM securityobjectsavailable WHERE windowid = @v_windowid_title AND LTRIM(RTRIM(LOWER(availobjectid))) = LTRIM(RTRIM(LOWER(@v_availobjectid))) AND LTRIM(RTRIM(LOWER(availobjectdesc))) = LTRIM(RTRIM(LOWER(@v_availobjectdesc)))) BEGIN
    exec get_next_key 'qsidba', @v_availablesecurityobjectskey output
    insert into securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,
                sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,
                availobjectcodetableid,allowadmintochoosevalueind,defaultaccesscode,criteriakey)
    values ( @v_availablesecurityobjectskey, @v_windowid_title, @v_availobjectid, null, @v_availobjectdesc, 1, null, null, null, 'QSIADMIN', getdate(), null, 0, null, null, null, null) 
END



