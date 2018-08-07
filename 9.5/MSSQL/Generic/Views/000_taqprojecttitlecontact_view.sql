if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqprojecttitlecontact_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqprojecttitlecontact_view]
GO

CREATE VIEW taqprojecttitlecontact_view AS
SELECT DISTINCT tpt.taqprojectkey, tpt.bookkey, tpt.printingkey, tpc.globalcontactkey, tpcr.rolecode,
       ct.title, ct.authorname, ct.formatname, ct.productnumber, ct.productnumberx, ct.altproductnumberx,
       cp.projecttitle, cp.projectstatus, cp.projectstatusdesc, cp.searchitemcode, cp.usageclasscode,
       cc.displayname, cc.email, cc.phone, tpt.titlerolecode, tpt.projectrolecode,
       tpt.quantity1, tpt.quantity2, tpt.indicator1, tpt.indicator2, tpt.datacode1, tpt.datacode2       
  FROM coreprojectinfo cp, taqprojecttitle tpt
       LEFT OUTER JOIN coretitleinfo ct ON (tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey),
       taqprojectcontactrole tpcr, taqprojectcontact tpc
       LEFT OUTER JOIN corecontactinfo cc ON (tpc.globalcontactkey = cc.contactkey)
 WHERE tpt.taqprojectkey = cp.projectkey
   and tpt.taqprojectkey = tpc.taqprojectkey
   and tpc.taqprojectcontactkey = tpcr.taqprojectcontactkey
   and tpt.taqprojectkey > 0 

GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqprojecttitlecontact_view]  TO [public]
GO