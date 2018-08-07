DECLARE
  @v_count  INT,
  @v_newkey INT,
  @v_relationship_code  INT,
  @v_webtab  INT,
  @v_tab_code  INT  
  
BEGIN
  -- Project Relationship to Web Relationship Tab Mapping
  -- 'Printing (for PO Reports)'  
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables  WHERE tableid = 582 AND
    qsicode = 29  --Printing (for PO Reports)
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 36 -- Printings (on PO Reports)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Web Relationship Tab
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

  -- 'PO Reports (for Printing )'  
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables  WHERE tableid = 582 AND
    qsicode = 30  
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_tab_code = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 36 -- Printings (on PO Reports)
    
    IF @v_tab_code > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 6 AND   --Project Relationship to Web Relationship Tab
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
  

END   

go
