IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cspartner]') AND type in (N'V'))
DROP VIEW [dbo].[cspartner]
GO

CREATE VIEW [cspartner] AS
    SELECT 
        c.globalcontactkey AS partnercontactkey,
        c.partnerkey AS [tag],
        c.groupname AS [name],
        c.activeind,
        c.lastuserid,
        c.lastmaintdate,
        g.datadesc AS partnertype,
        dt.datadesc AS distributiontype
    FROM globalcontact c
    JOIN gentables g ON g.tableid=520 AND c.grouptypecode=g.datacode
    LEFT JOIN globalcontactcategory gc ON gc.globalcontactkey=c.globalcontactkey
    LEFT JOIN gentables dt ON dt.tableid=619 AND gc.contactcategorycode=dt.datacode
    WHERE c.partnerkey > 0
 
 GO

GRANT  SELECT  ON [dbo].[cspartner]  TO [public]
GO
