/******************************************************************************************
**  Publicity Campaigns, Projects and Author Tours
**  qutl_insert_taqrelationshiptabconfig_labels procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_taqrelationshipconfigkey INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 
  
 

exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Publicity Campaign',3,56, '', '', '', '',NULL,'', NULL,'',0,0,0,1,1,1, 1, 2,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Publicity (Publ Campgn)',3,54, '', '', '', '',NULL,'', NULL,'',0,1,0,1,1,1, 1, 2,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	


END  
  
 GO