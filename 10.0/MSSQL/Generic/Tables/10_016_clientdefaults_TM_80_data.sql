DECLARE @v_error_code INT, @v_error_desc VARCHAR(2000)
exec qutl_insert_clientdefaults_value
94,
'Default Help Url',
'This is the default Help URL that can be navigated to for help information when no section level url''s are available',
NULL,
NULL,
'https://firebrandtechsupport.zendesk.com/hc/en-us',
NULL,
3,
NULL,
NULL,
1,
@v_error_code OUTPUT,
@v_error_desc OUTPUT

IF @v_error_code <> 0
BEGIN
	print 'clientdefaultidid = ' + CAST(87 AS varchar)+ ',  error message =' + @v_error_desc
END