
GO

/****** Object:  View [dbo].[rpt_get_TaqProject_Categories_view]    Script Date: 08/25/2015 14:43:51 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_TaqProject_Categories_view]'))
DROP VIEW [dbo].[rpt_get_TaqProject_Categories_view]
GO


GO

/****** Object:  View [dbo].[rpt_get_TaqProject_Categories_view]    Script Date: 08/25/2015 14:43:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[rpt_get_TaqProject_Categories_view] as  
Select TSC.TaqProjectkey,TSC.subjectkey as subjectkey,     
TSC.categorytableid as v,     
gtd.tabledesclong as tabledesclong,     
TSC.categorycode as categorycode,     
ltrim(rtrim(g1.datadesc)) +  CASE WHEN g2.datadesc is not null THEN '  /  ' + ltrim(rtrim(ISNULL(g2.datadesc,''))) ELSE '' END  as DataDesc1and2,     
TSC.categorysubcode as categorysubcode,     
TSC.categorysub2code as categorysub2code,     
g3.datadesc as datadesc from TaqProjectSubjectCategory TSC  
inner join gentablesdesc gtd  
on TSC.categorytableID=gtd.tableid  
inner join gentables g1 on tsc.categorytableid = g1.tableid and     
g1.datacode = TSC.categorycode     
left outer join subgentables g2 on TSC.categorytableid = g2.tableid and     
TSC.categorycode = g2.datacode and     
TSC.categorysubcode = g2.datasubcode     
left outer join sub2gentables g3 on TSC.categorytableid = g3.tableid and     
TSC.categorycode = g3.datacode and     
TSC.categorysubcode = g3.datasubcode and     
TSC.categorysub2code = g3.datasub2code  
GO
Grant all on rpt_get_TaqProject_Categories_view to public

