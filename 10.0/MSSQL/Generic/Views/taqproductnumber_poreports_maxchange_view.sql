/****** Object:  View [dbo].[taqproductnumber_poreports_maxchange_view]    Script Date: 04/09/2015 14:34:47 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[taqproductnumber_poreports_maxchange_view]'))
DROP VIEW [dbo].[taqproductnumber_poreports_maxchange_view]
GO

/****** Object:  View [dbo].[taqproductnumber_poreports_maxchange_view]    Script Date: 04/09/2015 14:34:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[taqproductnumber_poreports_maxchange_view]
as
select ponumber,maxchange=max(changenum) 
from taqproductnumbers_ponumbers_view 
where usageclasscode<>1
group by ponumber

GO

GRANT SELECT ON dbo.taqproductnumber_poreports_maxchange_view to public
GO
