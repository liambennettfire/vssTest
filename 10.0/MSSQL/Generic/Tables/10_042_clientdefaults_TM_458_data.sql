

DECLARE @RC int
DECLARE @i_cliendefaultid int
DECLARE @i_clientdefaultname varchar(40)
DECLARE @i_defaultvaluecomment varchar(400)
DECLARE @i_clientdefaultvalue float
DECLARE @i_clientdefaultsubvalue int
DECLARE @i_stringvalue varchar(255)
DECLARE @i_tableid int
DECLARE @i_valuetypecode int
DECLARE @i_defaultdescripiton varchar(2000)
DECLARE @i_systemfunctioncode int
DECLARE @i_activeind tinyint
DECLARE @v_error_code int
DECLARE @v_error_desc varchar(2000)

EXEC qutl_insert_clientdefaults_value 97,
	'Password Management Link',
	'This will toggle a link on the TMM Web login page pointing to a password management application hosted elsewhere. The link would only appear if the default is not null',
	NULL,
	NULL,
	'',
	NULL,
	1,
	'This will toggle a link on the TMM Web login page pointing to a password management application hosted elsewhere. The link would only appear if the default is not null',
	NULL,
	1,
	@v_error_code OUTPUT,
	@v_error_desc OUTPUT

IF @v_error_code <> 0
	PRINT 'clientdefaultidid = ' + CAST(97 AS VARCHAR) + ',  error message =' + @v_error_desc



