IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_text') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_text
END
GO

CREATE PROCEDURE Specs_Copy_write_text	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind			 INT,
  @i_printingnum      INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE
	@v_vendorkey	INT,
   @v_printingmethod		INT,
	@v_filmavailableind	VARCHAR(1),
	@v_bleedind				VARCHAR(1),
	@v_inks		INT,
	@v_headermargin	VARCHAR(15),
	@v_guttermargin	VARCHAR(15),
	@v_inkdescription	VARCHAR(100),
	@v_dupfilm			VARCHAR(1),
	@v_film				INT,
	@v_blues				VARCHAR(15),
	@v_illusvendorkey	INT,
	@v_linecuts			VARCHAR(1),
	@v_stainind			VARCHAR(1),
	@v_impositionind	VARCHAR(2),
	@v_plateavailind	VARCHAR(1),
	@v_designer			VARCHAR(25),
	@v_compositor		VARCHAR(25),
	@v_headerspecs    INT,
	@v_halftonesind	VARCHAR(1),
   @v_count				INT,
   @v_convheadermargin VARCHAR(15),
   @v_convguttermargin VARCHAR(15),
	@v_convbleedind     VARCHAR(1),
   @v_convfilm 	INT,
   @v_convinks	INT,
   @v_convprintingmethod INT,
   @v_convvendorkey	INT,
   @v_convinkdescription VARCHAR(100),
	@v_colorkey  INT,
   @v_colordesc VARCHAR(100)	

	DECLARE textcolor_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM textcolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 


BEGIN

	SELECT @v_count = count(*)
     FROM textspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT @v_vendorkey=vendorkey,@v_printingmethod=printingmethod,@v_filmavailableind=filmavailableind,@v_bleedind=bleedind,@v_inks=inks,
				 @v_headermargin=headermargin,@v_guttermargin=guttermargin,@v_inkdescription=inkdescription,@v_dupfilm=dupfilm,@v_film=film,
				 @v_blues=blues,@v_illusvendorkey=illusvendorkey,@v_linecuts=linecuts,@v_stainind=stainind,@v_impositionind=impositionind,
				 @v_plateavailind=plateavailind,@v_designer=designer,@v_compositor=compositor,@v_headerspecs=headerspecs,@v_halftonesind= halftonesind
		 FROM textspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) ;
    END
	ELSE
   BEGIN
		SET @v_vendorkey	= NULL
   	SET @v_printingmethod = NULL
		SET @v_filmavailableind	= NULL
		SET @v_bleedind = NULL
		SET @v_inks	= NULL
		SET @v_headermargin = NULL
		SET @v_guttermargin = NULL
		SET @v_inkdescription= NULL
		SET @v_dupfilm	= NULL
		SET @v_film	= NULL
		SET @v_blues	= NULL
		SET @v_illusvendorkey = NULL
		SET @v_linecuts = NULL
		SET @v_stainind = NULL
		SET @v_impositionind	= NULL
		SET @v_plateavailind	= NULL
		SET @v_designer	= NULL
		SET @v_compositor	= NULL
		SET @v_headerspecs = NULL
		SET @v_halftonesind	= NULL
  	END

   IF @i_printingnum > 1
      SET @v_filmavailableind	= 'Y'



	IF @i_specind = 1
   BEGIN
		INSERT INTO textspecs (bookkey,printingkey,vendorkey,printingmethod,bleedind,inks,headermargin,guttermargin,inkdescription,dupfilm,
			film,blues,illusvendorkey,lastuserid,lastmaintdate,filmavailableind,linecuts,stainind,impositionind,plateavailind,designer,compositor,
			headerspecs,halftonesind)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_printingmethod,@v_bleedind,@v_inks,@v_headermargin,@v_guttermargin,@v_inkdescription,@v_dupfilm,
			@v_film,@v_blues,@v_illusvendorkey,@i_userid,getdate(),@v_filmavailableind,@v_linecuts,@v_stainind,@v_impositionind,@v_plateavailind,@v_designer,@v_compositor,
			@v_headerspecs,@v_halftonesind) 
	END
   IF @i_specind = 0
	BEGIN
		SELECT @v_count = count(*)
		  FROM textspecs
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey

      IF @v_count = 0
      BEGIN
			INSERT INTO textspecs (bookkey,printingkey,vendorkey,printingmethod,bleedind,inks,headermargin,guttermargin,inkdescription,dupfilm,
				film,blues,illusvendorkey,lastuserid,lastmaintdate,filmavailableind,linecuts,stainind,impositionind,plateavailind,designer,compositor,
				headerspecs,halftonesind)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_printingmethod,@v_bleedind,@v_inks,@v_headermargin,@v_guttermargin,@v_inkdescription,@v_dupfilm,
				@v_film,@v_blues,@v_illusvendorkey,@i_userid,getdate(),@v_filmavailableind,@v_linecuts,@v_stainind,@v_impositionind,@v_plateavailind,@v_designer,@v_compositor,
				@v_headerspecs,@v_halftonesind) 
		END
      ELSE
      BEGIN
			SELECT @v_convheadermargin =headermargin,@v_convguttermargin=guttermargin,@v_convbleedind=bleedind,
           @v_convfilm=film,@v_convinks=inks,@v_convprintingmethod=printingmethod,@v_convvendorkey=vendorkey,@v_convinkdescription=inkdescription
			FROM textspecs
		  WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey

			IF @v_convinks IS NOT NULL AND @v_convinks <> 0
         	SET @v_inks = @v_convinks
			IF @v_convprintingmethod IS NOT NULL AND @v_convprintingmethod <> 0
         	SET @v_printingmethod = @v_convprintingmethod
			IF @v_convinkdescription IS NOT NULL 
         	SET @v_inkdescription = @v_convinkdescription
			IF @v_convvendorkey IS NOT NULL AND @v_convvendorkey <> 0
         	SET @v_vendorkey = @v_convvendorkey
			IF @v_convheadermargin IS NOT NULL 
         	SET @v_headermargin = @v_convheadermargin
			IF @v_convguttermargin IS NOT NULL 
         	SET @v_guttermargin = @v_convguttermargin
			IF @v_convbleedind IS NOT NULL 
         	SET @v_bleedind = @v_convbleedind
			IF @v_convfilm IS NOT NULL AND @v_convfilm <> 0
         	SET @v_film = @v_convfilm

			UPDATE textspecs
				SET vendorkey = @v_vendorkey,printingmethod = @v_printingmethod,bleedind = @v_bleedind,inks = @v_inks,headermargin = @v_headermargin,
					 guttermargin = @v_guttermargin,inkdescription = @v_inkdescription,dupfilm = @v_dupfilm,film = @v_film,blues = @v_blues,
					 illusvendorkey = @v_illusvendorkey,lastuserid = @i_userid,lastmaintdate = getdate(),filmavailableind = @v_filmavailableind,
					 linecuts = @v_linecuts,stainind = @v_stainind,impositionind = @v_impositionind,plateavailind = @v_plateavailind,
		          designer = @v_designer,compositor = @v_compositor,headerspecs = @v_headerspecs,halftonesind = @v_halftonesind
			  WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey
		END
  END -- specind = 1

	-- Copy all textcolor specs
		OPEN textcolor_cur
	
		FETCH NEXT FROM textcolor_cur INTO @v_colorkey, @v_colordesc
		
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN
	
			INSERT INTO textcolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
				VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
			FETCH NEXT FROM textcolor_cur INTO @v_colorkey, @v_colordesc
				 
		END --textcolor_cur LOOP
				
		CLOSE textcolor_cur
		DEALLOCATE textcolor_cur
END
go