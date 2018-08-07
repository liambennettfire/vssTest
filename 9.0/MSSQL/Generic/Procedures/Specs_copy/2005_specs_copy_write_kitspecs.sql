IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_kitspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_kitspecs
END
GO

CREATE PROCEDURE specs_copy_write_kitspecs 	(
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
   @v_outrightpurchaseind VARCHAR(1),
	@v_artworkdesc VARCHAR(100),
   @v_molds  INT,
	@v_count INT   


BEGIN

	SELECT @v_count = count(*)
     FROM kitspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_outrightpurchaseind=outrightpurchaseind, @v_molds= molds
		FROM kitspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 

		INSERT INTO kitspecs(bookkey, printingkey, vendorkey,outrightpurchaseind,molds,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_outrightpurchaseind,@v_molds,@i_userid,getdate())
	END

	-- Copy all notes associated with kitspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,24,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go