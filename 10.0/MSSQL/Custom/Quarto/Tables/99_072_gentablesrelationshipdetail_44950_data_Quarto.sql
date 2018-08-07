DECLARE @v_classdatacode INT,
				@v_classdatasubcode INT,
				@v_righttype INT,
				@v_detailkey INT

SELECT @v_classdatacode = datacode,
			 @v_classdatasubcode = datasubcode
FROM subgentables
WHERE tableid = 550
  AND qsicode = 59

DECLARE cur_relation CURSOR FOR
SELECT datacode
FROM gentables
WHERE tableid = 157
		  
OPEN cur_relation 

FETCH NEXT FROM cur_relation INTO @v_righttype

WHILE (@@FETCH_STATUS <> -1)
BEGIN
	EXEC dbo.get_next_key 'QSIDBA', @v_detailkey OUT

	INSERT INTO gentablesrelationshipdetail
	(gentablesrelationshipkey, code1, gentablesrelationshipdetailkey, code2, subcode2, defaultind, lastuserid, lastmaintdate)
	VALUES
	(39, @v_righttype, @v_detailkey, @v_classdatacode, @v_classdatasubcode, 1, 'QSIDBA', GETDATE())
	
	FETCH NEXT FROM cur_relation INTO @v_righttype
END

CLOSE cur_relation
DEALLOCATE cur_relation