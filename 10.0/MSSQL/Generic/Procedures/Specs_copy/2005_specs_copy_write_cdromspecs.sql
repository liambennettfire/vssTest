IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_cdromspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_cdromspecs
END
GO

CREATE PROCEDURE specs_copy_write_cdromspecs (
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
	@v_masteringformat	INT,
   @v_masteringturnaround INT,
   @v_discserialization VARCHAR(1),
   @v_masterdiscdata VARCHAR(1),
   @v_inputmediastorage VARCHAR(1),
   @v_numcds INT,
   @v_totalruntime VARCHAR(10),
   @v_count INT

BEGIN

	SELECT @v_count = count(*)
     FROM cdromspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_masteringformat=masteringformat, @v_masteringturnaround= masteringturnaround,
         @v_discserialization=discserialization,@v_masterdiscdata =masterdiscdata ,@v_inputmediastorage=inputmediastorage,
         @v_numcds=numcds ,@v_totalruntime=totalruntime
		FROM cdromspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO cdromspecs(bookkey, printingkey, vendorkey,masteringformat,masteringturnaround,discserialization,
        masterdiscdata,inputmediastorage,numcds,totalruntime,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_masteringformat,@v_masteringturnaround,@v_discserialization,
            @v_masterdiscdata ,@v_inputmediastorage,@v_numcds,@v_totalruntime,@i_userid,getdate())
	END

	-- Copy all notes associated with cdromspecs
   EXEC specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,12,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
go