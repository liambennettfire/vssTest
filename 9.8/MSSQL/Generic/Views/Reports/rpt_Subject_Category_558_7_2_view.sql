
/****** Object:  View [dbo].[rpt_Subject_Category_558_7_2_view]    Script Date: 03/24/2009 13:36:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[rpt_Subject_Category_558_7_2_view] AS 

select bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder
from booksubjectcategory
where categorytableid = 558 and categorycode = 7 and categorysubcode = 2

