
GO

/****** Object:  View [dbo].[rpt_get_taqProjectTitle_Format_view]    Script Date: 08/25/2015 14:37:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_taqProjectTitle_Format_view]'))
DROP VIEW [dbo].[rpt_get_taqProjectTitle_Format_view]
GO


GO

/****** Object:  View [dbo].[rpt_get_taqProjectTitle_Format_view]    Script Date: 08/25/2015 14:37:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[rpt_get_taqProjectTitle_Format_view] as 

SELECT DISTINCT taqprojecttitle.initialrun,ean,taqprojectformatdesc, 
taqprojecttitle.price, taqprojecttitle.taqprojectkey, 
season.seasondesc as season,season.begindate as season_begin,
dbo.get_gentables_desc(459,"taqprojecttitle"."discountcode",'D') as Discount
 FROM    taqprojecttitle
INNER JOIN season ON 
taqprojecttitle.seasoncode=season.seasonkey
--where taqprojectkey=1031786



GO
Grant all on rpt_get_taqProjectTitle_Format_view to public


