DECLARE 
	@v_itemtypecode INT,
	@v_usageclasscode INT,
	@v_role INT,
	@v_newkey INT
	
	SELECT @v_itemtypecode = datacode, @v_usageclasscode = datasubcode FROM subgentables where tableid = 550 and qsicode = 28
	
	  DECLARE work_gentablesitemtype_cur CURSOR FOR
		SELECT DISTINCT tr.rolecode  FROM taqprojectcontactrole tr
		WHERE tr.taqprojectcontactkey IN (
		Select taqprojectcontactkey from taqprojectcontact t INNER JOIN coreprojectinfo c ON t.taqprojectkey = c.projectkey  WHERE c.searchitemcode = @v_itemtypecode 
		AND usageclasscode = @v_usageclasscode) 
		AND NOT EXISTS (SELECT * from gentablesitemtype g WHERE tableid = 285 AND g.datacode = tr.rolecode AND g.itemtypecode = @v_itemtypecode AND
		 g.itemtypesubcode IN (@v_usageclasscode, 0))

	  OPEN work_gentablesitemtype_cur

	  FETCH NEXT FROM work_gentablesitemtype_cur INTO @v_role

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 285, @v_role, 0, @v_itemtypecode, @v_usageclasscode, 'QSIDBA', getdate())
        
		FETCH NEXT FROM work_gentablesitemtype_cur INTO @v_role
	  END

	  CLOSE work_gentablesitemtype_cur 
	  DEALLOCATE work_gentablesitemtype_cur