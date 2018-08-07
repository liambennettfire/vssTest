     
  DECLARE 
    @v_contactkey  INT,
    @v_authortypecode INT,
    @v_contact_role INT,
    @ExistingRoleCount INT,
    @v_printingkey			INT,
	@v_authorkey 			INT, 
	@v_authorname			VARCHAR(150),
	@v_illustratorname		VARCHAR(150),
	@v_autodisplayind		TINYINT,
	@v_displayname			VARCHAR(150),
	@v_globalcontactkey		INT,
	@v_bookkey				INT
     
    DECLARE authors_cursor CURSOR FAST_FORWARD FOR
	  SELECT DISTINCT ba.authorkey, ba.authortypecode FROM bookauthor ba 
	  INNER JOIN author a  ON ba.authorkey = a.authorkey 
	  INNER JOIN globalcontact gc ON a.authorkey = gc.globalcontactkey 
	  where ba.authortypecode IN 
	  (
		SELECT code1
		FROM gentablesrelationshipdetail
		WHERE gentablesrelationshipkey = 1
	  )
	  and NOT EXISTS 
	  (
		SELECT Distinct gr.globalcontactkey 
		FROM globalcontactrole gr 
		WHERE ba.authorkey = gr.globalcontactkey
		  AND gr.rolecode = (SELECT code2 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 1 AND code1 = ba.authortypecode)
	  )
	  
    OPEN authors_cursor
	FETCH NEXT FROM authors_cursor INTO @v_contactkey, @v_authortypecode	  		
	WHILE @@fetch_status = 0
	BEGIN	
	  SET @v_contact_role = null  
	  SET @ExistingRoleCount = 0
	  
	  SELECT @v_contact_role = code2
	  FROM gentablesrelationshipdetail
	  WHERE gentablesrelationshipkey = 1 AND code1 = @v_authortypecode		
	  
	  IF @v_contact_role IS NOT NULL
	  BEGIN
		SELECT @ExistingRoleCount = COUNT(*) 
		FROM globalcontactrole 
		WHERE globalcontactkey = @v_contactkey AND rolecode = @v_contact_role
	    
		IF @ExistingRoleCount = 0
		BEGIN
		  INSERT INTO globalcontactrole (globalcontactkey, rolecode, keyind, lastuserid, lastmaintdate, sortorder)
		  VALUES (@v_contactkey, @v_contact_role, 0, 'verifier', getdate(), null)      
		END 					
	  END	
				
	FETCH NEXT FROM authors_cursor INTO @v_contactkey, @v_authortypecode
    END
    CLOSE authors_cursor
    DEALLOCATE authors_cursor     	