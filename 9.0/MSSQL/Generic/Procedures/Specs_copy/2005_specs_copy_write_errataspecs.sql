IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_errataspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_errataspecs
END
GO

CREATE PROCEDURE specs_copy_write_errataspecs 	(
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
   @v_numcolors INT,
   @v_printmethod INT,
   @v_numsides INT,
   @v_numpages INT,
   @v_coating INT,
	@v_perfed VARCHAR(1),
	@v_scored VARCHAR(1),
   @v_folded VARCHAR(1),
   @v_collated VARCHAR(1),
   @v_drilled VARCHAR(1),
   @v_shrinkwrapped VARCHAR(1),
   @v_bindin VARCHAR(1),
   @v_blowin VARCHAR(1),
   @v_dies VARCHAR(1),
   @v_diedescription VARCHAR(100),
   @v_count INT

BEGIN

	SELECT @v_count = count(*)
     FROM errataspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_artwork=artwork, @v_artworkdesc= artworkdesc,@v_flatsize=flatsize,@v_finalsize=finalsize,
         @v_stock=stock,@v_numcolors=numcolors,@v_numsides=numsides,@v_numpages=numpages,@v_printmethod=printmethod,@v_coating = coating,
         @v_perfed=perfed,@v_scored=scored,@v_folded=folded,@v_collated=collated,@v_drilled=drilled,@v_shrinkwrapped=shrinkwrapped,
			@v_bindin=bindin,@v_blowin=blowin,@v_dies=dies,@v_diedescription=diedescription
		FROM errataspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO errataspecs(bookkey, printingkey, vendorkey,artwork,artworkdesc,flatsize,finalsize,stock,numcolors,
          numsides,numpages,printmethod,coating,perfed,scored,folded,collated,drilled,shrinkwrapped,bindin,blowin,dies,diedescription,
          lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_artwork,@v_artworkdesc,@v_flatsize,@v_finalsize,@v_stock,@v_numcolors,
            @v_numsides,@v_numpages,@v_printmethod,@v_coating,@v_perfed,@v_scored,@v_folded,@v_collated,@v_drilled,@v_shrinkwrapped,
				@v_bindin,@v_blowin,@v_dies,@v_diedescription,@i_userid,getdate())
	END

	-- Copy all notes associated with errataspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey, 29,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go