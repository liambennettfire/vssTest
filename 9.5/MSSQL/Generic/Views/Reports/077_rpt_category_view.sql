SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_category_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[rpt_category_view]
GO
CREATE VIEW rpt_category_view AS 
select s.bookkey as bookkey, 
s.subjectkey as subjectkey, 
s.categorytableid as v, 
gd.tabledesclong as tabledesclong, 
s.categorycode as categorycode, 
g1.datadesc as datadesc1, 
s.categorysubcode as categorysubcode, 
g2.datadesc as datadesc2, 
s.categorysub2code as categorysub2code, 
g3.datadesc as datadesc
from booksubjectcategory s join gentablesdesc gd on s.categorytableid = gd.tableid 
join gentables g1 on s.categorytableid = g1.tableid and 
g1.datacode = s.categorycode 
left outer join subgentables g2 on s.categorytableid = g2.tableid and 
s.categorycode = g2.datacode and 
s.categorysubcode = g2.datasubcode 
left outer join sub2gentables g3 on s.categorytableid = g3.tableid and 
s.categorycode = g3.datacode and 
s.categorysubcode = g3.datasubcode and 
s.categorysub2code = g3.datasub2code
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[rpt_category_view]  TO [public]
GO