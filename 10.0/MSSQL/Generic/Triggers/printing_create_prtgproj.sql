IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.printing_create_prtgproj') AND type = 'TR')
  DROP TRIGGER dbo.printing_create_prtgproj
GO

CREATE TRIGGER printing_create_prtgproj ON printing
FOR INSERT, UPDATE AS
IF UPDATE (printingnum)

BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_count  INT,
    @v_error  INT,
    @v_error_desc VARCHAR(2000),
    @v_name_autogen TINYINT,
    @v_name_gen_sql VARCHAR(2000),
    @v_printingkey  INT,
    @v_printingnum	INT,
    @v_projectkey INT,
    @v_prtg_title VARCHAR(255),
    @v_quote  CHAR(1),
    @v_result_value1 VARCHAR(255),
    @v_result_value2 VARCHAR(255),
    @v_result_value3 VARCHAR(255),
    @v_userid VARCHAR(30),
    @v_jobnumberalpha CHAR(7) ,
    @v_productidcode INT,
    @v_count2 INT ,
    @v_new_productnumberkey INT     

  SELECT @v_bookkey = i.bookkey, @v_printingkey = i.printingkey, @v_userid = lastuserid
  FROM inserted i

  SELECT @v_count = COUNT(*)
  FROM taqprojectprinting_view
  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

  IF @v_count = 0 -- Printing project doesn't exist yet - create   
    EXEC qprinting_prtgproj_from_prtgtbl @v_bookkey, @v_printingkey, @v_userid, @v_error OUT, @v_error_desc OUT
  ELSE
  BEGIN
    SELECT @v_projectkey = taqprojectkey, @v_printingnum = printingnum
    FROM taqprojectprinting_view
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

    SELECT @v_name_autogen = autogeneratenameind
    FROM taqproject
    WHERE taqprojectkey = @v_projectkey
    
    SELECT @v_name_gen_sql = alternatedesc1
    FROM subgentables
    WHERE tableid = 550 AND qsicode = 40  --Printing/Printing

    -- Execute the name auto-generation stored procedure if it exists for Printings and if taqproject.autogeneratenameind = 1
    IF @v_name_gen_sql IS NOT NULL AND @v_name_autogen = 1
    BEGIN
      SET @v_quote = CHAR(39)

      -- Replace each parameter placeholder with corresponding value
      SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@userid', @v_quote + @v_userid + @v_quote)
      SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@bookkey', CONVERT(VARCHAR, @v_bookkey))
      SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@printingkey', CONVERT(VARCHAR, @v_printingkey))
      SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@printingnum', CONVERT(VARCHAR, @v_printingnum))
    
      -- Execute the stored name auto-generation stored procedure for Printings
      EXEC qutl_execute_prodidsql2 @v_name_gen_sql, @v_result_value1 OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT,
        @v_error OUTPUT, @v_error_desc OUTPUT

      SET @v_prtg_title = @v_result_value1

      IF @v_prtg_title IS NOT NULL
        UPDATE taqproject
        SET taqprojecttitle = @v_prtg_title, lastuserid = @v_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @v_projectkey
       
       SELECT @v_jobnumberalpha = jobnumberalpha
			  FROM taqprojectprinting_view
			  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey


	  IF @v_jobnumberalpha IS NOT NULL AND LEN(@v_jobnumberalpha) > 0 BEGIN
			SELECT @v_productidcode = datacode FROM gentables WHERE tableid = 594 and qsicode = 14
			
			IF @v_productidcode > 0 BEGIN
				SET @v_count2 = 0
			    
				SELECT @v_count2 = COUNT(*) FROM taqproductnumbers WHERE taqprojectkey = @v_projectkey AND productidcode = @v_productidcode
					 AND ltrim(rtrim(productnumber)) = @v_jobnumberalpha
					
				IF @v_count2 = 0 BEGIN 
					EXEC dbo.get_next_key 'QSIDBA', @v_new_productnumberkey OUT
					
					INSERT INTO taqproductnumbers (productnumberkey,taqprojectkey,productidcode,productnumber,sortorder,lastuserid, lastmaintdate)
						VALUES (@v_new_productnumberkey,@v_projectkey,@v_productidcode,@v_jobnumberalpha,1,@v_userid, getdate())
				END
		   END --@v_productidcode > 0
	  END    --IF @v_jobnumberalpha IS NOT NULL AND LEN(@v_jobnumberalpha) > 0       

    END
  END
  
  SELECT @v_projectkey = taqprojectkey
  FROM taqprojectprinting_view
  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey  
  
  IF @v_projectkey > 0 AND @v_bookkey > 0 BEGIN
	 SELECT @v_count = COUNT(*)
	 FROM taqprojecttask
	 WHERE taqprojectkey = @v_projectkey 
	 
	 IF @v_count > 0 BEGIN
	    UPDATE taqprojecttask 
	    SET taqprojectkey = NULL, bookkey = @v_bookkey, printingkey = @v_printingkey
 	    WHERE taqprojectkey = @v_projectkey   	  
 	 END   
  END    
  
  EXEC qtitle_copy_title_format_to_printing @v_bookkey, @v_printingkey, @v_userid, @v_error OUT, @v_error_desc OUT

END
GO
