DECLARE @v_taqprojectkey INT
DECLARE @v_productnumberkey INT
DECLARE @v_newkey INT
DECLARE @o_JobNumberSeq	char(7) 
DECLARE	@o_error_code	integer     
DECLARE	@o_error_desc	varchar(2000) 
DECLARE @v_taqprojecttitle VARCHAR(255)
DECLARE @v_bookkey INT
DECLARE @v_printingkey INT
DECLARE @v_count INT
DECLARE @v_printingnum INT

BEGIN
	DECLARE taqproductnumbers_cur CURSOR FOR
	select n.productnumberkey, n.taqprojectkey from taqproductnumbers n where taqprojectkey in 
	  (select p.taqprojectkey from taqproject p, taqprojecttitle t where searchitemcode = 14 and usageclasscode = 1
		and t.taqprojectkey = p.taqprojectkey 
		and t.printingkey > 1)
		and productidcode = 5
		and productnumber is NULL
		
	OPEN taqproductnumbers_cur

	FETCH taqproductnumbers_cur INTO @v_productnumberkey, @v_taqprojectkey

	WHILE @@fetch_status = 0
	BEGIN
	    SELECT @v_count = 0
	    SELECT @v_printingnum = 0
	    SELECT @o_error_code = 0
	    SELECT @o_error_desc = ''
	    SELECT @o_JobNumberSeq = ''	
		
		SELECT @v_count = COUNT(*)
		  FROM taqproductnumbers
		 WHERE taqprojectkey = 	@v_taqprojectkey
		   AND productnumberkey = @v_productnumberkey 
		   AND productnumber IS NULL
		   AND productidcode = 5
		   
		SELECT @v_bookkey = bookkey,@v_printingkey = printingkey FROm taqprojecttitle WHERE taqprojectkey = @v_taqprojectkey
		
		SELECT @v_printingnum = printingnum FROM taqprojectprinting_view WHERE bookkey = @v_bookkey
		   
		IF @v_count = 1 AND @v_printingnum > 1 BEGIN
			exec qprinting_get_next_jobnumber_alpha @o_JobNumberSeq output,@o_error_code output,@o_error_desc output
			
			IF @o_JobNumberSeq IS NOT NULL AND @o_JobNumberSeq <> '' 
				UPDATE taqproductnumbers 
				   SET productnumber = LTRIM(rtrim(@o_JobNumberSeq)),
					   lastuserid = 'FB_31553_CLENUP',
					   lastmaintdate = GETDATE()
				 WHERE taqprojectkey = @v_taqprojectkey
				   AND productnumberkey = @v_productnumberkey
				   
			SELECT @v_taqprojecttitle = taqprojecttitle FROm taqproject WHERE taqprojectkey = @v_taqprojectkey
			
			PRINT 'taqprojecttitle: ' + @v_taqprojecttitle
			PRINT 'bookkey: ' + convert(varchar(20),@v_bookkey)
			PRINT 'printingkey: ' + convert(varchar(20),@v_printingkey)
			PRINT 'printingnum: ' + convert(varchar(20),@v_printingnum)
		END

		FETCH taqproductnumbers_cur INTO @v_productnumberkey, @v_taqprojectkey

	END

	CLOSE taqproductnumbers_cur 
	DEALLOCATE taqproductnumbers_cur
END
go