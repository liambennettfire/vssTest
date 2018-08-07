DECLARE  
	@o_error_code INT, 
	@o_error_desc VARCHAR(2000), 
	@o_datacode INT, 
	@o_datasubcode INT,
	@v_tablemnemonic VARCHAR(40),
	@v_tableid INT
	
SET @o_error_desc = ''
SET @o_error_code = 0
SET @o_datacode = 0
SET @o_datasubcode = 0

SELECT @v_tableid = 669

SELECT @v_tablemnemonic = tablemnemonic FROM gentablesdesc WHERE tableid = @v_tableid

EXEC qutl_insert_gentable_value @v_tableid,@v_tablemnemonic,NULL,'HMH Mktg Catalog Creation',NULL,1,@o_datacode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT

 IF @o_error_code <> 0 BEGIN
     print @o_error_desc
 END 
 ELSE BEGIN
     print '@o_datacode: + ' + CONVERT(VARCHAR,@o_datacode)
     
	 UPDATE gentables_ext
		SET gentext1 = 'HMHMktgCampaingISBNs',
		    gentext2 = 'HMH_Create_Mktg_Campaigns',
		    lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        
     SELECT @o_datasubcode = 0 
     EXEC qutl_insert_subgentable_value @v_tableid,@o_datacode,@v_tablemnemonic,NULL,'ProcessInstanceKey',NULL,1,
     @o_datasubcode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT
     
     print '@o_datasubcode: + ' + CONVERT(VARCHAR,@o_datasubcode)
     
     UPDATE subgentables
        SET subgen1ind = 1,
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
     
     UPDATE subgentables_ext
        SET gentext1 = '@instancekey',
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
        
     EXEC qutl_insert_subgentable_value @v_tableid,@o_datacode,@v_tablemnemonic,NULL,'Isbn',NULL,1,
     @o_datasubcode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT
     
     print '@o_datasubcode: + ' + CONVERT(VARCHAR,@o_datasubcode)
     
     UPDATE subgentables
        SET subgen1ind = 1,
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
     
     
        
     EXEC qutl_insert_subgentable_value @v_tableid,@o_datacode,@v_tablemnemonic,NULL,'Lastuserid',NULL,1,
     @o_datasubcode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT
     
     print '@o_datasubcode: + ' + CONVERT(VARCHAR,@o_datasubcode)
     
     UPDATE subgentables
        SET subgen1ind = 1,
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
        
     UPDATE subgentables_ext
        SET gentext1 = '@userid',
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
     
             
     EXEC qutl_insert_subgentable_value @v_tableid,@o_datacode,@v_tablemnemonic,NULL,'Lastmaintdate',NULL,1,
     @o_datasubcode OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT
     
     print '@o_datasubcode: + ' + CONVERT(VARCHAR,@o_datasubcode)
     
     UPDATE subgentables
        SET subgen1ind = 1,
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
     
     UPDATE subgentables_ext
        SET gentext1 = '@',
			lastuserid = 'QSIDBA',
			lastmaintdate = GETDATE()
      WHERE tableid = 669
        AND datacode = @o_datacode
        AND datasubcode = @o_datasubcode
        
END