IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_printingname') AND type = 'TR')
	DROP TRIGGER dbo.book_printingname
GO

CREATE TRIGGER book_printingname ON book
FOR UPDATE AS
IF UPDATE (title)

BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_error  INT,
    @v_error_desc VARCHAR(2000),
    @v_name_autogen TINYINT,
    @v_name_gen_sql_raw VARCHAR(2000),
    @v_name_gen_sql VARCHAR(2000),
    @v_printingkey  INT,
    @v_printingnum	INT,
    @v_projectkey INT,
    @v_prtg_title VARCHAR(255),
    @v_quote  CHAR(1),
    @v_result_value1 VARCHAR(255),
    @v_result_value2 VARCHAR(255),
    @v_result_value3 VARCHAR(255),
    @v_userid VARCHAR(30)

  SELECT @v_bookkey = i.bookkey, @v_userid = lastuserid
  FROM inserted i

  SELECT @v_projectkey = taqprojectkey
  FROM taqprojectprinting_view
  WHERE bookkey = @v_bookkey

  SELECT @v_name_autogen = autogeneratenameind
  FROM taqproject
  WHERE taqprojectkey = @v_projectkey
  
  SELECT @v_name_gen_sql_raw = alternatedesc1
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 40  --Printing/Printing

  -- Execute the name auto-generation stored procedure if it exists for Printings and if taqproject.autogeneratenameind = 1
  IF @v_name_gen_sql_raw IS NOT NULL AND @v_name_autogen = 1
  BEGIN
    DECLARE taqproj_cur CURSOR FOR 
    SELECT taqprojectkey, printingkey, printingnum
    FROM taqprojectprinting_view
    WHERE bookkey = @v_bookkey

    OPEN taqproj_cur
    FETCH taqproj_cur INTO @v_projectkey, @v_printingkey, @v_printingnum
    WHILE @@fetch_status = 0 
    BEGIN
      SET @v_quote = CHAR(39)
      SET @v_name_gen_sql = @v_name_gen_sql_raw

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
      BEGIN
        UPDATE taqproject
        SET taqprojecttitle = @v_prtg_title, lastuserid = @v_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @v_projectkey
      END
      
      FETCH taqproj_cur INTO @v_projectkey, @v_printingkey, @v_printingnum
    END
    CLOSE taqproj_cur 
    DEALLOCATE taqproj_cur
  END
END
GO	