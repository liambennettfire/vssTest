DECLARE
@v_gentablesrelationshipkey INT    
	
	DECLARE cur CURSOR FOR
    SELECT DISTINCT gentablesrelationshipkey
    FROM gentablesrelationships
    WHERE LOWER(description) like '%project relationship tab%'
                    
    OPEN cur
             
    FETCH NEXT FROM cur INTO @v_gentablesrelationshipkey
             
    WHILE @@FETCH_STATUS = 0
    BEGIN

     UPDATE gentablesrelationships
	 SET description = replace(description, 'Project Relationship Tab' , 'Web Relationship Tab')
	  WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
	                    
      FETCH NEXT FROM cur INTO @v_gentablesrelationshipkey
    END
             
    CLOSE cur
    DEALLOCATE cur

