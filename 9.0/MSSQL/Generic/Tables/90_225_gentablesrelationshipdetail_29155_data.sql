DECLARE
  @v_count  INT,
  @v_newkey INT,
  @v_relationship_code  INT,
  @v_webtab  INT,
  @v_code2  INT   
  
BEGIN
  -- Role Type to Contact Comment Type Mapping
  
 -- Role: Shipping Location 
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 285 AND
    qsicode = 17  
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_code2 = datacode
    FROM gentables
    WHERE tableid = 528 AND qsicode = 10 -- Shipping Instructions 
    
    IF @v_code2 > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 28 AND   --Role Type to Contact Comment Type
        code1 = @v_relationship_code AND
        code2 = @v_code2
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, subcode2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (28, @v_newkey,@v_relationship_code, @v_code2, 0, 1, 'QSIDBA', getdate())
      END
    END
  END  

 -- Role: Shipping Location (Rarely Used) 
  SET @v_relationship_code = 0
  SELECT @v_relationship_code = datacode
  FROM gentables
  WHERE tableid = 285 AND
    qsicode = 18  
  
  IF @v_relationship_code > 0
  BEGIN
    
    SELECT @v_code2 = datacode
    FROM gentables
    WHERE tableid = 528 AND qsicode = 10 -- Shipping Instructions 
    
    IF @v_code2 > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 28 AND   --Role Type to Contact Comment Type
        code1 = @v_relationship_code AND
        code2 = @v_code2
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, subcode2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (28, @v_newkey,@v_relationship_code, @v_code2, 0, 1, 'QSIDBA', getdate())                  
      END
    END
  END
END   
go