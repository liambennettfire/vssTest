


/******************************************************************************************
**  Executes qutl_insert_taqrelationshiptabconfig_misc
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
   
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Titles (Projects)', 3,54,'Announced 1st Printing','Announced 1st Printng',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	 	 
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'Major Market','Major Market',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity (Publ Campgn)', 3,54,'City','City',NULL,NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity Campaign', 3,56,'Related Title Author','Author',NULL,NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_misc NULL,'Publicity Campaign', 3,56,'Related Title Pub Date','Pub Date',NULL,NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc


END  
  
 GO