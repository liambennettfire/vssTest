DECLARE
  @v_dateype_expectedshipdate int,
  @v_datetypecode INT,
  @v_count	INT,
  @v_newkey	INT,
  @v_max_code INT,
  @v_datacode_ParticipantsByRole1 INT,
  @v_datacode_ParticipantsByRole2 INT,
  @v_datacode_ParticipantsByRole3 INT,
  @v_datasubcode INT,
  @v_itemtypecode INT,
  @v_usageclass INT,
  @v_relateddatacode INT
  
BEGIN
  -- Check for 'expected ship date' with the wrong qsicode
  SELECT @v_dateype_expectedshipdate = datetypecode
    FROM datetype
   WHERE LOWER(description) = 'expected ship date'
     AND COALESCE(qsicode,0) <> 9
   
  IF @v_dateype_expectedshipdate > 0 BEGIN  
    -- back out changes from 90_221_gentablesitetype636_29155_data.sql
    SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
      FROM subgentables
     WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders 
   
    SET @v_datasubcode = 11 -- Date
  
    SET @v_datacode_ParticipantsByRole1 = 6
    SET @v_datacode_ParticipantsByRole2 = 7
    SET @v_datacode_ParticipantsByRole3 = 8 
  
    DELETE FROM gentablesitemtype
     WHERE tableid = 636  
	     AND itemtypecode = @v_itemtypecode  
	     AND itemtypesubcode = @v_usageclass 
	     AND datacode = @v_datacode_ParticipantsByRole2 
	     AND datasubcode = @v_datasubcode
	     AND relateddatacode = @v_dateype_expectedshipdate
  
    UPDATE datetype
       SET qsicode = 9
     WHERE datetypecode = @v_dateype_expectedshipdate

    -- redo 90_221_gentablesitetype636_29155_data.sql if needed
    SELECT @v_count = COUNT(*) FROM datetype where tableid = 323 and qsicode = 23

    IF @v_count = 0 BEGIN
      SELECT @v_count = COUNT(*) FROM datetype where tableid = 323 and LOWER(description) = 'ship date'

      IF @v_count > 0 BEGIN
	      SELECT  TOP(1) @v_datetypecode = datetypecode FROM datetype where tableid = 323 and LOWER(description) = 'ship date'	
	      UPDATE datetype SET qsicode = 23 WHERE datetypecode = @v_datetypecode AND tableid = 323 
      END
      ELSE BEGIN 
        -- Ship Date
        SELECT @v_max_code = MAX(datetypecode)
        FROM datetype
        WHERE datetypecode < 20000
        
        IF @v_max_code IS NULL
	        SET @v_max_code = 0

        SELECT @v_max_code = @v_max_code + 1

        INSERT INTO datetype
          (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
          tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
          sortorder, showintaqind,
          taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
        VALUES
          (@v_max_code, 'Ship Date', 0, 0, 'Ship Date', 'Ship Date',
          323, 'QSIDBA', getdate(), 0, 0, 0, 0, 
          0, 0,
          0,0,0,1,23)    		  
      END 
    END
     
    SELECT @v_relateddatacode = datetypecode FROM datetype where tableid = 323 AND qsicode = 23

    SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
    FROM subgentables
    WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders 
   
    SET @v_datasubcode = 11 -- Date
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
    itemtypecode = @v_itemtypecode AND 
    itemtypesubcode = @v_usageclass AND
    datacode = @v_datacode_ParticipantsByRole2 AND
    datasubcode = @v_datasubcode
  	  
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  	  
      INSERT INTO gentablesitemtype
	    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1, relateddatacode)
      VALUES
	    (@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 8, NULL, @v_relateddatacode)
    END      
    ELSE BEGIN
      UPDATE gentablesitemtype SET relateddatacode = @v_relateddatacode WHERE tableid = 636 AND itemtypecode = @v_itemtypecode AND itemtypesubcode = @v_usageclass
	       AND datacode = @v_datacode_ParticipantsByRole2 AND datasubcode = @v_datasubcode
    END
  END
  ELSE BEGIN
    -- Check that there is a row with qsicode = 9 at all
    SELECT @v_count = COUNT(*) FROM datetype where tableid = 323 and qsicode = 9
    IF @v_count = 0 BEGIN
        -- Expected Ship Date
      SELECT @v_max_code = MAX(datetypecode)
      FROM datetype
      WHERE datetypecode < 20000
        
      IF @v_max_code IS NULL
        SET @v_max_code = 0

      SELECT @v_max_code = @v_max_code + 1

      INSERT INTO datetype
          (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
          tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
          sortorder, showintaqind,
          taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
      VALUES
          (@v_max_code, 'Expected Ship Date', 0, 0, 'Expected Ship Date', 'ExpShipDat',
          323, 'QSIDBA', getdate(), 0, 0, 0, 0, 
          0, 0,
          0,0,0,1,9)    		  
    END
  END
END
go
