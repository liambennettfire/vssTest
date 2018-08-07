DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_numericdesc1 INT,
  @v_alternatedesc2 VARCHAR(255),
  @v_jobnumber INT ,
  @v_jobnumberalpha char(7),
  @v_jobnumber_temp char(6) ,
  @v_jobnumber_zeros char(6)       
    
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 594
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 594 AND qsicode = 14
        
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 594 AND LOWER(datadesc) = 'Job Number Alpha' AND qsicode = 14
  
  IF @v_count = 0
  BEGIN
  
   SELECT @v_jobnumberalpha = COALESCE(jobnumberseq,NULL)  FROM defaults
  
   IF    @v_jobnumberalpha <> '' AND @v_jobnumberalpha IS NOT NULL BEGIN
  
	   SELECT @v_jobnumber_temp = SUBSTRING(@v_jobnumberalpha,2,6)	

	  SELECT @v_jobnumber = CONVERT(NUMERIC(6,0),@v_jobnumber_temp)

	  SELECT @v_jobnumber = @v_jobnumber + 1
  END 

   --SET @v_alternatedesc2 = 'qprinting_get_next_jobnumber_alpha'
        
   SET @v_max_code = @v_max_code + 1
    
  
     IF    @v_jobnumberalpha <> '' AND @v_jobnumberalpha IS NOT NULL BEGIN    
		INSERT INTO gentables
		  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
		  lastuserid, lastmaintdate, numericdesc1,alternatedesc2,qsicode, lockbyqsiind, lockbyeloquenceind,gen2ind)
		VALUES
		  (594, @v_max_code, 'Job Number Alpha', 'Y', 'Project/ElementIDType', 'Job Number',
		  'QSIDBA', getdate(), @v_jobnumber,NULL,14, 0, 0,0)
	END
	ELSE BEGIN
		INSERT INTO gentables
		  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
		  lastuserid, lastmaintdate, numericdesc1,alternatedesc2,qsicode, lockbyqsiind, lockbyeloquenceind,gen2ind)
		VALUES
		  (594, @v_max_code, 'Job Number Alpha', 'Y', 'Project/ElementIDType', 'Job Number',
		  'QSIDBA', getdate(), 'J000001',@v_alternatedesc2,14, 0, 0,0)
	END 
  END

END
go
