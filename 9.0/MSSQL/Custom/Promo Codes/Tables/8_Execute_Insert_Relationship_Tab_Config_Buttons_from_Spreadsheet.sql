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


exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Promo Codes',3,45, 2 , 3,46,  NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Promo Codes',3,45, 1 , 3, 46,  NULL, 'Promo Code',NULL, 'Promotion', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Promotion',3,46, 2 , 3,45,  NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_button NULL, 'Promotion',3,46, 1 , NULL, NULL,  NULL, '',NULL, '', NULL, '', NULL, '',@v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc


  
END  
  
 GO