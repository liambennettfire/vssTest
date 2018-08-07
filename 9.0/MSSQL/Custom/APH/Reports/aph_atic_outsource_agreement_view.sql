/****** Object:  View [dbo].[aph_atic_outsource_agreement_view]    Script Date: 07/22/2015 11:50:25 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[aph_atic_outsource_agreement_view]'))
DROP VIEW [dbo].[aph_atic_outsource_agreement_view]
GO
/****** Object:  View [dbo].[aph_atic_outsource_agreement_view]    Script Date: 07/22/2015 11:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from [dbo].[aph_atic_outsource_agreement_view] where bookkey=34330328
create view [dbo].[aph_atic_outsource_agreement_view] as
select 
	bookkey = b.bookkey,
	elementkey =te.taqelementkey ,
	elementdesc =te.taqelementdesc ,
	completed = dbo.rpt_get_title_task (b.bookkey,(select datetypecode from datetype where externalcode='ATICCOMPTRANSDUE') ,'B'), -- BidRecvd
	received =  dbo.rpt_get_title_task (b.bookkey,(select datetypecode from datetype where externalcode='BidRecvd') ,'B'), 
	isbn = dbo.rpt_get_misc_value_text(b.bookkey, (select misckey from bookmiscitems where externalid='ParentIsbn')),
	catalognum = i.itemnumber ,
	title = b.title,
	first3due = dbo.rpt_get_title_task (b.bookkey,(select datetypecode from datetype where externalcode='First3Due') ,'B') ,
	transcribedusing = dbo.[rpt_get_category_list] (b.bookkey,431,'; ','1','ATICEMBOSS'),
	transcribedon = dbo.[rpt_get_category_list] (b.bookkey,431,'; ','1','ATICPGSIDE'), 
	CostPerBraillePg = dbo.rpt_get_misc_value_float(b.bookkey, (select misckey from bookmiscitems where externalid='CostPerBraillePg')),
	CostPerGraphicPg = dbo.rpt_get_misc_value_float(b.bookkey, (select misckey from bookmiscitems where externalid='CostPerGraphicPg')),
	textbookincludes = dbo.[rpt_get_category_list] (b.bookkey,643,'; ','D',null), 
	outsourcename = g.groupname,
	contactname = contact.firstname + ' '+ contact.lastname,
	contactkey1 = contact.k1,
	contactkey2 = contact.k2
from book b 
	inner join isbn i on b.bookkey=i.bookkey
	inner join taqprojectelement te on b.bookkey=te.bookkey 
				and te.elementstatus = (select datacode from gentables where tableid=593 and externalcode='BAWRD')
	inner join globalcontact g on te.globalcontactkey=g.globalcontactkey
	inner join (	select max(globalcontactrelationshipkey) as min, c.firstname as firstname, c.lastname as lastname, c.globalcontactkey as k1, r.globalcontactkey2 as k2
					from globalcontactrelationship r
					inner join globalcontact c on c.globalcontactkey=r.globalcontactkey1
					group by firstname, lastname, globalcontactkey, globalcontactkey2
				) contact on contact.k2 = g.globalcontactkey
						

GO
