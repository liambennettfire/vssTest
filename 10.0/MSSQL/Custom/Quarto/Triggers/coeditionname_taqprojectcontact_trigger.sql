IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.contact_coeditionname ') AND type = 'TR')
  DROP TRIGGER dbo.contact_coeditionname 
GO

CREATE TRIGGER contact_coeditionname  ON taqprojectcontact
FOR UPDATE AS
IF UPDATE (globalcontactkey)

BEGIN
  DECLARE
    @v_projectkey INT,
    @v_error  INT,
    @v_error_desc VARCHAR(2000),
    @v_name_gen_sql_raw VARCHAR(2000),
    @v_name_gen_sql VARCHAR(2000),
    @v_name_autogen TINYINT,
    @v_generated_title VARCHAR(255),
    @v_result_value VARCHAR(255),
    @v_result_value2 VARCHAR(255),
    @v_result_value3 VARCHAR(255),
    @v_userid VARCHAR(30),
    @v_qsicode INT

  SET @v_projectkey = 0
  
  SELECT @v_projectkey = i.taqprojectkey, @v_userid = i.lastuserid
  FROM inserted i  

  -- Autogenerate Name --
  
  DECLARE @QsiCodeTable TABLE (qsicode INT)

  -- Co-Edition Contract
  INSERT INTO @QsiCodeTable (qsicode) VALUES (63) 
  
  -- Disk & Royalty Deal
  INSERT INTO @QsiCodeTable (qsicode) VALUES (76) 
  
  DECLARE class_cur CURSOR FOR
  SELECT qsicode FROM @QsiCodeTable
  OPEN class_cur
  FETCH class_cur INTO @v_qsicode

  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @v_name_autogen = 0
    
    -- Check for project type match
    SELECT @v_name_autogen = tp.autogeneratenameind FROM taqproject tp
    WHERE EXISTS (SELECT 1 FROM subgentables sg
         WHERE tp.searchitemcode = 10 AND tp.usageclasscode  = sg.datasubcode 
         AND tableid = 550 and sg.qsiCode = @v_qsicode) 
         AND @v_projectkey = tp.taqprojectkey

    IF @v_name_autogen = 1
    BEGIN
      SELECT @v_name_gen_sql_raw = ISNULL(alternatedesc1, '')
      FROM subgentables
      WHERE tableid = 550 AND qsicode = @v_qsicode

      -- Execute the name auto-generation stored procedure if it exists
      IF @v_name_gen_sql_raw <> ''
      BEGIN
        SET @v_name_gen_sql = @v_name_gen_sql_raw

        -- Replace each parameter placeholder with corresponding value
        SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@projectkey', CONVERT(VARCHAR, @v_projectkey))
      
        -- Execute the stored name auto-generation stored procedure
        EXEC qutl_execute_prodidsql2 @v_name_gen_sql, @v_result_value OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT, 
          @v_error OUTPUT, @v_error_desc OUTPUT

        SET @v_generated_title = @v_result_value

        IF @v_generated_title IS NOT NULL
        BEGIN
          UPDATE taqproject
          SET taqprojecttitle = @v_generated_title, lastuserid = @v_userid, lastmaintdate = getdate()
          WHERE taqprojectkey = @v_projectkey
        END
      END
      
      BREAK
    END
    
    FETCH class_cur INTO @v_qsicode
  END
  
  CLOSE class_cur
  DEALLOCATE class_cur
END
GO  