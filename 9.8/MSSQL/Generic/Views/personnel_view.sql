SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[personnel_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[personnel_view]
GO


CREATE VIEW personnel_view AS 
select
bc.bookkey,
p.displayname,
p.firstname,
p.middlename,
p.lastname,
p.shortname,
g.datadesc,
bc.resourcedesc,
bc.sortorder
from bookcontributor bc, person p,gentables g
where
p.contributorkey=bc.contributorkey
and g.tableid=285
and g.datacode=bc.roletypecode

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
