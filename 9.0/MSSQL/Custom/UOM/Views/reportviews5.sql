if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_exhibits_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_exhibits_view]
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_exhibits_view
AS
SELECT     dbo.book.bookkey, dbo.subjectcategory437_view.datacode, dbo.subjectcategory437_view.subjectcategory
FROM         dbo.subjectcategory437_view INNER JOIN
                      dbo.booksubjectcategory ON dbo.subjectcategory437_view.datacode = dbo.booksubjectcategory.categorycode RIGHT OUTER JOIN
                      dbo.book ON dbo.booksubjectcategory.bookkey = dbo.book.bookkey
WHERE dbo.booksubjectcategory.categorytableid = 437 