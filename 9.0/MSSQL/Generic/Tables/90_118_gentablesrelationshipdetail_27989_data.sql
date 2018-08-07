DECLARE
  @v_count  INT,
  @v_newkey INT,
  @v_relationship_code  INT,
  @v_webtab  INT,
  @v_tab_code  INT  
  
BEGIN
  -- Project Relationship to Project Relationship Tab Mapping
  -- 'Printing (for Purchase Orders)'  
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 25  --Printing (for Purchase Orders)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 32 --Purchase Orders (on Printings)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey,@v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

    
  
    IF @v_relationship_code > 0
    BEGIN
     SELECT @v_tab_code = datacode
	   FROM gentables
	  WHERE tableid = 583 AND qsicode = 33 --Printings (on Purchase Orders)
	    
	 IF @v_tab_code > 0
    
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey,@v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

  END
  
  -- --Purchase Orders (for Printings)  
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 26  --Purchase Orders (for Printings)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 32 --Purchase Orders (on Printings)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey,@v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END
  
    IF @v_relationship_code > 0
    BEGIN
     SELECT @v_tab_code = datacode
	   FROM gentables
	  WHERE tableid = 583 AND qsicode = 33 --Printings (on Purchase Orders)
	    
	 IF @v_tab_code > 0
    
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey, @v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

  END

  -- Project Relationships of 'Purchase Orders (for PO Reports)' to tab 'Purchase Orders (on Printings) and 'PO Reports'
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 27  --Purchase Orders (for PO Reports)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 34 --Purchase Orders (on PO Reports)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey, @v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

    
  
    IF @v_relationship_code > 0
    BEGIN
     SELECT @v_tab_code = datacode
	   FROM gentables
	  WHERE tableid = 583 AND qsicode = 35 --PO Reports
	    
	 IF @v_tab_code > 0
    
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey,@v_relationship_code,  @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

  END
  
  -- Project Relationships of 'PO Reports' to tab 'Purchase Orders (on PO Reports) and 'PO Reports'
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 28  --PO Report
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 34 --Purchase Orders (on PO Reports)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey, @v_relationship_code,  @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END
 
    IF @v_relationship_code > 0
    BEGIN
     SELECT @v_tab_code = datacode
	   FROM gentables
	  WHERE tableid = 583 AND qsicode = 35 --PO Reports
	    
	 IF @v_tab_code > 0
    
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (6, @v_newkey, @v_relationship_code,  @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END

  END
  
  -- Project Relationship to Project Relationship Mapping
  -- Relate Project relationship  'Printing (for Purchase Orders)' to  'Purchase Orders (for Printings)'
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 25  --Printing (for Purchase Orders)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 582 AND qsicode = 26 --Purchase Orders (for Printings)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 5 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (5, @v_newkey, @v_relationship_code, @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END
  END
  
  
  -- Project Relationships of 'Purchase Orders (for PO Reports)' to 'PO Reports'
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 582 AND
    qsicode = 27  --Purchase Orders (for PO Reports)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 582 AND qsicode = 28 --PO Report
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 5 AND   --Project Relationship to Project Relationship
        code1 = @v_relationship_code AND
        code2 = @v_tab_code
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (5, @v_newkey, @v_relationship_code,  @v_tab_code, 1, 'QSIDBA', getdate())
      END
    END
  END
END   

go
