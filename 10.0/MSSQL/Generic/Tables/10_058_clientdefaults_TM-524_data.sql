DECLARE @v_error_code INT,
	@v_error_desc VARCHAR(2000)

exec qutl_insert_clientdefaults_value 98,'Zendesk Help Shared Token','This token is used to connect to Zendesk help.  PLEASE DO NOT UPDATE unless instructed by Firebrand to do so',0,NULL,'ho5MIF5Perdx9wBoWDi4Gfku8FL2hiziS7ijKv2RR474HKCQ',NULL,3,'This default is created on the Zendesk site and should not be updated without instruction',1,1, @v_error_code OUTPUT,@v_error_desc OUTPUT

exec qutl_insert_clientdefaults_value 99,'Zendesk Help Default User Name','This will be used to connect to Zendesk help if the individual user cannot connect directly to Zendesk',0,NULL,'TM User',NULL,3,'If the user is not a valid individual user for Zendesk, we will use this user name when authenticating',1,1, @v_error_code OUTPUT,@v_error_desc OUTPUT

exec qutl_insert_clientdefaults_value 100,'Zendesk Help Default User Email','This will be used to connect to Zendesk help if the individual user email is not available',0,NULL,'zendesk@firebrandtech.com',NULL,3,'If the user is not a valid individual user for Zendesk, we will use this email when authenticating',1,1, @v_error_code OUTPUT,@v_error_desc OUTPUT

exec qutl_insert_clientdefaults_value 101,'Zendesk Help Default Organization','This will be used to connect to Zendesk help if the  user organization is not available.  It will only be filled in if Zendesk is being used for custom help or is available for individual ticket creation.',0,NULL,'',NULL,3,'If there is no organization associated with the individual user and the organization is needed for custom help or for ticket creation, this organization will be used to authenticate and/or create user',1,1, @v_error_code OUTPUT,@v_error_desc OUTPUT


go