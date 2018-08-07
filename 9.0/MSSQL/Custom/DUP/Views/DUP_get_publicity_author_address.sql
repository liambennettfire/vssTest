

/****** Object:  View [dbo].[DUP_get_publicity_author_address]    Script Date: 10/13/2015 12:47:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_get_publicity_author_address]'))
DROP VIEW [dbo].[DUP_get_publicity_author_address]
GO



/****** Object:  View [dbo].[DUP_get_publicity_author_address]    Script Date: 10/13/2015 12:47:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[DUP_get_publicity_author_address] AS
select min(sorder) as sorder,address1,address2,address3,city,state,zipcode,country,globalcontactkey
from (select
	'primary' as type,
	1 as sorder,
	gca.address1,
	gca.address2,
	gca.address3,
	gca.city,
	dbo.get_gentables_desc (160,gca.statecode,'L') as state,
	gca.zipcode,
	dbo.get_gentables_desc (114,gca.countrycode,'L') as country,
	gca.globalcontactkey
		
from globalcontactaddress gca
where  gca.primaryind = 1

UNION
select
   	'company' as type,
   	4 as sorder,
	gca.address1,
	gca.address2,
	gca.address3,
	gca.city,
	dbo.get_gentables_desc (160,gca.statecode,'L') as state,
	gca.zipcode,
	dbo.get_gentables_desc (114,gca.countrycode,'L') as country,
	gca.globalcontactkey
		
from globalcontactaddress gca
where  gca.primaryind = (select datacode from gentables where tableid=207 and datadesc='Company Mailing')

UNION
select
   	'home' as type,
   	2 as sorder,
	gca.address1,
	gca.address2,
	gca.address3,
	gca.city,
	dbo.get_gentables_desc (160,gca.statecode,'L') as state,
	gca.zipcode,
	dbo.get_gentables_desc (114,gca.countrycode,'L') as country,
	gca.globalcontactkey
		
from globalcontactaddress gca
where  gca.primaryind = (select datacode from gentables where tableid=207 and datadesc='Home Mailing')

UNION
select
   	'university' as type,
   	3 as sorder,
	gca.address1,
	gca.address2,
	gca.address3,
	gca.city,
	dbo.get_gentables_desc (160,gca.statecode,'L') as state,
	gca.zipcode,
	dbo.get_gentables_desc (114,gca.countrycode,'L') as country,
	gca.globalcontactkey
		
from globalcontactaddress gca
where  gca.primaryind = (select datacode from gentables where tableid=207 and datadesc='University Mailing')
)  list
group by globalcontactkey, address1,address2,address3,city,state,zipcode,country
 

GO


