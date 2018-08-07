/****** Object:  View [dbo].[rpt_poreport_to_posummary_relationship_view]    Script Date: 01/19/2015 18:21:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_poreport_to_posummary_relationship_view]'))
DROP VIEW [dbo].[rpt_poreport_to_posummary_relationship_view]
GO
/****** Object:  View [dbo].[rpt_poreport_to_posummary_relationship_view]    Script Date: 01/19/2015 18:21:46 ******/
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
where tr.relationshipcode1=15 and tr.relationshipcode2=14
GO

grant select on [dbo].[rpt_poreport_to_posummary_relationship_view] to public
go

