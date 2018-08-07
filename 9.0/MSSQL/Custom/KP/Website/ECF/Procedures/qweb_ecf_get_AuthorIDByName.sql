if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_AuthorIDByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_get_AuthorIDByName]

GO


CREATE Procedure [dbo].[qweb_ecf_get_AuthorIDByName]
@AuthorName nvarchar(512)
AS
BEGIN

	Select TOP 1 pc.objectid
	FROM ProductEx_Contributors pc
	JOIN Product p
	ON pc.objectid = p.productid
	WHERE pc.Contributor_Display_Name = @AuthorName
	and p.visible = 1
	ORDER BY pc.objectid DESC 
	--The idea is is there are duplicate records most probably the newest record is the active one, 
	--the older record(s) should have been deactivated in TMM

END

GO
Grant execute on dbo.qweb_ecf_get_AuthorIDByName to Public
GO