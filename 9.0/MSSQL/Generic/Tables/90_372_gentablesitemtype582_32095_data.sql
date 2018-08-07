DECLARE
  @v_tableid              INT,
  @v_datacode             INT,
  @v_datacode_relatedprojects  INT,
  @v_sortorder_relatedprojects INT,
  @v_sortorder INT,
  @v_datasubcode          INT,
  @v_datasub2code         INT,
  @v_itemtype             INT,
  @v_class				  INT,	       
  @o_error_code           INT ,
  @o_error_desc			  VARCHAR(2000)
  
SET @v_tableid = 598
SET @v_datacode = 0	
SET @v_itemtype = 0
SET @v_datasubcode = 0
SET @v_datasub2code = 0

SELECT @v_datacode_relatedprojects = dbo.qutl_get_gentables_datacode(@v_tableid, 10, NULL)
SELECT @v_datacode = dbo.qutl_get_gentables_datacode(@v_tableid, 26, NULL)	
SELECT @v_itemtype = dbo.qutl_get_gentables_datacode(550, 3, NULL)	

IF @v_datacode_relatedprojects > 0 AND @v_datacode > 0 AND @v_itemtype > 0 BEGIN
  SELECT @v_sortorder = sortorder FROM gentables WHERE tableid = @v_tableid AND datacode = @v_datacode
  
  DECLARE crItemTypeClass CURSOR FOR
  SELECT datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = @v_itemtype 

  OPEN crItemTypeClass 

  FETCH NEXT FROM crItemTypeClass INTO @v_class

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    
	EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode,@v_datasub2code,@v_itemtype, @v_class,@o_error_code OUTPUT,@o_error_desc OUTPUT     
	
	IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  PRINT @o_error_desc
	  RETURN
	END	 
	
	IF EXISTS (SELECT * FROM gentablesitemtype WHERE tableid = @v_tableid AND datacode = @v_datacode_relatedprojects AND itemtypecode = @v_itemtype AND itemtypesubcode IN (@v_class , 0) AND sortorder IS NOT NULL) BEGIN
		SELECT TOP(1) @v_sortorder_relatedprojects = sortorder FROM gentablesitemtype WHERE tableid = @v_tableid AND datacode = @v_datacode_relatedprojects AND sortorder IS NOT NULL AND itemtypecode = @v_itemtype AND itemtypesubcode IN (@v_class , 0)
		ORDER BY itemtypesubcode DESC
		
		SET @v_sortorder_relatedprojects = @v_sortorder_relatedprojects + 1
		
		UPDATE gentablesitemtype SET sortorder = @v_sortorder_relatedprojects WHERE tableid = @v_tableid AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
	END
	ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = @v_sortorder WHERE tableid = @v_tableid AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
	END
	
    FETCH NEXT FROM crItemTypeClass INTO @v_class
  END /* WHILE FECTHING */

  CLOSE crItemTypeClass 
  DEALLOCATE crItemTypeClass	

END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 598 qsicode 26 OR gentables 550 qsicode 3'
END