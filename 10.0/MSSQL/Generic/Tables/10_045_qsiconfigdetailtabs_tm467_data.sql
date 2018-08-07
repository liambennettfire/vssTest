DECLARE @v_count INT,
		@v_configobjectkey	INT,
		@v_configobjectid	VARCHAR(100),
		@v_itemtypecode		INT,
		@v_datacode         INT,
		@v_itemtypesubcode  INT	,
		@v_configdetailkey  INT,
		@v_sortorder		INT,
		@v_error_code		INT,
		@v_error_desc       VARCHAR(1000)

  -- this script is written to add any tabgroups that were not created during the initial conversion 97_014_qsiconfigdetailtabs_38527_conversion.sql

BEGIN
	DECLARE qsiconfigobjects_cur CURSOR FOR
		SELECT configobjectkey, configobjectid, itemtypecode
		  FROM qsiconfigobjects
		 WHERE configobjectdesc = 'Main Relationship Group'
		  ORDER BY configobjectkey ASC
			  
	OPEN qsiconfigobjects_cur
	
	FETCH NEXT FROM qsiconfigobjects_cur INTO @v_configobjectkey, @v_configobjectid, @v_itemtypecode

	WHILE (@@FETCH_STATUS = 0) BEGIN
	  DECLARE gentablesitemtype_cur CURSOR FOR
		SELECT i.datacode, i.itemtypesubcode, COALESCE(i.sortorder, g.sortorder)
		  FROM gentablesitemtype i
		  JOIN gentables g
		  ON i.tableid = g.tableid AND i.datacode = g.datacode
		 WHERE i.tableid = 583 
		   AND i.itemtypecode = @v_itemtypecode
		   AND (deletestatus <> 'Y' or deletestatus <> 'y')
		 ORDER BY i.datacode
	
		OPEN gentablesitemtype_cur
		
		FETCH NEXT FROM gentablesitemtype_cur INTO @v_datacode,@v_itemtypesubcode,@v_sortorder
		
		WHILE (@@FETCH_STATUS = 0) BEGIN
			--IF @v_itemtypesubcode > 0 BEGIN
				
				DECLARE configdetail_cur CURSOR FOR
				SELECT d.configdetailkey
				  FROM qsiconfigdetail d
				  JOIN qsiwindowview w
				  ON d.qsiwindowviewkey = w.qsiwindowviewkey
				 WHERE d.configobjectkey = @v_configobjectkey
				   AND (d.usageclasscode = @v_itemtypesubcode OR w.usageclasscode = @v_itemtypesubcode OR @v_itemtypesubcode = 0)

				OPEN configdetail_cur

				FETCH NEXT FROM configdetail_cur INTO @v_configdetailkey

				WHILE (@@FETCH_STATUS = 0) BEGIN
					SELECT @v_count = COUNT(*) FROM qsiconfigdetailtabs WHERE configdetailkey = @v_configdetailkey AND relationshiptabcode = @v_datacode
					
					IF COALESCE(@v_sortorder, 0) = 0
					BEGIN
						SET @v_sortorder = 1
					END

					IF @v_count = 0 BEGIN
						INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
							VALUES(@v_configdetailkey,@v_datacode,@v_sortorder,'QSIDBA',GETDATE())
							
						SELECT @v_error_code = @@ERROR
						IF @v_error_code <> 0 BEGIN
	  						SET @v_error_desc = 'Error occurred inserting into qsiconfigdetailtabs for ' + @v_configobjectid  
							print @v_error_desc
						END	
					END
					--ELSE BEGIN
					--	UPDATE qsiconfigdetailtabs
					--	SET sortorder = @v_sortorder,
					--		lastuserid = 'QSIDBA',
					--		lastmaintdate = GETDATE()
					--	WHERE configdetailkey = @v_configdetailkey AND relationshiptabcode = @v_datacode

					--	SELECT @v_error_code = @@ERROR
					--	IF @v_error_code <> 0 BEGIN
	  		--				SET @v_error_desc = 'Error occurred updating qsiconfigdetailtabs for ' + @v_configobjectid  
					--		print @v_error_desc
					--	END	
					--END

					FETCH NEXT FROM configdetail_cur INTO @v_configdetailkey
				END

				CLOSE configdetail_cur
				DEALLOCATE configdetail_cur
			--END
	
			FETCH NEXT FROM gentablesitemtype_cur INTO @v_datacode,@v_itemtypesubcode,@v_sortorder
		END  --gentablesitemtype_cur
		CLOSE gentablesitemtype_cur
		DEALLOCATE gentablesitemtype_cur
		
		FETCH NEXT FROM qsiconfigobjects_cur INTO @v_configobjectkey, @v_configobjectid, @v_itemtypecode
	END  --qsiconfigobjects_cur


	CLOSE qsiconfigobjects_cur
	DEALLOCATE qsiconfigobjects_cur
END 
go