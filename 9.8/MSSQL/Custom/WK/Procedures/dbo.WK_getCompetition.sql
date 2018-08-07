if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getCompetition') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getCompetition
GO
CREATE PROCEDURE dbo.WK_getCompetition
@bookkey int
/*
Competition[] comp = new Competition[1];
comp[0].domesticPrice;
comp[0].editionNumber;
comp[0].id;
comp[0].leadPerson;
comp[0].pageCount;
ProAndCon[] pc = new ProAndCon[1];
pc[0].competitionId;
pc[0].id;
pc[0].sequence;
pc[0].text;
pc[0].type;

comp[0].proAndCon = pc;
comp[0].pubDate;
comp[0].publisher;
comp[0].sequence;
comp[0].title;

Select * FROM associatedtitles
where associationtypecode = 1

origpubhousecode -- gentableid = 126

Select dbo.rpt_get_gentables_desc(126, origpubhousecode,'long')
from associatedtitles
where associationtypecode = 1

Select bookkey, sortorder, Count(*) FROM associatedtitles
where associationtypecode = 1
GROUP BY bookkey, sortorder
HAVING Count(*) >1


Select * FROM WK_ORA.WKDBA.COMPETITION
ORDER BY COMPETITION_ID

SElect * FROM WK_ORA.WKDBA.COMMON_PRODUCT
WHERE COMMON_PRODUCT_ID = 113797

dbo.WK_getCompetition 923044
566415

Select * FROM associatedtitles
where associationtypecode = 1

Select * FROM book
where title = 'Essentials of Maternity, Newborn, and Women''s Health Nursing'

Select Max(COMPETITION_ID) FROM WK_ORA.WKDBA.COMPETITION --2638082

Select MIN(COMPETITION_ID) FROM WK_ORA.WKDBA.COMPETITION --1



*/

AS
BEGIN


Select DISTINCT
--(Cast(bookkey as varchar(20)) + Cast(associationtypecode as varchar(20)) + Cast(sortorder as varchar(20))) as [idField], 
(Cast(bookkey as varchar(20)) +  Cast(sortorder as varchar(20))) as [idField], 
title as [titleField],
authorname as [leadpersonField],
[dbo].[rpt_get_gentables_field](200, editioncode, 'D') as [editionNumberField], --ENHANCEMENT
[pagecount] as [pagecountField], --ENHANCEMENT,
pubdate as [pubdateField],
sortorder as [sequenceField],
dbo.rpt_get_gentables_desc(126, origpubhousecode,'long') as [publisherField],
price as [domesticPriceField]
FROM associatedtitles
WHERE bookkey = @bookkey and 
associationtypecode = 1
ORDER BY sortorder

END
