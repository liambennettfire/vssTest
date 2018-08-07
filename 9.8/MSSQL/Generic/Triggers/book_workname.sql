IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.book_workname') AND type = 'TR')
	DROP TRIGGER dbo.book_workname
GO

CREATE TRIGGER book_workname ON book
FOR UPDATE AS
IF UPDATE (title)

BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_error  INT,
    @v_error_desc VARCHAR(2000),
    @v_name_gen_sql_raw VARCHAR(2000),
    @v_name_gen_sql VARCHAR(2000),
  	@v_name_autogen TINYINT,
    @v_primaryformatind TINYINT,
    @v_projectkey INT,
    @v_work_title VARCHAR(255),
    @v_result_value VARCHAR(255),
    @v_result_value2 VARCHAR(255),
    @v_result_value3 VARCHAR(255),
    @v_userid VARCHAR(30)

  SET @v_projectkey = 0
  SET @v_name_autogen = 0
  SET @v_primaryformatind = 0
  
  SELECT @v_bookkey = i.bookkey, @v_userid = i.lastuserid
  FROM inserted i

  SELECT @v_projectkey = p.taqprojectkey, @v_name_autogen = p.autogeneratenameind, @v_primaryformatind = t.primaryformatind
  FROM book b 
  LEFT JOIN taqproject p ON b.workkey = p.workkey
  LEFT JOIN taqprojecttitle t ON b.bookkey = t.bookkey AND p.taqprojectkey = t.taqprojectkey
  WHERE b.bookkey=@v_bookkey 

  SELECT @v_name_gen_sql_raw = alternatedesc1
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 28  --Work

  -- Execute the name auto-generation stored procedure if it exists for Printings and if taqproject.autogeneratenameind = 1
  IF @v_name_gen_sql_raw IS NOT NULL AND @v_name_autogen = 1 AND @v_primaryformatind = 1
  BEGIN
      SET @v_name_gen_sql = @v_name_gen_sql_raw

      -- Replace each parameter placeholder with corresponding value
      SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@bookkey', CONVERT(VARCHAR, @v_bookkey))
    
      -- Execute the stored name auto-generation stored procedure for Works
      EXEC qutl_execute_prodidsql2 @v_name_gen_sql, @v_result_value OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT, 
        @v_error OUTPUT, @v_error_desc OUTPUT

      SET @v_work_title = @v_result_value

      IF @v_work_title IS NOT NULL
      BEGIN
        UPDATE taqproject
        SET taqprojecttitle = @v_work_title, lastuserid = @v_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @v_projectkey
      END
  END
END
GO	