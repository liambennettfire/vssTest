DELETE from subgentables 
  WHERE tableid = 339 AND
	     datadesc = 
'South Asian Languages see Indic & South Asian Languages'
go

DELETE from subgentables 
  WHERE tableid = 339 AND
	     datadesc =
	'Bible/Versions see headings under Bibles'
go

DELETE from subgentables 
  WHERE tableid = 339 AND
	     datadesc =
	'Christian Life see Christianity/Christian Life'
go

DELETE from subgentables 
  WHERE tableid = 339 AND
	     datadesc =
	'Church History see Christianity/History'
go
DELETE from subgentables 
  WHERE tableid = 339 AND
	     datadesc = 'Christian Education see headings under Christianity / Education'
go
/*added to remove several non-coded religious entries*/

delete from subgentables where 
tableid=339 
and bisacdatacode is null 
and lastuserid='qsi-sql-V2006'
go