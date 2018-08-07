if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_resync_sortorder_bookcontact_View]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_resync_sortorder_bookcontact_View]
GO

Create VIEW rpt_resync_sortorder_bookcontact_View
as
	Select bc.bookcontactkey,bc.bookkey,bc.printingkey,bc.globalcontactkey,bc.participantnote,bc.keyind,bc.sortorder,bc.lastuserid,bc.lastmaintdate,
	br.rolecode,br.activeind,br.workrate,br.ratetypecode,br.departmentcode, Row_Number() over (partition By bookkey,printingkey,rolecode order by bookkey,printingkey,sortorder ) as new_sort_order
	from bookcontact bc
	inner join bookcontactrole br
	on bc.bookcontactkey=br.bookcontactkey 
Go
Grant all on rpt_resync_sortorder_bookcontact_View to public