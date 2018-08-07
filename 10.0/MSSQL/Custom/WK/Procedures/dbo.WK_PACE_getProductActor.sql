if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getProductActor') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getProductActor
GO
CREATE PROCEDURE dbo.WK_PACE_getProductActor
AS
/*

EXEC dbo.WK_PACE_getProductActor

EAN	
TMM_ActorID	
FirstName	
MiddleName	
LastName	
SucceedingTitle	
SOCIETY_AUTHOR_NAME	
IS_LEAD_AUTHOR	
DISPLAY_SEQUENCE

Select * FROM globalcontact gc
WHERE gc.grouptypecode IS NOT NULL and gc.grouptypecode > 0 

Select * FROM WK_ORA.WKDBA.PRODUCT_ACTOR
WHERE COMMON_PRODUCT_ID = 80143

Select * FROM bookauthor
WHERE bookkey = 909169

Select [dbo].[rpt_get_misc_value](b.bookkey, 2, 'long') from book b
where b.bookkey = 909169

*/
BEGIN  

Select
dbo.WK_get_itemnumber_withdashes(ba.bookkey) as EAN, 
gc.globalcontactkey as TMM_ActorID, 
gc.firstname as FirstName, 
gc.middlename as MiddleName, 
gc.lastname as LastName, 
gc.degree as SucceedingTitle,
(CASE WHEN grouptypecode = 2 THEN groupname
ELSE NULL END) as SOCIETY_AUTHOR_NAME,
ba.primaryind as IS_LEAD_AUTHOR,
ba.sortorder as DISPLAY_SEQUENCE
FROM bookauthor ba
JOIN globalcontact gc
ON ba.authorkey = gc.globalcontactkey
WHERE dbo.WK_get_itemnumber_withdashes(ba.bookkey) <> ''
ORDER BY ba.bookkey, ba.sortorder

END

