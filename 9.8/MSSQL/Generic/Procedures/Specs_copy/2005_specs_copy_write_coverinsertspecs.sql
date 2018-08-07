IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_coverinsert') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_coverinsert
END
GO

CREATE PROCEDURE Specs_Copy_write_coverinsert (
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
   @v_specialeffectsind VARCHAR(1),
   @v_stock		INT,
	@v_finish   INT,
	@v_inks		INT,
   @v_speceffvendor INT,
	@v_firstcovinks INT,
	@v_secondcovinks INT,
	@v_thirdcovinks INT,
	@v_fourthcovinks INT,
	@v_foilind			VARCHAR(1),
	@v_diecutind VARCHAR(1),
	@v_embossedind		VARCHAR(1),
	@v_dupfilm			VARCHAR(1),
   @v_perfectprintind VARCHAR(1),
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

	DECLARE covinsertcolor_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM covinsertcolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 
BEGIN

	SELECT @v_count = count(*)
     FROM coverinsertspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  


		SELECT  @v_vendorkey=vendorkey, @v_finish=finish, @v_embossedind = embossedind,@v_diecutind=diecutind,@v_perfectprintind= perfectedprintind, 
			@v_foilind=foilind,@v_stock= stock,@v_inks=inks,@v_speceffvendor=speceffvendor,@v_firstcovinks=firstcovinks,@v_secondcovinks=secondcovinks,
 			@v_thirdcovinks=thirdcovinks,@v_fourthcovinks=fourthcovinks,@v_dupfilm=dupfilm,
			@v_specialeffectsind=specialeffectsind,@v_speceffvendor=speceffvendor
		FROM coverinsertspecs
	  WHERE (bookkey = @i_from_bookkey) AND
		 	 (printingkey = @i_from_printingkey)
    END 
	ELSE
   BEGIN
		SET @v_vendorkey	= NULL
   	SET @v_stock	= NULL
		SET @v_finish = NULL
		SET @v_inks	= NULL
		SET @v_firstcovinks = NULL
		SET @v_secondcovinks = NULL
		SET @v_thirdcovinks = NULL
		SET @v_fourthcovinks = NULL
		SET @v_foilind			= NULL
		SET @v_diecutind = NULL
      SET @v_perfectprintind = NULL
		SET @v_embossedind = NULL
		SET @v_dupfilm	= NULL
 		SET @v_speceffvendor = NULL
      SET @v_specialeffectsind = NULL
	END

   
	IF @i_specind = 1
   BEGIN
		INSERT INTO coverinsertspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, foilind, stock, inks,
			dupfilm, lastuserid, lastmaintdate, firstcovinks, secondcovinks, thirdcovinks, fourthcovinks,
			speceffvendor,specialeffectsind)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectprintind,@v_foilind,@v_stock,@v_inks,
			@v_dupfilm,@i_userid,getdate(),@v_firstcovinks,@v_secondcovinks,@v_thirdcovinks,@v_fourthcovinks,
			@v_speceffvendor,@v_specialeffectsind) 
	END
   IF @i_specind = 0
	BEGIN
		SELECT @v_count = count(*)
		  FROM coverinsertspecs
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey

      IF @v_count = 0
      BEGIN
		INSERT INTO coverinsertspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, foilind, stock, inks,
			dupfilm, lastuserid, lastmaintdate, firstcovinks, secondcovinks, thirdcovinks, fourthcovinks,
			speceffvendor,specialeffectsind)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectprintind,@v_foilind,@v_stock,@v_inks,
			@v_dupfilm,@i_userid,getdate(),@v_firstcovinks,@v_secondcovinks,@v_thirdcovinks,@v_fourthcovinks,
			@v_speceffvendor,@v_specialeffectsind)  
		END
      ELSE
      BEGIN
			SELECT @v_toembossedind=embossedind,@v_todiecutind=diecutind,@v_tofoilind=foilind,@v_convfinish=finish,@v_convstock=stock,
             @v_convvendorkey=vendorkey,@v_toinks=inks
			  FROM coverinsertspecs
	  	    WHERE bookkey = @i_to_bookkey AND
				 	printingkey = @i_to_printingkey

			IF @v_toembossedind IS NULL AND @v_toembossedind <> ''
         	SET @v_embossedind = @v_toembossedind
			IF @v_todiecutind IS NULL AND @v_todiecutind <> ''
         	SET @v_diecutind = @v_todiecutind
			IF @v_tofoilind IS NULL AND @v_tofoilind <> ''
         	SET @v_foilind = @v_tofoilind
--			IF @v_convvendorkey IS NULL AND @v_convvendorkey <> 0
--         	SET @v_vendorkey = @v_convvendorkey
--			IF @v_toinks IS NULL AND @v_toinks <> ''
--         	SET @v_inks = @v_toinks
--			IF @v_ConvStock IS NULL AND @v_ConvStock <> 0
--         	SET @v_Stock = @v_ConvStock
--			IF @v_ConvFinish IS NULL AND @v_ConvFinish <> 0
--         	SET @v_finish = @v_ConvFinish


			UPDATE coverinsertspecs
			SET vendorkey = @v_vendorkey,embossedind = @v_embossedind,diecutind = @v_diecutind,foilind = @v_foilind,finish = @v_finish,
				 perfectedprintind = @v_perfectprintind,stock = @v_stock,inks = @v_inks,dupfilm = @v_dupfilm,lastuserid = @i_userid,
			 	 lastmaintdate = getdate(),speceffvendor = @v_speceffvendor,firstcovinks = @v_firstcovinks,secondcovinks = @v_secondcovinks,
		 		 thirdcovinks = @v_thirdcovinks,fourthcovinks = @v_fourthcovinks
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey
		END
  END -- specind = 1

	-- Copy all notes associated with coverinsertspecs
   EXEC specs_copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,27,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT


	-- Copy all covinsertcolor specs
	OPEN covinsertcolor_cur
	
	FETCH NEXT FROM covinsertcolor_cur INTO @v_colorkey, @v_colordesc
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO covinsertcolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
		FETCH NEXT FROM covinsertcolor_cur INTO @v_colorkey, @v_colordesc
				 
	END --covinsertcolor_cur LOOP
				
	CLOSE covinsertcolor_cur
	DEALLOCATE covinsertcolor_cur
END
go