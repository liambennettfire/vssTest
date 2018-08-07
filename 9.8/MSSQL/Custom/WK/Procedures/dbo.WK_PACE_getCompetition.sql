if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getCompetition') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getCompetition
GO
CREATE PROCEDURE dbo.WK_PACE_getCompetition
AS
/*
ITEMNUMBER	
TMM_COMPETITIONID	
TITLE	
DISPLAYSEQUENCE	  
EDITION_NUMBER    	  
LEAD_PERSON       	  
PUB_DATE          	  
DOMESTIC_PRICE
PAGE_COUNT
PUBLISHER

SELECT * FROM WK_ORA.WKDBA.COMPETITION   
*/

BEGIN
Select DISTINCT
dbo.WK_get_itemnumber_withdashes(bookkey) as ITEMNUMBER,
(Cast(bookkey as varchar(20)) +  Cast(sortorder as varchar(20))) as TMM_COMPETITIONID, 
title as TITLE,
sortorder as DISPLAYSEQUENCE,
[dbo].[rpt_get_gentables_field](200, editioncode, 'D') as EDITION_NUMBER, --ENHANCEMENT
authorname as LEAD_PERSON,
pubdate as PUB_DATE,
price as DOMESTIC_PRICE,
[pagecount] as PAGE_COUNT, --ENHANCEMENT,
dbo.rpt_get_gentables_desc(126, origpubhousecode,'long') as PUBLISHER
FROM associatedtitles
WHERE associationtypecode = 1 and
dbo.WK_get_itemnumber_withdashes(bookkey) <> ''
ORDER BY dbo.WK_get_itemnumber_withdashes(bookkey), sortorder

END
