if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bnpubactiveclassdivision_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bnpubactiveclassdivision_view]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.bnpubactiveclassdivision_view
AS
SELECT     datadesc
FROM         dbo.subgentables
WHERE     (tableid = 525) AND (datacode = 2) AND (deletestatus = 'N')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

