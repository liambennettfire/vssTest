DECLARE
 @v_sortorder integer,
 @v_datacode integer,
 @v_datasubcode integer,
 @v_error_code  integer,
 @v_error_desc varchar(2000)  
 
SET @v_sortorder = 0
SET @v_datacode = 1

IF NOT EXISTS (SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Payment Method')
BEGIN
  EXEC qutl_insert_subgentable_value 636, @v_datacode, 'SECCNFG', NULL, 'Payment Method', @v_sortorder, 0,
    @v_datasubcode OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT

  UPDATE subgentables SET datadescshort = 'Payment Method', numericdesc1 = @v_datasubcode
  WHERE tableid = 636 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
END

GO