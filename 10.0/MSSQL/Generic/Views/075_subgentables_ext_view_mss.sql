if exists (select * from dbo.sysobjects where id = object_id(N'dbo.subgentables_ext_view') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.subgentables_ext_view
GO

CREATE VIEW dbo.subgentables_ext_view
AS 
select s.*,se.onixsubcode,se.otheronixcode,se.otheronixcodedesc,
       se.onixsubcodedefault,se.onixversion
from subgentables s LEFT OUTER JOIN subgentables_ext se ON
     s.tableid = se.tableid AND
     s.datacode = se.datacode AND
     s.datasubcode = se.datasubcode
go

GRANT DELETE, INSERT, SELECT, UPDATE ON  dbo.subgentables_ext_view TO public
go

