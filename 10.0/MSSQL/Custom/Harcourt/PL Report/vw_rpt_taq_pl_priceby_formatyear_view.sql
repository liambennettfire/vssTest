/****** Object:  View [dbo].rpt_taq_pl_priceby_formatyear_view    Script Date: 04/13/2010 10:12:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_priceby_formatyear_view'))
DROP VIEW [dbo].rpt_taq_pl_priceby_formatyear_view
GO

Create view rpt_taq_pl_priceby_formatyear_view as
Select taqprojectkey, 'HC List Price' as type, 1 as sortorder,
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 1, 'HC List Price') as Year1_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 2, 'HC List Price') as Year2_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 3, 'HC List Price') as Year3_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 4, 'HC List Price') as Year4_Price 
from taqversion
UNION
Select taqprojectkey, 'PB List Price' as type, 2 as sortorder,
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 1, 'PB List Price') as Year1_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 2, 'PB List Price') as Year2_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 3, 'PB List Price') as Year3_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 4, 'PB List Price') as Year4_Price
from taqversion
UNION
Select taqprojectkey, 'Ebook List Price' as type, 3 as sortorder,
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 1, 'Ebook List Price') as Year1_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 2, 'Ebook List Price') as Year2_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 3, 'Ebook List Price') as Year3_Price, 
	   dbo.rpt_taq_pl_priceby_formatyear(taqprojectkey, plstagecode, taqversionkey, 4, 'Ebook List Price') as Year4_Price
from taqversion

Go 
GRANT ALL ON rpt_taq_pl_priceby_formatyear_view TO PUBLIC 

