	
/******************************************************************************************
**  Executes the relationship tab button procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_relationtabqsicode		integer,
  @v_relationtabdatadesc	varchar (40),
  @v_itemqsicode		integer,
  @v_classqsicode		integer,
  @v_button_type		integer,     -- 0, no button, 1 for Create, 2 for Relate
  @v_button_itemqsicode		integer,
  @v_button_classqsicode	integer,
  @v_newrelateqsicode		integer,     -- only needed for create for proj-proj
  @v_newrelatedesc		varchar(40), -- only needed for create for proj-proj
  @v_existrelateqsicode		integer,     -- only needed for create for proj-proj
  @v_existrelatedesc		varchar(40), -- only needed for create for proj-proj 
  @v_projroleqsicode		integer,     -- only needed for create for proj-title
  @v_projroledesc		varchar(40), -- only needed for create for proj-title
  @v_titleroleqsicode		integer,	 -- only needed for create for proj-title
  @v_titleroledesc		varchar(40), -- only needed for create for proj-title
  @v_taqrelationshipconfigkey   integer,
  @v_error_code			integer,
  @v_error_desc			varchar(2000) 


  SET @v_relationtabqsicode = NULL
  SET @v_relationtabdatadesc = 'Third Party Rights (Titles)'
  SET @v_itemqsicode = NULL
  SET @v_classqsicode = NULL
  SET @v_button_type = 2
  SET @v_button_itemqsicode = 3
  SET @v_button_classqsicode = 49
  SET @v_newrelateqsicode = 0
  SET @v_newrelatedesc = ''
  SET @v_existrelateqsicode = 0
  SET @v_existrelatedesc = ' '
  SET @v_projroleqsicode = 0
  SET @v_projroledesc= ' '
  SET @v_titleroleqsicode = 0
  SET @v_titleroledesc ='Third Party Rights'
  SET @v_taqrelationshipconfigkey = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '


  exec qutl_insert_taqrelationshiptabconfig_button @v_relationtabqsicode,  @v_relationtabdatadesc, @v_itemqsicode, @v_classqsicode,  @v_button_type,			
  @v_button_itemqsicode, @v_button_classqsicode,  @v_newrelateqsicode, @v_newrelatedesc, @v_existrelateqsicode, @v_existrelatedesc, @v_projroleqsicode,
  @v_projroledesc, @v_titleroleqsicode, @v_titleroledesc, @v_taqrelationshipconfigkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT			
				
  
print 'taq relation key = '   + cast (@v_taqrelationshipconfigkey AS varchar)
print 'error code = ' + cast (@v_error_code AS varchar)
print 'error desc = ' + @v_error_desc   
  
END  
  
 GO