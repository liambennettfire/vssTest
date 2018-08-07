IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_labelspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_labelspecs
END
GO

CREATE PROCEDURE specs_copy_write_labelspecs 	(
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
   @v_artwork INT,
	@v_artworkdesc VARCHAR(100),
   @v_flatsize VARCHAR(30),
   @v_finalsize VARCHAR(30),
	@v_stock INT,
   @v_stocktype INT,
   @v_stockweight INT,
   @v_numcolors INT,
   @v_printmethod INT,
   @v_coating INT,
	@v_perfed VARCHAR(1),
	@v_scored VARCHAR(1),
   @v_folded VARCHAR(1),
   @v_collated VARCHAR(1),
   @v_shrinkwrapped VARCHAR(1),
   @v_dies VARCHAR(1),
   @v_diedescription VARCHAR(100),
   @v_rollcoresize VARCHAR(1),
   @v_count INT,
	@v_colorkey  INT,
   @v_colordesc VARCHAR(100)

	DECLARE compcolors_cur CURSOR FOR
	 SELECT colorkey,colordesc FROM compcolors
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 

BEGIN

	SELECT @v_count = count(*)
     FROM labelspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_artwork=artwork, @v_artworkdesc= artworkdesc,@v_flatsize=flatsize,@v_finalsize=finalsize,
         @v_stock=stock,@v_stocktype=stocktype,@v_stockweight=stockweight,@v_numcolors=numcolors,@v_printmethod=printmethod,@v_coating = coating,
         @v_perfed=perfed,@v_scored=scored,@v_folded=folded,@v_collated=collated,@v_shrinkwrapped=shrinkwrapped,
			@v_dies=dies,@v_diedescription=diedescription,@v_rollcoresize=rollcoresize
		FROM labelspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO labelspecs(bookkey, printingkey, vendorkey,artwork,artworkdesc,flatsize,finalsize,stock,stocktype,stockweight,numcolors,
          printmethod,coating,perfed,scored,folded,collated,shrinkwrapped,dies,diedescription,rollcoresize,
          lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_artwork,@v_artworkdesc,@v_flatsize,@v_finalsize,@v_stock,@v_stocktype,@v_stockweight,@v_numcolors,
            @v_printmethod,@v_coating,@v_perfed,@v_scored,@v_folded,@v_collated,@v_shrinkwrapped,@v_dies,@v_diedescription,@v_rollcoresize,
				@i_userid,getdate())
	END

	-- Copy all notes associated with labelspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,17,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

	-- Copy all compcolors specs
	OPEN compcolors_cur
	
	FETCH NEXT FROM compcolors_cur INTO @v_colorkey, @v_colordesc
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO compcolors(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
		FETCH NEXT FROM compcolors_cur INTO @v_colorkey, @v_colordesc
				 
	END --compcolors_cur LOOP
				
	CLOSE compcolors_cur
	DEALLOCATE compcolors_cur

END
go