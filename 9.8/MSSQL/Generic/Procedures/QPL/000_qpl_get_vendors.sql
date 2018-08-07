if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_vendors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_vendors
GO

CREATE PROCEDURE qpl_get_vendors
 (@i_orderbyname	tinyint, --1 = true, 0 = false (false orders by globalcontactkey)
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_get_vendors
**  Desc: Gets all the Vendors for the specified category type
**
**  Auth: Dustin Miller
**  Date: March 1, 2012
**********************************************************************************/
  
DECLARE
	@v_catcode		INT,
	@v_rolecode		INT,
	@v_contactkey	INT,
	@v_name				VARCHAR(255),
	@v_activeind	INT,
  @v_error			INT,
  @v_rowcount		INT,
  @v_count      INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE @contact_results_table TABLE
	(
		itemcategorycode	INT,
		globalcontactkey	INT,
		displayname	VARCHAR(255),
		activeind			INT
	)
	
	DECLARE relationship_cursor CURSOR FAST_FORWARD FOR
	SELECT code1 AS itemcategorycode, code2 AS rolecode
	FROM gentablesrelationshipdetail 
	WHERE gentablesrelationshipkey IN 
		(SELECT gentablesrelationshipkey 
		FROM gentablesrelationships 
		WHERE gentable1id = 616 
			AND gentable2id = 285)
	
	OPEN relationship_cursor
	
	FETCH relationship_cursor
	INTO @v_catcode, @v_rolecode
  
  WHILE (@@FETCH_STATUS = 0)
  BEGIN	
		DECLARE contacts_cursor CURSOR FAST_FORWARD FOR
		SELECT DISTINCT g.globalcontactkey, g.displayname, g.activeind
		FROM globalcontact g, globalcontactrole r
		WHERE g.globalcontactkey = r.globalcontactkey 
			AND r.rolecode = @v_rolecode
			
		OPEN contacts_cursor
	
		FETCH contacts_cursor
		INTO @v_contactkey, @v_name, @v_activeind
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF @v_contactkey IS NOT NULL AND @v_name IS NOT NULL
			BEGIN
				INSERT INTO @contact_results_table
				VALUES (@v_catcode, @v_contactkey, @v_name, @v_activeind)
			END
			
			FETCH contacts_cursor
			INTO @v_contactkey, @v_name, @v_activeind
		END
		
		CLOSE contacts_cursor
		DEALLOCATE contacts_cursor
		
		FETCH relationship_cursor
		INTO @v_catcode, @v_rolecode
  END
  
  CLOSE relationship_cursor
	DEALLOCATE relationship_cursor
	
	SELECT @v_count = count(*)
  FROM @contact_results_table
		
	IF @v_count > 0 BEGIN
	  IF @i_orderbyname = 1
	  BEGIN
		  SELECT * 
		  FROM @contact_results_table
		  ORDER BY displayname
	  END
	  ELSE BEGIN
		  SELECT * 
		  FROM @contact_results_table
		  ORDER BY globalcontactkey
	  END
	END
	ELSE BEGIN
		DECLARE default_cursor CURSOR FAST_FORWARD FOR
		SELECT DISTINCT g.globalcontactkey, g.displayname, g.activeind
		FROM globalcontact g, globalcontactrole r
		WHERE g.globalcontactkey = r.globalcontactkey 
			AND rolecode in (select datacode from gentables where tableid = 285 and qsicode = 15)
			
		OPEN default_cursor
	
		FETCH default_cursor
		INTO @v_contactkey, @v_name, @v_activeind
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF @v_contactkey IS NOT NULL AND @v_name IS NOT NULL
			BEGIN
				INSERT INTO @contact_results_table
				VALUES (0, @v_contactkey, @v_name, @v_activeind)
			END
			
			FETCH default_cursor
			INTO @v_contactkey, @v_name, @v_activeind
		END
		
		CLOSE default_cursor
		DEALLOCATE default_cursor
	
	  IF @i_orderbyname = 1
	  BEGIN
		  SELECT * 
		  FROM @contact_results_table
		  ORDER BY displayname
	  END
	  ELSE BEGIN
		  SELECT * 
		  FROM @contact_results_table
		  ORDER BY globalcontactkey
	  END

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access globalcontact/globalcontactrole/taqversionspeccategory table (qpl_get_vendors).'
    END
	END
  
END

GO

GRANT EXEC ON qpl_get_vendors TO PUBLIC
go
