IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_endpaper') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_endpaper
END
GO

CREATE PROCEDURE Specs_Copy_write_endpaper 	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE
	@v_vendorkey	INT,
   @v_endpapermatl		INT,
	@v_endpapercolor   VARCHAR(25),
	@v_inks		INT,
	@v_texttype INT,
	@v_printingmethod INT,
	@v_notekey INT,
	@v_totalnumbersheets   INT,
   @v_count INT,
   @v_colorkey  INT,
   @v_colordesc VARCHAR(100)

DECLARE endpaper_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM endpcolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 
BEGIN

	SELECT @v_count = count(*)
     FROM endpapers
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_endpapermatl=endpapermatl, @v_endpapercolor= endpapercolor,@v_texttype=texttype,
         @v_inks=inks,@v_printingmethod= printingmethod
		FROM endpapers
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO endpapers(bookkey, printingkey, vendorkey, endpapermatl,endpapercolor,texttype,inks,printingmethod,lastuserid, lastmaintdate)
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_endpapermatl,@v_endpapercolor,@v_texttype,@v_inks,@v_printingmethod,@i_userid,getdate())
	END
   
	-- Copy all notes associated with endpaper specs 
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,7,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT
	IF @o_error_code < 0 
   BEGIN
  		SET @o_error_desc = 'Unable to write jacketspecs notes.'
      RETURN
   END

	
	-- Copy all endpaper specs
	OPEN endpaper_cur
	
	FETCH NEXT FROM endpaper_cur INTO @v_colorkey, @v_colordesc
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO endpcolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
		FETCH NEXT FROM endpaper_cur INTO @v_colorkey, @v_colordesc
				 
	END --endpaper_cur LOOP
				
	CLOSE endpaper_cur
	DEALLOCATE endpaper_cur
END
go