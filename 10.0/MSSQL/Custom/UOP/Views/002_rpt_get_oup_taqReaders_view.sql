

GO

/****** Object:  View [dbo].[rpt_get_oup_taqReaders_view]    Script Date: 02/10/2017 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_oup_taqReaders_view]'))
DROP VIEW [dbo].[rpt_get_oup_taqReaders_view]
GO



CREATE view [dbo].[rpt_get_oup_taqReaders_view]
as 
Select top 100 percent dbo.rpt_get_contact_name(globalcontactkey,'d') Name,
ROW_NUMBER() over (partition by taqprojectkey order by sortorder) as reorder,
*
from rpt_get_taqreaders_view order by taqprojectkey

Go
Grant all on rpt_get_oup_taqReaders_view to PUBLIC


