/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.CoreTitleInfo_Load') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP PROC dbo.CoreTitleInfo_Load
  END
GO

CREATE PROCEDURE CoreTitleInfo_Load AS
BEGIN

DECLARE
  @v_firstrow			CHAR(1), 
  @v_isauthor			CHAR(1),
  @v_bookkey			INT,    
  @v_printingkey			INT,
  @v_media				INT,
  @v_format				INT,
  @v_editioncode 		 	INT,
  @v_bisacstatus			INT,
  @v_seriescode   		INT,
  @v_seasonkey			INT,
  @v_count	 			INT,
  @v_authoption			INT,
  @v_childformat			INT,
  @v_imprintlevel			INT,
  @v_imprintkey			INT,
  @v_tmmhdrlevel1			INT,
  @v_tmmhdrkey1			INT,
  @v_tmmhdrlevel2			INT,
  @v_tmmhdrkey2			INT,
  @v_orglevelkey			INT,
  @v_orgentrykey			INT,
  @v_pricetype			INT,
  @v_currency			INT,
  @v_allagesind			INT,
  @v_agelowupind			INT,
  @v_agehighupind			INT,
  @v_gradelowupind		INT,
  @v_gradehighupind		INT,
  @v_finalpriceind		INT,
  @v_agelow				FLOAT,
  @v_agehigh			FLOAT,
  @v_budgetprice			FLOAT,
  @v_finalprice			FLOAT,
  @v_pubdate			DATETIME,
  @v_reldate			DATETIME,
  @v_testdate			DATETIME,
  @v_gradelow			VARCHAR(4), 
  @v_gradehigh			VARCHAR(4),
  @v_authorname			VARCHAR(150),
  @v_tempstring			VARCHAR(50),
  @v_isbn				VARCHAR(13),
  @v_gentabledesc			VARCHAR(40),
  @v_imprintdesc			VARCHAR(40),
  @v_tmmhdrorgdesc1		VARCHAR(40),
  @v_tmmhdrorgdesc2		VARCHAR(40),
  @v_ageinfo			VARCHAR(20),
  @v_gradeinfo			VARCHAR(20),
  @v_agegradeinfo			VARCHAR(40),
  @v_seasondesc			VARCHAR(80),
  @v_formatname			VARCHAR(120),
  @v_orgentryfilter		VARCHAR(40),
  @v_auth_firstname  		VARCHAR(75),
  @v_auth_lastname		VARCHAR(75),
  @v_auth_middlename		VARCHAR(75),
  @v_auth_suffix			VARCHAR(75),
  @v_auth_degree			VARCHAR(75),
  @v_auth_corpcontrind		TINYINT,
  @v_illus_firstname  		VARCHAR(75),
  @v_illus_lastname   		VARCHAR(75),
  @v_illus_middlename		VARCHAR(75),
  @v_illus_suffix			VARCHAR(75),
  @v_illus_degree			VARCHAR(75),
  @v_illus_corpcontrind		TINYINT,
  @v_source_bookkey		INT,
  @v_source_printingkey		INT,
  @v_source_mediatypecode	INT,
  @v_source_mediatypesubcode	INT,
  @v_source_editioncode		INT,
  @v_source_bisacstatuscode	SMALLINT,
  @v_source_seriescode		INT,
  @v_source_issuenumber		INT,
  @v_source_productnumber	VARCHAR(50),
  @v_source_title			VARCHAR(80),
  @v_source_titleprefix		VARCHAR(15),
  @v_source_shorttitle		VARCHAR(50),
  @v_source_titleprefixupper	VARCHAR(15),
  @v_source_productnumberx	VARCHAR(50),
  @v_source_pubmonthcode	INT,
  @v_pubmonth			VARCHAR(15),
  @v_source_pubyear		INT,
  @v_source_allagesind		INT,
  @v_source_agelowupind 	INT,
  @v_source_agehighupind 	INT,
  @v_source_agelow 		FLOAT,
  @v_source_agehigh 		FLOAT,
  @v_source_gradelowupind	INT,
  @v_source_gradehighupind	INT,
  @v_source_gradelow		VARCHAR(4),
  @v_source_gradehigh 		VARCHAR(4),
  @v_source_linklevelcode	TINYINT,
  @v_source_standardind		CHAR(1),
  @v_source_publishtowebind	CHAR(1),
  @v_source_sendtoeloind	CHAR(1),
  @v_source_seasonkey 		INT,
  @v_source_estseasonkey 	INT,
  @v_source_titlestatuscode	INT,
  @v_source_titletypecode	INT,
  @v_source_workkey		INT,
  @v_counter			INT

