IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_nonbook') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_nonbook
END
GO

CREATE PROCEDURE Specs_Copy_write_nonbook 	(
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
   @v_productdesc		VARCHAR(140),
	@v_colordesc   VARCHAR(100),
	@v_dimensions	VARCHAR(100),
	@v_numberpieces VARCHAR(100),
	@v_otherspecs VARCHAR(255),
	@v_singlesource VARCHAR(1),
	@v_outrightpurchaseind   VARCHAR(1),
   @v_count INT
  
BEGIN

	SELECT @v_count = count(*)
     FROM nonbookspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey

	IF @v_count > 0 
   BEGIN  

		SELECT  @v_vendorkey=vendorkey, @v_productdesc=productdesc, @v_colordesc= colordesc,@v_dimensions=dimensions,@v_numberpieces=numberpieces,
         @v_otherspecs=otherspecs,@v_singlesource= singlesource,@v_outrightpurchaseind = outrightpurchaseind 
		FROM nonbookspecs
		WHERE (bookkey = @i_from_bookkey) AND
				(printingkey = @i_from_printingkey) 


		INSERT INTO nonbookspecs(bookkey, printingkey, vendorkey,productdesc,colordesc,dimensions,numberpieces,otherspecs,singlesource,
        outrightpurchaseind,lastuserid,lastmaintdate )
        VALUES (@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_productdesc,@v_colordesc,@v_dimensions,@v_numberpieces,@v_otherspecs,@v_singlesource,
             @v_outrightpurchaseind,@i_userid,getdate())
	END
END
go