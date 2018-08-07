DECLARE @v_error_code int,
        @v_error_desc varchar(2000)

BEGIN
  exec qutl_insert_clientdefaults_value 93,'Title default author search criteria',
  'This is default search criteria key that will appear by default in the contact search popup for finding authors for titles',
  87,NULL,'',0,1,'NULL',10,1, @v_error_code OUTPUT,@v_error_desc OUTPUT

  IF @v_error_code <> 0  BEGIN
    print 'clientdefaultidid = ' + CAST(93 AS varchar)+ ',  error message =' + @v_error_desc
  END
END