DECLARE filterpricetype_cur CURSOR FOR
  SELECT pricetypecode, currencytypecode
  FROM filterpricetype
  WHERE filterkey = 5 	/* TMM Header Price - GENMSDEV 8,6 */

DECLARE source_cur CURSOR FOR
  SELECT p.bookkey,
	p.printingkey,
	p.issuenumber,
	pn.productnumber,
	b.title,
	bd.titleprefix,
	b.shorttitle,
	p.pubmonthcode,
	YEAR(p.pubmonth) pubyear,
	bd.mediatypecode,
	bd.mediatypesubcode,
	bd.editioncode,
	bd.bisacstatuscode,
	b.titlestatuscode,
	b.titletypecode,
	bd.seriescode,
	p.estseasonkey,
	p.seasonkey,
	b.linklevelcode,
	b.standardind,
	bd.publishtowebind,
	b.sendtoeloind,
	b.workkey,
	REPLACE(UPPER(bd.titleprefix), ' ', '') titleprefixupper,
	REPLACE(pn.productnumber, '-', '') productnumberx,
	bd.allagesind, 
	bd.agelowupind, 
	bd.agehighupind, 
	bd.agelow, 
	bd.agehigh,
	bd.gradelowupind,
	bd.gradehighupind, 
	bd.gradehigh, 
	bd.gradelow
  FROM printing p,
	book b,
	productnumber pn,
	bookdetail bd
  WHERE p.bookkey = b.bookkey AND
	b.bookkey = pn.bookkey AND
	b.bookkey = bd.bookkey  
  ORDER BY p.bookkey, p.printingkey 

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

  /* Get Price Type and Currency for the TMM Header Price */
  OPEN filterpricetype_cur 	
  FETCH NEXT FROM filterpricetype_cur INTO @v_pricetype, @v_currency 

  IF @@FETCH_STATUS < 0  /*filterpricetype_cur%NOTFOUND*/ 	/* Default price to Retail US Dollars */
    BEGIN
	SET @v_pricetype = 8 
	SET @v_currency = 6 
    END

  CLOSE filterpricetype_cur
  DEALLOCATE filterpricetype_cur

  /* Check at which organizational level this client stores Imprint */
  SELECT @v_imprintlevel = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 15  /* Imprint - GENMSDEV 2 */
  /* NOTE: not checking for errors here - IMPRINT filterorglevel record must exist */

  /* Check at which organizational level this client stores TMM Header Display Level 1 */
  SELECT @v_tmmhdrlevel1 = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 16	/* Title Header Level One - GENMSDEV 2*/
  /* NOTE: not checking for errors here - TMM Header1 filterorglevel record must exist */

  /* Check at which organizational level this client stores TMM Header Display Level 1 */
  SELECT @v_tmmhdrlevel2 = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 17	/* Title Header Level Two - GENMSDEV 3*/
  /* NOTE: not checking for errors here - TMM Header2 filterorglevel record must exist */

  /* Delete all rows on coretitleinfo */
  TRUNCATE TABLE coretitleinfo

  /* <<source_cursor>> */
  OPEN source_cur

  FETCH NEXT FROM source_cur
  INTO @v_source_bookkey, @v_source_printingkey, @v_source_issuenumber, @v_source_productnumber,
	@v_source_title, @v_source_titleprefix, @v_source_shorttitle, @v_source_pubmonthcode,
	@v_source_pubyear, @v_source_mediatypecode, @v_source_mediatypesubcode, @v_source_editioncode,
	@v_source_bisacstatuscode, @v_source_titlestatuscode, @v_source_titletypecode, @v_source_seriescode,
	@v_source_estseasonkey, @v_source_seasonkey, @v_source_linklevelcode, @v_source_standardind,
	@v_source_publishtowebind, @v_source_sendtoeloind, @v_source_workkey, 
	@v_source_titleprefixupper, @v_source_productnumberx, @v_source_allagesind, @v_source_agelowupind,
	@v_source_agehighupind, @v_source_agelow, @v_source_agehigh, @v_source_gradelowupind,
	@v_source_gradehighupind, @v_source_gradehigh, @v_source_gradelow  

  WHILE (@@FETCH_STATUS = 0)  /*FOR @v_source_data IN source_cur LOOP */
    BEGIN
	SET @v_bookkey = @v_source_bookkey 
	SET @v_printingkey = @v_source_printingkey 
	SET @v_media = @v_source_mediatypecode 
	SET @v_format = @v_source_mediatypesubcode 
	SET @v_editioncode = @v_source_editioncode 
	SET @v_bisacstatus = @v_source_bisacstatuscode 
	SET @v_seriescode = @v_source_seriescode 
	SET @v_authorname = NULL 
  	SET @v_tempstring = NULL 
	SET @v_ageinfo = NULL 
	SET @v_gradeinfo = NULL 
	SET @v_agegradeinfo = NULL
	SET @v_imprintkey = NULL
	SET @v_imprintdesc = NULL
	SET @v_tmmhdrkey1 = NULL
	SET @v_tmmhdrkey2 = NULL
	SET @v_tmmhdrorgdesc1 = NULL
	SET @v_tmmhdrorgdesc2 = NULL
	SET @v_orgentryfilter = NULL

	/* Convert month code into string */
	SELECT @v_pubmonth =
	CASE @v_source_pubmonthcode
	  WHEN 1 THEN 'January'
	  WHEN 2 THEN 'February'
	  WHEN 3 THEN 'March'
	  WHEN 4 THEN 'April'
	  WHEN 5 THEN 'May'
	  WHEN 6 THEN 'June'
	  WHEN 7 THEN 'July'
	  WHEN 8 THEN 'August'
	  WHEN 9 THEN 'September'
	  WHEN 10 THEN 'October'
	  WHEN 11 THEN 'November'
	  WHEN 12 THEN 'December'
	END

	INSERT INTO coretitleinfo
	  (bookkey,
	  printingkey,
	  issuenumber,
	  productnumber,
	  title,
	  titleprefix,
	  shorttitle,
	  pubmonth,
	  pubyear,
	  mediatypecode,
	  mediatypesubcode,
	  editioncode,
	  bisacstatuscode,
	  titlestatuscode,
	  titletypecode,
	  seriescode,
	  estseasonkey,
	  seasonkey,
	  linklevelcode,
	  standardind,
	  publishtowebind,
	  sendtoeloind,
	  workkey,
	  titleprefixupper,
	  productnumberx)
 	VALUES
	  (@v_bookkey,
	  @v_printingkey,
	  @v_source_issuenumber,
	  @v_source_productnumber,
	  @v_source_title,
	  @v_source_titleprefix,
	  @v_source_shorttitle,
	  @v_pubmonth,
	  @v_source_pubyear,
	  @v_media,
	  @v_format,
	  @v_editioncode,
	  @v_bisacstatus,
	  @v_source_titlestatuscode,
	  @v_source_titletypecode,
	  @v_seriescode,
	  @v_source_estseasonkey,
	  @v_source_seasonkey,
	  @v_source_linklevelcode,
	  @v_source_standardind,
	  @v_source_publishtowebind,
	  @v_source_sendtoeloind,
	  @v_source_workkey,
	  @v_source_titleprefixupper,
	  @v_source_productnumberx) 

	/*** Fill in AUTHOR NAME ***/
	SELECT @v_count = count(*)
	FROM bookauthor, author
	WHERE bookauthor.authorkey = author.authorkey AND
		bookauthor.bookkey = @v_bookkey AND
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
		ba.bookkey = @v_bookkey AND 
		ba.primaryind = 1 
	ORDER BY ba.sortorder 

	OPEN author_cur

	IF @v_count = 1 
  	  BEGIN
		/* Fetch the primary author row */
		FETCH NEXT FROM author_cur 
		INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

		/* Generate Author displayname based on clientoption and the author data retrieved */
		IF @@FETCH_STATUS = 0
		  EXEC CoreAuthorDisplayname @v_authoption,'T',@v_auth_firstname,@v_auth_lastname,@v_auth_middlename,@v_auth_suffix,@v_auth_degree,@v_auth_corpcontrind,@v_authorname OUTPUT

	  END
	ELSE IF @v_count > 1
	  BEGIN
		/* Only show first 2 primary author lastnames */
		SET @v_firstrow = 'T'  /*TRUE*/
		SET @v_counter = 0

          /* Fetch the primary author row */
		FETCH NEXT FROM author_cur 
		INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

		WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
		  BEGIN
			/* Use firstname if lastname is missing */
			SET @v_tempstring = @v_auth_lastname 

			IF @v_tempstring IS NULL 
			  SET @v_tempstring = @v_auth_firstname 

			IF @v_tempstring IS NOT NULL 
			  BEGIN       
				IF @v_firstrow = 'T'  /*TRUE*/ 
				  SET @v_authorname = @v_tempstring 
				ELSE
				  SET @v_authorname = @v_authorname + '/' + @v_tempstring 
			  END   	      
	      
			SET @v_counter = @v_counter + 1

			/* When 2 primary author rows have been processed, exit - displayname will include first 2 primary authors if more exist */
			IF @v_counter = 2 
			  BREAK

			SET @v_firstrow = 'F'  /*FALSE*/
          
			/* Fetch the primary author row */
			FETCH NEXT FROM author_cur 
			INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind
 		  END
	  END 

	CLOSE author_cur 
	DEALLOCATE author_cur
		
 	IF @v_authorname IS NOT NULL
	  UPDATE coretitleinfo
  	  SET authorname = @v_authorname
 	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 

	  SET @v_authorname = NULL 
	  SET @v_tempstring = NULL 

 	  /*** Fill in ILLUSTRATOR NAME ***/
	  SELECT @v_count = count(*)
	  FROM bookauthor ba, author a, gentables g
	  WHERE ba.authorkey = a.authorkey AND
			ba.authortypecode = g.datacode AND
			ba.bookkey = @v_bookkey AND			
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
		  ba.bookkey = @v_bookkey AND 
		  g.tableid = 134 AND
		  g.gen2ind = 1
		ORDER BY ba.sortorder 
	
 	  OPEN illus_cur

	  IF @v_count = 1 
		BEGIN
		  /* Fetch the illustrator row */
 		  FETCH NEXT FROM illus_cur 
		  INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind

		  /* Generate Illustrator displayname based on clientoption and the illustrator data retrieved */
		  IF @@FETCH_STATUS = 0
		  	EXEC CoreAuthorDisplayname @v_authoption, 'T', @v_illus_firstname,@v_illus_lastname,@v_illus_middlename,@v_illus_suffix,@v_illus_degree,@v_illus_corpcontrind,@v_authorname OUTPUT
		END
	  ELSE IF @v_count > 1 
		BEGIN
		  /* Only show first 2 illustrator lastnames */
		  SET @v_firstrow = 'T'  /*TRUE*/
		  SET @v_counter = 0
 
		  /* Fetch the illustrator row */
		  FETCH NEXT FROM illus_cur INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind
      
		  WHILE (@@FETCH_STATUS = 0) 
			BEGIN
			  /* Use firstname if lastname is missing */
			  SET @v_tempstring = @v_illus_lastname 
			
			  IF @v_tempstring IS NULL 
				SET @v_tempstring = @v_illus_firstname 
			  IF @v_tempstring IS NOT NULL 
				BEGIN  
				  IF @v_firstrow = 'T'  /*TRUE*/
					SET @v_authorname = @v_tempstring 
				  ELSE
					SET @v_authorname = @v_authorname + '/' + @v_tempstring 
				END

 			  /* When 2 illustrator rows have been processed, exit - displayname will include first 2 illustrators if more than 2 exist */
			  SET @v_counter = @v_counter + 1

			  IF @v_counter = 2 
				BREAK  /*EXIT illustrator_cursor */
	  
			  SET @v_firstrow = 'F'  /*FALSE*/
 
			  /* Fetch the illustrator row */
			  FETCH NEXT FROM illus_cur 
			  INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind
			END
		END

	  CLOSE illus_cur 
	  DEALLOCATE illus_cur
		
	  IF @v_authorname IS NOT NULL
 		UPDATE coretitleinfo
		SET illustratorname = @v_authorname
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 

	  /*** Fill in PUB DATE ***/
	  DECLARE pubdate_cur CURSOR FOR
		SELECT bestdate, activedate
		FROM pubdate_view
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey 
      
      OPEN pubdate_cur
      FETCH NEXT FROM pubdate_cur INTO @v_pubdate, @v_testdate

      IF @@FETCH_STATUS = 0  /*pubdate_cur%FOUND*/
        IF @v_pubdate IS NOT NULL 
          BEGIN
	    UPDATE coretitleinfo
	    SET bestpubdate = @v_pubdate
  	    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 

	    IF @v_pubdate = @v_testdate
              UPDATE coretitleinfo
	      SET finalpubdateind = 1
	      WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
          END 

      CLOSE pubdate_cur 
      DEALLOCATE pubdate_cur

      /*** Fill in RELEASE DATE ***/
      DECLARE reldate_cur CURSOR FOR
    	SELECT bestdate, activedate
    	FROM releasedate_view
    	WHERE bookkey = @v_bookkey AND
		printingkey = @v_printingkey

      OPEN reldate_cur
      FETCH NEXT FROM reldate_cur INTO @v_reldate, @v_testdate 

      IF @@FETCH_STATUS = 0  /*reldate_cur%FOUND */
       IF @v_reldate IS NOT NULL 
         BEGIN
           UPDATE coretitleinfo
           SET bestreldate = @v_reldate
           WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
           IF @v_reldate = @v_testdate
	     UPDATE coretitleinfo
	     SET finalreldateind = 1
	     WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
         END

      CLOSE reldate_cur 
      DEALLOCATE reldate_cur

      /*** Fill in FORMAT DESCRIPTION ***/
      DECLARE formatname_cur CURSOR FOR
    	SELECT datadesc
	FROM subgentables
    	WHERE tableid = 312 AND
		  datacode = @v_media AND
		  datasubcode = @v_format 

      OPEN formatname_cur
      FETCH NEXT FROM formatname_cur INTO @v_formatname 

      IF @@FETCH_STATUS = 0  /*formatname_cur%FOUND */
        IF @v_formatname IS NOT NULL
          BEGIN
	    UPDATE coretitleinfo
  	    SET formatname = @v_formatname
  	    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
          END

      CLOSE formatname_cur 
      DEALLOCATE formatname_cur

      /*** Fill in EDITION DESCRIPTION ***/
      DECLARE editiondesc_cur CURSOR FOR
    	SELECT datadesc
    	FROM gentables
    	WHERE tableid = 200 AND
		datacode = @v_editioncode 

      OPEN editiondesc_cur
      FETCH NEXT FROM editiondesc_cur INTO @v_gentabledesc 

      IF @@FETCH_STATUS = 0  /*editiondesc_cur%FOUND */
        IF @v_gentabledesc IS NOT NULL 
          BEGIN
	    UPDATE coretitleinfo
	    SET editiondesc = @v_gentabledesc
  	    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
          END

      CLOSE editiondesc_cur
      DEALLOCATE editiondesc_cur

      /*** Fill in BISAC STATUS DESCRIPTION ***/
      DECLARE bisacstatusdesc_cur CURSOR FOR
	SELECT datadesc
	FROM gentables
    	WHERE tableid = 314 AND
		datacode = @v_bisacstatus 

      OPEN bisacstatusdesc_cur
      FETCH NEXT FROM bisacstatusdesc_cur INTO @v_gentabledesc 

      IF @@FETCH_STATUS = 0  /*bisacstatusdesc_cur%FOUND */
        IF @v_gentabledesc IS NOT NULL 
          BEGIN
	    UPDATE coretitleinfo
  	    SET bisacstatusdesc = @v_gentabledesc
	    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
          END

      CLOSE bisacstatusdesc_cur 
      DEALLOCATE bisacstatusdesc_cur

      /*** Fill in SERIES DESCRIPTION ***/
      DECLARE seriesdesc_cur CURSOR FOR
    	SELECT datadesc
    	FROM gentables
    	WHERE tableid = 327 AND
	  	datacode = @v_seriescode 

      OPEN seriesdesc_cur
      FETCH NEXT FROM seriesdesc_cur INTO @v_gentabledesc 
  
      IF @@FETCH_STATUS = 0  /*seriesdesc_cur%FOUND */
        IF @v_gentabledesc IS NOT NULL 
          BEGIN
            UPDATE coretitleinfo
            SET seriesdesc = @v_gentabledesc
            WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
          END

      CLOSE seriesdesc_cur 
      DEALLOCATE seriesdesc_cur
 
      /*** Fill in SEASON information ***/
      SET @v_seasonkey = @v_source_seasonkey 
      /* If Season is missing, use estimated season */
      IF @v_seasonkey IS NULL OR @v_seasonkey = 0 
        SET @v_seasonkey = @v_source_estseasonkey 
      /* Only if season or estimated season is filled in, get description and update core table */
      IF @v_seasonkey IS NOT NULL AND @v_seasonkey <> 0 			
        BEGIN
          DECLARE season_cur CURSOR FOR
    	    SELECT seasondesc
    	    FROM season
    	    WHERE seasonkey = @v_seasonkey

          OPEN season_cur
          FETCH NEXT FROM season_cur INTO @v_seasondesc 
	 
          IF @@FETCH_STATUS = 0  /*season_cur%FOUND */
	    IF @v_seasondesc IS NOT NULL 
              BEGIN
	        UPDATE coretitleinfo
	        SET bestseasonkey = @v_seasonkey,
	  	    seasondesc = @v_seasondesc
  	        WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	      END

          CLOSE season_cur 			
	    DEALLOCATE season_cur
        END

      /*** Fill in CHILDRENS FORMAT information ***/
      DECLARE childformat_cur CURSOR FOR
    	SELECT formatchildcode
    	FROM booksimon
    	WHERE bookkey = @v_bookkey 

      OPEN childformat_cur
      FETCH NEXT FROM childformat_cur INTO @v_childformat 
 
      IF @@FETCH_STATUS = 0  /*childformat_cur%FOUND */
        IF @v_childformat IS NOT NULL AND @v_childformat <> 0 
          BEGIN
            /* Get Children's Format description */
   	    DECLARE childformatdesc_cur CURSOR FOR
    	    	SELECT datadesc
    		FROM gentables
    		WHERE tableid = 300 AND
	  		datacode = @v_childformat 

            OPEN childformatdesc_cur
	    FETCH NEXT FROM childformatdesc_cur INTO @v_gentabledesc 

    	    IF @@FETCH_STATUS = 0  /*childformatdesc_cur%FOUND */
	      IF @v_gentabledesc IS NOT NULL 
                BEGIN
	          UPDATE coretitleinfo
	          SET formatchildcode = @v_childformat,
	   	      childformatdesc = @v_gentabledesc
	          WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	        END 

            CLOSE childformatdesc_cur 
	      DEALLOCATE childformatdesc_cur
          END

      CLOSE childformat_cur 
      DEALLOCATE childformat_cur

      /*** Fill in IMPRINT information ****/
      DECLARE orgentry_cur CURSOR FOR
    	SELECT o.orgentrykey, o.orgentrydesc
    	FROM bookorgentry bo, orgentry o
    	WHERE bo.orgentrykey = o.orgentrykey AND
		bo.bookkey = @v_bookkey AND
	  	bo.orglevelkey = @v_imprintlevel

      OPEN orgentry_cur
      FETCH NEXT FROM orgentry_cur INTO @v_imprintkey, @v_imprintdesc 

      IF @@FETCH_STATUS =0  /*orgenty_cur%FOUND*/
        BEGIN 
          IF @v_imprintdesc IS NOT NULL 
            BEGIN
              UPDATE coretitleinfo
	        SET imprintkey = @v_imprintkey,
  		  imprintname = @v_imprintdesc
	        WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
            END 
        END

      CLOSE orgentry_cur
      DEALLOCATE orgentry_cur

      /*** Fill in TMM HEADER LEVEL 1 information ****/
      IF @v_imprintlevel = @v_tmmhdrlevel1
	/* If TMM Header Level 1 is identical to Imprint level, use retrieved info above */
	UPDATE coretitleinfo
	SET tmmheaderorg1key = @v_imprintkey,
	    tmmheaderorg1desc = @v_imprintdesc
	WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

      ELSE
        BEGIN
      	DECLARE orgentry_cur CURSOR FOR
    	    SELECT o.orgentrykey, o.orgentrydesc
    	    FROM bookorgentry bo, orgentry o
    	    WHERE bo.orgentrykey = o.orgentrykey AND
			bo.bookkey = @v_bookkey AND
		  	bo.orglevelkey = @v_tmmhdrlevel1

	  OPEN orgentry_cur
	  FETCH NEXT FROM orgentry_cur INTO @v_tmmhdrkey1, @v_tmmhdrorgdesc1
	
	  IF @@FETCH_STATUS =0  /*orgentry_cur %FOUND*/
	    IF @v_tmmhdrorgdesc1 IS NOT NULL
	      UPDATE coretitleinfo
	      SET tmmheaderorg1key = @v_tmmhdrkey1,
		tmmheaderorg1desc = @v_tmmhdrorgdesc1
	      WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  CLOSE orgentry_cur
	  DEALLOCATE orgentry_cur
	END

	/*** Fill in TMM HEADER LEVEL 2 information ****/
	IF @v_imprintlevel = @v_tmmhdrlevel2
	/* If TMM Header Level 2 is identical to Imprint level, use retrieved info above */
	  UPDATE coretitleinfo
	  SET tmmheaderorg2key = @v_imprintkey,
		tmmheaderorg2desc = @v_imprintdesc
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

	ELSE IF @v_tmmhdrlevel1 = @v_tmmhdrlevel2
  	  /* If TMM Header Level 2 is identical to TMM Header Level 1, use retrieved info above */
	  UPDATE coretitleinfo
	  SET tmmheaderorg2key = @v_tmmhdrkey1,
	  	tmmheaderorg2desc = @v_tmmhdrorgdesc1
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	ELSE
          BEGIN
	    DECLARE orgentry_cur CURSOR FOR
    	      SELECT o.orgentrykey, o.orgentrydesc
    	      FROM bookorgentry bo, orgentry o
    	      WHERE bo.orgentrykey = o.orgentrykey AND
			bo.bookkey = @v_bookkey AND
		  	bo.orglevelkey = @v_tmmhdrlevel2

	    OPEN orgentry_cur
	    FETCH orgentry_cur INTO @v_tmmhdrkey2, @v_tmmhdrorgdesc2

	    IF @@FETCH_STATUS = 0 /*orgentry_cur %FOUND*/
	      IF @v_tmmhdrorgdesc2 IS NOT NULL
		UPDATE coretitleinfo
		SET tmmheaderorg2key = @v_tmmhdrkey2,
		    tmmheaderorg2desc = @v_tmmhdrorgdesc2
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	    CLOSE orgentry_cur
	    DEALLOCATE orgentry_cur
	  END

	/*** Fill in ORGENTRY FILTER string ****/
	DECLARE bookorgentry_cur CURSOR FOR
	  SELECT orglevelkey, orgentrykey
 	  FROM bookorgentry
	  WHERE bookkey = @v_bookkey

	OPEN bookorgentry_cur

	FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey

	SET @v_counter = 1

	WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		IF @v_counter = 1  /* bookorgentry_cur%ROWCOUNT*/
		  SET @v_orgentryfilter = '(' + LTRIM(STR(@v_orgentrykey))
	  ELSE		
		SET @v_orgentryfilter = @v_orgentryfilter + ',' + LTRIM(STR(@v_orgentrykey))
		
		FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey

		SET @v_counter = @v_counter + 1
	  END  /* END LOOP bookorgentry_cursor */

	IF @v_orgentryfilter IS NOT NULL
	  BEGIN
		SET @v_orgentryfilter = @v_orgentryfilter + ')'

		UPDATE coretitleinfo
		SET orgentryfilter = @v_orgentryfilter
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END

	CLOSE bookorgentry_cur
	DEALLOCATE bookorgentry_cur

      /*** Fill in AGE and GRADE information ***/
      SET @v_allagesind = @v_source_allagesind 
      SET @v_agelowupind = @v_source_agelowupind 
      SET @v_agehighupind = @v_source_agehighupind 
      SET @v_agelow = @v_source_agelow 
      SET @v_agehigh = @v_source_agehigh 
      SET @v_gradelowupind = @v_source_gradelowupind 
      SET @v_gradehighupind = @v_source_gradehighupind 
      SET @v_gradelow = @v_source_gradelow 
      SET @v_gradehigh = @v_source_gradehigh 

      IF @v_agelow IS NULL 
        SET @v_agelow = 0 
   
      IF @v_agehigh IS NULL 
        SET @v_agehigh = 0 

      IF @v_gradelow IS NULL 
        SET @v_gradelow = '0' 
	 	
      IF @v_gradehigh IS NULL 
        SET @v_gradehigh = '0' 
   
      IF @v_allagesind = 1 
        SET @v_ageinfo = 'All' 
      ELSE IF @v_agelowupind = 1 
        SET @v_ageinfo = 'Up to ' + LTRIM(STR(@v_agehigh))
      ELSE IF @v_agehighupind = 1 
        SET @v_ageinfo = LTRIM(STR(@v_agelow)) + ' and up' 
      ELSE IF @v_agelow <> 0 AND @v_agehigh <> 0 
        SET @v_ageinfo = LTRIM(STR(@v_agelow)) + ' to ' + LTRIM(STR(@v_agehigh))

      IF @v_gradelowupind = 1 
        SET @v_gradeinfo = 'Up to ' + @v_gradehigh
      ELSE IF @v_gradehighupind = 1 
        SET @v_gradeinfo = @v_gradelow + ' and up' 
      ELSE IF @v_gradelow <> '0' AND @v_gradehigh <> '0' 
        SET @v_gradeinfo = @v_gradelow + ' to ' + @v_gradehigh
  
      IF @v_ageinfo IS NOT NULL AND @v_gradeinfo IS NOT NULL 
        SET @v_agegradeinfo = @v_ageinfo + ' / ' + @v_gradeinfo 
      ELSE
        BEGIN
         IF @v_gradeinfo IS NOT NULL 
           SET @v_agegradeinfo = '/ ' + @v_gradeinfo 
          ELSE IF @v_ageinfo IS NOT NULL 
            SET @v_agegradeinfo = @v_ageinfo 
        END

      IF @v_agegradeinfo IS NOT NULL 		
        BEGIN
          UPDATE coretitleinfo
          SET ageinfo = @v_agegradeinfo
          WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
        END  

      /*** Fill in the price ***/
      DECLARE price_cur CURSOR FOR
    	SELECT budgetprice, finalprice
    	FROM bookprice
    	WHERE bookkey = @v_bookkey AND
		pricetypecode = @v_pricetype AND
	  	currencytypecode = @v_currency 

      OPEN price_cur
      FETCH NEXT FROM price_cur INTO @v_budgetprice, @v_finalprice 

      IF @@FETCH_STATUS = 0  /*price_cur%FOUND */
        BEGIN
          /* If final price is missing, use budget price */
          IF @v_finalprice IS NULL OR @v_finalprice = 0 
		BEGIN
	      	SET @v_finalprice = @v_budgetprice
			SET @v_finalpriceind = 0
		END
	    ELSE
		BEGIN
			SET @v_finalpriceind = 1
		END
       
          /* Only if budget or final price is filled in, update core table */
          IF @v_finalprice IS NOT NULL AND @v_finalprice <> 0 			
            BEGIN
              UPDATE coretitleinfo
              SET tmmprice = @v_finalprice, finalpriceind = @v_finalpriceind
              WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
            END
        END

      CLOSE price_cur 
      DEALLOCATE price_cur 

	/*** Fill in ISBN ***/
	SELECT @v_isbn = isbn
	FROM isbn
	WHERE bookkey = @v_bookkey

	IF @v_isbn IS NOT NULL
	  BEGIN
		UPDATE coretitleinfo
		SET isbn = @v_isbn, isbnx = REPLACE(@v_isbn, '-', '')
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END

     
  	FETCH NEXT FROM source_cur INTO @v_source_bookkey,@v_source_printingkey,@v_source_issuenumber,
	@v_source_productnumber,@v_source_title,@v_source_titleprefix,@v_source_shorttitle,
	@v_source_pubmonthcode,@v_source_pubyear,@v_source_mediatypecode,@v_source_mediatypesubcode,
	@v_source_editioncode,@v_source_bisacstatuscode,@v_source_titlestatuscode,@v_source_titletypecode,
	@v_source_seriescode,@v_source_estseasonkey,@v_source_seasonkey,@v_source_linklevelcode,
	@v_source_standardind,@v_source_publishtowebind,@v_source_sendtoeloind,@v_source_workkey,
	@v_source_titleprefixupper,@v_source_productnumberx,@v_source_allagesind,
	@v_source_agelowupind,@v_source_agehighupind,@v_source_agelow,@v_source_agehigh,
	@v_source_gradelowupind,@v_source_gradehighupind,@v_source_gradehigh,@v_source_gradelow  

    END  /*LOOP source_cursor */

  CLOSE source_cur
  DEALLOCATE source_cur

END
GO

/**** Execute the coretitle load stored procedure *****/
EXEC CoreTitleInfo_Load
GO

