/******************************************************************************************
**  Publicity Campaigns, Projects and Author Tours
**  Execute qutl_insert_gentablesrelationshipdetail_value procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_gentablesrelationshipdetailkey INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 
  
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Publicity Campaign ', NULL, 'Publicity Project',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Publicity Project', NULL, 'Publicity Campaign',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
	
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Publicity Project', NULL, 'Publicity (Publ Campgn)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Publicity Campaign ', NULL, 'Publicity (Publ Campgn)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Publicity Project', NULL, 'Publicity Campaign ',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Publicity Campaign ', NULL, 'Publicity Campaign ',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
	
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Publicity', NULL, 'Marketing (Titles)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Publicity', NULL, 'Titles (Projects)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
	
exec qutl_insert_gentablesrelationshipdetail_value 9, 'Publicity Campaign', NULL, 'Publicity',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 9, 'National', NULL, 'Publicity',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 9, 'Online', NULL, 'Publicity',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 9, 'Regional/Misc', NULL, 'Publicity',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
	
exec qutl_insert_gentablesrelationshipdetail_value 14, 'Publicity Campaign', NULL, 'Title',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 14, 'National', NULL, 'Title',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 14, 'Online', NULL, 'Title',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 14, 'Regional/Misc', NULL, 'Title',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END  
  
 GO