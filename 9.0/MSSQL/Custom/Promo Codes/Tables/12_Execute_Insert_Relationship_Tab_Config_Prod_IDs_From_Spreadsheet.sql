

/******************************************************************************************
**  Executes the relationship tab product ids procedure from spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE

  @v_taqrelationshipconfigkey   integer,
  @v_error_code					integer,
  @v_error_desc					varchar(2000) 


  SET @v_taqrelationshipconfigkey = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '
		
exec qutl_insert_taqrelationshiptabconfig_productids NULL,'Promo Codes', 3,45,'Promo Code ID','Promo Code ID',NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc

  
END  
  
 GO