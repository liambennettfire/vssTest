SET NOCOUNT ON

DECLARE @v_tablename VARCHAR(255),
        @v_tableschema VARCHAR(255),
        @v_sql NVARCHAR(MAX)

DECLARE ssn_cur CURSOR FOR
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='ssn'

OPEN ssn_cur
FETCH ssn_cur INTO @v_tableschema, @v_tablename

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @v_sql = 'UPDATE [' + @v_tableschema + '].[' + @v_tablename + '] SET [ssn] = NULL'
  EXECUTE sp_executesql @v_sql
  IF @@ERROR = 0
    PRINT 'Wiped all SSN data from table: [' + @v_tableschema + '].[' + @v_tablename + ']'
  ELSE
    PRINT 'ERROR wiping SSN data from table: [' + @v_tableschema + '].[' + @v_tablename + ']'

  SET @v_sql = 'ALTER TABLE [' + @v_tableschema + '].[' + @v_tablename + '] ADD CONSTRAINT [CK_SSN_' + UPPER(@v_tablename) + '] CHECK ([ssn] IS NULL)'
  EXECUTE sp_executesql @v_sql
  IF @@ERROR = 0
    PRINT 'Added SSN constraint to table: [' + @v_tableschema + '].[' + @v_tablename + ']'
  ELSE
    PRINT 'ERROR adding SSN constraint to table: [' + @v_tableschema + '].[' + @v_tablename + ']'

  FETCH ssn_cur INTO @v_tableschema, @v_tablename
END

CLOSE ssn_cur
DEALLOCATE ssn_cur

GO
