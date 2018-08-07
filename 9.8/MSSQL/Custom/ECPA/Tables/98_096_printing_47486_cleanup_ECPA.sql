DECLARE
   @v_error_code  INT,
   @v_error_desc varchar(2000), 
   @v_bookkey INT,
   @v_printingkey INT,
   @v_datacode INT
   
   SET @v_datacode = 0
   
	--Find Bisac Unit of Measure for Inches datacode
	exec @v_datacode = qutl_get_gentables_datacode 613, NULL , 'Inches'
		  		  
	IF @v_datacode = 0  BEGIN
	  SET @v_error_code = -1
	  PRINT 'No entry in gentables 613 with datadesc of Inches found'
	  RETURN
	END      
  
  --- Set Spine Size UOM to Inches when spinesize has a value 		 	  
  DECLARE crPrinting_setSpinesizeUOM CURSOR FOR
	select bookkey, printingkey
	from printing where ISNULL(spinesizeunitofmeasure, 0) = 0 AND  ISNULL(LTRIM(RTRIM(spinesize)), '') <> ''
		  
  OPEN crPrinting_setSpinesizeUOM 

  FETCH NEXT FROM crPrinting_setSpinesizeUOM INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
  
    UPDATE printing
    SET spinesizeunitofmeasure = @v_datacode, lastmaintdate = GETDATE(), lastuserid = 'Case 40191'
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
    
 --   SET @v_error_code = 0
 --   SET @v_error_desc = ''

	--exec qtitle_auto_verify_title @v_bookkey, @v_printingkey, 'Case 40191',  @v_error_code OUTPUT,@v_error_desc OUTPUT	 

    FETCH NEXT FROM crPrinting_setSpinesizeUOM INTO @v_bookkey, @v_printingkey
  END /* WHILE FECTHING */

  CLOSE crPrinting_setSpinesizeUOM 
  DEALLOCATE crPrinting_setSpinesizeUOM   
    
  --- Clearing out Spine Size UOM When spinesize has no value 
  DECLARE crPrinting_clearSpinesizeUOM CURSOR FOR
	select bookkey, printingkey
	from printing where ISNULL(spinesizeunitofmeasure, 0) > 0 AND  ISNULL(LTRIM(RTRIM(spinesize)), '') = ''
		  
  OPEN crPrinting_clearSpinesizeUOM 

  FETCH NEXT FROM crPrinting_clearSpinesizeUOM INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
  
    UPDATE printing
    SET spinesizeunitofmeasure = NULL, lastmaintdate = GETDATE(), lastuserid = 'Case 40191'
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
    
 --   SET @v_error_code = 0
 --   SET @v_error_desc = ''

	--exec qtitle_auto_verify_title @v_bookkey, @v_printingkey, 'Case 40191',  @v_error_code OUTPUT,@v_error_desc OUTPUT	 

    FETCH NEXT FROM crPrinting_clearSpinesizeUOM INTO @v_bookkey, @v_printingkey
  END /* WHILE FECTHING */

  CLOSE crPrinting_clearSpinesizeUOM 
  DEALLOCATE crPrinting_clearSpinesizeUOM     
    
  --- Set Trim Size UOM to Inches when esttrimsizewidth or esttrimsizelength have a value or tmmactualtrimlength or tmmactualtrimwidth have a value		 	  
  DECLARE crPrinting_setTrimsizeUOM CURSOR FOR
	select bookkey, printingkey	
	from printing where ISNULL(trimsizeunitofmeasure, 0) = 0 AND  
	(
    	  ISNULL(LTRIM(RTRIM(trimsizewidth)), '') <> ''
    OR  ISNULL(LTRIM(RTRIM(trimsizelength)), '') <> ''
    OR  ISNULL(LTRIM(RTRIM(esttrimsizewidth)), '') <> ''
    OR  ISNULL(LTRIM(RTRIM(esttrimsizelength)), '') <> ''
    OR  ISNULL(LTRIM(RTRIM(tmmactualtrimlength)), '') <> ''
    OR  ISNULL(LTRIM(RTRIM(tmmactualtrimwidth)), '') <> ''
	)
	
  OPEN crPrinting_setTrimsizeUOM 

  FETCH NEXT FROM crPrinting_setTrimsizeUOM INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
  
    UPDATE printing
    SET trimsizeunitofmeasure = @v_datacode, lastmaintdate = GETDATE(), lastuserid = 'Case 40191'
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
    

	--exec qtitle_auto_verify_title @v_bookkey, @v_printingkey, 'Case 40191',  @v_error_code OUTPUT,@v_error_desc OUTPUT	 

    FETCH NEXT FROM crPrinting_setTrimsizeUOM INTO @v_bookkey, @v_printingkey
  END /* WHILE FECTHING */

  CLOSE crPrinting_setTrimsizeUOM 
  DEALLOCATE crPrinting_setTrimsizeUOM 
  
  
  --- Clearing out Trim Size UOM When esttrimsizewidth & esttrimsizelength & tmmactualtrimwidth & tmmactualtrimlength have no value 
  DECLARE crPrinting_clearTrimsizeUOM CURSOR FOR
	select bookkey, printingkey
	from printing where 
       ISNULL(trimsizeunitofmeasure, 0) > 0
	 AND ISNULL(LTRIM(RTRIM(trimsizewidth)), '') = ''
	 AND ISNULL(LTRIM(RTRIM(trimsizelength)), '') = ''
	 AND ISNULL(LTRIM(RTRIM(esttrimsizewidth)), '') = ''
	 AND ISNULL(LTRIM(RTRIM(esttrimsizelength)), '') = ''
	 AND ISNULL(LTRIM(RTRIM(tmmactualtrimwidth)), '') = ''
   AND ISNULL(LTRIM(RTRIM(tmmactualtrimlength)), '') = ''
		  
  OPEN crPrinting_clearTrimsizeUOM 

  FETCH NEXT FROM crPrinting_clearTrimsizeUOM INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
  
    UPDATE printing
    SET trimsizeunitofmeasure = NULL, lastmaintdate = GETDATE(), lastuserid = 'Case 40191'
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
    
 --   SET @v_error_code = 0
 --   SET @v_error_desc = ''

	--exec qtitle_auto_verify_title @v_bookkey, @v_printingkey, 'Case 40191',  @v_error_code OUTPUT,@v_error_desc OUTPUT	 

    FETCH NEXT FROM crPrinting_clearTrimsizeUOM INTO @v_bookkey, @v_printingkey
  END /* WHILE FECTHING */

  CLOSE crPrinting_clearTrimsizeUOM 
  DEALLOCATE crPrinting_clearTrimsizeUOM   
  
GO  