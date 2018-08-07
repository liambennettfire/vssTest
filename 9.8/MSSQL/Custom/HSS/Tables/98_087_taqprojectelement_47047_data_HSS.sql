DECLARE 
  @v_taqelementkey INT,
  @v_count_before INT,
  @v_count_after INT,
  @o_error_code INT,
  @o_error_desc VARCHAR(2000)

SELECT @v_count_before = COUNT(*)
  FROM taqprojectelement 
  WHERE taqelementtypecode IN (
    SELECT datacode FROM gentables WHERE tableid=287 AND datadesc LIKE 'Enthrill%'
  )

PRINT 'Deleting ' + CAST(@v_count_before AS VARCHAR) + ' Enthrill elements from taqprojectelement...'

DECLARE element_cur CURSOR FOR
  SELECT taqelementkey 
  FROM taqprojectelement 
  WHERE taqelementtypecode IN (
    SELECT datacode FROM gentables WHERE tableid=287 AND datadesc LIKE 'Enthrill%'
  )

OPEN element_cur

FETCH element_cur INTO @v_taqelementkey

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC qelement_delete_element @v_taqelementkey, 0, @o_error_code OUTPUT, @o_error_desc OUTPUT

  IF @o_error_code <> 0
    PRINT 'Error deleting taqelementkey ' + CAST(@v_taqelementkey AS VARCHAR) + ': ' + @o_error_desc

  FETCH element_cur INTO @v_taqelementkey
END

CLOSE element_cur
DEALLOCATE element_cur

SELECT @v_count_after = COUNT(*)
  FROM taqprojectelement 
  WHERE taqelementtypecode IN (
    SELECT datacode FROM gentables WHERE tableid=287 AND datadesc LIKE 'Enthrill%'
  )

IF @v_count_after = 0
  PRINT 'Deleted ' + CAST(@v_count_before AS VARCHAR) + ' Enthrill elements from taqprojectelement.'
ELSE
  PRINT 'Failed to delete ' + CAST(@v_count_after AS VARCHAR) + ' Enthrill elements from taqprojectelement.'
