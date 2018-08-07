DECLARE @v_count INT
DECLARE @v_count2 INT
DECLARE @v_windowid INT
DECLARE @v_windowid_new_1 INT
DECLARE @v_windowid_new_2 INT
DECLARE @v_availablesecurityobjectkey INT
DECLARE @v_availablesecurityobjectskey_new_1 INT
DECLARE @v_availablesecurityobjectskey_new_2 INT
DECLARE @v_availsecurityobjectkey INT
DECLARE @v_securityobjectkey  INT
DECLARE @v_securitygroupkey INT
DECLARE @v_userkey  INT
DECLARE @v_securitystatustypekey INT 
DECLARE @v_securityobjectvalue INT
DECLARE @v_accessind SMALLINT
DECLARE @v_firstprintingind CHAR(1)
DECLARE @v_lastuserid VARCHAR(30)
DECLARE @v_lastmaintdate datetime
DECLARE @v_datacode INT
DECLARE @v_datasubcode  INT
DECLARE @v_securityobjectsubvalue INT

BEGIN

     SELECT @v_windowid = windowid
     FROM qsiwindows
     WHERE windowname = 'PrintingSummary'
    
     SELECT  @v_availablesecurityobjectkey = availablesecurityobjectskey
     FROM securityobjectsavailable 
     WHERE windowid = @v_windowid AND
		   availobjectid = 'shTitleTasks'
		   
     SELECT @v_windowid_new_1 = windowid
     FROM qsiwindows
     WHERE windowname = 'POSummary' AND 
           windowcategoryid = 133      
      
     SELECT @v_availablesecurityobjectskey_new_1 = availablesecurityobjectskey
     FROM securityobjectsavailable
     WHERE windowid = @v_windowid_new_1 and 
           availobjectid = 'shTitleTasks' 		   
    
     DECLARE securityobjects_cursor CURSOR FAST_FORWARD FOR
			SELECT securityobjectkey, securitygroupkey, userkey, securitystatustypekey, securityobjectvalue, accessind, firstprintingind, 
				   lastuserid, lastmaintdate, datacode, datasubcode, securityobjectsubvalue
			  FROM securityobjects WHERE availsecurityobjectkey = @v_availablesecurityobjectkey

    OPEN securityobjects_cursor
	FETCH NEXT FROM securityobjects_cursor INTO @v_securityobjectkey, @v_securitygroupkey, @v_userkey, @v_securitystatustypekey, @v_securityobjectvalue, @v_accessind, 
			       @v_firstprintingind, @v_lastuserid, @v_lastmaintdate, @v_datacode, @v_datasubcode, @v_securityobjectsubvalue
		
	WHILE @@fetch_status = 0
	BEGIN
   --- Set Information  
	  EXEC dbo.get_next_key 'QSIDBA', @v_securityobjectkey OUTPUT

	  INSERT INTO securityobjects (securityobjectkey, availsecurityobjectkey, securitygroupkey, userkey, securitystatustypekey,
		securityobjectvalue, accessind, firstprintingind, lastuserid, lastmaintdate, datacode, datasubcode, securityobjectsubvalue)
		VALUES(@v_securityobjectkey,@v_availablesecurityobjectskey_new_1,@v_securitygroupkey,@v_userkey,@v_securitystatustypekey,
		  @v_securityobjectvalue, @v_accessind,@v_firstprintingind,'QSIDBA',getdate(),@v_datacode,@v_datasubcode,@v_securityobjectsubvalue)
	   
   FETCH NEXT FROM securityobjects_cursor INTO @v_securityobjectkey, @v_securitygroupkey, @v_userkey, @v_securitystatustypekey, @v_securityobjectvalue, @v_accessind, 
												@v_firstprintingind, @v_lastuserid, @v_lastmaintdate, @v_datacode, @v_datasubcode, @v_securityobjectsubvalue
   END
   CLOSE securityobjects_cursor
   DEALLOCATE securityobjects_cursor       
    
