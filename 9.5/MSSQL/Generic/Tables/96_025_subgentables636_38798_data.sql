  DECLARE
   @v_datacode integer,
   @v_datasubcode integer,
   @v_error_code  integer,
   @v_error_desc varchar(2000)  
   
   SET @v_datacode = 13 -- Project Details
   
   exec qutl_insert_subgentable_value 636, @v_datacode,'SECCNFG',NULL,'Season', 4,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Season', numericdesc1 = 4, subgen1ind = 0, subgen2ind = 0,   acceptedbyeloquenceind = 0, exporteloquenceind = 0, eloquencefieldtag = NULL,
    lockbyeloquenceind = 0,  lastuserid =  'QSIDBA', alternatedesc1 = 'Season'  
    WHERE tableid = 636 AND datacode = @v_datacode AND datasubcode = @v_datasubcode

GO