/****** Object:  View [dbo].[taq_contacts]    Script Date: 11/12/2013 14:36:45 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[TAQ_Project_Contacts_View]'))
DROP VIEW [dbo].[TAQ_Project_Contacts_View]
GO

GO

/****** Object:  View [dbo].[taq_contacts]    Script Date: 11/12/2013 14:36:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create view [dbo].[TAQ_Project_Contacts_View]
as
Select t.taqprojectkey, t.globalcontactkey, r.authortypecode,r.rolecode,sortorder,
dbo.rpt_get_contact_name(t.globalcontactkey,'D')Name,activeind,
r.primaryind,
dbo.rpt_get_gentables_desc(134,authortypecode,'d')ContributorType,
dbo.rpt_get_gentables_desc(285,Rolecode,'d')RoleType
from taqprojectcontact t join taqprojectcontactrole r 
on r.taqprojectcontactkey = t.taqprojectcontactkey


GO


grant all on [dbo].[TAQ_Project_Contacts_View] to public