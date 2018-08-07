


/******************************************************************************************
**  Executes qutl_insert_taqrelationshiptabconfig_dates
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
   
exec qutl_insert_taqrelationshiptabconfig_dates NULL,'Publicity (Publ Campgn)', 3,54,'Start/Run date','Start/Run date',NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_taqrelationshiptabconfig_dates 15,'Titles (Projects)', 3,54,'Publication Date','Pub Date',NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc


END  
  
 GO