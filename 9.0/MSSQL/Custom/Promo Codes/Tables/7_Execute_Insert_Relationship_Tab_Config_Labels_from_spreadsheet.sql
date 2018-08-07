

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

exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Promo Codes',3,45, '', '', '', '',NULL,'', NULL,'',1,1,1,1,1,1, 1, 1,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	UPDATE taqrelationshiptabconfig SET decimal1label = '', decimal1format = '', decimal2label = '', decimal2format ='' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey
exec qutl_insert_taqrelationshiptabconfig_labels NULL,'Promotion',3,46, '', '', '', '',NULL,'', NULL,'',1,1,0,1,1,1, 1, 1,0,1,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	UPDATE taqrelationshiptabconfig SET decimal1label = '', decimal1format = '', decimal2label = '', decimal2format ='' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey
exec qutl_insert_taqrelationshiptabconfig_labels 15,'Titles (Projects)',3,46, '', '', '', '',NULL,'', NULL,'',0,0,0,0,0,1, 0, 0,0,0,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	UPDATE taqrelationshiptabconfig SET decimal1label = 'Discount Amt', decimal1format = '$###,##0.00', decimal2label = '', decimal2format ='' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey


END  
  
 GO