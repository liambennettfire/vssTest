if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[otherformat_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[otherformat_view]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.otherformat_view
AS
SELECT     *
FROM         dbo.gentables
WHERE     (tableid = 300)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

