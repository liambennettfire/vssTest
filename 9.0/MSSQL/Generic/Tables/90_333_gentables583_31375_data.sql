DECLARE
  @v_datacode INT,
  @v_count  INT,
  @v_option_value INT
  
BEGIN
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 31 -- Printings (on Titles)
  
  IF @v_count = 1
  BEGIN
  
    SELECT @v_datacode = datacode
	  FROM gentables
	  WHERE tableid = 583 AND qsicode = 31 -- Printings (on Titles)
    
    SELECT @v_option_value = COALESCE(optionvalue,0)  
	  FROM clientoptions
	 WHERE optionid = 117 -- Production on the Web
	 
	IF @v_option_value = 0 BEGIN -- Production on the Web turned off
	    UPDATE gentables
	       SET deletestatus = 'Y',
	           lastmaintdate = getdate()
	     WHERE tableid = 583
	       AND datacode = @v_datacode
	       AND deletestatus = 'N'
	END
	IF @v_option_value = 1 BEGIN -- Production on the Web turned on
	    UPDATE gentables
	       SET deletestatus = 'N',
	           lastmaintdate = getdate()
	     WHERE tableid = 583
	       AND datacode = @v_datacode
	       AND deletestatus = 'Y'
	END
 END
END	
go

