IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_diskettespecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_diskettespecs
END
GO

CREATE PROCEDURE specs_copy_write_diskettespecs 	(
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
   @v_goldmastering VARCHAR(1),
   @v_submaster INT,
   @v_style INT,
   @v_density INT,
   @v_diskettesize INT,
   @v_diskformat INT,
   @v_masteringturnaround INT,
   @v_casecolor INT,
   @v_writeprotected VARCHAR(1),
   @v_count INT


BEGIN

	SELECT @v_count = count(*)
     FROM diskettespecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_goldmastering=goldmastering, @v_submaster= submaster,@v_style=style,@v_density=density,
         @v_diskettesize=diskettesize,@v_diskformat=diskformat,@v_masteringturnaround = masteringturnaround ,@v_casecolor = casecolor,
         @v_writeprotected=writeprotected
		FROM diskettespecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO diskettespecs(bookkey, printingkey, vendorkey,goldmastering,submaster,style,diskettesize,diskformat,
          masteringturnaround,casecolor,writeprotected,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_goldmastering,@v_submaster,@v_style,@v_diskettesize,@v_diskformat,
              @v_masteringturnaround,@v_casecolor,@v_writeprotected,@i_userid,getdate())
	END
END
go