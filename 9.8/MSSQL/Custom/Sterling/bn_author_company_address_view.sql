/****** Object:  View [dbo].[bn_author_company_address_view]    Script Date: 04/19/2010 21:56:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

drop view [dbo].[bn_author_company_address_view] 
go
CREATE VIEW [dbo].[bn_author_company_address_view] 
AS
select  
g.globalcontactkey,
g.contributorkey,
ga.primaryind,
g.groupname, 
g.displayname, 
g.firstname,
g.lastname,
ga.address1 "addressline1", 
ga.address2 "addressline2",
ga.address3 "addressline3",
ga.city,
statedesc = (select gentables.datadesc from gentables where datacode = ga.statecode and tableid = 160),
ga.zipcode "zip",
contrydesc = (select gentables.datadesc from gentables where datacode = ga.countrycode and tableid = 114),
g.globalcontactnotes
from globalcontactaddress ga, 
globalcontact g 
where ga.primaryind=1
and ga.addresstypecode=1
and g.globalcontactkey=ga.globalcontactkey
go
grant select on dbo.[bn_author_company_address_view] to public
go

/*company website*/
/*phone - work*/
/*category and subcategory*/
/*isbn*/





