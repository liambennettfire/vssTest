DECLARE
 @v_sortorder integer,
 @v_datacode integer,
 @v_datasubcode integer,
 @v_error_code  integer,
 @v_error_desc varchar(2000)  
 
SET @v_sortorder = 3

SET @v_datacode = 6
WHILE @v_datacode < 9
BEGIN
  IF NOT EXISTS (SELECT * FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'PO Section')
  BEGIN
    UPDATE subgentables SET sortorder = sortorder + 1 WHERE sortorder >= 3 AND tableid = 636 AND datacode = @v_datacode
    EXEC qutl_insert_subgentable_value 636, @v_datacode, 'SECCNFG', NULL, 'PO Section', @v_sortorder, 0,
      @v_datasubcode OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT

    UPDATE subgentables SET datadescshort = 'Product'  
    WHERE tableid = 636 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
  END
  
  SET @v_datacode = @v_datacode + 1
END

GO