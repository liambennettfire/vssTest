DECLARE @v_error_code int,@v_error_desc varchar(2000)

exec qutl_insert_clientoptions_value 124,'Lock Titles/Projects','0 (default) will not Lock Titles/Projects which will allow multiple users to update at the same time; 1 will lock the title/project upon first entry so only that user will be able to update.  All other users can enter in read only mode',1,'If this option is set to 0 multiple users will be able to update titles/projects at the same time.  If this option is set to 1 only one user will be able to update titles/projects at a time.  All other users can view the title/project in read only mode.',1,1, @v_error_code OUTPUT,@v_error_desc OUTPUT	
IF @v_error_code <> 0 BEGIN
  print 'optionid = ' + CAST(124 AS varchar)+ ',  error message =' + @v_error_desc
END
