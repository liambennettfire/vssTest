IF EXISTS(select * from qsiconfigobjects 
	WHERE LTRIM(RTRIM(LOWER(configobjectid))) = 'linkuploadwebcatalog') BEGIN
	
	UPDATE qsiconfigobjects SET configobjectid = 'linkUploadProject', configobjectdesc = 'Upload Project'
	WHERE LTRIM(RTRIM(LOWER(configobjectid))) = 'linkuploadwebcatalog'
	
	IF EXISTS(SELECT * from qsiconfigdetail 
	WHERE configobjectkey IN (SELECT configobjectkey FROM qsiconfigobjects
	 WHERE LTRIM(RTRIM(LOWER(configobjectid))) = 'linkuploadwebcatalog')) BEGIN
	
		UPDATE qsiconfigdetail SET labeldesc = 'Upload Project' 
		WHERE configobjectkey IN (SELECT configobjectkey FROM qsiconfigobjects
			WHERE LTRIM(RTRIM(LOWER(configobjectid))) = 'linkuploadwebcatalog')		
	END
END