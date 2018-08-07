
/****** Object:  View [dbo].[rpt_poreport_to_printing_relationship_view]    Script Date: 01/19/2015 18:23:42 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_poreport_to_printing_relationship_view]'))
DROP VIEW [dbo].[rpt_poreport_to_printing_relationship_view]
GO

/****** Object:  View [dbo].[rpt_poreport_to_printing_relationship_view]    Script Date: 01/19/2015 18:23:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[rpt_poreport_to_printing_relationship_view]
AS
select 
poreportprojectkey = tr.taqprojectkey2 ,
printingprojectkey = tr.taqprojectkey1,
poreporttype = (select datadesc from gentables where datacode=tp.taqprojecttype and tableid=521),
poreportname = tp.taqprojecttitle,
printingname = tp2.taqprojecttitle
from taqprojectrelationship tr
inner join taqproject tp on tr.taqprojectkey2 = tp.taqprojectkey
inner join taqproject tp2 on tr.taqprojectkey1 = tp2.taqprojectkey
where tr.relationshipcode1=16 and tr.relationshipcode2=17
GO

grant select on [dbo].[rpt_poreport_to_printing_relationship_view] to public
go

