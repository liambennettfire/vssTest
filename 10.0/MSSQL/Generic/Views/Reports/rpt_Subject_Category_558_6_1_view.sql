
/****** Object:  View [dbo].[rpt_Subject_Category_558_6_1_view]    Script Date: 03/24/2009 13:32:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[rpt_Subject_Category_558_6_1_view] AS 

select bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder
from booksubjectcategory
where categorytableid = 558 and categorycode = 6 and categorysubcode = 1

