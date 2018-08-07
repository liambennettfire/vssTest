

/******************************************************************************************
**  Executes the relationship tab misc procedure from spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE

  @v_taqrelationshipconfigkey   integer,
  @v_error_code					integer,
  @v_error_desc					varchar(2000) 


  SET @v_taqrelationshipconfigkey = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '
		
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Promo Codes', 3,45,'Order Discount Amt Cap','Disc Cap',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Promo Codes', 3,45,'Max Times Allowed','Max Times ',NULL,NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Promo Codes', 3,45,'Discount Amount Default ','Disc Amt Default',NULL,NULL,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Promotion', 3,46,'Discount Amt Cap Default (Promotion)','Disc Cap Default',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Promotion', 3,46,'Max Times Allowed Default (Promotion)','Max Times Default',NULL,NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc		

END  
  
 GO