DECLARE
  @v_count	INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_defaultind TINYINT,
  @v_newkey	INT,  
  @v_reldatacode INT,
  @v_sortorder	INT
  
BEGIN

  DECLARE genitemtype_cur CURSOR FOR
    SELECT datasubcode, defaultind, sortorder, relateddatacode 
    FROM gentablesitemtype 
    WHERE tableid = 636 AND datacode = 4 AND itemtypecode = 3
  		
  OPEN genitemtype_cur

  FETCH genitemtype_cur INTO @v_datasubcode, @v_defaultind, @v_sortorder, @v_reldatacode

  WHILE @@fetch_status = 0
  BEGIN
  
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 4 AND datasubcode = @v_datasubcode AND itemtypecode = 5
    
    IF @v_count = 0
    BEGIN    
	  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, defaultind,
        lastuserid, lastmaintdate, sortorder, relateddatacode)
      VALUES
	    (@v_newkey, 636, 4, @v_datasubcode, 5, 0, @v_defaultind, 'FIREBRAND', GETDATE(), @v_sortorder, @v_reldatacode)
	END

    FETCH genitemtype_cur INTO @v_datasubcode, @v_defaultind, @v_sortorder, @v_reldatacode
  END
  
  CLOSE genitemtype_cur 
  DEALLOCATE genitemtype_cur
  
  
  DECLARE genitemtype_cur CURSOR FOR
    SELECT datacode, datasubcode, defaultind, sortorder, relateddatacode 
    FROM gentablesitemtype 
    WHERE tableid = 616 AND itemtypecode = 3
  		
  OPEN genitemtype_cur

  FETCH genitemtype_cur INTO @v_datacode, @v_datasubcode, @v_defaultind, @v_sortorder, @v_reldatacode

  WHILE @@fetch_status = 0
  BEGIN
  
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 616 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = 5
    
    IF @v_count = 0
    BEGIN 
	  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, defaultind,
        lastuserid, lastmaintdate, sortorder, relateddatacode)
      VALUES
	    (@v_newkey, 616, @v_datacode, @v_datasubcode, 5, 0, @v_defaultind, 
	    'FIREBRAND', GETDATE(), @v_sortorder, @v_reldatacode)
	END

    FETCH genitemtype_cur INTO @v_datacode, @v_datasubcode, @v_defaultind, @v_sortorder, @v_reldatacode
  END
  
  CLOSE genitemtype_cur 
  DEALLOCATE genitemtype_cur  
  
END
go
