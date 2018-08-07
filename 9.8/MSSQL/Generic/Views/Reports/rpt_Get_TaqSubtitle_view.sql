
GO

/****** Object:  View [dbo].[rpt_Get_TaqSubtitle_view]    Script Date: 08/25/2015 14:25:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_TaqSubtitle_view]'))
DROP VIEW [dbo].[rpt_Get_TaqSubtitle_view]
GO


GO

/****** Object:  View [dbo].[rpt_Get_TaqSubtitle_view]    Script Date: 08/25/2015 14:25:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create  view [dbo].[rpt_Get_TaqSubtitle_view] as  
Select taqprojectSubtitle,taqprojectkey,taqprojecteditionDesc from TaqProject 
GO

Grant all on rpt_Get_TaqSubtitle_view to public
