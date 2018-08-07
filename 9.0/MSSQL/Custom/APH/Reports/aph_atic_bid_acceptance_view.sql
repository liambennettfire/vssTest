
/****** Object:  View [dbo].[aph_atic_bid_acceptance_view]    Script Date: 07/22/2015 11:50:25 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[aph_atic_bid_acceptance_view]'))
DROP VIEW [dbo].[aph_atic_bid_acceptance_view]
GO

/****** Object:  View [dbo].[aph_atic_bid_acceptance_view]    Script Date: 07/22/2015 11:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--  select * from [dbo].[aph_atic_bid_acceptance_view] where bookkey=34330328
create view [dbo].[aph_atic_bid_acceptance_view] as
select 
	bookkey = b.bookkey,
	elementkey =te.taqelementkey ,
	elementdesc =te.taqelementdesc ,
	completed = dbo.rpt_get_title_task (b.bookkey,(select datetypecode from datetype where externalcode='ATICCOMPTRANSDUE') ,'B'),
	ean = i.ean13,
	catalognum = i.itemnumber ,
	title = b.title,
	first3due = dbo.rpt_get_title_task (b.bookkey,(select datetypecode from datetype where externalcode='First3Due') ,'B') ,
	transcribedusing = dbo.[rpt_get_category_list] (b.bookkey,431,'; ','1','ATICEMBOSS'),
	transcribedon = dbo.[rpt_get_category_list] (b.bookkey,431,'; ','1','ATICPGSIDE'), 
	outsourcename = g.groupname,
	contactname = contact.firstname + ' '+ contact.lastname,
	contactkey1 = contact.k1,
	contactkey2 = contact.k2,
	contactaddrress1 = gca.address1,
	contactaddrress2 = gca.address2,
	contactaddrress3 = gca.address3,
	contactcity = gca.city,
	contactstate = (select datadesc from gentables where tableid=160 and datacode=gca.statecode),
	contactzip = gca.zipcode
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
	left join globalcontactaddress gca on gca.globalcontactkey=g.globalcontactkey
	
where  gca.primaryind=1

GO
