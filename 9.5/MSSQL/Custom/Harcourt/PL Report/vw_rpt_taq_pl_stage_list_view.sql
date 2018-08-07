
/****** Object:  View [dbo].rpt_taq_pl_stage_list_view    Script Date: 04/13/2010 10:12:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_stage_list_view'))
DROP VIEW [dbo].rpt_taq_pl_stage_list_view
GO
Create view rpt_taq_pl_stage_list_view as
Select datacode, datadesc
from gentables 
where tableid = 562
GO
GRANT ALL ON rpt_taq_pl_stage_list_view  to public
