DELETE FROM bookwhupdate WHERE bookkey in (select contractkey from contract)
go
DELETE FROM bookwhupdate WHERE bookkey in (select bookkey FROM titledeleteaudit)
go
DELETE FROM bookwhupdate WHERE bookkey in (select catalogkey FROM catalog)
go
DELETE FROM bookwhupdate WHERE bookkey not in (select bookkey FROM book)
go