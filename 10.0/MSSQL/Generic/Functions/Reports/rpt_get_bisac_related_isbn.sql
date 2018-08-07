SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_bisac_related_isbn') )
DROP FUNCTION rpt_get_bisac_related_isbn
GO

create FUNCTION rpt_get_bisac_related_isbn
		(@i_bookkey	INT, @i_associationtypesubcode int)

RETURNS VARCHAR(20)

/*	The purpose of the rpt_get_replaces_isbn function is to return a the ISBN column from associated title table
	for Association Type Code 5 (Bisac Related),for the Sub Code passed, as defined in the
	Association Type Code User Table.  

	Parameter Options
		bookkey

	AssociationTypeSubCode
	For Example:
	Replaces = 3
	Replaced by = 4
*/	

AS
BEGIN

	DECLARE @RETURN			VARCHAR(20)
	DECLARE @v_isbn			VARCHAR(20)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	  FROM associatedtitles
	 WHERE bookkey = @i_bookkey 
		AND associationtypecode = 5 --Bisac Related
		AND associationtypesubcode = @i_associationtypesubcode

	IF @i_assocbookkey > 0
	BEGIN
		SELECT @v_isbn = ean
	  	  FROM isbn
		 WHERE bookkey = @i_assocbookkey
 	END
	ELSE
	BEGIN
		SELECT @v_isbn = isbn
		  FROM associatedtitles
		 WHERE bookkey = @i_bookkey 
			AND associationtypecode = 5 -- Bisac Related
			AND associationtypesubcode = @i_associationtypesubcode
	END

	IF LEN(@v_isbn) > 0
	BEGIN
		SELECT @RETURN = @v_isbn
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END
RETURN @RETURN
END
go

grant execute on rpt_get_bisac_related_isbn to public
go
