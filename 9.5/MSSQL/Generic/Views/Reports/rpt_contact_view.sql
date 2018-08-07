if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_contact_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_contact_view]
GO

create view dbo.rpt_contact_view as
select
globalcontact.globalcontactkey, 
globalcontact.firstname,
globalcontact.middlename,
globalcontact.lastname,
dbo.get_gentables_desc(210,globalcontact.accreditationcode,'long') "title",
globalcontact.suffix,
globalcontact.degree,
dbo.rpt_get_yes_no (globalcontact.individualind) "individual",
globalcontact.groupname,
globalcontact.displayname,
globalcontact.globalcontactnotes,
dbo.rpt_get_contact_role(globalcontact.globalcontactkey,1,'D') "role1",
dbo.rpt_get_contact_role(globalcontact.globalcontactkey,2,'D') "role2",
dbo.rpt_get_contact_role(globalcontact.globalcontactkey,3,'D') "role3",
dbo.rpt_get_contact_best_method(globalcontact.globalcontactkey,3) "email",
dbo.rpt_get_contact_best_method(globalcontact.globalcontactkey,1) "phone",
dbo.rpt_get_contact_best_method(globalcontact.globalcontactkey,2) "fax",
dbo.rpt_get_contact_best_method(globalcontact.globalcontactkey,4) "website",
dbo.rpt_get_contact_primary_addresstype (globalcontact.globalcontactkey) "addresstype",
dbo.rpt_get_contact_primary_address1 (globalcontact.globalcontactkey) "address1",
dbo.rpt_get_contact_primary_address2 (globalcontact.globalcontactkey) "address2",
dbo.rpt_get_contact_primary_address3 (globalcontact.globalcontactkey) "address3",
dbo.rpt_get_contact_primary_city (globalcontact.globalcontactkey) "city",
dbo.rpt_get_contact_primary_state (globalcontact.globalcontactkey) "state",
dbo.rpt_get_contact_primary_province (globalcontact.globalcontactkey) "province",
dbo.rpt_get_contact_primary_zip (globalcontact.globalcontactkey) "zip",
dbo.rpt_get_contact_primary_country (globalcontact.globalcontactkey) "country"
from globalcontact
where globalcontact.activeind =1 
go
grant select on rpt_contact_view to public
go