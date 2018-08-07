
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.finalpo_view') and OBJECTPROPERTY(id, N'IsView') = 1)
   drop view dbo.finalpo_view
GO

CREATE view finalpo_view
as
select g.gpokey, gs.key1 bookkey, gs.key2 printingkey,c.compdesc "Component",
gs.Quantity,
gponumber "PO Number" ,gpochangenum "PO Change Number",gpodate "PO Date",
gpostatus "PO Status",warehousedate "Warehouse Date",prodcontact "Production Contact",
g.daterequired "Date Required",
g.vendorkey,g.vendorname "Vendor Name",g.vendoraddress1 "Vendor Address 1",
g.vendoraddress2 "Vendor Address 2",g.vendorcity "Vendor City",g.vendorstate "Vendor State",
g.vendorzipcode "Vendor Zip",
g.vendorattn "Vendor Attn",g.vendorponumber "Vendor PO Number",g.vendorid "Vendor Name Short",
g.lastuserid "Last Modified By",g.lastmaintdate "Last Modified On", boundbookdate "Bound Book Date",
gpodescription "PO Description",sapstatus "SAP Status",
potype "PO Type",g.potypekey
from gpo g, gposection gs, comptype c, compspec cs
where
gs.key1=cs.bookkey
and gs.key2=cs.printingkey
and gs.key3=cs.compkey
and cs.finishedgoodind='Y'
and gs.key3=c.compkey
and g.gpokey=gs.gpokey
and g.gpostatus='F'


go

GRANT SELECT ON finalpo_view TO public

go
