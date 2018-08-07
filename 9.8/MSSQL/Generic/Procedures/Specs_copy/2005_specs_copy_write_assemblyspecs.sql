/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_assemblyspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_assemblyspecs
END
GO

CREATE PROCEDURE specs_copy_write_assemblyspecs 
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
	@v_vendorkey	INT,
   @v_productdesc varchar(40),
	@v_colordesc varchar(100),
	@v_dimensions varchar(100),
	@v_numberpieces varchar(100),
	@v_otherspecs varchar(255),
	@v_singlesource varchar(1),
	@v_count INT   

BEGIN

	SELECT @v_count = count(*)
     FROM assemblyspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_productdesc=productdesc,@v_colordesc=colordesc,@v_dimensions=dimensions,@v_numberpieces=numberpieces,
         @v_otherspecs=otherspecs,@v_singlesource=singlesource
		FROM assemblyspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 

		INSERT INTO assemblyspecs(bookkey,printingkey,vendorkey,productdesc,colordesc,dimensions,numberpieces,
          otherspecs,singlesource,lastuserid,lastmaintdate )
        VALUES(@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_productdesc,@v_colordesc,@v_dimensions,@v_numberpieces,
           @v_otherspecs,@v_singlesource,@i_userid,getdate())
	END

	-- Copy all notes associated with assemblyspecs
   EXEC specs_copy_write_notes @i_from_bookkey, @i_from_printingkey, @i_to_bookkey, @i_to_printingkey,25,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT 

END
