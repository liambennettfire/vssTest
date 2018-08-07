IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.CoreAuthorDisplayname') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP PROC dbo.CoreAuthorDisplayname
  END
GO

CREATE PROC dbo.CoreAuthorDisplayname
   @p_authoroption INT,
   @p_isauthor CHAR(1),
   @p_firstname VARCHAR(75),
   @p_lastname VARCHAR(75),
   @p_middlename VARCHAR(75),
   @p_suffix VARCHAR(75),
   @p_degree VARCHAR(75),
   @p_corpcontrind TINYINT,
   @v_authorname VARCHAR(75) OUTPUT
AS

BEGIN
  DECLARE @v_comma		CHAR(2),
   	  @v_space 			CHAR(1),
	  @v_authfirstname	VARCHAR(75),
	  @v_authlastname		VARCHAR(75),
	  @v_authmidname		VARCHAR(75),
	  @v_authsuffix		VARCHAR(75),
	  @v_authdegree		VARCHAR(75),
	  @v_authcorpind		TINYINT,
	  @v_firstinitoption	TINYINT,
     @v_displaynameformat TINYINT,
     @v_firstname_initial varchar(1),
     @v_middlename_initial varchar(1),
     @v_space2 			CHAR(1)


  /* Check the client option for Author Full Displayname - prefer to use cursors to avoid raised exceptions */
   DECLARE option_cur CURSOR FOR
    SELECT optionvalue
    FROM clientoptions
    WHERE optionname = 'displayname generation'

  OPEN option_cur 	
  FETCH NEXT FROM option_cur INTO @v_displaynameformat 

  IF @@FETCH_STATUS < 0
    SET @v_displaynameformat = 0

  CLOSE option_cur 
  DEALLOCATE option_cur 

 /* Initial values */
  SET @v_comma = ', '
  SET @v_space = ' '
  SET @v_space2 = ' '
  SET @v_authlastname = @p_lastname

  SET @v_firstname_initial = SUBSTRING(@p_firstname, 1, 1)
  SET @v_authfirstname = @p_firstname
  SET @v_authmidname = @p_middlename
  SET @v_middlename_initial = SUBSTRING(@p_middlename, 1, 1)


  /* For corporate contributors, return lastname */
  SET @v_authcorpind = @p_corpcontrind
  IF @v_authcorpind = 1
    BEGIN
      SELECT @v_authorname = @v_authlastname
      RETURN
    END
  
  /* When both firstname and middlename are missing, return lastname */
  IF @v_authfirstname IS NULL AND @v_authmidname IS NULL
    BEGIN
      SELECT @v_authorname = @v_authlastname
      RETURN
    END

	/* When firstname or middlename is missing, eliminate the space that divides firstname from middlename */
  IF @v_authfirstname IS NULL OR @v_authmidname IS NULL
    SET @v_space = ''

    /*0 (default) Last, First MI */

	/* Generate displayname from lastname, firstname and middlename */
	IF @v_displaynameformat = 0
   BEGIN
    	IF @v_middlename_initial IS NULL 
         SET @v_space = ''
      IF @v_authfirstname IS NULL
         SET @v_space = '' 
      IF @v_middlename_initial IS NULL AND @v_authfirstname IS NULL
      BEGIN
			SET @v_space = ''
			SET @v_comma = ''
		END
      ---IF @v_authlastname IS NOT NULL
		---	SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname) + @v_space + isNull(@v_middlename_initial, '')
      ---ELSE IF @v_authlastname IS NULL
      ---   SET @v_authorname =  @v_comma + LTRIM(@v_authfirstname) + @v_space + isNull(@v_middlename_initial, '')
	  IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NOT NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_middlename_initial)
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NULL AND @v_middlename_initial IS NOT NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_middlename_initial)
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname)
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NOT NULL
        SET @v_authorname = @v_comma + LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_middlename_initial)
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NULL
        SET @v_authorname = @v_comma + LTRIM(@v_authfirstname) 
   END

   /*1 will generate: Last, FirstInitial */

	IF @v_displaynameformat = 1
   BEGIN
		IF @v_firstname_initial IS NULL 
     	  SET @v_space = ''
      IF @v_authlastname IS NOT NULL AND @v_firstname_initial IS NOT NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + @v_firstname_initial 
      ELSE IF @v_authlastname IS NOT NULL AND @v_firstname_initial IS NULL
		 SET @v_authorname = LTRIM(@v_authlastname) 
      ELSE IF @v_authlastname IS NULL AND @v_firstname_initial IS NOT NULL
        SET @v_authorname = @v_comma + @v_firstname_initial
   END

   /*  2 will generate First Last */
	IF @v_displaynameformat = 2
   BEGIN
      IF @v_authfirstname  IS NULL
         SET @v_space = ''
      IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL
		SET @v_authorname = LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_authlastname) 
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS  NULL 
  		SET @v_authorname = LTRIM(@v_authfirstname)
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL
        SET @v_authorname = LTRIM(@v_authfirstname)
   END

  /* 3 will generate First MI Last */

	IF @v_displaynameformat = 3
   BEGIN
      IF @v_authfirstname IS NOT NULL AND @v_authmidname IS NULL
         SET @v_space = ''

      IF @v_authfirstname IS NULL AND @v_authmidname IS NOT NULL
         SET @v_space = ''

      IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NOT NULL
			SET @v_authorname = LTRIM(@v_authfirstname) + @v_space + @v_middlename_initial + @v_space2 + LTRIM(@v_authlastname) 
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NOT NULL
         SET @v_authorname = LTRIM(@v_authfirstname) + @v_space + @v_middlename_initial  
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_middlename_initial IS NULL
		SET @v_authorname = LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_authlastname) 
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NULL AND @v_middlename_initial IS NOT NULL
		SET @v_authorname = LTRIM(@v_middlename_initial) + @v_space + LTRIM(@v_authlastname) 
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NULL AND @v_middlename_initial IS NULL
          SET @v_authorname = ' '
   END

   /*  4 will generate Last, First, Middle */
   IF @v_displaynameformat = 4
   BEGIN
       IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NULL AND @v_authmidname IS NULL
      		SET @v_authorname = LTRIM(@v_authlastname)
       ELSE IF @v_authlastname IS NULL AND  @v_authfirstname IS NULL AND @v_authmidname IS NULL
       	 	SET @v_authorname = ' '
       ELSE  IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NULL
      		SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname)
       ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NULL
       		SET @v_authorname =  @v_comma + LTRIM(@v_authfirstname)
       ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NULL AND @v_authmidname IS NOT NULL
     		SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authmidname)
       ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NULL AND @v_authmidname IS NOT NULL
      		SET @v_authorname = @v_comma + LTRIM(@v_authmidname)
       ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NOT NULL
       		SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname)  + @v_space2 + LTRIM(@v_authmidname) 
       ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NOT NULL
       	SET @v_authorname = @v_comma + LTRIM(@v_authfirstname)  + @v_space2 + LTRIM(@v_authmidname) 
    END

  /* Generate displayname from lastname, firstname and middlename */
  /*IF @v_authlastname IS NULL
    BEGIN
      IF @v_authmidname IS NOT NULL
        SET @v_authorname = LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_authmidname)
      ELSE
	SET @v_authorname = LTRIM(@v_authfirstname)
    END
  ELSE
    BEGIN
      IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NOT NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_authmidname)
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NULL AND @v_authmidname IS NOT NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authmidname)
      ELSE IF @v_authlastname IS NOT NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NULL
        SET @v_authorname = LTRIM(@v_authlastname) + @v_comma + LTRIM(@v_authfirstname)
      ELSE IF @v_authlastname IS NULL AND @v_authfirstname IS NOT NULL AND @v_authmidname IS NOT NULL
        SET @v_authorname = @v_comma + LTRIM(@v_authfirstname) + @v_space + LTRIM(@v_authmidname)
    END */

  /* If this is an author and if the full displayname client option is on, */
  /* must include suffix and degrees in displayname */
  IF (@p_authoroption = 1) AND (@p_isauthor = 'T')
    BEGIN
      SET @v_authsuffix = @p_suffix
      SET @v_authdegree = @p_degree

      IF @v_authsuffix IS NOT NULL
        SET @v_authorname = LTRIM(@v_authorname) + @v_comma + LTRIM(@v_authsuffix)
       
      IF @v_authdegree IS NOT NULL
        SET @v_authorname = LTRIM(@v_authorname) + @v_comma + LTRIM(@v_authdegree)
    END

  RETURN

END
GO