DECLARE
  @v_count  INT,
  @v_newkey INT,
  @v_role  INT,
  @v_webtab  INT,
  @v_projecttype  INT  
  
BEGIN
  SET @v_role = 0
  SELECT @v_role = datacode
  FROM gentables
  WHERE tableid = 604 AND qsicode = 3

  IF @v_role > 0
  BEGIN
  SET @v_webtab = 0
  SELECT @v_webtab = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 31

  IF @v_webtab > 0
  BEGIN
	SELECT @v_count = COUNT(*)
	FROM gentablesrelationshipdetail
	WHERE gentablesrelationshipkey = 10 AND
	  code1 = @v_role AND
	  code2 = @v_webtab 
  
		IF @v_count = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	    
		  INSERT INTO gentablesrelationshipdetail
			(gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
		  VALUES
			(10, @v_newkey, @v_role, @v_webtab,  1, 'QSIDBA', getdate())
		END
   END
  END
   
  SET @v_role = 0
  SELECT @v_role = datacode
  FROM gentables
  WHERE tableid = 605 AND qsicode = 7
  
  IF @v_role > 0
  BEGIN
    SET @v_webtab = 0
    SELECT @v_webtab = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 31

    IF @v_webtab > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesrelationshipdetail
      WHERE gentablesrelationshipkey = 11 AND
        code1 = @v_role AND
        code2 = @v_webtab 
      
      IF @v_count = 0
      BEGIN
        EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
        INSERT INTO gentablesrelationshipdetail
          (gentablesrelationshipkey, gentablesrelationshipdetailkey, code1, code2, defaultind, lastuserid, lastmaintdate)
        VALUES
          (11, @v_newkey, @v_role, @v_webtab,  1, 'QSIDBA', getdate())
      END
    END   
  END   
END
go
