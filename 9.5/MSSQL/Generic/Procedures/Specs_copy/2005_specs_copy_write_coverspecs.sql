IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_coverspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_coverspecs
END
GO

CREATE PROCEDURE Specs_Copy_write_coverspecs (
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind			 INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE
	@v_vendorkey	INT,
   @v_stock		INT,
	@v_finish   INT,
	@v_bleedind				VARCHAR(1),
	@v_inks		INT,
	@v_firstcovinks INT,
	@v_secondcovinks INT,
	@v_description	VARCHAR(100),
	@v_thirdcovinks INT,
	@v_fourthcovinks INT,
	@v_foilind			VARCHAR(1),
	@v_diecutind VARCHAR(1),
	@v_embossedind		VARCHAR(1),
	@v_dupfilm			VARCHAR(1),
	@v_perfectedprintind	VARCHAR(1),
	@v_offlineind	VARCHAR(1),
   @v_speceffvendor INT,
	@v_maxnumbercolors			VARCHAR(4),
	@v_minnumbersheets	INT,
	@v_numberout    INT,
	@v_spoilagepercent	FLOAT(1),
   @v_costgenerateoption	INT,
   @v_stocksource INT,
   @v_manualsheetsind VARCHAR(1),
	@v_totalnumbersheets   INT,
   @v_count INT,
   @v_toembossedind  VARCHAR(1), 
   @v_todiecutind  VARCHAR(1), 
   @v_tofoilind  VARCHAR(1), 
   @v_ConvFinish  INT, 
   @v_ConvStock  INT, 
   @v_ConvVendorkey   INT, 
   @v_toinks  INT,
   @v_colorkey  INT,
   @v_colordesc VARCHAR(100)

	DECLARE covercolor_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM covercolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 
BEGIN

	SELECT @v_count = count(*)
     FROM coverspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_finish=finish, @v_embossedind = embossedind,@v_diecutind=diecutind,@v_perfectedprintind= perfectedprintind, 
			@v_foilind=foilind,@v_stock= stock,@v_inks=inks,@v_speceffvendor=speceffvendor,@v_firstcovinks=firstcovinks,@v_secondcovinks=secondcovinks,
 			@v_thirdcovinks=thirdcovinks,@v_fourthcovinks=fourthcovinks,@v_dupfilm=dupfilm,	@v_description=description,@v_offlineind=offlineind,
         @v_maxnumbercolors=maxnumbercolors,@v_minnumbersheets=minnumbersheets,@v_numberout=numberout,@v_spoilagepercent=spoilagepercent,
         @v_costgenerateoption=costgenerateoption,@v_stocksource=stocksource
		FROM coverspecs
	  WHERE (bookkey = @i_from_bookkey) AND
			(printingkey = @i_from_printingkey) 
    END
	ELSE
   BEGIN
		SET @v_vendorkey	= NULL
   	SET @v_stock	= NULL
		SET @v_finish = NULL
		SET @v_bleedind	= NULL
		SET @v_inks	= NULL
		SET @v_firstcovinks = NULL
		SET @v_secondcovinks = NULL
		SET @v_description	= NULL
		SET @v_thirdcovinks = NULL
		SET @v_fourthcovinks = NULL
		SET @v_foilind			= NULL
		SET @v_diecutind = NULL
		SET @v_embossedind = NULL
		SET @v_dupfilm	= NULL
		SET @v_perfectedprintind	= NULL
		SET @v_offlineind	= NULL
   	SET @v_speceffvendor = NULL
		SET @v_maxnumbercolors = NULL
		SET @v_minnumbersheets = NULL
		SET @v_numberout = NULL
		SET @v_spoilagepercent = NULL
   	SET @v_costgenerateoption	= NULL
   	SET @v_stocksource = NULL
   	SET @v_manualsheetsind = NULL
		SET @v_totalnumbersheets   = NULL
  	END

   
	IF @i_specind = 1
   BEGIN
		INSERT INTO coverspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, foilind, stock, inks,
			dupfilm, lastuserid, lastmaintdate, speceffvendor,firstcovinks, secondcovinks, thirdcovinks, fourthcovinks,
			description, offlineind, maxnumbercolors, minnumbersheets,numberout, spoilagepercent, costgenerateoption, stocksource)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectedprintind,@v_foilind,@v_stock,@v_inks,
			@v_dupfilm,@i_userid,getdate(),@v_speceffvendor,@v_firstcovinks,@v_secondcovinks,@v_thirdcovinks,@v_fourthcovinks,
			@v_description,@v_offlineind,@v_maxnumbercolors, @v_minnumbersheets,@v_numberout,@v_spoilagepercent,@v_costgenerateoption,@v_stocksource) 
	END
   IF @i_specind = 0
	BEGIN
		SELECT @v_count = count(*)
		  FROM coverspecs
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey

      IF @v_count = 0
      BEGIN
		INSERT INTO coverspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, foilind, stock, inks,
			dupfilm, lastuserid, lastmaintdate, speceffvendor,firstcovinks, secondcovinks, thirdcovinks, fourthcovinks,
			description, offlineind, maxnumbercolors, minnumbersheets,numberout, spoilagepercent, costgenerateoption, stocksource)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectedprintind,@v_foilind,@v_stock,@v_inks,
			@v_dupfilm,@i_userid,getdate(),@v_speceffvendor,@v_firstcovinks,@v_secondcovinks,@v_thirdcovinks,@v_fourthcovinks,
			@v_description,@v_offlineind,@v_maxnumbercolors, @v_minnumbersheets,@v_numberout,@v_spoilagepercent,@v_costgenerateoption,@v_stocksource) 
		END
      ELSE
      BEGIN
			SELECT @v_toembossedind=embossedind,@v_todiecutind=diecutind,@v_tofoilind=foilind,@v_ConvFinish=finish,@v_ConvStock=stock,@v_ConvVendorkey=vendorkey,@v_toinks=inks
			  FROM coverspecs
	  	    WHERE bookkey = @i_to_bookkey AND
				 	printingkey = @i_to_printingkey

			IF @v_toembossedind IS NOT NULL 
         	SET @v_embossedind = @v_toembossedind
			IF @v_todiecutind IS NOT NULL 
         	SET @v_diecutind = @v_todiecutind
			IF @v_tofoilind IS  NOT NULL 
         	SET @v_foilind = @v_tofoilind
			IF @v_convvendorkey IS NOT NULL AND @v_convvendorkey <> 0
         	SET @v_vendorkey = @v_convvendorkey
			IF @v_toinks IS NOT NULL 
         	SET @v_inks = @v_toinks
			IF @v_ConvStock IS NOT NULL AND @v_ConvStock <> 0
         	SET @v_Stock = @v_ConvStock
			IF @v_ConvFinish IS NOT NULL AND @v_ConvFinish <> 0
         	SET @v_finish = @v_ConvFinish
	

			UPDATE coverspecs
			SET vendorkey = @v_vendorkey,embossedind = @v_embossedind,diecutind = @v_diecutind,foilind = @v_foilind,finish = @v_finish,
				 perfectedprintind = @v_perfectedprintind,stock = @v_stock,inks = @v_inks,dupfilm = @v_dupfilm,lastuserid = @i_userid,
			 	 lastmaintdate = getdate(),speceffvendor = @v_speceffvendor,firstcovinks = @v_firstcovinks,secondcovinks = @v_secondcovinks,
		 		 thirdcovinks = @v_thirdcovinks,fourthcovinks = @v_fourthcovinks,description= @v_description,offlineind = @v_offlineind,
				 maxnumbercolors = @v_maxnumbercolors, minnumbersheets = @v_minnumbersheets,numberout = @v_numberout,spoilagepercent = @v_spoilagepercent,
				 costgenerateoption = @v_costgenerateoption,stocksource = @v_stocksource 
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey
		END
  END -- specind = 1

	-- Copy all notes associated with coverspecs
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,4,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

	
	-- Copy all covercolor specs
	OPEN covercolor_cur
	
	FETCH NEXT FROM covercolor_cur INTO @v_colorkey, @v_colordesc
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO covercolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
		FETCH NEXT FROM covercolor_cur INTO @v_colorkey, @v_colordesc
				 
	END --covercolor_cur LOOP
				
	CLOSE covercolor_cur
	DEALLOCATE covercolor_cur
END
go