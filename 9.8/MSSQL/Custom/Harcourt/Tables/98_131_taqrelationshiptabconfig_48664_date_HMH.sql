


/******************************************************************************************
**  Executes qutl_insert_taqrelationshiptabconfig_dates
add 'End Date' task to publicty project tab located on Publicity Campaign Summary
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
   
exec qutl_insert_taqrelationshiptabconfig_dates NULL,'Publicity (Publ Campgn)', 3,54,'Start/Run Date','Start/Run Date',NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	exec qutl_insert_taqrelationshiptabconfig_dates NULL,'Publicity (Publ Campgn)', 3,54,'End Date','End Date',NULL,2, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	


END  
  
 GO