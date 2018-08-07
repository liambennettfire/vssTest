IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_stickerspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_stickerspecs
END
GO

CREATE PROCEDURE specs_copy_write_stickerspecs 	(
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
   @v_artwork int,
	@v_artworkdesc varchar(100) ,
	@v_flatsize varchar(30) ,
	@v_finalsize varchar(30) ,
	@v_numcolors int,
	@v_stock int,
	@v_stocktype int,
	@v_stockweight int,
	@v_printmethod  int,
	@v_coating int,
	@v_perfed varchar(1) ,
	@v_scored varchar(1) ,
	@v_folded varchar(1) ,
	@v_collated varchar(1) ,
	@v_shrinkwrapped varchar(1) ,
	@v_dies varchar(1) ,
	@v_diedescription varchar(100),
	@v_count INT   

BEGIN

	SELECT @v_count = count(*)
     FROM stickerspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_artwork=artwork, @v_artworkdesc= artworkdesc,@v_flatsize=flatsize,@v_finalsize=finalsize,
         @v_stock=stock,@v_stocktype=stocktype,@v_stockweight=stockweight,@v_numcolors=numcolors,@v_printmethod=printmethod,@v_coating = coating,
         @v_perfed=perfed,@v_scored=scored,@v_folded=folded,@v_collated=collated,@v_shrinkwrapped=shrinkwrapped,
			@v_dies=dies,@v_diedescription=diedescription
		FROM stickerspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 

		INSERT INTO stickerspecs(bookkey, printingkey, vendorkey,artwork,artworkdesc,flatsize,finalsize,stock,stocktype,stockweight,numcolors,
         printmethod,coating,perfed,scored,folded,collated,shrinkwrapped,dies,diedescription,
          lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_artwork,@v_artworkdesc,@v_flatsize,@v_finalsize,@v_stock,@v_stocktype,@v_stockweight,@v_numcolors,
            @v_printmethod,@v_coating,@v_perfed,@v_scored,@v_folded,@v_collated,@v_shrinkwrapped,@v_dies,@v_diedescription,
				@i_userid,getdate())
	END

	-- Copy all notes associated with stickerspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,18,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go