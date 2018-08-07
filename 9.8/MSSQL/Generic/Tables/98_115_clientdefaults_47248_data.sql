DECLARE 
  @v_error_code INT, 
  @v_error_desc VARCHAR(2000),
  @v_default_currency int
  
  SELECT @v_default_currency = (
    SELECT datacode
    FROM gentables
    WHERE tableid = 122 AND qsicode = 2 --US Dollars
  )

exec qutl_insert_clientdefaults_value  
  92, 'Default Currency', 
  'This will be the default currency for new projects if not otherwise specified.', 
  @v_default_currency, NULL, NULL, 122, 5, NULL, 6, 1, 
  @v_error_code OUTPUT,@v_error_desc OUTPUT

IF @v_error_code <> 0  print 'clientdefaultidid = ' + CAST(92 AS VARCHAR)+ ',  error message =' + @v_error_desc
