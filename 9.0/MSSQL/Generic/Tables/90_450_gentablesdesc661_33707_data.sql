UPDATE gentablesdesc
   SET itemtyperelatedtableid = NULL
 WHERE tableid = 616
   AND itemtyperelatedtableid = 661
go

UPDATE gentablesitemtype
   SET relateddatacode = NULL
 WHERE tableid = 616
   AND relateddatacode > 0
go

DELETE FROM gentables_ext WHERE tableid = 661  --Specification Value Location
go

DELETE FROM gentables WHERE tableid = 661  --Specification Value Location
go

DELETE FROM gentablesdesc WHERE tableid = 661  --Specification Value Location
go
