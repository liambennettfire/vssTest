DECLARE
	@v_sortorder INT,
	@o_datasubcode INT,
	@o_error_code INT,
	@o_error_desc varchar(2000),
	@v_datacode INT,
	@v_tableid INT,
	@v_datadesc varchar(40)
	
SET @v_tableid = 284
SET @v_datacode = 0	
SET @v_datadesc = 'editorial'
	
SELECT @v_datacode = dbo.qutl_get_gentables_datacode(@v_tableid, NULL, @v_datadesc)	

IF @v_datacode < 0 
	RETURN

SET @v_sortorder = NULL

exec dbo.qutl_insert_subgentable_value @v_tableid, @v_datacode, 'COMMENTT', 7, 'Auto Generated Author Bio', @v_sortorder, 1, @o_datasubcode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

IF @o_error_code < 0 BEGIN
  SET @o_error_code = -1
  PRINT @o_error_desc
  RETURN
END

UPDATE subgentables 
SET subgen1ind = 0, subgen2ind = 0, acceptedbyeloquenceind = 1, exporteloquenceind = 1, lockbyqsiind = 1, lockbyeloquenceind = 0, eloquencefieldtag = 'AI', subgen3ind = 0, subgen4ind = 0
WHERE tableid = @v_tableid AND datacode = @v_datacode and datasubcode = @o_datasubcode	
  
GO