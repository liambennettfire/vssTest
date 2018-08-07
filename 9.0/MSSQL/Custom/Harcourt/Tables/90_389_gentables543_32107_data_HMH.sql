DECLARE  
	@o_error_code INT, 
	@o_error_desc VARCHAR(2000), 
	@o_datacode INT, 
	@o_datasubcode INT,
	@v_tablemnemonic VARCHAR(40),
	@v_tableid INT,
	@v_usageclasscode INT,
	@v_itemtypecode INT
	
SET @o_error_desc = ''
SET @o_error_code = 0
SET @o_datacode = 0
SET @o_datasubcode = 0

SELECT @v_tableid = 543

SELECT @v_tablemnemonic = tablemnemonic FROM gentablesdesc WHERE tableid = @v_tableid

EXEC qutl_insert_gentable_value @v_tableid,@v_tablemnemonic,NULL,'HMH Mktg Campaign Creation',NULL,1,@o_datacode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT

 IF @o_error_code <> 0 BEGIN
     print @o_error_desc
 END 
 ELSE BEGIN
   print '@o_datacode: ' + CONVERT(VARCHAR,@o_datacode)
     
	 UPDATE gentables
		  SET gen1ind = 1,   --Show in TM
		      lastuserid = 'QSIDBA',
			    lastmaintdate = GETDATE()
    WHERE tableid = @v_tableid
      AND datacode = @o_datacode

	 UPDATE gentables_ext
		  SET gentext1 = 'BOOK',   --key 1
		      lastuserid = 'QSIDBA',
			    lastmaintdate = GETDATE()
    WHERE tableid = @v_tableid
      AND datacode = @o_datacode
        
    SELECT @v_itemtypecode = datacode FROM gentables WHERE tableid = 550 AND qsicode = 13 ---Job
    SELECT @v_usageclasscode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 34 -- Title Job
    
    EXEC qutl_insert_gentablesitemtype @v_tableid,@o_datacode,0,0,@v_itemtypecode,@v_usageclasscode,@o_error_code OUTPUT,@o_error_desc OUTPUT
        
END