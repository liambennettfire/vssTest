set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[currency_view]') and objectproperty(id, N'isview') = 1)
drop view [dbo].[currency_view]
go


create view dbo.currency_view(tableid, datacode, datadesc, deletestatus, applid, sortorder, tablemnemonic, externalcode, datadescshort, lastuserid, lastmaintdate, numericdesc1, numericdesc2)  as 
  select 
      dbo.gentables.tableid, 
      dbo.gentables.datacode, 
      dbo.gentables.datadesc, 
      dbo.gentables.deletestatus, 
      dbo.gentables.applid, 
      dbo.gentables.sortorder, 
      dbo.gentables.tablemnemonic, 
      dbo.gentables.externalcode, 
      dbo.gentables.datadescshort, 
      dbo.gentables.lastuserid, 
      dbo.gentables.lastmaintdate, 
      dbo.gentables.numericdesc1, 
      dbo.gentables.numericdesc2
    from dbo.gentables
    where (dbo.gentables.tableid = 122)



go
set quoted_identifier off 
go
set ansi_nulls on 
go
grant  select ,  update ,  insert ,  delete  on [dbo].[currency_view]  to [public]
go

