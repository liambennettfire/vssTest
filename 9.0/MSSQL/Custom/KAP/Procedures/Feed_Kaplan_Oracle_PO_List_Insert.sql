alter proc dbo.Feed_Kaplan_Oracle_PO_List_Insert (@i_batchkey int, @i_gpokey int, @i_feedkapheaderkey int)
AS

BEGIN

Insert into Feed_Kaplan_Oracle_PO_List 
	(feedkapheaderkey,
	datecreated,
	batchkey,
	pokey,
	sectionkey,
	itemtypecode,
	paperisbn,
	unitofmeasure,
	quantity,
	totalfixedcost,
	totalruncost,
	finishedgoodind)

	select @i_feedkapheaderkey,
		getdate(),
		@i_batchkey,
		gs.gpokey,
		gs.sectionkey,
		ct.externalcode,
		'',--substring(ms.stockdesc,1,13),
		'Each' as [Unit of Measure],
		gs.quantity as Quantity,
		SUM(CASE c.externalcode WHEN 'FIXED' THEN gc.totalcost END) as [Total Fixed Cost],
		SUM(CASE c.externalcode WHEN 'RUN' THEN gc.totalcost END) as [Total Run Cost],
		cs.finishedgoodind	
	from gposection gs, gpo g, gposhiptovendor gsv, compspec cs, gpocost gc, cdlist c, comptype ct, materialspecs ms
	where g.gpokey = gs.gpokey
		and g.gpokey = gsv.gpokey
		and gs.key3 = cs.compkey
		and gs.key1 = cs.bookkey
		and gs.key2 = cs.printingkey
		and gs.key1 = ms.bookkey
		and gs.key2 = ms.printingkey
		and gs.sectionkey *= gc.sectionkey
		and gs.gpokey *= gc.gpokey
		and g.gpostatus = 'F'
		and gc.chgcodecode =* c.internalcode
		and c.externalcode IN ('FIXED','RUN')
		and gs.key3 = ct.compkey
		and gs.gpokey = @i_gpokey
	Group by gs.gpokey, gs.key3, gs.sectionkey, gs.quantity, ct.externalcode, cs.finishedgoodind
	order by 3



print 'Feed_Kaplan_Oracle_PO_List insert for gpokey: ' + cast(@i_gpokey as varchar)


END