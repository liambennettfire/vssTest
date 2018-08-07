if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_global_contact_relationship_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_global_contact_relationship_view]
GO

CREATE VIEW [dbo].rpt_global_contact_relationship_view AS
select
    globalcontactrelationshipkey,
    gcr.globalcontactkey1 "globalcontactkey",
    gc.displayname "contactname",
    gcr.globalcontactkey2 "relatedcontactkey",
    gc2.displayname "relatedcontactname", 
    contactrelationshipcode1 "relationshipcode",
    datadesc "relationshipdesc",
    gen1ind "companyind",
    contactrelationshipaddtldesc,
    keyind,
    gcr.sortorder,
    gcr.lastmaintdate,
    gcr.lastuserid
  from globalcontactrelationship gcr, globalcontact gc, globalcontact gc2, gentables g
  where gcr.globalcontactkey1=gc.globalcontactkey
    and gcr.globalcontactkey2=gc2.globalcontactkey
    and gcr.contactrelationshipcode1=g.datacode
    and g.tableid=519
    and gcr.globalcontactkey2 is not null
UNION
select
    globalcontactrelationshipkey,
    gcr.globalcontactkey2 "globalcontactkey",
    gc2.displayname "contactname", 
    gcr.globalcontactkey1 "relatedcontactkey",
    gc.displayname "relatedcontactname",
    contactrelationshipcode2 "relationshipcode",
    datadesc "relationshipdesc",
    gen1ind "companyind",
    contactrelationshipaddtldesc,
    keyind,
    gcr.sortorder,
    gcr.lastmaintdate,
    gcr.lastuserid
  from globalcontactrelationship gcr, globalcontact gc, globalcontact gc2, gentables g
  where gcr.globalcontactkey2=gc2.globalcontactkey
    and gcr.globalcontactkey1=gc.globalcontactkey
    and gcr.contactrelationshipcode2=g.datacode
    and g.tableid=519
    and globalcontactkey2 is not null
UNION
select
    globalcontactrelationshipkey,
    gcr.globalcontactkey1 "globalcontactkey",
    gc.displayname "contactname",
    gcr.globalcontactkey2 "relatedcontactkey",
    globalcontactname2 "relatedcontactname",
    contactrelationshipcode1 "relationshipcode",
    datadesc "relationshipdesc",
    gen1ind "companyind",
    contactrelationshipaddtldesc,
    keyind,
    gcr.sortorder,
    gcr.lastmaintdate,
    gcr.lastuserid
  from globalcontactrelationship gcr, globalcontact gc, gentables g
  where gcr.globalcontactkey1=gc.globalcontactkey
    and gcr.globalcontactkey2 is NULL
    and gcr.contactrelationshipcode1=g.datacode
    and g.tableid=519 
go

grant select on rpt_global_contact_relationship_view to public 
go