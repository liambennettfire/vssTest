IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_videocassette') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_videocassette
END
GO

CREATE PROCEDURE specs_copy_write_videocassette 	(
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
   @v_vendorkey  INT,
	@v_usamasteringformat	INT,
   @v_intlmasteringformat INT,
   @v_mastertape INT,
   @v_tapelength INT,
   @v_tapestock INT,
   @v_premiumind VARCHAR(1),
   @v_copyprotected VARCHAR(1),
	@v_macrovision VARCHAR(1),
   @v_mastertapestorage INT,
   @v_count INT

BEGIN

	SELECT @v_count = count(*)
     FROM videocassettespecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_usamasteringformat=usamasteringformat, @v_intlmasteringformat= intlmasteringformat,
         @v_mastertape=mastertape,@v_tapelength =tapelength ,@v_premiumind=premiumind,@v_copyprotected=copyprotected,
         @v_macrovision=macrovision ,@v_mastertapestorage=mastertapestorage,@v_tapestock=tapestock
		FROM videocassettespecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO videocassettespecs(bookkey, printingkey, vendorkey,usamasteringformat,intlmasteringformat,mastertape,
        tapelength,tapestock,premiumind,copyprotected,macrovision,mastertapestorage,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_usamasteringformat,@v_intlmasteringformat,@v_mastertape,
            @v_tapelength,@v_tapestock,@v_premiumind,@v_copyprotected,@v_macrovision,@v_mastertapestorage,@i_userid,getdate())
	END

	-- Copy all notes associated with videocassettespecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,13,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go