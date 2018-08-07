GO

/****** Object:  View [dbo].[rpt_Get_TaqAuthors_View]    Script Date: 02/10/2017 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_TaqAuthors_View]'))
DROP VIEW [dbo].[rpt_Get_TaqAuthors_View]
GO

CREATE view [dbo].[rpt_Get_TaqAuthors_View] as    
SELECT c.taqprojectcontactkey,c.taqprojectkey,g.datadesc,
g2.globalcontactkey, c.sortorder,
g2.displayname, g2.firstname, g2.lastname, g2.middlename,
dbo.rpt_get_contact_name (g2.globalcontactkey,'C') as fullname,
dbo.rpt_GET_QSI_Comment (g2.globalcontactkey,10,0) as authorbio  
FROM taqprojectcontact c, taqprojectcontactrole r, gentables g,globalcontact g2    
   WHERE c.taqprojectkey = r.taqprojectkey     
and c.taqprojectcontactkey = r.taqprojectcontactkey     
and g.tableid = 134     
and g.datacode = r.authortypecode    
and c.globalcontactkey = g2.globalcontactkey    
and authortypecode <> 0 and authortypecode <> -1 and authortypecode is not null
Go
Grant all on rpt_Get_TaqAuthors_View to PUBLIC