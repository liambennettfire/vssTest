IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_jacketspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_jacketspecs
END
GO

CREATE PROCEDURE Specs_Copy_write_jacketspecs 	(
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
	@v_inks		INT,
	@v_diecutind VARCHAR(1),
	@v_embossedind		VARCHAR(1),
	@v_dupfilm			VARCHAR(1),
	@v_perfectedprintind	VARCHAR(1),
	@v_numberout    INT,
	@v_stocksource	INT,
   @v_manualsheetsind VARCHAR(1),
	@v_totalnumbersheets   INT,
   @v_count INT,
   @v_toembossedind  VARCHAR(1), 
   @v_todiecutind  VARCHAR(1), 
   @v_foilind VARCHAR(1),
   @v_tofoilind  VARCHAR(1), 
   @v_ConvFinish  INT, 
   @v_ConvStock  INT, 
   @v_ConvVendorkey   INT, 
   @v_toinks  INT,
   @v_colorkey  INT,
   @v_colordesc VARCHAR(100),
   @v_vendorname VARCHAR(100)

	DECLARE jackcolor_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM covercolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 
BEGIN

	SELECT @v_count = count(*)
     FROM jacketspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_finish=finish, @v_embossedind = embossedind,@v_diecutind=diecutind,@v_perfectedprintind= perfectedprintind, 
			@v_stock= stock,@v_inks=inks,@v_dupfilm=dupfilm,@v_numberout=numberout,@v_stocksource=stocksource,@v_manualsheetsind=manualsheetsind,
         @v_totalnumbersheets=totalnumbersheets
		FROM jacketspecs
				WHERE (bookkey = @i_from_bookkey) AND
						(printingkey = @i_from_printingkey) 
    END
	ELSE
   BEGIN
		SET @v_vendorkey	= NULL
   	SET @v_stock	= NULL
		SET @v_finish = NULL
		SET @v_inks	= NULL
		SET @v_diecutind = NULL
		SET @v_embossedind = NULL
		SET @v_dupfilm	= NULL
		SET @v_perfectedprintind	= NULL
		SET @v_numberout	= NULL
   	SET @v_stocksource = NULL
		SET @v_manualsheetsind = NULL
		SET @v_totalnumbersheets = NULL
  	END

   
	IF @i_specind = 1
   BEGIN
		INSERT INTO jacketspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, stock, inks,
			lastuserid, lastmaintdate, numberout, stocksource,manualsheetsind,totalnumbersheets)
		VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectedprintind,@v_stock,@v_inks,
			@i_userid,getdate(),@v_numberout,@v_stocksource,@v_manualsheetsind,@v_totalnumbersheets) 
	END
   IF @i_specind = 0
	BEGIN
		SELECT @v_count = count(*)
		  FROM jacketspecs
		 WHERE bookkey = @i_to_bookkey AND
				 printingkey = @i_to_printingkey

      IF @v_count = 0
      BEGIN
			INSERT INTO jacketspecs(bookkey, printingkey, vendorkey, finish, embossedind,diecutind, perfectedprintind, stock, inks,
				lastuserid, lastmaintdate, numberout, stocksource,manualsheetsind,totalnumbersheets)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_finish,@v_embossedind,@v_diecutind,@v_perfectedprintind,@v_stock,@v_inks,
				@i_userid,getdate(),@v_numberout,@v_stocksource,@v_manualsheetsind,@v_totalnumbersheets)  
		END
      ELSE
      BEGIN
			SELECT @v_toembossedind=embossedind, @v_todiecutind=diecutind, @v_tofoilind=foilind,@v_ConvFinish= finish,
             @v_ConvStock= stock,@v_ConvVendorkey= vendorkey,@v_toinks= inks
			 FROM jacketspecs
	  	   WHERE bookkey = @i_to_bookkey AND
				 	printingkey = @i_to_printingkey

			IF @v_toembossedind IS NULL 
         	SET @v_embossedind = @v_toembossedind
			IF @v_todiecutind IS NULL 
         	SET @v_diecutind = @v_todiecutind
			IF @v_tofoilind IS NULL 
         	SET @v_foilind = @v_tofoilind
			IF @v_convvendorkey IS NULL AND @v_convvendorkey <> 0
         	SET @v_vendorkey = @v_convvendorkey
			IF @v_toinks IS NULL 
         	SET @v_inks = @v_toinks
			IF @v_ConvStock IS NULL AND @v_ConvStock <> 0
         	SET @v_Stock = @v_ConvStock
			IF @v_ConvFinish IS NULL AND @v_ConvFinish <> 0
         	SET @v_finish = @v_ConvFinish
	

			UPDATE jacketspecs
				SET vendorkey = @v_vendorkey,embossedind = @v_embossedind,diecutind = @v_diecutind,foilind = @v_foilind,finish = @v_finish,
					 perfectedprintind = @v_perfectedprintind,stock = @v_stock,inks = @v_inks,dupfilm = @v_dupfilm,lastuserid = @i_userid,
					 lastmaintdate = getdate(),numberout=@v_numberout,stocksource=@v_stocksource,manualsheetsind=@v_manualsheetsind,
					 totalnumbersheets=@v_totalnumbersheets
			 WHERE bookkey = @i_to_bookkey AND
					 printingkey = @i_to_printingkey

		END
  END -- specind = 0

	-- update titlehistory
	IF @v_vendorkey IS NOT NULL 
	BEGIN
		SELECT @v_vendorname = name
        FROM vendor
       WHERE vendorkey = @v_vendorkey

		EXECUTE qtitle_update_titlehistory 'jacketspecs','vendorkey',@i_to_bookkey,@i_to_printingkey,0,
				  @v_vendorname,'insert',@i_userid,null,'Jacket Vendor',@o_error_code output,@o_error_desc output
		
		IF @o_error_code < 0 BEGIN
			RETURN
		 END
   END

	-- Copy all notes associated with jacket specs 
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,5,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT
	IF @o_error_code < 0 
   BEGIN
  		SET @o_error_desc = 'Unable to write jacketspecs notes.'
      RETURN
   END

	
	-- Copy all jackcolor specs
	OPEN jackcolor_cur
	
	FETCH NEXT FROM jackcolor_cur INTO @v_colorkey, @v_colordesc
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO jackcolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
		FETCH NEXT FROM jackcolor_cur INTO @v_colorkey, @v_colordesc
				 
	END --jackcolor_cur LOOP
				
	CLOSE jackcolor_cur
	DEALLOCATE jackcolor_cur
END
go