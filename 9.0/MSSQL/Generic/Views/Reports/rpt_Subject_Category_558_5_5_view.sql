
/****** Object:  View [dbo].[rpt_Subject_Category_558_5_5_view]    Script Date: 03/24/2009 13:25:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[rpt_Subject_Category_558_5_5_view] AS 

select bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder
from booksubjectcategory
where categorytableid = 558 and categorycode = 5 and categorysubcode = 5

