DECLARE @v_error_code INT, @v_error_desc VARCHAR(2000)
exec qutl_insert_clientdefaults_value 88,'Home Page Tasks Contact Default','The datacode selected here determines the As dropdown selection in the Task window on the Home Page. Users can determine if they want to see the assigned tasks as Project Owner, Contact 1 or Contact2, Contact 1, Contact 2, All',1,NULL,'NULL',686,5,'NULL',11,1, @v_error_code OUTPUT,@v_error_desc OUTPUT

IF @v_error_code <> 0  print 'clientdefaultidid = ' + CAST(88 AS varchar)+ ',  error message =' + @v_error_desc

