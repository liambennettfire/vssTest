DECLARE
  @v_tableid              INT,
  @v_datacode             INT,
  @v_datasubcode          INT,
  @v_datasub2code         INT,
  @v_itemtype             INT,
  @v_class				  INT,	       
  @o_error_code           INT ,
  @o_error_desc			  VARCHAR(2000),
  @v_datadesc varchar(40)
  
SET @v_tableid = 284
SET @v_datacode = 0	
SET @v_itemtype = 0
SET @v_datasubcode = 0
SET @v_datasub2code = 0
SET @v_datadesc = 'editorial'
SET @v_class = 0

SELECT @v_datacode = dbo.qutl_get_gentables_datacode(@v_tableid, NULL, @v_datadesc)	
SELECT @v_datasubcode = datasubcode FROM subgentables WHERE tableid = @v_tableid AND datacode = @v_datacode AND qsicode = 7
SELECT @v_itemtype = dbo.qutl_get_gentables_datacode(550, 1, NULL)	

IF @v_datacode > 0 AND @v_itemtype > 0 BEGIN
	EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode,@v_datasub2code,@v_itemtype, @v_class,@o_error_code OUTPUT,@o_error_desc OUTPUT     
END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 598 qsicode 26 OR gentables 550 qsicode 3'
END

GO