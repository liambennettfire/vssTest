IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_laserdiscspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_laserdiscspecs
END
GO

CREATE PROCEDURE specs_copy_write_laserdiscspecs 	(
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
   @v_alphadisc VARCHAR(1),
   @v_cavapplication INT,
   @v_tapeformat INT,
   @v_masteringturnaround INT,
	@v_frameaccuracycheck VARCHAR(1),
   @v_checkdisc VARCHAR(1),
	@v_glassmaster VARCHAR(1),
   @v_masterdisctapemediastorage VARCHAR(1),
   @v_count INT

BEGIN

	SELECT @v_count = count(*)
     FROM laserdiscspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_alphadisc=alphadisc, @v_cavapplication= cavapplication,@v_tapeformat=tapeformat,@v_masteringturnaround=masteringturnaround,
         @v_frameaccuracycheck =frameaccuracycheck ,@v_checkdisc=checkdisc,@v_glassmaster = glassmaster ,@v_masterdisctapemediastorage = masterdisctapemediastorage
		FROM laserdiscspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO laserdiscspecs(bookkey, printingkey, vendorkey,alphadisc,cavapplication,tapeformat,masteringturnaround,
        frameaccuracycheck ,checkdisc,glassmaster,masterdisctapemediastorage,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_alphadisc,@v_cavapplication,@v_tapeformat,@v_masteringturnaround,
            @v_frameaccuracycheck ,@v_checkdisc,@v_masteringturnaround,@v_masterdisctapemediastorage,@i_userid,getdate())
	END

	-- Copy all notes associated with laserdiscspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,11,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go