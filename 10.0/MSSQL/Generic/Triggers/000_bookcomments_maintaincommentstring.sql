IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.bookcomments_maintaincommentstring') AND type = 'TR')
	DROP TRIGGER dbo.bookcomments_maintaincommentstring
GO

CREATE TRIGGER bookcomments_maintaincommentstring ON bookcomments
AFTER INSERT, UPDATE AS

IF UPDATE (commenttext)
BEGIN
  DECLARE @v_bookkey			INT,
		  @v_printingkey		INT,
		  @v_commenttypecode	INT,
		  @v_commenttypesubcode INT,
		  @v_commentstring		VARCHAR(2000)

    SELECT @v_bookkey = Inserted.bookkey,
           @v_printingkey = Inserted.printingkey,
           @v_commenttypecode = Inserted.commenttypecode,
           @v_commenttypesubcode = Inserted.commenttypesubcode
    FROM Inserted

    IF (EXISTS(SELECT * FROM bookcomments WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode AND commenttypesubcode = @v_commenttypesubcode))
    BEGIN   
		SELECT @v_commentstring = SUBSTRING(CONVERT(VARCHAR(2000), bookcomments.commenttext), 1, 255)
		FROM bookcomments 
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode AND commenttypesubcode = @v_commenttypesubcode

		UPDATE bookcomments SET commentstring = @v_commentstring
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode AND commenttypesubcode = @v_commenttypesubcode
	END
END
GO
