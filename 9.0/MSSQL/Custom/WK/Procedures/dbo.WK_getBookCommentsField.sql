if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getBookCommentsField') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getBookCommentsField
GO
CREATE PROCEDURE dbo.WK_getBookCommentsField
@bookkey int,
@commenttypecode int,
@commenttypesubcode int
AS
BEGIN
Select commenttext
FROM bookcomments
WHERE bookkey = @bookkey
and printingkey = 1
and commenttypecode = @commenttypecode and commenttypesubcode = @commenttypesubcode
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
--Select dbo.rpt_get_book_comment(@bookkey, 3, 57, 1)
END


