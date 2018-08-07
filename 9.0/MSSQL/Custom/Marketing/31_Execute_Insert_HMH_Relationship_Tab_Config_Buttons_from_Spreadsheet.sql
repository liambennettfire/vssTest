/******************************************************************************************
**  Executes the relationship tab button procedure from the Spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE
  @v_taqrelationshipconfigkey   integer,
  @v_error_code					integer,
  @v_error_desc					varchar(2000) 

  SET @v_taqrelationshipconfigkey = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '

exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Marketing (Titles)',NULL,NULL, 2 , 3,9,  NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Marketing (Titles)',NULL,NULL, 1 , 3, 9,  NULL, '',NULL, '', NULL, 'Marketing', NULL, 'Title',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Mktg Campaigns (Mktg Plan)',3,10, 2 , 3,9,  NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Mktg Campaigns (Mktg Plan)',3,10, 1 , 3, 9,  NULL, 'Marketing Campaign (Plan)',NULL, 'Marketing Plan', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Mktg Projects (Campaign)',3,9, 1 , 3, 3,  NULL, 'Marketing Project',NULL, 'Marketing Campaign (Projects)', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Mktg Plan (Mktg Campaign)',3,9, 2 , 3,10,  NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Mktg Plan (Mktg Campaign)',3,9, 1 , NULL, NULL,  NULL, '',NULL, '', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

  
END  
  
 GO