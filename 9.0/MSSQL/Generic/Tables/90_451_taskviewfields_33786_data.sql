DECLARE @v_taskviewkey INT,
		@v_taskviewkey_template INT,
		@v_columnorder INT,
		@v_taskfieldkey INT,
		@v_sortorder INT

SELECT @v_taskviewkey = taskviewkey FROM taskview WHERE qsicode = 5
SELECT @v_taskviewkey_template = taskviewkey FROM taskview WHERE qsicode = 1

IF @v_taskviewkey > 0 AND @v_taskviewkey_template > 0 AND NOT EXISTS(SELECT * FROM taskviewfields f, taskfieldnames n WHERE f.taskfieldkey = n.taskfieldkey AND f.taskviewkey = @v_taskviewkey AND COALESCE(f.columnorder, 0) > 0) BEGIN

  DECLARE crTaskViewFields CURSOR FOR
  SELECT taskfieldkey, sortorder, columnorder
  FROM taskviewfields
  WHERE taskviewkey = @v_taskviewkey_template

  OPEN crTaskViewFields 

  FETCH NEXT FROM crTaskViewFields INTO @v_taskfieldkey, @v_sortorder, @v_columnorder

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
  
	IF NOT EXISTS (SELECT * FROM taskviewfields WHERE taskviewkey = @v_taskviewkey AND taskfieldkey = @v_taskfieldkey) BEGIN
		INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, sortorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, @v_taskfieldkey, @v_columnorder, @v_sortorder, 'QSIDBA', getdate()) 
	END
	ELSE BEGIN
		UPDATE taskviewfields SET columnorder=@v_columnorder, sortorder = @v_sortorder, lastuserid='QSIDBA', lastmaintdate=getdate() WHERE taskviewkey=@v_taskviewkey AND taskfieldkey = @v_taskfieldkey
	END  
  
    FETCH NEXT FROM crTaskViewFields INTO @v_taskfieldkey, @v_sortorder, @v_columnorder
  END /* WHILE FECTHING */

  CLOSE crTaskViewFields 
  DEALLOCATE crTaskViewFields   
END

GO