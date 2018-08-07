

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
  
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Plan)', 3,10,'Campaign Budget','Campaign Budget',NULL,135,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Plan)', 3,10,'Campaign Project Original Total','Original',NULL,136,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Plan)', 3,10,'Total Revised','Revised',NULL,56,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Plan)', 3,10,'Total Project Variance','Variance',NULL,137,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Projects (Campaign)', 3,9,'Project Original','Original',NULL,133,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Projects (Campaign)', 3,9,'Project Revised','Revised',NULL,134,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Projects (Campaign)', 3,9,'Total Variance','Variance',NULL,72,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	 	 
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Plan (Mktg Campaign)', 3,9,'Total Original','Original',NULL,64,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Plan (Mktg Campaign)', 3,9,'Total Revised','Revised',NULL,56,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Plan (Mktg Campaign)', 3,9,'Total Variance','Variance',NULL,72,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	 	 
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Projects)', 3,3,'Total Original','Original',NULL,64,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Projects)', 3,3,'Total Revised','Revised',NULL,56,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Mktg Campaigns (Mktg Projects)', 3,3,'Total Variance','Variance',NULL,72,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	 	 

  
END  
  
 GO