DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 285 AND LOWER(datadesc) = 'production manager'
    AND deletestatus = 'N'
    AND qsicode is NULL
  
  IF @v_count = 1
  BEGIN
    UPDATE gentables
       SET qsicode = 22
     WHERE tableid = 285
       AND LOWER(datadesc) = 'production manager'
       AND deletestatus = 'N'
       AND qsicode is NULL
  END    
END
go