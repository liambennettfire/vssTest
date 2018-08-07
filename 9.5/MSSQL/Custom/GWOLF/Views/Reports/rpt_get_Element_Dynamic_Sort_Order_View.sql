if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_get_Element_Dynamic_Sort_Order_View]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_get_Element_Dynamic_Sort_Order_View]
GO

/****** Object:  View [dbo].[rpt_get_Element_Dynamic_Sort_Order_View]    Script Date: 12/11/2014 16:12:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[rpt_get_Element_Dynamic_Sort_Order_View] as
	Select Top 1000000000 taqprojectkey,bookkey,t.taqelementkey,
	taqelementtypecode,dbo.rpt_get_gentables_desc(287,taqelementtypecode,'long') as MediaType,
	taqelementtypesubcode,dbo.rpt_get_subgentables_desc(287,taqelementtypecode,taqelementtypesubcode,'long') as MediaSubType,
	Case when taqelementtypesubcode > 0 then 
	lower(dbo.rpt_get_gentables_desc(287,taqelementtypecode,'long'))+'/'+lower(dbo.rpt_get_subgentables_desc(287,taqelementtypecode,taqelementtypesubcode,'long')) 
	else lower(dbo.rpt_get_gentables_desc(287,taqelementtypecode,'long')) end
	as QuoteType,
	taqelementdesc,dbo.rpt_GET_QSI_Comment(t.taqelementkey,7,4) as Short_Quote,
	dbo.rpt_GET_QSI_Comment(t.taqelementkey,7,5) as Long_Quote,
	dbo.rpt_Get_taqelement_misc_value(t.taqelementkey,1,128) as Web_Indicator,
	dbo.rpt_get_taqelementmisc_value_gentable(t.taqelementkey,128,'long') as Web_Indicator_Desc,
	Case when t.sortorder is null then
	5000
	else t.sortorder  end as Sort_order,
	tem.lastmaintdate, Row_Number() over(Partition by bookkey order by Case 
	when t.sortorder is null then
	5000
	else t.sortorder  end,tem.lastmaintdate)as New_Sort_Order
	from taqprojectelement t
	left outer join taqelementmisc tem
	on t.taqelementkey=tem.taqelementkey and tem.misckey = 126
	where --tem.misckey=126 --and taqprojectkey=664776
	--bookkey = 657476 and
	exists(Select * from qsicomments where commentkey = t.taqelementkey and commenttypecode = 7)
	group by taqprojectkey,bookkey,taqelementtypecode,taqelementtypesubcode,taqelementdesc,t.taqelementkey,tem.lastmaintdate,t.sortorder
	order by taqprojectkey,bookkey, 
	Row_Number() over(Partition by taqprojectkey,bookkey order by Case 
	when t.sortorder is null then
	5000
	else t.sortorder  end,tem.lastmaintdate),
	t.sortorder ,
	tem.lastmaintdate asc
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[rpt_get_Element_Dynamic_Sort_Order_View]  TO [public]
GO
