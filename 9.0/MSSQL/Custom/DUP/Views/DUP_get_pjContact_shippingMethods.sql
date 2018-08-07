 
/****** Object:  View [dbo].[DUP_get_pjContact_shippingMethods]    Script Date: 08/06/2015 13:53:25 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_get_pjContact_shippingMethods]'))
DROP VIEW [dbo].[DUP_get_pjContact_shippingMethods]
GO
 
/****** Object:  View [dbo].[DUP_get_pjContact_shippingMethods]    Script Date: 08/06/2015 13:53:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- select * from dbo.DUP_get_pjContact_shippingMethods where globalcontactkey = 3091802
CREATE VIEW [dbo].[DUP_get_pjContact_shippingMethods] 
	(globalcontactkey, longvalue, misckey, datacode, datadesc, datasubcode)
AS 
select g.globalcontactkey, g.longvalue, g.misckey
	,s.datacode
	,s.datadesc
	,s.datasubcode
from globalcontactmisc g
inner join subgentables s 
	on s.datasubcode=g.longvalue
where g.misckey=704
	and s.datacode=107
	and s.tableid=525
	and s.deletestatus <> 'Y'
union 
select 0,0,0,0,'All',0


GO


