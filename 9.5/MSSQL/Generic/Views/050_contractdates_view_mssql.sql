
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.contractdates_view') and OBJECTPROPERTY(id, N'IsView') = 1)
   drop view dbo.contractdates_view
GO


create view dbo.contractdates_view as
select contractdates.contractkey,
contractdates.datetypecode,
contractdates.activedate,
contractdates.actualind,
contractdates.recentchangeind,
contractdates.lastuserid,
contractdates.lastmaintdate,
contractdates.estdate,
contractdates.sortorder,
contractdates.bestdate,
datetype.description Task
from contractdates, datetype
where contractdates.datetypecode = datetype.datetypecode

go

GRANT ALL on contractdates_view to PUBLIC 
go


