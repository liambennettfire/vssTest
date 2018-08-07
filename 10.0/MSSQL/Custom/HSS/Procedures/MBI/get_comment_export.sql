SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_comment_export]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[get_comment_export]
GO




CREATE PROCEDURE get_comment_export(@bookkey	INT,
				@o_errorcode	INT OUT,
				@o_errormsg	VARCHAR(1000) OUT)
AS

DECLARE @isbn10				VARCHAR(20)
DECLARE @cstatus			INT
DECLARE @commenttype			VARCHAR(50)
DECLARE @comment			VARCHAR(8000)
DECLARE @commenthtml			VARCHAR(8000)


SET @commenttype = ''


SELECT @isbn10 = isbn10
FROM isbn
WHERE bookkey = @bookkey


BEGIN

/*  GET BRIEF DESCRIPTION		*/				
	SET @commenttype = 'Brief Description'
	SET @comment = ''
	SET @commenthtml = ''

	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 7
				

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)


/*  GET  DESCRIPTION		*/				
	SET @commenttype = 'Description'
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 8

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET AUTHOR BIO		*/				
	SET @commenttype = 'Author Bio'
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 10

				

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Key selling point 1		*/				
	SET @commenttype = 'Key selling point 1'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 9

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Key selling point 2		*/				
	SET @commenttype = 'Key selling point 2'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 10

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Key selling point 3		*/				
	SET @commenttype = 'Key selling point 3'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 11

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Review Quote 1		*/				
	SET @commenttype = 'Review Quote 1'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 4

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Review Quote 2		*/				
	SET @commenttype = 'Review Quote 2'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 5

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Review Quote 3		*/				
	SET @commenttype = 'Review Quote 3'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 6

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)


/*  GET Sales Handle	*/				
	SET @commenttype = 'Sales Handle'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 25

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Catalog Body Copy	*/				
	SET @commenttype = 'Catalog Body Copy'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 3
			AND commenttypesubcode = 1

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)

/*  GET Catalog Bullets	*/				
	SET @commenttype = 'Catalog Bullets'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 2

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)


/*  GET Publicity	*/				
	SET @commenttype = 'Publicity'	
	SET @comment = ''
	SET @commenthtml = ''
	SELECT @comment = COALESCE(commenttext,''),
		@commenthtml = COALESCE(commenthtml,'')
	FROM bookcomments
	WHERE bookkey = @bookkey
			AND commenttypecode = 1
			AND commenttypesubcode = 21

	INSERT INTO export_comment(bookkey,isbn10,commenttype,comment,commenthtml)
	VALUES (@bookkey,@isbn10,@commenttype,@comment,@commenthtml)



END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
