


/******************************************************************************************
**  Executes qutl_insert_taqrelationshiptabconfig_misc
add 'sub-type' misc item and 'state' misc items to publicity project tab located on publicity campaign summary
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

exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'State','State',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'City','City',NULL,NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'Major Market (optional)','Major Market',NULL,NULL,3, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'Sub-Type (optional)','Sub-Type',NULL,NULL,4, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc



END  
  
 GO