if exists (select * from dbo.sysobjects where id = object_id(N'dbo.gentables_ext_view') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.gentables_ext_view
GO

CREATE VIEW dbo.gentables_ext_view
AS 
select g.*,ge.onixcode,ge.onixcodedefault,ge.onixversion
from gentables g LEFT OUTER JOIN gentables_ext ge ON
 g.tableid = ge.tableid AND
 g.datacode = ge.datacode
go

GRANT DELETE, INSERT, SELECT, UPDATE ON  dbo.gentables_ext_view TO public
go

