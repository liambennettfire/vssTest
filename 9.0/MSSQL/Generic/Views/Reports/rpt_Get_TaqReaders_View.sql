
GO

/****** Object:  View [dbo].[rpt_Get_TaqReaders_View]    Script Date: 08/25/2015 14:42:18 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_TaqReaders_View]'))
DROP VIEW [dbo].[rpt_Get_TaqReaders_View]
GO


GO

/****** Object:  View [dbo].[rpt_Get_TaqReaders_View]    Script Date: 08/25/2015 14:42:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create view [dbo].[rpt_Get_TaqReaders_View] as  
SELECT c.taqprojectkey,g.datadesc,g2.displayname  
FROM taqprojectcontact c, taqprojectcontactrole r, gentables g,globalcontact g2  
   WHERE c.taqprojectkey = r.taqprojectkey   
and c.taqprojectcontactkey = r.taqprojectcontactkey   
and g.tableid = 285   
and g.datacode = r.rolecode  
and c.globalcontactkey = g2.globalcontactkey  
and qsicode=3  
GO
Grant all on rpt_Get_TaqReaders_View to Public

