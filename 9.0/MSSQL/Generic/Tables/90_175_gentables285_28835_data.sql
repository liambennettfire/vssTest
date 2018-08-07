DECLARE   @v_count              int
DECLARE   @v_datacode           int
DECLARE   @v_datasubcode        int
DECLARE   @v_tableid            int
DECLARE   @v_datadesc           varchar(120)
DECLARE   @v_datadescshort      varchar(20)
DECLARE   @v_tablemnemonic      varchar(40)
DECLARE   @v_alternatedesc1     varchar(255)
DECLARE   @v_alternatedesc2     varchar(255)
DECLARE   @v_newkey             int
DECLARE   @v_numericdesc1       int
DECLARE   @v_numericdesc2       int
DECLARE   @v_itemtypecode       int
DECLARE   @v_itemtypesubcode    int
DECLARE   @v_qsicode            int
DECLARE   @v_deletestatus		varchar(1)

BEGIN
  SET @v_tableid = 285
  SET @v_tablemnemonic = 'ROLETYPE'
  SET @v_qsicode = 17

  SELECT @v_datacode = max(datacode)
    FROM gentables
   WHERE tableid = @v_tableid

  IF @v_datacode = 0 BEGIN
    SET @v_datacode = 1
  END
  ELSE BEGIN
  	SET @v_datacode = @v_datacode + 1
  END
  
  SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND datadesc = 'Ship to'
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Ship to'
    SET @v_datadescshort = 'Ship to'
    
    
    
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND datadesc = 'Ship to'

      UPDATE gentables
	     SET qsicode = @v_qsicode
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END

  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 15 and itemtypesubcode = 1) BEGIN
	  -- add it to gentablesitemtype for Titles
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 1, 0, 'INITDATA', getdate(), null)
	END
	
   IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 15 and itemtypesubcode = 2) BEGIN
		 -- add it to gentablesitemtype for Projects
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 2, 0, 'INITDATA', getdate(), null)
	END
	
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 1 and itemtypesubcode = 3) BEGIN
		-- add it to gentablesitemtype for Contacts
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 3, 0, 'INITDATA', getdate(), null)
   END
   
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND qsicode = 15 --Vendor
     
   IF @v_count = 1 BEGIN
   
    SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND qsicode = 15
   
	IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 15 and itemtypesubcode = 1) BEGIN
	  -- add it to gentablesitemtype for Titles
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 1, 0, 'INITDATA', getdate(), null)
		END
		
	   IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 15 and itemtypesubcode = 2) BEGIN
			 -- add it to gentablesitemtype for Projects
			 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
		
			 INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
				 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
			 VALUES
				(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 2, 0, 'INITDATA', getdate(), null)
		END
		
	  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = 1 and itemtypesubcode = 3) BEGIN
			-- add it to gentablesitemtype for Contacts
			 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
		
			 INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
				 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
			 VALUES
				(@v_newkey, @v_tableid, @v_datacode, 0, 0, 15, 3, 0, 'INITDATA', getdate(), null)
	   END
   END
END
go