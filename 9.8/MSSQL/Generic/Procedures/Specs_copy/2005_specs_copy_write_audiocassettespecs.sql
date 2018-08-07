IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_audiocassette') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_audiocassette
END
GO

CREATE PROCEDURE specs_copy_write_audiocassette 
	(@i_from_bookkey     INT,
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
	@v_mastering int,
	@v_tapestock int,
	@v_premiumind char(1),
	@v_copyprotected char(1),
	@v_mastertapestorage int,
	@v_numcassettes int,
	@v_totalruntime varchar(10),
	@v_shelltypecode int,
	@v_assemblytypecode int,
	@v_shrinkwrapped varchar(1),
   @v_tapenum INT,
   @v_tapelengthcode INT,
   @v_side1length varchar(10),
   @v_side2length varchar(10),
   @v_shellcolorcode INT,
   @v_imprintcolorcode INT,
   @v_count INT

	DECLARE audiotapes_cur CURSOR FOR
  SELECT tapenum,tapelengthcode,side1length,side2length,shellcolorcode,imprintcolorcode
	 FROM audiotapes
   WHERE bookkey=@i_from_bookkey AND printingkey=@i_from_printingkey 
  ORDER BY tapenum


BEGIN

	SELECT @v_count = count(*)
     FROM audiocassettespecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT @v_vendorkey=vendorkey, @v_mastering=mastering, @v_tapestock=tapestock,@v_premiumind=premiumind,@v_copyprotected=copyprotected ,
            @v_mastertapestorage=mastertapestorage,@v_numcassettes=numcassettes,@v_totalruntime=totalruntime ,@v_shelltypecode=shelltypecode,
            @v_assemblytypecode=assemblytypecode,@v_shrinkwrapped=shrinkwrapped 
		FROM audiocassettespecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO audiocassettespecs(bookkey, printingkey, vendorkey,mastering,tapestock,premiumind,
        copyprotected,mastertapestorage,numcassettes,totalruntime,shelltypecode,assemblytypecode,shrinkwrapped,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_mastering,@v_tapestock,@v_premiumind,
            @v_copyprotected,@v_mastertapestorage,@v_numcassettes,@v_totalruntime,@v_shelltypecode,@v_assemblytypecode,@v_shrinkwrapped,@i_userid,getdate())
	END

   OPEN audiotapes_cur
 
   FETCH audiotapes_cur INTO @v_tapenum,@v_tapelengthcode,@v_side1length,@v_side2length,@v_shellcolorcode,@v_imprintcolorcode

	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
       INSERT INTO audiotapes (bookkey,printingkey,tapenum,tapelengthcode,side1length,side2length,shellcolorcode,imprintcolorcode,lastuserid,lastmaintdate)
         VALUES(@i_to_bookkey,@i_to_printingkey,@v_tapenum,@v_tapelengthcode,@v_side1length,@v_side2length,@v_shellcolorcode,@v_imprintcolorcode,
                @i_userid,getdate())

		 FETCH audiotapes_cur INTO @v_tapenum,@v_tapelengthcode,@v_side1length,@v_side2length,@v_shellcolorcode,@v_imprintcolorcode

   END
   CLOSE audiotapes_cur
	DEALLOCATE audiotapes_cur

	-- Copy all notes associated with audiocassettespecs
   EXEC specs_copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,14,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT 

END
go