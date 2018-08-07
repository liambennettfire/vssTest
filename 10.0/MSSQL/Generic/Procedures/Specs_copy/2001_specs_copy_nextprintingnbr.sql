/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_nextprintingnbr') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_nextprintingnbr
END
GO

CREATE PROCEDURE specs_copy_nextprintingnbr 
	(@i_from_bookkey     INT,
  @i_printingjobs_boolean     INT,
  @o_nextprintingnbr  INT OUTPUT,
  @o_nextjobnbr       INT OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS


BEGIN

	IF @i_printingjobs_boolean = 1
   BEGIN
		SELECT @o_nextprintingnbr = nextprintingnbr, @o_nextjobnbr = nextjobnbr
        FROM book
       WHERE bookkey = @i_from_bookkey
   END
   ELSE
   BEGIN
		SELECT @o_nextprintingnbr = nextprintingnbr
        FROM book
       WHERE bookkey = @i_from_bookkey

      SET @o_nextjobnbr = NULL
   END

END
go