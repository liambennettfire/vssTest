
/****** Object:  View [dbo].[addresstype_view]    Script Date: 04/13/2010 10:12:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_advance_by_year_view'))
DROP VIEW [dbo].rpt_taq_pl_advance_by_year_view
GO
Create view rpt_taq_pl_advance_by_year_view as 
Select taqprojectkey,plstagecode, taqversionkey, 
[dbo].rpt_taq_pl_royalty_by_year (taqprojectkey,  plstagecode, taqversionkey, 1) as  adv_year_1,
[dbo].rpt_taq_pl_advance_by_year (taqprojectkey,  plstagecode, taqversionkey, 2) as  adv_year_2,
[dbo].rpt_taq_pl_advance_by_year (taqprojectkey,  plstagecode, taqversionkey, 3) as  adv_year_3,
[dbo].rpt_taq_pl_advance_by_year (taqprojectkey,  plstagecode, taqversionkey, 4) as  adv_year_4,
[dbo].rpt_taq_pl_advance_by_year (taqprojectkey,  plstagecode, taqversionkey, 5) as  adv_year_0
FROM taqversionroyaltyadvance 
GO
GRANT ALL ON rpt_taq_pl_advance_by_year_view TO PUBLIC