END

go

DECLARE @v_count INT
DECLARE @v_count2 INT
DECLARE @v_windowid INT
DECLARE @v_windowid_new_1 INT
DECLARE @v_windowid_new_2 INT
DECLARE @v_availablesecurityobjectkey INT
DECLARE @v_availablesecurityobjectskey_new_1 INT
DECLARE @v_availablesecurityobjectskey_new_2 INT
DECLARE @v_availsecurityobjectkey INT
DECLARE @v_securityobjectkey  INT
DECLARE @v_securitygroupkey INT
DECLARE @v_userkey  INT
DECLARE @v_securitystatustypekey INT 
DECLARE @v_securityobjectvalue INT
DECLARE @v_accessind SMALLINT
DECLARE @v_firstprintingind CHAR(1)
DECLARE @v_lastuserid VARCHAR(30)
DECLARE @v_lastmaintdate datetime
DECLARE @v_datacode INT
DECLARE @v_datasubcode  INT
DECLARE @v_securityobjectsubvalue INT

BEGIN

     SELECT @v_windowid = windowid
     FROM qsiwindows
     WHERE windowname = 'PrintingSummary'
    
     SELECT  @v_availablesecurityobjectkey = availablesecurityobjectskey
     FROM securityobjectsavailable 
     WHERE windowid = @v_windowid AND
		   availobjectid = 'shKeyDates'
		   
     SELECT @v_windowid_new_1 = windowid
     FROM qsiwindows
     WHERE windowname = 'POSummary' AND 
           windowcategoryid = 133      
      
     SELECT @v_availablesecurityobjectskey_new_1 = availablesecurityobjectskey
     FROM securityobjectsavailable
     WHERE windowid = @v_windowid_new_1 and 
           availobjectid = 'shKeyDates' 		   
    
     DECLARE securityobjects_cursor CURSOR FAST_FORWARD FOR
			SELECT securityobjectkey, securitygroupkey, userkey, securitystatustypekey, securityobjectvalue, accessind, firstprintingind, 
				   lastuserid, lastmaintdate, datacode, datasubcode, securityobjectsubvalue
			  FROM securityobjects WHERE availsecurityobjectkey = @v_availablesecurityobjectkey

    OPEN securityobjects_cursor
	FETCH NEXT FROM securityobjects_cursor INTO @v_securityobjectkey, @v_securitygroupkey, @v_userkey, @v_securitystatustypekey, @v_securityobjectvalue, @v_accessind, 
			       @v_firstprintingind, @v_lastuserid, @v_lastmaintdate, @v_datacode, @v_datasubcode, @v_securityobjectsubvalue
		
	WHILE @@fetch_status = 0
	BEGIN
   --- Set Information  
	  EXEC dbo.get_next_key 'QSIDBA', @v_securityobjectkey OUTPUT

	  INSERT INTO securityobjects (securityobjectkey, availsecurityobjectkey, securitygroupkey, userkey, securitystatustypekey,
		securityobjectvalue, accessind, firstprintingind, lastuserid, lastmaintdate, datacode, datasubcode, securityobjectsubvalue)
		VALUES(@v_securityobjectkey,@v_availablesecurityobjectskey_new_1,@v_securitygroupkey,@v_userkey,@v_securitystatustypekey,
		  @v_securityobjectvalue, @v_accessind,@v_firstprintingind,'QSIDBA',getdate(),@v_datacode,@v_datasubcode,@v_securityobjectsubvalue)
	   
   FETCH NEXT FROM securityobjects_cursor INTO @v_securityobjectkey, @v_securitygroupkey, @v_userkey, @v_securitystatustypekey, @v_securityobjectvalue, @v_accessind, 
												@v_firstprintingind, @v_lastuserid, @v_lastmaintdate, @v_datacode, @v_datasubcode, @v_securityobjectsubvalue
   END
   CLOSE securityobjects_cursor
   DEALLOCATE securityobjects_cursor       
    
END

go