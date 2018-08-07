IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cspartnermediaformat]') AND type in (N'V'))
DROP VIEW [dbo].[cspartnermediaformat]
GO

CREATE VIEW [cspartnermediaformat] AS
    SELECT 
        p.partnercontactkey,
        p.tag AS partnertag,
        p.name AS partnername,
        g.datacode AS mediacode,
        g.eloquencefieldtag AS mediatag,
        g.datadesc AS [medianame],
        s.datasubcode AS formatcode,
        s.eloquencefieldtag AS formattag,
        s.datadesc AS formatname,
        f.customerkey,
        c.customerlongname AS customername,
        f.lastuserid,
        f.lastmaintdate
    FROM 
        cspartnerformat f,
        cspartner p,
        customer c,
        gentables g,
        subgentables s
    WHERE
        f.partnercontactkey=p.partnercontactkey AND
        g.tableid=312 AND
        s.tableid=312 AND
        g.datacode=s.datacode AND
        f.mediacode=g.datacode AND
        f.mediasubcode=s.datasubcode AND
        c.customerkey = f.customerkey

GO

GRANT  SELECT  ON [dbo].[cspartnermediaformat]  TO [public]
GO