if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[subjectcategory412_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[subjectcategory412_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[subjectcategory437_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[subjectcategory437_view]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.subjectcategory412_view
AS
SELECT     dbo.gentables.tableid, dbo.gentables.datacode, dbo.gentables.datadesc AS subjectcategory, dbo.subgentables.datasubcode, 
                      dbo.subgentables.datadesc AS subjectsubcategory
FROM         dbo.gentables INNER JOIN
                      dbo.subgentables ON dbo.gentables.datacode = dbo.subgentables.datacode
WHERE     (dbo.gentables.tableid = 412) AND (dbo.subgentables.tableid = 412)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.subjectcategory437_view
AS
SELECT     tableid, datacode, datadesc AS subjectcategory
FROM         dbo.gentables
WHERE     (tableid = 437)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_exhibits_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_exhibits_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_skilllevel_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_skilllevel_view]
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

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.skilllevel_view
AS
SELECT     dbo.book.bookkey, dbo.subjectcategory412_view.datacode, dbo.subjectcategory412_view.subjectcategory, 
                      dbo.subjectcategory412_view.datasubcode, dbo.subjectcategory412_view.subjectsubcategory
FROM         dbo.subjectcategory412_view INNER JOIN
                      dbo.booksubjectcategory ON dbo.subjectcategory412_view.datacode = dbo.booksubjectcategory.categorycode AND 
                      dbo.subjectcategory412_view.datasubcode = dbo.booksubjectcategory.categorysubcode RIGHT OUTER JOIN
                      dbo.book ON dbo.booksubjectcategory.bookkey = dbo.book.bookkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



