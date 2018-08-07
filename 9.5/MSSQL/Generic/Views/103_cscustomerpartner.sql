IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cscustomerpartner]') AND type in (N'V'))
DROP VIEW [dbo].[cscustomerpartner]
GO

CREATE VIEW [cscustomerpartner] AS
    SELECT
        cp.customerkey,
        c.customerlongname AS [customername], 
        p.partnercontactkey,
        p.tag AS [partnertag],
        p.name AS [partnername],
        p.activeind AS [partneractiveind],
        p.lastuserid AS [partnerlastuserid],
        p.lastmaintdate AS [partnerlastmaintdate],
        p.partnertype,
        cp.lastuserid,
        cp.lastmaintdate
    FROM
        cspartner p,
        customerpartner cp,
        customer c
    WHERE
        p.partnercontactkey=cp.partnercontactkey AND
        cp.customerkey=c.customerkey
 

 GO

GRANT  SELECT  ON [dbo].[cscustomerpartner]  TO [public]
GO
