IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cscustomerpartnerasset]') AND type in (N'V'))
DROP VIEW [dbo].[cscustomerpartnerasset]
GO

CREATE VIEW [cscustomerpartnerasset] AS
    SELECT
        cp.customerkey,
        cp.customername,
        cp.partnercontactkey,
        cp.partnertag,
        cp.partnername,
        g.datacode AS assettypecode,
        g.eloquencefieldtag AS assettypetag,
        g.datadesc AS assettypename,
        cp.partneractiveind,
        cp.partnertype,
        g.deletestatus AS assettypedeletestatus,
        cp.lastuserid AS customerpartnerlastuserid,
        cp.lastmaintdate AS customerpartnerlastmaintdate,
        cp.partnerlastuserid,
        cp.partnerlastmaintdate,
        g.lastuserid AS assettypelastuserid,
        g.lastmaintdate AS assettypelastmaintdate,
        a.lastuserid,
        a.lastmaintdate
    FROM 
        cscustomerpartner cp,
        customerpartnerassets a,
        gentables g
    WHERE
        cp.partnercontactkey=a.partnercontactkey AND
        cp.customerkey=a.customerkey AND
        g.tableid=287 AND
        g.gen1ind=1 AND
        g.datacode=a.assettypecode
GO

GRANT  SELECT  ON [dbo].[cscustomerpartnerasset]  TO [public]
GO
