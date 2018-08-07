GO

/****** Object:  View [dbo].[rpt_oup_Get_TaqAuthors_View]    Script Date: 02/10/2017 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_oup_Get_TaqAuthors_View]'))
DROP VIEW [dbo].[rpt_oup_Get_TaqAuthors_View]
GO


CREATE view [dbo].[rpt_oup_Get_TaqAuthors_View] as 
   
SELECT c.taqprojectkey,c.datadesc,
c.globalcontactkey, c.sortorder,
ROW_NUMBER() over (partition by c.taqprojectkey order by c.sortorder) as reorder,
c.displayname, c.firstname, c.lastname, c.middlename,
c.fullname,
c.authorbio  
FROM rpt_Get_TaqAuthors_View c
--order by c.taqprojectkey, c.sortorder, reorder
Go
Grant all on rpt_oup_Get_TaqAuthors_View to PUBLIC