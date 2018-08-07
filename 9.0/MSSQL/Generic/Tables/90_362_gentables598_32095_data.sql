DECLARE
	@v_sortorder INT,
	@o_datacode INT,
	@o_error_code INT,
	@o_error_desc varchar(2000)
	
SELECT @v_sortorder = sortorder FROM gentables WHERE tableid = 598 AND qsicode = 10

UPDATE gentables SET sortorder = sortorder + 1 WHERE sortorder > @v_sortorder and  tableid = 598

SET @v_sortorder = @v_sortorder + 1

exec dbo.qutl_insert_gentable_value 598, 'CopyProjectDataGroups', 26, 'Relate/Create New Related Projects', @v_sortorder, 1, @o_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

IF @o_error_code < 0 BEGIN
  SET @o_error_code = -1
  PRINT @o_error_desc
  RETURN
END

UPDATE gentables 
SET alternatedesc1 = 'Copy Related Projects or Relate new Copies of Related Projects depending on Project Relationship type',
	gen2ind = 0
WHERE tableid = 598 AND datacode = @o_datacode  	
  
GO