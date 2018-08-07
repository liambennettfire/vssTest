DECLARE 
	@v_taskviewkey INT
	
	SELECT TOP(1) @v_taskviewkey = taskviewkey FROM taskview WHERE LTRIM(RTRIM(LOWER(taskviewdesc))) = 'all tasks - completed tasks hidden'
	
	IF @v_taskviewkey > 0 BEGIN
		INSERT INTO clientdefaults
		  (clientdefaultid, clientdefaultname, clientdefaultcomment, clientdefaultvalue, lastuserid, lastmaintdate)
		VALUES
		  (81, 'Task View Default for Overdue Tasks', 'This will be the default Task View for Overdue Tasks', @v_taskviewkey, 'QSIDBA', getdate())		
	END
	