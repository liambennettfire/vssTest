if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqprojectpayments_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqprojectpayments_view]
GO

CREATE VIEW taqprojectpayments_view AS
  SELECT p.paymentkey, p.taqprojectkey, p.paymenttype, p.datetypecode, p.dateoffsetcode, p.paymentamount, p.taqtaskkey, p.date,
  CASE (SELECT g.gen1ind FROM gentables g WHERE g.tableid = 635 AND g.datacode = p.paymenttype)
    WHEN 1 THEN (SELECT t.activedate FROM taqprojecttask t WHERE t.taqtaskkey = p.taqtaskkey)
    ELSE originaldate
  END originaldate,
  CASE (SELECT g.gen1ind FROM gentables g WHERE g.tableid = 635 AND g.datacode = p.paymenttype)
    WHEN 1 THEN DATEADD(mm, COALESCE(o.numericdesc1,0), DATEADD(dd, COALESCE(o.numericdesc2,0), (SELECT t.activedate FROM taqprojecttask t WHERE t.taqtaskkey = p.taqtaskkey)))
    ELSE reviseddate
  END reviseddate,
  p.note, p.payeecontactkey, p.pmtstatuscode, p.invoicenumber, p.invoicesent, 
  p.checknumber, p.lastuserid, p.lastmaintdate, p.sortorder
  FROM taqprojectpayments p, gentables o
  WHERE p.dateoffsetcode = o.datacode 
    AND o.tableid = 466 
 
GO

GRANT  SELECT, UPDATE, INSERT, DELETE  ON [dbo].[taqprojectpayments_view]  TO [public]
GO