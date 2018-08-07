if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getOrganizations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getOrganizations
GO
CREATE PROCEDURE dbo.WK_PACE_getOrganizations
AS
/*
EAN	
TMM_OrganizationID	
ORGANIZATION_TEXT	
TMM_ACTORID

Select * FROM WK_ORA.WKDBA.ORGANIZATION

*/
BEGIN
SELECT
dbo.WK_get_itemnumber_withdashes(ba.bookkey) as EAN, 
gc.globalcontactkey as TMM_OrganizationID, 
(Select commenttext from qsicomments WHERE commentkey = gc.globalcontactkey and commenttypecode = 9 and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0)
as ORGANIZATION_TEXT,
gc.globalcontactkey as TMM_ACTORID 
FROM bookauthor ba
JOIN globalcontact gc
ON ba.authorkey = gc.globalcontactkey
WHERE dbo.WK_get_itemnumber_withdashes(ba.bookkey) <> ''
ORDER BY ba.bookkey, ba.sortorder

END

