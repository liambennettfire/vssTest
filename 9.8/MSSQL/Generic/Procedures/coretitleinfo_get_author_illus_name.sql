if exists (select * from dbo.sysobjects where id = object_id(N'dbo.CoreTitleInfo_get_author_illus_name') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.CoreTitleInfo_get_author_illus_name
GO

CREATE PROCEDURE CoreTitleInfo_get_author_illus_name
@a_bookkey int, @a_authorname varchar(150) OUTPUT, @a_illustratorname varchar(150) OUTPUT
AS

DECLARE @v_authorkey 			INT, 
	@v_auth_firstname			VARCHAR(75),
	@v_auth_lastname			VARCHAR(75),
	@v_auth_middlename		VARCHAR(75),
	@v_auth_suffix			VARCHAR(75),
	@v_auth_degree			VARCHAR(75),
	@v_auth_corpcontrind		TINYINT,
	@v_illus_firstname		VARCHAR(75),
	@v_illus_lastname			VARCHAR(75),
	@v_illus_middlename		VARCHAR(75),
	@v_illus_suffix			VARCHAR(75),
	@v_illus_degree			VARCHAR(75),
	@v_illus_corpcontrind		TINYINT,
	@v_authoption			TINYINT,
	@v_tempstring			VARCHAR(150),
	@v_count				INT,
	@v_firstrow				CHAR(1),
	@v_counter				INT,
	@v_auth_cur_status		INT,
	@v_illus_cur_status		INT

BEGIN

/* Check the client option for Author Full Displayname - prefer to use cursors to avoid raised exceptions */
DECLARE option_cur CURSOR FOR
  SELECT optionvalue
  FROM clientoptions
  WHERE optionname = 'full displayname'

OPEN option_cur 	
FETCH NEXT FROM option_cur INTO @v_authoption 

IF @@FETCH_STATUS < 0  /*option_cur%NOTFOUND */
  SET @v_authoption = 0 

CLOSE option_cur 
DEALLOCATE option_cur 

/*** Fill in AUTHOR NAME ***/
SELECT @v_count = count(*)
FROM bookauthor, author
WHERE bookauthor.authorkey = author.authorkey AND
	bookauthor.bookkey = @a_bookkey AND
	bookauthor.primaryind = 1

DECLARE author_cur CURSOR FOR
SELECT a.firstname,
	a.lastname,			
	a.middlename,
	a.authorsuffix,
	a.authordegree,
	a.corporatecontributorind
FROM bookauthor ba, author a
WHERE ba.authorkey = a.authorkey AND
	ba.bookkey = @a_bookkey AND 
	ba.primaryind = 1 
ORDER BY ba.sortorder 

OPEN author_cur

IF @v_count = 1 
  BEGIN
	/* Fetch the primary author row */
	FETCH NEXT FROM author_cur 
	INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

	SET @v_auth_cur_status = @@FETCH_STATUS

	/* Generate Author displayname based on clientoption and the author data retrieved */
	IF @v_auth_cur_status = 0
	  EXEC CoreAuthorDisplayname @v_authoption,'T',@v_auth_firstname,@v_auth_lastname,@v_auth_middlename,@v_auth_suffix,@v_auth_degree,@v_auth_corpcontrind,@a_authorname OUTPUT

  END
ELSE IF @v_count > 1
  BEGIN
	/* Only show first 2 primary author lastnames */
	SET @v_firstrow = 'T'  /*TRUE*/
	SET @v_counter = 0

      /* Fetch the primary author row */
	FETCH NEXT FROM author_cur 
	INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

	SET @v_auth_cur_status = @@FETCH_STATUS

	WHILE (@v_auth_cur_status = 0)  /*LOOP*/
	  BEGIN
		/* Use firstname if lastname is missing */
		SET @v_tempstring = @v_auth_lastname 

		IF @v_tempstring IS NULL 
		  SET @v_tempstring = @v_auth_firstname 

		IF @v_tempstring IS NOT NULL 
		  BEGIN       
			IF @v_firstrow = 'T'  /*TRUE*/ 
			  SET @a_authorname = @v_tempstring 
			ELSE
			  SET @a_authorname = @a_authorname + '/' + @v_tempstring 
		  END   	      
	      
		SET @v_counter = @v_counter + 1

		/* When 2 primary author rows have been processed, exit - displayname will include first 2 primary authors if more exist */
		IF @v_counter = 2 
		  BREAK

		SET @v_firstrow = 'F'  /*FALSE*/
          
		/* Fetch the primary author row */
		FETCH NEXT FROM author_cur 
		INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

		SET @v_auth_cur_status = @@FETCH_STATUS

	  END
  END 

CLOSE author_cur 
DEALLOCATE author_cur
		
SET @v_tempstring = NULL 

/*** Fill in ILLUSTRATOR NAME ***/
SELECT @v_count = count(*)
FROM bookauthor ba, author a, gentables g
WHERE ba.authorkey = a.authorkey AND
	ba.authortypecode = g.datacode AND
	ba.bookkey = @a_bookkey AND			
	g.tableid = 134 AND
	g.gen2ind = 1
  
DECLARE illus_cur CURSOR FOR
	SELECT a.firstname,
	  a.lastname,			
	  a.middlename,
	  a.authorsuffix,
	  a.authordegree,
	  a.corporatecontributorind
	FROM bookauthor ba, author a, gentables g
	WHERE ba.authorkey = a.authorkey AND
	  ba.authortypecode = g.datacode AND
	  ba.bookkey = @a_bookkey AND 
	  g.tableid = 134 AND
	  g.gen2ind = 1
	ORDER BY ba.sortorder 
	
OPEN illus_cur

IF @v_count = 1 
  BEGIN
  	/* Fetch the illustrator row */
	FETCH NEXT FROM illus_cur 
	INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind

	SET @v_illus_cur_status = @@FETCH_STATUS

	/* Generate Illustrator displayname based on clientoption and the illustrator data retrieved */
	IF @v_illus_cur_status = 0
	   EXEC CoreAuthorDisplayname @v_authoption, 'T', @v_illus_firstname,@v_illus_lastname,@v_illus_middlename,@v_illus_suffix,@v_illus_degree,@v_illus_corpcontrind,@a_illustratorname OUTPUT
  END
ELSE IF @v_count > 1 
  BEGIN
      /* Only show first 2 illustrator lastnames */
	SET @v_firstrow = 'T'  /*TRUE*/
	SET @v_counter = 0
 
	/* Fetch the illustrator row */
	FETCH NEXT FROM illus_cur INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind

	SET @v_illus_cur_status = @@FETCH_STATUS
      
	WHILE (@v_illus_cur_status = 0) 
	  BEGIN
	    /* Use firstname if lastname is missing */
	    SET @v_tempstring = @v_illus_lastname 
			
	    IF @v_tempstring IS NULL 
		SET @v_tempstring = @v_illus_firstname 
	    IF @v_tempstring IS NOT NULL 
		BEGIN  
		  IF @v_firstrow = 'T'  /*TRUE*/
		    SET @a_illustratorname = @v_tempstring 
		  ELSE
		    SET @a_illustratorname = @a_illustratorname + '/' + @v_tempstring 
		  END

	    /* When 2 illustrator rows have been processed, exit - displayname will include first 2 illustrators if more than 2 exist */
	    SET @v_counter = @v_counter + 1

	    IF @v_counter = 2 
	       BREAK  /*EXIT illustrator_cursor */
	  
	    SET @v_firstrow = 'F'  /*FALSE*/
 
	    /* Fetch the illustrator row */
	    FETCH NEXT FROM illus_cur 
	    INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind

	    SET @v_illus_cur_status = @@FETCH_STATUS

	  END
  END

CLOSE illus_cur 
DEALLOCATE illus_cur	


END

GO
