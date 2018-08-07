DECLARE
  @v_tableid					INT,
  @v_datacode					INT,
  @v_datacode_relatedprojects   INT,
  @v_sortorder_relatedprojects  INT,
  @v_sortorder					INT,
  @v_datasubcode				INT,
  @v_datasub2code				INT,
  @v_itemtype					INT,
  @v_class						INT,	       
  @o_error_code					INT,
  @v_count						INT,
  @o_error_desc					VARCHAR(2000)

SET @v_tableid = 583
SET @v_datacode = 0
SET @v_datasubcode = 0
SET @v_datasub2code = 0
SET @v_itemtype = 0

SELECT @v_datacode_relatedprojects = dbo.qutl_get_gentables_datacode(@v_tableid, 10, NULL)
SELECT @v_datacode = dbo.qutl_get_gentables_datacode(@v_tableid, 1, NULL)		

IF @v_datacode_relatedprojects > 0 AND @v_datacode > 0 BEGIN
  SELECT @v_sortorder = sortorder FROM gentables WHERE tableid = @v_tableid AND datacode = @v_datacode
  
  DECLARE crItemTypeClass CURSOR FOR
  SELECT DISTINCT itemtypecode,usageclasscode 
  FROM qsiwindowview
  WHERE userkey = -1 
        AND defaultind = 1
        AND itemtypecode in (SELECT itemtypecode FROM qsiconfigobjects
                              WHERE configobjectid = 'ProjectRelationshipsTab'
                                AND defaultvisibleind = 1)
        AND itemtypecode <> 1 -- titles

  OPEN crItemTypeClass 

  FETCH NEXT FROM crItemTypeClass INTO @v_itemtype,@v_class

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    
	 IF @v_class > 0 BEGIN
          SELECT @v_count = count(*)
            FROM subgentables
           WHERE tableid = 550
             and datacode = @v_itemtype
             and datasubcode = @v_class
        END
        ELSE IF @v_class = 0 BEGIN
          SET @v_count = 1
        END

        IF @v_count > 0 BEGIN
			EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode, @v_datasub2code, @v_itemtype, @v_class, @o_error_code OUTPUT, @o_error_desc OUTPUT     

  IF @o_error_code < 0 BEGIN
    SET @o_error_code = -1
    PRINT @o_error_desc
    RETURN
  END
        END 	 
	
    FETCH NEXT FROM crItemTypeClass INTO @v_itemtype,@v_class
  END /* WHILE FECTHING */

  CLOSE crItemTypeClass 
  DEALLOCATE crItemTypeClass	

END
ELSE BEGIN
	PRINT 'ERROR retrieving datacode for gentables 583 qsicode 1'
END

GO


