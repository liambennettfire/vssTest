if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csdistribution_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[csdistribution_view]
GO
CREATE VIEW csdistribution_view AS 
select d.bookkey as bookkey, 
c.printingkey as printingkey,
d.assetkey as assetkey,
d.partnercontactkey as partnerkey,
d.statuscode as statuscode,
c.title as title,
c.productnumber as productnumber,
tpe.taqelementtypecode as assetcode,
tpe.taqelementdesc as assetdesc, 
dbo.get_gentables_desc(576,d.statuscode,'long') as statusdesc,
dbo.get_distribution_datetypecode(11) as distributionassetdatetypecode,
dbo.qcontact_get_displayname(d.partnercontactkey) partnername
FROM csdistribution d, taqprojectelement tpe, coretitleinfo c
     WHERE d.assetkey = tpe.taqelementkey
       AND tpe.bookkey = c.bookkey
       AND tpe.printingkey = c.printingkey
       AND tpe.printingkey = 1
       AND d.lastmaintdate = (SELECT max(lastmaintdate) FROM csdistribution
                               WHERE bookkey = d.bookkey
                                 AND assetkey = d.assetkey
                                 AND partnercontactkey = d.partnercontactkey
                                 AND statuscode not in (select datacode from gentables where tableid = 576 and gen2ind = 1))
       
GO
GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[csdistribution_view]  TO [public]
GO