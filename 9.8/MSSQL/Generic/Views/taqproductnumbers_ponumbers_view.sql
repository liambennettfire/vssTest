/****** Object:  View [dbo].[taqproductnumbers_ponumbers_view]    Script Date: 04/09/2015 14:28:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[taqproductnumbers_ponumbers_view]'))
DROP VIEW [dbo].[taqproductnumbers_ponumbers_view]
GO

/****** Object:  View [dbo].[taqproductnumbers_ponumbers_view]    Script Date: 04/09/2015 14:28:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[taqproductnumbers_ponumbers_view]
AS
select 
t.taqprojectkey,
t.searchitemcode,
t.usageclasscode,
t.taqprojecttype,
ponumprodnumkey=n1.productnumberkey,
ponumbercode=n1.productidcode,
changenumprodnumkey=n2.productnumberkey,
changenumcode=n2.productidcode,
poname = t.taqprojecttitle,
potype = (select datadesc from gentables where tableid=521 and datacode = t.taqprojecttype),
ismisc = g.sequencenum,
gpostatus = gp.gpostatus,
poreportstatuscode = t.taqprojectstatuscode,
poreportstatus = (select datadesc from gentables where tableid=522 and datacode =t.taqprojectstatuscode),
poclass = (select datadesc from subgentables where tableid=550 and datacode =t.searchitemcode and datasubcode=t.usageclasscode),
ponumber=n1.productnumber,
changenum=n2.productnumber 
from taqproject t
inner join taqproductnumbers n1  on n1.taqprojectkey=t.taqprojectkey and t.searchitemcode=15 and n1.productidcode=3
left outer join gpo gp on t.taqprojectkey=gp.gpokey
left outer join taqproductnumbers n2 on n1.taqprojectkey=n2.taqprojectkey and n2.productidcode=4
left outer join gposection g on t.taqprojectkey = g.gpokey and g.sequencenum=99

GO

GRANT SELECT ON [dbo].[taqproductnumbers_ponumbers_view] TO PUBLIC
GO
