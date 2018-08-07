DECLARE
  @v_max_code INT,
  @v_datasubcode INT,
  @v_datadesc VARCHAR(40),
  @v_datadescshort VARCHAR(20),
  @v_datacode INT
 
  
BEGIN
   --Freight Terms 
   SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (525, @v_max_code, 'Freight Terms', 'N', 'MISCTABLES', 'Freight Terms', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
	  
	  
   SET @v_datasubcode =  1
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'FOB', 'N', 'MISCTABLES', NULL, 'FOB',
        'QSIDBA', getdate(), 1)
        
    SET @v_datasubcode =  2
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'CIF', 'N', 'MISCTABLES', NULL, 'CIF',
        'QSIDBA', getdate(), 1)
        
        
    SET @v_datasubcode =  3
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'EXWORKS', 'N', 'MISCTABLES', NULL, 'EXWORKS',
        'QSIDBA', getdate(), 1)
	  
	  
   --Import Country 
   SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (525, @v_max_code, 'Import Country', 'N', 'MISCTABLES', 'Import Country', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
	  
	  
	DECLARE cur CURSOR FOR
	  SELECT datacode, datadesc, datadescshort
	   FROM gentables
	  WHERE tableid = 114
	   ORDER BY datacode
	   
	OPEN cur
	   
	FETCH cur INTO @v_datacode, @v_datadesc ,  @v_datadescshort
		
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    --print '@v_max_code'
	    --print @v_max_code
	    --print '@v_datacode'
	    --print @v_datacode
	    
		INSERT INTO subgentables
		   (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
		   lastuserid, lastmaintdate, lockbyqsiind)
		 VALUES
			(525, @v_max_code,@v_datacode, @v_datadesc, 'N', 'MISCTABLES', NULL, @v_datadescshort,
			'QSIDBA', getdate(), 1)
	
		FETCH cur INTO @v_datacode, @v_datadesc ,  @v_datadescshort
	END
	
	CLOSE cur
	DEALLOCATE cur 
  
END 
go