IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookdetail') AND type = 'TR')
	DROP TRIGGER dbo.core_bookdetail
GO

CREATE TRIGGER core_bookdetail ON bookdetail
FOR INSERT, UPDATE AS
IF UPDATE (titleprefix) OR 
	UPDATE (mediatypecode) OR 
	UPDATE (mediatypesubcode) OR 
	UPDATE (editioncode) OR 
    UPDATE (editionnumber) OR
   	UPDATE (additionaleditinfo) OR
	UPDATE (bisacstatuscode) OR 
	UPDATE (seriescode) OR 
	UPDATE (origincode) OR 
	UPDATE (publishtowebind) OR
	UPDATE (titleverifycode) OR
	UPDATE (allagesind) OR
	UPDATE (agelowupind) OR
	UPDATE (agehighupind) OR
	UPDATE (agelow) OR
	UPDATE (agehigh) OR
	UPDATE (gradelowupind) OR
	UPDATE (gradehighupind) OR
	UPDATE (gradelow) OR
	UPDATE (gradehigh) OR
  UPDATE(csapprovalcode)

BEGIN
	DECLARE @v_bookkey 		INT,
		@v_printingkey		INT,
		@v_titleprefix 		VARCHAR(15), 
		@v_mediatypecode 		SMALLINT, 
		@v_mediatypesubcode 	SMALLINT, 
		@v_editioncode 		INT, 
        @v_editionnumber INT,
        @v_additionaleditinfo VARCHAR(100),
		@v_bisacstatuscode 	SMALLINT, 
		@v_titleverifycode 	SMALLINT, 
		@v_titleverifydesc 	varchar(40), 
		@v_seriescode 		INT, 
		@v_origincode 		INT, 
		@v_publishtowebind 	INT,
		@v_allagesind 		TINYINT,
		@v_agelowupind 		TINYINT,
		@v_agehighupind 	TINYINT,
		@v_agelow 		FLOAT,
		@v_agehigh 		FLOAT,
		@v_gradelowupind 	TINYINT,
		@v_gradehighupind 	TINYINT,
		@v_gradelow 		VARCHAR(4),
		@v_gradehigh 		VARCHAR(4),
		@v_ageinfo		VARCHAR(40),
		@v_gradeinfo		VARCHAR(40),
		@v_agegradeinfo		VARCHAR(40),
		@v_formatname		VARCHAR(120),
		@v_editiondesc		VARCHAR(40),
		@v_bisacstatusdesc	VARCHAR(40),
		@v_seriesdesc		VARCHAR(40),
		@v_origindesc		VARCHAR(40),
    @v_csapprovalcode INT

	
	SELECT @v_bookkey =i.bookkey,
	       @v_titleprefix =i.titleprefix,  
	       @v_mediatypecode=i.mediatypecode,  
	       @v_mediatypesubcode=i.mediatypesubcode,  
	       @v_editioncode =i.editioncode,  
           @v_editionnumber = i.editionnumber,
           @v_editiondesc = editiondescription,
           @v_additionaleditinfo = additionaleditinfo,
	       @v_bisacstatuscode=i.bisacstatuscode,  
	       @v_seriescode =i.seriescode,  
	       @v_origincode =i.origincode,  
	       @v_publishtowebind=i.publishtowebind, 
	       @v_allagesind =i.allagesind, 
	       @v_agelowupind=i.agelowupind, 
	       @v_agehighupind=i.agehighupind, 
	       @v_agelow =i.agelow, 
	       @v_agehigh=i.agehigh, 
	       @v_gradelowupind =i.gradelowupind, 
	       @v_gradehighupind=i.gradehighupind, 
	       @v_gradelow =i.gradelow, 
	       @v_gradehigh=i.gradehigh,
		   @v_titleverifycode=i.titleverifycode,
           @v_csapprovalcode = i.csapprovalcode
	FROM inserted i

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	/*** Fill in AGE and GRADE information ***/
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
	ELSE IF @v_agelowupind = 1 AND @v_agehigh > 0
	   SET @v_ageinfo = 'Up to ' + LTRIM(STR(@v_agehigh, 10, 2))
	ELSE IF @v_agehighupind = 1 AND @v_agelow > 0
	   SET @v_ageinfo = LTRIM(STR(@v_agelow, 10, 2)) + ' and up' 
	ELSE IF @v_agelow <> 0 AND @v_agehigh <> 0 
	   SET @v_ageinfo = LTRIM(STR(@v_agelow, 10, 2)) + ' to ' + LTRIM(STR(@v_agehigh, 10, 2))
   ELSE IF @v_agelow <> 0 AND @v_agehigh = 0 
      SET @v_ageinfo = LTRIM(STR(@v_agelow, 10, 2))

	IF @v_gradelowupind = 1 AND @v_gradehigh <> '0' 
	   SET @v_gradeinfo = 'Up to ' + @v_gradehigh
	ELSE IF @v_gradehighupind = 1 AND @v_gradelow <> '0'
	   SET @v_gradeinfo = @v_gradelow + ' and up' 
	ELSE IF @v_gradelow <> '0' AND @v_gradehigh <> '0' 
	   SET @v_gradeinfo = @v_gradelow + ' to ' + @v_gradehigh
	ELSE IF @v_gradelow <> '0' AND @v_gradehigh = '0' 
      SET @v_gradeinfo = @v_gradelow
  
	IF @v_ageinfo IS NOT NULL AND @v_gradeinfo IS NOT NULL 
	   SET @v_agegradeinfo = @v_ageinfo + ' / ' + @v_gradeinfo 
	ELSE
	   BEGIN
	     IF @v_gradeinfo IS NOT NULL 
	        SET @v_agegradeinfo = '/ ' + @v_gradeinfo 
	     ELSE IF @v_ageinfo IS NOT NULL 
	        SET @v_agegradeinfo = @v_ageinfo 
	     END

	/*** Fill in description fields ***/
	exec subgent_longdesc 312,@v_mediatypecode,@v_mediatypesubcode,@v_formatname OUTPUT
	
  	-- This function returns a value for editiondescription based on editioncode, editionnumber and additionaleditinfo
	SET @v_editiondesc = dbo.qtitle_get_edition_description(@v_bookkey)
	
	exec gentables_longdesc 314,@v_bisacstatuscode,@v_bisacstatusdesc OUTPUT
	exec gentables_longdesc 327,@v_seriescode,@v_seriesdesc OUTPUT
	exec gentables_longdesc 315,@v_origincode,@v_origindesc OUTPUT
	exec gentables_longdesc 513,@v_titleverifycode,@v_titleverifydesc OUTPUT

	UPDATE coretitleinfo
	SET titleprefix=@v_titleprefix,
	    titleprefixupper=REPLACE(UPPER(@v_titleprefix),' ',''),
	    mediatypecode=@v_mediatypecode,
	    mediatypesubcode=@v_mediatypesubcode ,
	    formatname=@v_formatname ,
	    editioncode =@v_editioncode ,
	    editiondesc =@v_editiondesc ,
      editionnumber = @v_editionnumber,
	    bisacstatuscode=@v_bisacstatuscode ,
	    bisacstatusdesc=@v_bisacstatusdesc ,
	    seriescode=@v_seriescode ,
	    seriesdesc=@v_seriesdesc ,
	    origincode=@v_origincode ,
	    origindesc=@v_origindesc ,
	    publishtowebind=@v_publishtowebind ,
	    titleverifydesc=@v_titleverifydesc ,
	    titleverifycode=@v_titleverifycode ,
	    ageinfo =@v_agegradeinfo,
      csapprovalcode = @v_csapprovalcode
	WHERE bookkey = @v_bookkey
END
GO

