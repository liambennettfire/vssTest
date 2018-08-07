IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_poreport_to_posummary_relationship_view]'))
DROP VIEW [dbo].[rpt_poreport_to_posummary_relationship_view]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[rpt_poreport_to_posummary_relationship_view]
AS
select 
poreportprojectkey = tr.taqprojectkey1 ,
posummaryprojectkey = tr.taqprojectkey2,
poreporttype = (select datadesc from gentables where datacode=tp.taqprojecttype and tableid=521),
poreportname = tp.taqprojecttitle,
posummaryname = tp2.taqprojecttitle
from taqprojectrelationship tr
inner join taqproject tp on tr.taqprojectkey1 = tp.taqprojectkey
inner join taqproject tp2 on tr.taqprojectkey2 = tp2.taqprojectkey
where tr.relationshipcode1=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 28)   --PO Reports (for Purchase Orders)
and tr.relationshipcode2=(select datacode FROM gentables WHERE tableid = 582 AND qsicode = 27)   --Purchase Orders (for PO Reports)

GO

grant select on [dbo].[rpt_poreport_to_posummary_relationship_view] to public
go

