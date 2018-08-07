DECLARE
  @v_tableid              INT,
  @v_datacode             INT,
  @v_datasubcode          INT,
  @v_datasub2code         INT,
  @v_itemtype             INT,
  @v_class				  INT,	       
  @o_error_code           INT ,
  @o_error_desc			  VARCHAR(2000)
  
SET @v_tableid = 598
SET @v_datacode = 0	
SET @v_itemtype = 0
SET @v_class = 0
SET @v_datasubcode = 0
SET @v_datasub2code = 0

SELECT @v_datacode = dbo.qutl_get_gentables_datacode(@v_tableid, 26, NULL)	
SELECT @v_itemtype = datacode, @v_class = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 9

IF @v_datacode > 0 AND @v_itemtype > 0 AND @v_class > 0 BEGIN
	EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode,@v_datasub2code,@v_itemtype, @v_class,@o_error_code OUTPUT,@o_error_desc OUTPUT     
	
	IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  PRINT @o_error_desc
	  RETURN
	END	 
	
	UPDATE gentablesitemtype SET text1 = 'For related Mktg Projects, create new projects and relate these; For all other related projects, copy the relationship'
	WHERE tableid = @v_tableid AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
	
END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 598 qsicode 26 OR gentables 550 qsicode 9'
END