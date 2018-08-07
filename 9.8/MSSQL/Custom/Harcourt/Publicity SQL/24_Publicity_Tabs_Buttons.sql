


/******************************************************************************************
**  HMH Publicity Tabs
**  Executes qutl_insert_taqrelationshiptabconfig_button
*******************************************************************************************/

BEGIN

  DECLARE
   @v_taqrelationshipconfigkey integer,
   @v_datasubcode integer,
   @v_error_code  integer,
   @v_error_desc varchar(2000) 
   
   set @v_datasubcode = 0
   set @v_error_code = 0
   set @v_error_desc = ' '

exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Publicity (Publ Campgn)',3,54, 2 , 3,56, NULL,  'Publicity Project', NULL,'Publicity Campaign ', NULL, '', NULL, '', @v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Publicity (Publ Campgn)',3,54, 1 , 3, 56,  NULL, 'Publicity Project',NULL, 'Publicity Campaign ', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	  	 	 	 
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Publicity Campaign',3,56, 2 , 3,54, NULL,  'Publicity Campaign ', NULL,'Publicity Project', NULL, '', NULL, '', @v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Publicity Campaign',3,56, 1 , NULL, NULL,  NULL, '',NULL, '', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	  	 	 	 
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Marketing (Titles)',NULL,NULL, 1 , NULL, NULL,  NULL, '',NULL, '', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Marketing (Titles)',NULL,NULL, 2 , 3,54,NULL,  '', NULL,'', NULL, 'Publicity', NULL, 'Title', @v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Marketing (Titles)',NULL,NULL,1 , 3, 54,  NULL, '',NULL, '', NULL, 'Publicity', NULL, 'Title',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END  
  
 GO