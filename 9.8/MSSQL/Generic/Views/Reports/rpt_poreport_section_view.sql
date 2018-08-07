IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_poreport_section_view]'))
DROP VIEW [dbo].[rpt_poreport_section_view]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view dbo.rpt_poreport_section_view
AS
SELECT
gpokey = gs.gpokey,
poreportkey = gs.gpokey,
sectionkey = gs.sectionkey,
subsectionkey = 0,
bookkey = gs.key1,
printingkey = gs.key2,
speccategorykey = gs.key3, 
posummaryprojectkey = tr.taqprojectkey2,
description = gs.description,
lastuserid = gs.lastuserid,
lastmaintdate = gs.lastmaintdate,
quantity = coalesce(gs.quantity,0),
gs.sectiontype,
itemcategorycode = (select itemcategorycode from taqversionspeccategory where taqversionspecategorykey=gs.key3)
from gposection  gs
left outer join taqprojectrelationship tr on gs.gpokey = tr.taqprojectkey1 
and tr.relationshipcode1=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 28)   --PO Reports (for Purchase Orders) 
and tr.relationshipcode2=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 27)   --Purchase Orders (for PO Reports) 
where gs.sectiontype in (2,3)
UNION
SELECT
gpokey = gss.gpokey,
poreportkey = gss.gpokey,
sectionkey = gss.sectionkey,
subsectionkey = gss.subsectionkey,
bookkey = gss.key1,
printingkey = gss.key2,
speccategorykey = gss.key3, 
posummaryprojectkey = tr.taqprojectkey2,
description = gss.description,
lastuserid = gss.lastuserid,
lastmaintdate = gss.lastmaintdate,
quantity = coalesce(gss.quantity,0),
sectiontype=gss.subsectiontype,
itemcategorycode = (select itemcategorycode from taqversionspeccategory where taqversionspecategorykey=gss.key3)
from gposubsection  gss
left outer join taqprojectrelationship tr on gss.gpokey = tr.taqprojectkey1 
and tr.relationshipcode1=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 28)   --PO Reports (for Purchase Orders) 
and tr.relationshipcode2=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 27)   --Purchase Orders (for PO Reports) 
where gss.subsectiontype in (2,3)
UNION
SELECT
gpokey = gs.gpokey,
poreportkey = gs.gpokey,
sectionkey = gs.sectionkey,
subsectionkey = 0,
bookkey = coalesce(pr.bookkey,0),
printingkey = coalesce(pr.printingkey,0),
speccategorykey = gs.key2, 
posummaryprojectkey = tr.relatedprojectkey,
description = gs.description,
lastuserid = gs.lastuserid,
lastmaintdate = gs.lastmaintdate,
quantity = coalesce(gs.quantity,0),
gs.sectiontype,
itemcategorycode = (select itemcategorycode from taqversionspeccategory where taqversionspecategorykey=gs.key2)
from gposection  gs
left outer join projectrelationshipview tr on gs.key1 = tr.taqprojectkey 
and tr.relationshipcode=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 25)   --PO Summary (for Printings) 
inner join taqprojectprinting_view pr on pr.taqprojectkey = tr.relatedprojectkey 
where gs.sectiontype in (6,7)
go
grant select on dbo.rpt_poreport_section_view to public
go

