DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtype INT,
  @v_usageclass INT
  
BEGIN

  -- Purchase Orders Reports:    
  DECLARE outer_cur CURSOR FOR
	SELECT datacode, datasubcode
	FROM subgentables WHERE tableid = 550 AND qsicode IN (42, 43)

  OPEN outer_cur
  
  FETCH NEXT FROM outer_cur INTO @v_itemtype, @v_usageclass

  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
  
	  DECLARE inner_cur CURSOR FOR
		SELECT datacode
		FROM gentables WHERE tableid = 594 AND qsicode IN (7, 13)

	  OPEN inner_cur
	  
	  FETCH NEXT FROM inner_cur INTO @v_datacode

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 594 AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass) BEGIN
			  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
		      
			  INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
			  VALUES
				(@v_newkey, 594, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
		  END  
	    
		FETCH NEXT FROM inner_cur INTO @v_datacode
	  END

	  CLOSE inner_cur 
	  DEALLOCATE inner_cur  
    
	FETCH NEXT FROM outer_cur INTO @v_itemtype, @v_usageclass
  END

  CLOSE outer_cur 
  DEALLOCATE outer_cur  
  
END
go