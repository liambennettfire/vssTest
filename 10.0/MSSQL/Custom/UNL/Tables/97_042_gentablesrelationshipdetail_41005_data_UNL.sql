DECLARE
@v_gentablesrelationshipdetailkey	integer,
@v_error_code						integer,
@v_error_desc						varchar(2000),
@o_itemtypekey						integer,
@v_datacode							integer,
@v_itemtype							integer,
@v_usageclass						integer
    
SET @v_gentablesrelationshipdetailkey = 0
SET @v_error_code = 0
SET @v_error_desc = ''

SET @v_datacode = NULL

SELECT @v_datacode = datacode --4
FROM gentables
WHERE tableid = 583
  AND qsicode = 4 -- Volumes (Journal)

IF @v_datacode IS NOT NULL
BEGIN
	exec qutl_insert_gentablesrelationshipdetail_value   6, 'Journal (for Journal Items)', 1, 'Volumes (Journal)', 4, NULL,  NULL, NULL,NULL,0, @v_gentablesrelationshipdetailkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
END

GO

DECLARE
@v_gentablesrelationshipdetailkey	integer,
@v_error_code						integer,
@v_error_desc						varchar(2000),
@o_itemtypekey						integer,
@v_datacode							integer,
@v_itemtype							integer,
@v_usageclass						integer
    
SET @v_gentablesrelationshipdetailkey = 0
SET @v_error_code = 0
SET @v_error_desc = ''

SET @v_datacode = NULL

SELECT @v_datacode = datacode --4
FROM gentables
WHERE tableid = 583
  AND qsicode = 4 -- Volumes (Journal)

IF @v_datacode IS NOT NULL
BEGIN
	exec qutl_insert_gentablesrelationshipdetail_value   6, 'Volume  (for Journal Items)', 2, 'Volumes (Journal)', 4, NULL,  NULL, NULL,NULL,0, @v_gentablesrelationshipdetailkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
END

GO
