DECLARE
  @v_max_code INT,
  @v_datasubcode INT
  
  
  
BEGIN
	--Report Specification Detail Type
    SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind,qsicode)
	VALUES
	  (525, @v_max_code, 'Report Specification Detail Type', 'N', 'MISCTABLES', 'Report Spec Detail', 'QSIDBA', GETDATE(), 0, 0, 1, 0,1)
  
  
    SET @v_datasubcode =  1
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind, qsicode)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'No Specification Details; Project/Title Info Only', 'N', 'MISCTABLES', NULL, 'No Spec Details',
        'QSIDBA', getdate(), 1,2)
        
    SET @v_datasubcode =  2
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind, qsicode)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'Summary Component Item Detail Only', 'N', 'MISCTABLES', NULL, 'Summary Component',
        'QSIDBA', getdate(), 1,3)
        
        
    SET @v_datasubcode =  3
      
    INSERT INTO subgentables
       (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
       lastuserid, lastmaintdate, lockbyqsiind, qsicode)
     VALUES
        (525, @v_max_code,@v_datasubcode, 'Specification Item Detail', 'N', 'MISCTABLES', NULL, 'Spec. Item Detail',
        'QSIDBA', getdate(), 1,4)
        
        
        
   --FOB (qsicode = 11)
   SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind,qsicode)
	VALUES
	  (525, @v_max_code, 'FOB', 'N', 'MISCTABLES', 'FOB', 'QSIDBA', GETDATE(), 0, 0, 1, 0,11)
	  
	  
   --Net Days (qsicode = 12)
   SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind,qsicode)
	VALUES
	  (525, @v_max_code, 'Net Days', 'N', 'MISCTABLES', 'Net Days', 'QSIDBA', GETDATE(), 0, 0, 1, 0,12)
	  
	  
   --Vendor ID (qsicode = 12)
   SELECT @v_max_code = MAX(datacode)
      FROM gentables
     WHERE tableid = 525
     
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SET @v_max_code = @v_max_code + 1

	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind,qsicode)
	VALUES
	  (525, @v_max_code, 'Vendor ID', 'N', 'MISCTABLES', 'Vendor ID', 'QSIDBA', GETDATE(), 0, 0, 1, 0,13)
   
END 
go