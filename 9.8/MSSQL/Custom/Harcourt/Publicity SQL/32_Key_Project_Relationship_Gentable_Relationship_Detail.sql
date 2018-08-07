/******************************************************************************************
**  Sets up Key Project Relationship: Project Class to Project Relationship
	for Publicity Projects search to display related Publicity Campaign
**  Execute qutl_insert_gentablesrelationshipdetail_value procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_gentablesrelationshipdetailkey INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 
  
exec qutl_insert_gentablesrelationshipdetail_value 36, 'Projects', 3, 'Publicity Campaign ',  NULL,'Publicity Project',  56, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END  
  
 GO