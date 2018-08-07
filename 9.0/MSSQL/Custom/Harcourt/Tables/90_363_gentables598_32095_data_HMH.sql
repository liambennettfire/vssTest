DECLARE
	@v_datacode INT

SET @v_datacode = 0	
SELECT @v_datacode = dbo.qutl_get_gentables_datacode(598, 26, NULL)	

IF @v_datacode > 0 BEGIN
	UPDATE gentables 
	SET gen2ind = 1
	WHERE tableid = 598 AND datacode = @v_datacode  	
END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 598 qsicode 26'
END
  
SET @v_datacode = 0	
SELECT @v_datacode = dbo.qutl_get_gentables_datacode(598, 10, NULL)	

IF @v_datacode > 0 BEGIN
	UPDATE gentables 
	SET gen2ind = 0
	WHERE tableid = 598 AND datacode = @v_datacode  	
END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 598 qsicode 10'
END  