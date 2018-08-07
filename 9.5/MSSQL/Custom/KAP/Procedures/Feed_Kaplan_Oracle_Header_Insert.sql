alter proc dbo.Feed_Kaplan_Oracle_Header_Insert (@i_batchkey int, @i_gpokey int, @i_feedkapheaderkey int, @i_validcomptypecount int)
AS

BEGIN

insert into Feed_Kaplan_Oracle_Header
select distinct 
	@i_feedkapheaderkey,
	getdate(),
	@i_batchkey,
	g.gpokey,
	0 as [New/Update Indicator],
	g.gponumber as [PM PO Number],
	gs.key2 as [PM Print Key],
	g.gpochangenum as [PM PO Revision #],
	CASE WHEN v.paytovendorkey IS NULL THEN v.vendorid ELSE CAST(v.paytovendorkey as varchar) END as [Vendor ID],	
	g.vendorid as [Vendor Site ID],
	CASE WHEN ph.ponumber <>  g.gponumber THEN v2.vendorid ELSE NULL END as [Ship to Vendor ID],
	CASE WHEN ph.ponumber <>  g.gponumber THEN gsv.shiptovendorid ELSE NULL END as [Ship To Site],
	CASE WHEN ga.requestor IS NULL THEN g.lastuserid ELSE ga.requestor END as [Buyer Name],
	g.lastmaintdate as [Created On],
	CASE WHEN gs.daterequired is null THEN g.lastmaintdate  ELSE gs.daterequired END as daterequired,
	dbo.get_isbn(gs.key1,17) + ' - ' + ISNULL(g.gpodescription,'') as [PO Description],
	dbo.get_Isbn(gs.key1,17) as [ISBN],
	CASE WHEN ph.ponumber = g.gponumber THEN 1 ELSE 3 END as [Item Type Code],
	gs.quantity as [Finished Goods Quantity],
	CASE WHEN ph.ponumber <>  g.gponumber THEN ph.ponumber ELSE NULL END as [Parent PM PO #],
	ph.changenum as [Parent PM PO Revision #],
	gs.key3 as componenttypecode
from gposection gs, gpo g, gposhiptovendor gsv, compspec cs, vendor v, vendor v2, gpoauthorization ga, pohistory ph
where g.gpokey = gs.gpokey
	and g.gpokey = gsv.gpokey
	and gs.key3 = cs.compkey
	and gs.key1 = cs.bookkey
	and gs.key2 = cs.printingkey
	and g.vendorkey = v.vendorkey
	and gsv.shiptovendorkey = v2.vendorkey
	and g.gpokey *= ga.gpokey
	and gs.key1 = ph.bookkey
	and gs.key2 = ph.printingkey
	and cs.finishedgoodind = CASE WHEN @i_validcomptypecount > 1 THEN 'Y' ELSE 'N' END
	and g.gpostatus = 'F'
	and gs.gpokey = @i_gpokey

print 'Feed_Kaplan_Oracle_Header insert for gpokey: ' + CAST(@i_gpokey as varchar) 
	

END

