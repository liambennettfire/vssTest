/****** Object:  View [dbo].[rpt_poreport_components_view]    Script Date: 02/07/2015 13:38:18 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_poreport_components_view]'))
DROP VIEW [dbo].[rpt_poreport_components_view]
GO
/****** Object:  View [dbo].[rpt_poreport_components_view]    Script Date: 02/07/2015 13:38:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[rpt_poreport_components_view]
AS
--need get printing level component info, but only for the components on the po
SELECT
poreportprojectkey = t.taqprojectkey ,
posummaryprojectkey = spo.taqprojectkey,
printingprojectkey = sp.taqprojectkey,
posummaryspeccategorykey = spo.taqversionspecategorykey, --this is the posummary spec categorykey, use this link to the gposection table
prtngspeccategorykey = sp.taqversionspecategorykey,  --this is the printnig speccategory where the data lives
plstagecode = sp.plstagecode,
taqversionkey = sp.taqversionkey,
taqversionformatkey = sp.taqversionformatkey,
itemcategorycode = coalesce(sp.itemcategorycode,0),
speccategorydescription = sp.speccategorydescription,
scaleprojecttype = sp.scaleprojecttype,
lastuserid = sp.lastuserid,
lastmaintdate = sp.lastmaintdate,
quantity = coalesce(sp.quantity,0),
finishedgoodind = coalesce(sp.finishedgoodind,0),
sortorder = sp.sortorder,
deriveqtyfromfgqty = sp.deriveqtyfromfgqty,
spoilagepercentage = sp.spoilagepercentage
from taqproject t
inner join taqprojectrelationship tr on t.taqprojectkey = tr.taqprojectkey2 and tr.relationshipcode1=16 and tr.relationshipcode2=17 -- po report to printing
inner join taqprojectrelationship tr2 on t.taqprojectkey = tr2.taqprojectkey1 and tr2.relationshipcode1=15 and tr2.relationshipcode2=14 -- po report to po summary  this way we only get components on the po summary
inner join taqversionspeccategory spo on spo.taqprojectkey = tr2.taqprojectkey2 and spo.itemcategorycode<>1  --posummary taqspeccategories 
inner join taqversionspeccategory sp on sp.taqversionspecategorykey = spo.relatedspeccategorykey  -- get the printing spec categories where the data really lives
--where t.taqprojectkey=14434288
GO

GRANT SELECT ON [dbo].[rpt_poreport_components_view] to PUBLIC
GO
