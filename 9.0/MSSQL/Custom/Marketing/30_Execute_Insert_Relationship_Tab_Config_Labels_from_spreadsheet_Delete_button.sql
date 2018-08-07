

/******************************************************************************************
**  Executes the relationship tab procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_taqrelationshipconfigkey   integer,
  @v_error_code		 integer,
  @v_error_desc		 varchar(2000) 



  SET @v_taqrelationshipconfigkey = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '

exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Mktg Campaigns (Mktg Plan)',3,10, '', '', '', '',NULL,'', NULL,'',1,1,1,1,1,1, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Mktg Projects (Campaign)',3,9, '', '', '', '',NULL,'', NULL,'',1,1,0,1,1,1, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Mktg Plan (Mktg Campaign)',3,9, '', '', '', '',NULL,'', NULL,'',1,1,1,1,1,1, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Mktg Campaigns (Mktg Projects)',3,3, '', '', '', '',NULL,'', NULL,'',1,1,1,1,1,1, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Marketing (Titles)',NULL,NULL, '', '', '', '',NULL,'', NULL,'',0,0,0,0,0,0, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END  
  
 GO