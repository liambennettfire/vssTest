DECLARE @v_error_code INT, @v_error_desc VARCHAR(2000)
exec qutl_insert_clientdefaults_value 87,'Home Page Tasks Due Selection Default','The datacode selected here determines the Due dropdown selection (tableid 259) in the Tasks window on the Home Page. Users can determine if they want to see Overdue tasks or upcoming tasks and the date range for those tasks',6,NULL,'NULL',589,5,'NULL',11,1, @v_error_code OUTPUT,@v_error_desc OUTPUT
IF @v_error_code <> 0  
 print 'clientdefaultidid = ' + CAST(87 AS varchar)+ ',  error message =' + @v_error_desc
