
/****** Object:  View [dbo].[rpt_Subject_Category_558_7_1_view]    Script Date: 03/24/2009 13:35:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[rpt_Subject_Category_558_7_1_view] AS 

select bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder
from booksubjectcategory
where categorytableid = 558 and categorycode = 7 and categorysubcode = 1

