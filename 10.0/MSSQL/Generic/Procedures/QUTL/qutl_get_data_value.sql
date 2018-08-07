IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_data_value')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_data_value'
    DROP  Procedure  qutl_get_data_value
  END

GO

-- 06/27/07 A.H.

CREATE   PROCEDURE qutl_get_data_value
 (@i_tablename       varchar(100),
  @i_columnname	      varchar(100),
  @i_whereclause     varchar(2000),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


-- verify that all required values are filled in
  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists: tablename is empty.'
    RETURN
  END 

  IF @i_columnname IS NULL OR ltrim(rtrim(@i_columnname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists: ColumnName is empty.'
    RETURN
  END 


  IF @i_whereclause IS NULL OR ltrim(rtrim(@i_whereclause)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists: where clause is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @SQLString_var NVARCHAR(4000),
          @SQLparams_var NVARCHAR(4000)

  
  SET @SQLString_var = N'SELECT ' + @i_columnname + ' columnname' +
                       ' FROM ' + @i_tablename +
                       ' WHERE ' + @i_whereclause

print @SQLString_var

  EXECUTE sp_executesql @SQLString_var, @SQLparams_var

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists on ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  
  RETURN 

GO

GRANT EXEC ON qutl_get_data_value TO PUBLIC

GO
