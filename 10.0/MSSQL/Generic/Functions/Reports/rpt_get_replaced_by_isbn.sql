SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_replaced_by_isbn') )
DROP FUNCTION rpt_get_replaced_by_isbn
GO

CREATE FUNCTION rpt_get_replaced_by_isbn 	(@i_bookkey	INT)
	RETURNS VARCHAR(20)

/*	The purpose of the rpt_get_replaces_isbn function is to return a the ISBN column from associated title table
	for Association Type Code 5 (Bisac Related),for Sub Code 4 which relates to 
     the REPLACED BY ISBN on ISBN details .  

	Parameter Options
		bookkey

*/	

AS
BEGIN
	DECLARE @RETURN			VARCHAR(20)
	select @RETURN=dbo.rpt_get_bisac_related_isbn (@i_bookkey,4)

RETURN @RETURN
END
go

grant execute on rpt_get_replaced_by_isbn to public
go
